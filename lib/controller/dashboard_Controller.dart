import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get_x/get.dart';
import 'package:piggy_log/VM/dashboard_handler.dart';
import 'package:intl/intl.dart';
import 'package:piggy_log/VM/monthly_budget_handler.dart';
import 'package:piggy_log/controller/setting_controller.dart';

/// Controller responsible for managing dashboard data and financial logic.
class DashboardController extends GetxController {
  final DashboardHandler handler = DashboardHandler();
  final MonthlyBudgetHandler monthlyBudgetHandler = MonthlyBudgetHandler();

  // Reactive state variables for core financial metrics
  RxList<Map<String, dynamic>> categoryList = <Map<String, dynamic>>[].obs;
  RxMap<String, double> categoryBreakdown = <String, double>{}.obs;
  RxList<Map<String, dynamic>> top5Categories = <Map<String, dynamic>>[].obs;
  
  RxDouble totalIncome = 0.0.obs;
  RxDouble totalExpense = 0.0.obs;
  RxDouble monthlyBudget = 0.0.obs;
  RxList<Map<String, dynamic>> recentTransactions = <Map<String, dynamic>>[].obs;
  
  RxString startDate = "".obs;
  RxString endDate = "".obs;

  bool _isAutoInserting = false;

  // Weekly spending trend for Bar Chart
  RxList<double> weeklyData = <double>[0, 0, 0, 0, 0, 0, 0].obs;

  // Radar Chart state management
  RxList<RadarEntry> radarDataEntries = <RadarEntry>[].obs;
  RxList<String> radarLabels = <String>[].obs;
  RxnInt selectedPieIndex = RxnInt();

  // Trigger for manual UI refresh
  RxInt dataRefreshTrigger = 0.obs;

  @override
  void onInit() {
    super.onInit();
    final now = DateTime.now();
    startDate.value = DateFormat('yyyy-MM-01').format(now);
    endDate.value = DateFormat('yyyy-MM-dd').format(now);

    // Sync dashboard whenever global settings (currency, etc.) change
    ever(Get.find<SettingController>().refreshTrigger, (_) {
      refreshDashboard();
    });

    // refreshDashboard();
  }

  // Consistent color palette for categorical visualization
  final List<Color> categoryColors = [
    const Color(0xFFFFA726),
    const Color(0xFF29B6F6),
    const Color(0xFF66BB6A),
    const Color(0xFFEF5350),
    const Color(0xFFAB47BC),
  ];

  /// Core pipeline to refresh all dashboard metrics and automate recurring payments.
  Future<void> refreshDashboard() async {
    final now = DateTime.now();
    if (startDate.value.isEmpty) startDate.value = DateFormat('yyyy-MM-01').format(now);
    if (endDate.value.isEmpty) endDate.value = DateFormat('yyyy-MM-dd').format(now);

    final String budgetYearMonth = startDate.value.substring(0, 7);

    // [Automation] Process recurring templates for the current month
    await _internalAutoInsert(DateFormat('yyyy-MM').format(now));

    // Reset interaction states
    categoryBreakdown.clear();
    selectedPieIndex.value = null; 

    // Sync financial totals and transactions
    totalExpense.value = await handler.getMonthlyTotalExpense(
      startDate: startDate.value,
      endDate: endDate.value,
    );

    final categoriesRaw = await handler.getCategoryExpenseByRange(startDate.value, endDate.value);
    categoryList.value = categoriesRaw.map((r) => {
      'id': r['id'],
      'name': r['name'],
      'total_expense': (r['total_expense'] as num?)?.toDouble() ?? 0.0,
      'total_income': (r['total_income'] as num?)?.toDouble() ?? 0.0,
    }).toList();

    monthlyBudget.value = await monthlyBudgetHandler.getMonthlyBudget(budgetYearMonth);
    
    final recentRaw = await handler.getRecentTransactions(limit: 5);
    recentTransactions.assignAll(recentRaw.map((r) => {
      't_id': r['t_id'], 
      'c_id': r['c_id'], 
      't_name': r['t_name'],
      'date': r['date'], 
      'type': r['type'], 
      'amount': (r['amount'] as num?)?.toDouble() ?? 0.0,
      'memo': r['memo'], 
      'isRecurring': r['isRecurring'] == 1,
      'icon_codepoint': r['icon_codepoint'], 
      'icon_font_family': r['icon_font_family'],
      'icon_font_package': r['icon_font_package'],
      'color': r['color'], 
    }).toList());

    _calculateTotals(categoryList);
    await loadWeeklyTrend(); 
    dataRefreshTrigger.value++;
  }

  /// Calculates global net totals for the active date range.
  void _calculateTotals(List<Map<String, dynamic>> categories) {
    double incomeSum = 0.0;
    double expenseSum = 0.0;
    for (var cat in categories) {
      incomeSum += (cat['total_income'] as num?)?.toDouble() ?? 0.0;
      expenseSum += (cat['total_expense'] as num?)?.toDouble() ?? 0.0;
    }
    totalIncome.value = incomeSum;
    totalExpense.value = expenseSum;
  }

  /// Prepares PieChart data with dynamic scaling for selected segments.
  List<PieChartSectionData> makePieData({int? selectedIndex}) {
    return categoryList.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final value = (item['total_expense'] as num?)?.toDouble() ?? 0.0;
      final color = categoryColors[index % categoryColors.length];
      final radius = (selectedIndex != null && selectedIndex == index) ? 70.0 : 55.0;
      
      return PieChartSectionData(
        value: value,
        title: item['name'] ?? '',
        color: color,
        radius: radius,
        titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
      );
    }).toList();
  }

/// Loads radar chart data for the selected category.
/// 
/// - Uses the top 5 category breakdown values.
/// - Applies square root scaling to reduce skew from large values.
/// - Adds 10% buffer to max value to prevent chart from looking fully saturated (Android/iOS visual consistency).
/// - Always keeps 5 radar axes for consistent layout.
Future<void> loadRadarData(int index) async {
  // Update the selected pie chart index
  selectedPieIndex.value = index;
  int categoryId = categoryList[index]['id'];

  // Fetch category breakdown data
  final data = await handler.getCategoryBreakdown(categoryId);

  // Sort entries alphabetically by label and take top 5
  var sortedByLabel = data.entries.toList()
    ..sort((a, b) => a.key.compareTo(b.key));
  var top5 = sortedByLabel.take(5).toList();

  List<RadarEntry> entries = [];
  List<String> labels = [];

  // Determine maximum value for scaling
  double maxOriginal = top5.isNotEmpty
      ? top5.map((e) => (e.value as num).toDouble()).reduce((a, b) => a > b ? a : b)
      : 1.0;

  // Apply square root scaling and add 10% buffer to leave visual margin
  double chartMaxScore = math.sqrt(maxOriginal) * 1.1;

  // Populate 5 radar axes
  for (int i = 0; i < 5; i++) {
    if (i < top5.length) {
      double originalValue = (top5[i].value as num).toDouble();
      double scaledValue = math.sqrt(originalValue);

      // Scale to 0-100 relative to max score
      double finalValue = chartMaxScore > 0 ? (scaledValue / chartMaxScore) * 100 : 0;

      // Cap at 100 to avoid overflow
      if (finalValue > 100) finalValue = 100;

      entries.add(RadarEntry(value: finalValue));
      labels.add(top5[i].key);
    } else {
      // Fill remaining axes with zero to maintain 5-axis layout
      entries.add(const RadarEntry(value: 0.0));
      labels.add("");
    }
  }

  // Update reactive lists for chart
  radarDataEntries.assignAll(entries);
  radarLabels.assignAll(labels);
}

  /// Aggregates a 7-day spending trend for the weekly Bar Chart.
  Future<void> loadWeeklyTrend() async {
    final now = DateTime.now();
    DateTime monday = now.subtract(Duration(days: now.weekday - 1));
    List<double> weekSums = [];
    
    for (int i = 0; i < 7; i++) {
      DateTime targetDay = monday.add(Duration(days: i));
      String formattedDate = DateFormat('yyyy-MM-dd').format(targetDay);
      double dailyTotal = await handler.getMonthlyTotalExpense(startDate: formattedDate, endDate: formattedDate);
      weekSums.add(dailyTotal);
    }
    weeklyData.assignAll(weekSums);
  }

  /// Clones recurring templates into the database while handling month-end logic.
Future<void> _internalAutoInsert(String currentYearMonth) async {
  if (_isAutoInserting) return;
  _isAutoInserting = true;

  try {
    final templates = await handler.getRecurringTemplates();

    for (var temp in templates) {
      bool exists = await handler.checkIfAlreadyAdded(
        temp['t_name'], 
        (temp['amount'] as num).toDouble(), 
        currentYearMonth
      );

      if (!exists) {
        String dayPart = temp['date'].toString().split('-').last;
        
        await handler.insertTransaction({
          'c_id': temp['c_id'],
          't_name': temp['t_name'],
          'amount': temp['amount'],
          'date': "$currentYearMonth-$dayPart",
          'type': temp['type'],
          'memo': '[Auto] ${temp['memo'] ?? ""}',
          'isRecurring': 1,
        });
      }
    }
  } finally {
    // 2. 처리가 다 끝나면 다시 문 열어주기
    _isAutoInserting = false;
  }
}

  /// Direct category lookup helpers for UI components
  String getSelectedCategoryName(int? index) => (index != null && index >= 0 && index < categoryList.length) ? categoryList[index]['name'] : "";
  double? getSelectedCategoryAmount(int? index) => (index != null && index >= 0 && index < categoryList.length) ? (categoryList[index]['total_expense'] as num?)?.toDouble() : null;
}