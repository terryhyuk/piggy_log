import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:piggy_log/core/database/repository/dashboard_repasitory.dart';
import 'package:piggy_log/core/database/repository/record_repository.dart';

class DashboardProvider with ChangeNotifier {
  final DashboardRepository dashboardRepository;
  final RecordRepository recordRepository;

  DashboardProvider(this.dashboardRepository, this.recordRepository);

  // --- [State Variables] ---
  List<Map<String, dynamic>> categoryList = [];
  double totalIncome = 0.0;
  double totalExpense = 0.0;
  double monthlyBudget = 0.0;
  List<Map<String, dynamic>> recentTransactions = [];

  String startDate = "";
  String endDate = "";
  bool isAutoInserting = false;

  // Chart Data
  List<String> radarLabels = [];
  List<RadarEntry> radarDataEntries = [];
  List<double> weeklySpendingTrend = List.filled(7, 0.0);
  int? selectedPieIndex;

  final List<Color> categoryColors = [
    const Color(0xFF6C8EBF),
    const Color(0xFFE58E8E),
    const Color(0xFF88B04B),
    const Color(0xFFF7CAC9),
    const Color(0xFF92A8D1),
    const Color(0xFFFBC02D),
    const Color(0xFF9575CD),
  ];

Future<void> refreshDashboard() async {
    final now = DateTime.now();

    if (startDate.isEmpty) startDate = DateFormat('yyyy-MM-01').format(now);
    if (endDate.isEmpty) endDate = DateFormat('yyyy-MM-dd').format(now);

    final String targetYM = startDate.substring(0, 7); 

    monthlyBudget = await dashboardRepository.getMonthlyBudget(targetYM);
    
    totalExpense = await recordRepository.getMonthlyTotalExpense(
      start: startDate,
      end: endDate,
    );

    categoryList = await dashboardRepository.getCategoryExpensesByRange(startDate, endDate);
    recentTransactions = await dashboardRepository.getRecentTransactions(limit: 5);

    _calculateNetTotals();
    await loadWeeklyTrend();

    if (selectedPieIndex != null) {
      await selectCategoryForAnalysis(selectedPieIndex);
    } else {
      notifyListeners();
    }
  }

  void _calculateNetTotals() {
    totalIncome = categoryList.fold(
      0.0,
      (sum, item) => sum + (item['total_income'] ?? 0.0),
    );
    totalExpense = categoryList.fold(
      0.0,
      (sum, item) => sum + (item['total_expense'] ?? 0.0),
    );
  }

  /// Weekly spending trend for the current week
  Future<void> loadWeeklyTrend() async {
    final now = DateTime.now();
    DateTime monday = now.subtract(Duration(days: now.weekday - 1));

    for (int i = 0; i < 7; i++) {
      DateTime target = monday.add(Duration(days: i));
      String formatted = DateFormat('yyyy-MM-dd').format(target);
      weeklySpendingTrend[i] = await recordRepository.getMonthlyTotalExpense(
        start: formatted,
        end: formatted,
      );
    }
    notifyListeners();
  }

  /// Category-specific analysis for Radar and Weekly trend
  Future<void> selectCategoryForAnalysis(int? index) async {
    selectedPieIndex = index;

    if (index != null && index >= 0 && index < categoryList.length) {
      final int categoryId = categoryList[index]['id'];
      final data = await dashboardRepository.getCategoryBreakdown(
        categoryId,
        startDate,
        endDate,
      );

      var sortedEntries = data.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key));
      var top5 = sortedEntries.take(5).toList();

      double maxOriginal = top5.isNotEmpty
          ? top5.map((e) => e.value).reduce((a, b) => a > b ? a : b)
          : 1.0;

      double chartMaxScore = math.sqrt(maxOriginal) * 1.1;

      List<RadarEntry> entries = [];
      List<String> labels = [];

      for (int i = 0; i < 5; i++) {
        if (i < top5.length) {
          double scaledValue = math.sqrt(top5[i].value);
          double finalValue = chartMaxScore > 0
              ? (scaledValue / chartMaxScore) * 100
              : 0;
          entries.add(RadarEntry(value: finalValue.clamp(0, 100)));
          labels.add(top5[i].key);
        } else {
          entries.add(const RadarEntry(value: 0.0));
          labels.add("");
        }
      }
      radarDataEntries = entries;
      radarLabels = labels;

      await _loadWeeklyTrendForCategory(categoryId);
    } else {
      radarDataEntries = [];
      radarLabels = [];
      await loadWeeklyTrend();
    }
    notifyListeners();
  }

  Future<void> _loadWeeklyTrendForCategory(int categoryId) async {
    final now = DateTime.now();
    DateTime monday = now.subtract(Duration(days: now.weekday - 1));

    for (int i = 0; i < 7; i++) {
      DateTime target = monday.add(Duration(days: i));
      String formatted = DateFormat('yyyy-MM-dd').format(target);
      weeklySpendingTrend[i] = await dashboardRepository.getCategoryTotalByDate(
        categoryId,
        formatted,
      );
    }
  }

  Future<void> refreshAnalysisIfSelected() async {
    if (selectedPieIndex != null) {
      await selectCategoryForAnalysis(selectedPieIndex);
    }
  }
}
