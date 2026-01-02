import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get_x/get.dart';
import 'package:piggy_log/VM/dashboard_handler.dart';
import 'package:intl/intl.dart';
import 'package:piggy_log/VM/monthly_budget_handler.dart';
import 'package:piggy_log/controller/setting_controller.dart';

/// Controller responsible for managing all data logic on the Dashboard.
/// Handles reactive state for expenses, income, charts, and recurring payments.
// -----------------------------------------------------------------------------------------------------------
//  * [Development Diary]
//  * 1. Dynamic Chart Sync: Implemented a 'Radar Data' generator that maintains a pentagon shape 
//  * even with fewer than 5 items, ensuring UI stability.
//  * 2. Auto-Insert Logic: Built a robust recurring transaction system that clones templates 
//  * while handling variable month lengths (e.g., Leap years/Feb 28th).
//  * 3. Performance: Used refreshTrigger and microtasks to ensure charts only rebuild when data 
//  * is fully processed to avoid 'Jank'.
// -----------------------------------------------------------------------------------------------------------

class DashboardController extends GetxController {
  final DashboardHandler handler = DashboardHandler();
  final MonthlyBudgetHandler monthlyBudgetHandler = MonthlyBudgetHandler();

  // Reactive state variables for UI updates
  RxList<Map<String, dynamic>> categoryList = <Map<String, dynamic>>[].obs;
  RxMap<String, double> categoryBreakdown = <String, double>{}.obs;
  RxList<Map<String, dynamic>> top3Categories = <Map<String, dynamic>>[].obs;
  RxDouble totalIncome = 0.0.obs;
  RxDouble totalExpense = 0.0.obs;
  RxDouble monthlyBudget = 0.0.obs;
  RxMap<String, double> selectedBreakdown = <String, double>{}.obs;
  RxList<Map<String, dynamic>> recentTransactions = <Map<String, dynamic>>[].obs;
  RxString startDate = "".obs;
  RxString endDate = "".obs;

  // Weekly spending data for Bar Chart [Mon, Tue, Wed, Thu, Fri, Sat, Sun]
  RxList<double> weeklyData = <double>[0, 0, 0, 0, 0, 0, 0].obs;

  // Radar chart state
  RxList<RadarEntry> radarDataEntries = <RadarEntry>[].obs;
  RxList<String> radarLabels = <String>[].obs;
  RxnInt selectedPieIndex = RxnInt(); // Stores selected index from Pie Chart

  // Trigger variable to force UI rebuilds when necessary
  RxInt dataRefreshTrigger = 0.obs;

  @override
  void onInit() {
    super.onInit();

    // 1. Set default date range: From the 1st of the current month to today.
    final now = DateTime.now();
    startDate.value = DateFormat('yyyy-MM-01').format(now);
    endDate.value = DateFormat('yyyy-MM-dd').format(now);

    // 2. Observer: Re-sync dashboard data whenever global settings change.
    ever(Get.find<SettingController>().refreshTrigger, (_) {
      startDate.value = DateFormat('yyyy-MM-01').format(now);
      endDate.value = DateFormat('yyyy-MM-dd').format(now);
      refreshDashboard();
    });

    // 3. Perform initial data synchronization.
    refreshDashboard();
  }

  // Predefined color palette for chart categorization.
  final List<Color> categoryColors = [
    const Color(0xFFFFA726),
    const Color(0xFF29B6F6),
    const Color(0xFF66BB6A),
    const Color(0xFFEF5350),
    const Color(0xFFAB47BC),
  ];

  /// Synchronizes category-level aggregates and updates the global net totals.
  Future<void> loadCategories(String yearMonth) async {
    final categories = await handler.getCategoryExpense(yearMonth);
    categoryList.value = categories.map((r) {
      return {
        'id': r['id'],
        'name': r['name'],
        'total_expense': (r['total_expense'] as num?)?.toDouble() ?? 0.0,
        'total_income': (r['total_income'] as num?)?.toDouble() ?? 0.0,
      };
    }).toList();

    _calculateTotals(categoryList);
  }

  /// Maps the reactive category list into PieChartSectionData for fl_chart.
  List<PieChartSectionData> makePieData({int? selectedIndex}) {
    return categoryList.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final value = (item['total_expense'] as num?)?.toDouble() ?? 0.0;
      final color = categoryColors[index % categoryColors.length];
      
      // Dynamic scaling for the selected slice to improve interactivity.
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

  /// Fetches detailed sub-category data and refreshes the current selection state.
  Future<void> loadBreakdown(int categoryId) async {
    final data = await handler.getCategoryBreakdown(categoryId);
    categoryBreakdown.value = data;
    selectedBreakdown.value = Map<String, double>.from(data);
  }

  /// Full synchronization pipeline: Clones recurring templates, resets state, and fetches all metrics.
  Future<void> refreshDashboard() async {
    final now = DateTime.now();

    if (startDate.value.isEmpty) startDate.value = DateFormat('yyyy-MM-01').format(now);
    if (endDate.value.isEmpty) endDate.value = DateFormat('yyyy-MM-dd').format(now);

    final String budgetYearMonth = startDate.value.substring(0, 7);

    // [Step 1] Execute recurring payment automation.
    await _internalAutoInsert(DateFormat('yyyy-MM').format(now));

    // [Step 2] Reset transient interaction states.
    selectedBreakdown.clear();
    categoryBreakdown.clear();
    selectedPieIndex.value = null; 

    // [Step 3] Aggregate totals and categorical distribution.
    totalExpense.value = await handler.getMonthlyTotalExpense(
      startDate: startDate.value,
      endDate: endDate.value,
    );

    final categoriesRaw = await handler.getCategoryExpenseByRange(
      startDate.value, 
      endDate.value
    );
    
    categoryList.value = categoriesRaw.map((r) {
      return {
        'id': r['id'],
        'name': r['name'],
        'total_expense': (r['total_expense'] as num?)?.toDouble() ?? 0.0,
        'total_income': (r['total_income'] as num?)?.toDouble() ?? 0.0,
      };
    }).toList();

    // [Step 4] Sync budget settings and transaction history.
    monthlyBudget.value = await monthlyBudgetHandler.getMonthlyBudget(budgetYearMonth);
    
    final recentRaw = await handler.getRecentTransactions(limit: 5);
    recentTransactions.value = recentRaw.map((r) {
      return {
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
      };
    }).toList();

    _calculateTotals(categoryList);
    await loadWeeklyTrend(); 

    dataRefreshTrigger.value++;
  }

  /// Internal utility to sum income and expense totals across all categories.
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

  /// Clones recurring templates into the active ledger while handling month-end constraints.
  Future<void> _internalAutoInsert(String currentYearMonth) async {
    final now = DateTime.now();
    final templates = await handler.getRecurringTemplates();

    for (var temp in templates) {
      bool exists = await handler.checkIfAlreadyAdded(
        temp['t_name'], 
        (temp['amount'] as num).toDouble(), 
        currentYearMonth
      );

      if (!exists) {
        DateTime originalDate = DateTime.parse(temp['date']);
        int fixedDay = originalDate.day;
        
        // Month-end Guard: Adjusts dates for months shorter than the template day.
        int lastDayOfMonth = DateTime(now.year, now.month + 1, 0).day;
        int targetDay = fixedDay > lastDayOfMonth ? lastDayOfMonth : fixedDay;
        
        String targetDate = "$currentYearMonth-${targetDay.toString().padLeft(2, '0')}";

        await handler.insertTransaction({
          'c_id': temp['c_id'],
          't_name': temp['t_name'],
          'amount': temp['amount'],
          'date': targetDate,
          'type': temp['type'],
          'memo': '[Auto] ${temp['memo'] ?? ""}',
          'isRecurring': 1,
        });
      }
    }
  }

  /// Force-updates the monthly budget from the database.
  Future<void> fetchMonthlyBudget() async {
    final yearMonth = DateFormat('yyyy-MM').format(DateTime.now());
    double budget = await monthlyBudgetHandler.getMonthlyBudget(yearMonth);
    monthlyBudget.value = budget;
  }

  /// Helper to get the category label for the selected chart index.
  String getSelectedCategoryName(int? index) {
    if (index == null || index < 0 || index >= categoryList.length) {
      return ""; 
    }
    return categoryList[index]['name'] ?? "";
  }

  /// Helper to get the expense amount for the selected chart index.
  double? getSelectedCategoryAmount(int? index) {
    if (index == null || index < 0 || index >= categoryList.length) {
      return null;
    }
    return (categoryList[index]['total_expense'] as num?)?.toDouble() ?? 0.0;
  }

  /// Prepares a normalized 5-point dataset for the Radar chart.
  Future<void> loadRadarData(int index) async {
    selectedPieIndex.value = index;
    int categoryId = categoryList[index]['id'];

    final data = await handler.getCategoryBreakdown(categoryId);
    categoryBreakdown.value = data;

    var sorted = data.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    var top5 = sorted.take(5).toList();

    List<RadarEntry> entries = [];
    List<String> labels = [];

    // Pentagon Maintenance: Pads zero entries to ensure a consistent 5-axis shape.
    for (int i = 0; i < 5; i++) {
      if (i < top5.length) {
        entries.add(RadarEntry(value: top5[i].value));
        labels.add(top5[i].key);
      } else {
        entries.add(const RadarEntry(value: 0));
        labels.add(""); 
      }
    }

    radarDataEntries.value = entries;
    radarLabels.value = labels;
  }

  /// Generates a 7-day spending trend for the Bar chart.
  Future<void> loadWeeklyTrend() async {
    final now = DateTime.now();
    DateTime monday = now.subtract(Duration(days: now.weekday - 1));
    
    List<double> weekSums = [];
    
    for (int i = 0; i < 7; i++) {
      DateTime targetDay = monday.add(Duration(days: i));
      String formattedDate = DateFormat('yyyy-MM-dd').format(targetDay);
      
      double dailyTotal = await handler.getMonthlyTotalExpense(
        startDate: formattedDate,
        endDate: formattedDate,
      );
      weekSums.add(dailyTotal);
    }
    
    weeklyData.value = weekSums;
  }
}