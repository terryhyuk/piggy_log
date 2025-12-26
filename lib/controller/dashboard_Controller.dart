import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get_x/get.dart';
import 'package:piggy_log/VM/dashboard_handler.dart';
import 'package:intl/intl.dart';
import 'package:piggy_log/VM/monthly_budget_handler.dart';
import 'package:piggy_log/controller/setting_controller.dart';

/// Controller responsible for managing all data logic on the Dashboard.
/// Handles reactive state for expenses, income, charts, and recurring payments.
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

  // Trigger variable to force UI rebuilds when necessary
  RxInt dataRefreshTrigger = 0.obs;

  onInit() {
    super.onInit();
    ever(Get.find<SettingController>().refreshTrigger, (_) {
    refreshDashboard();
  });

  refreshDashboard();
  }

  // Standard color palette for charts
  final List<Color> categoryColors = [
    const Color(0xFFFFA726),
    const Color(0xFF29B6F6),
    const Color(0xFF66BB6A),
    const Color(0xFFEF5350),
    const Color(0xFFAB47BC),
  ];

  /// Loads category-wise spending/income for the specified month and calculates totals.
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

  /// Generates data for the PieChart widget based on the current category list.
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

  /// Loads detailed item-level breakdown for a specific category and updates Top 3 stats.
  Future<void> loadBreakdown(int categoryId) async {
    final data = await handler.getCategoryBreakdown(categoryId);
    categoryBreakdown.value = data;
    selectedBreakdown.value = Map<String, double>.from(data);

    final top3Raw = await handler.getTop3Categories(DateFormat('yyyy-MM').format(DateTime.now()));
    top3Categories.value = top3Raw.map((r) {
      return {
        'id': r['id'],
        'name': r['name'],
        'total': (r['total'] as num?)?.toDouble() ?? 0.0,
      };
    }).toList();
  }

  /// Comprehensive refresh of all dashboard data including auto-insertion of recurring items.
  Future<void> refreshDashboard() async {
    final yearMonth = DateFormat('yyyy-MM').format(DateTime.now());

    // 1. Process recurring payments first to ensure data accuracy
    await _internalAutoInsert(yearMonth);

    selectedBreakdown.clear();
    categoryBreakdown.clear();

    // 2. Fetch all required data points from the Database
    final categoriesRaw = await handler.getCategoryExpense(yearMonth);
    categoryList.value = categoriesRaw.map((r) {
      return {
        'id': r['id'],
        'name': r['name'],
        'total_expense': (r['total_expense'] as num?)?.toDouble() ?? 0.0,
        'total_income': (r['total_income'] as num?)?.toDouble() ?? 0.0,
      };
    }).toList();

    _calculateTotals(categoryList);

    final top3Raw = await handler.getTop3Categories(yearMonth);
    top3Categories.value = top3Raw.map((r) {
      return {
        'id': r['id'],
        'name': r['name'],
        'total': (r['total'] as num?)?.toDouble() ?? 0.0,
      };
    }).toList();

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
      };
    }).toList();

    final budget = await monthlyBudgetHandler.getMonthlyBudget(yearMonth);
    monthlyBudget.value = budget;

    // Increment refresh trigger to rebuild Obx widgets
    dataRefreshTrigger.value++;
  }

  /// Internal helper to aggregate total income and expense from category list.
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

  /// Private function that handles the logic of cloning recurring transaction templates 
  /// into the current month if they haven't been added yet.
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
        
        // Ensure day is valid for the current month (e.g., handles Feb 29th/30th)
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

  /// Fetches the budget for the current month specifically.
  Future<void> fetchMonthlyBudget() async {
    final yearMonth = DateFormat('yyyy-MM').format(DateTime.now());
    double budget = await monthlyBudgetHandler.getMonthlyBudget(yearMonth);
    monthlyBudget.value = budget;
  }
}