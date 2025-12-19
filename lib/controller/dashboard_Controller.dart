import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get_x/get.dart';
import 'package:piggy_log/VM/dashboard_handler.dart';
import 'package:intl/intl.dart';

class DashboardController extends GetxController {
  final DashboardHandler handler = DashboardHandler();

  RxList<Map<String, dynamic>> categoryList = <Map<String, dynamic>>[].obs;
  RxMap<String, double> categoryBreakdown = <String, double>{}.obs;
  RxList<Map<String, dynamic>> top3Categories = <Map<String, dynamic>>[].obs;
  RxDouble totalIncome = 0.0.obs;
  RxDouble totalExpense = 0.0.obs;
  RxMap<String, double> selectedBreakdown = <String, double>{}.obs;
  RxList<Map<String, dynamic>> recentTransactions = <Map<String, dynamic>>[].obs;

  RxInt dataRefreshTrigger = 0.obs; // reactive rebuild용

  final List<Color> categoryColors = [
    const Color(0xFFFFA726),
    const Color(0xFF29B6F6),
    const Color(0xFF66BB6A),
    const Color(0xFFEF5350),
    const Color(0xFFAB47BC),
  ];

  /// 전체 카테고리 불러오기 + PieChart용 데이터 준비
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

  /// PieChart 데이터
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

  /// 특정 카테고리 Breakdown 불러오기
  Future<void> loadBreakdown(int categoryId) async {
    final data = await handler.getCategoryBreakdown(categoryId);
    categoryBreakdown.value = data;
    selectedBreakdown.value = Map<String, double>.from(data);

    // Top3 카테고리
    final top3Raw = await handler.getTop3Categories(DateFormat('yyyy-MM').format(DateTime.now()));
    top3Categories.value = top3Raw.map((r) {
      return {
        'id': r['id'],
        'name': r['name'],
        'total': (r['total'] as num?)?.toDouble() ?? 0.0,
      };
    }).toList();
  }

  /// 트랜잭션 추가/삭제 후 총액 계산 및 화면 갱신
  Future<void> refreshDashboard() async {
    final yearMonth = DateFormat('yyyy-MM').format(DateTime.now());

    selectedBreakdown.clear();
    categoryBreakdown.clear();

    // 카테고리
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

    // Top3 갱신
    final top3Raw = await handler.getTop3Categories(yearMonth);
    top3Categories.value = top3Raw.map((r) {
      return {
        'id': r['id'],
        'name': r['name'],
        'total': (r['total'] as num?)?.toDouble() ?? 0.0,
      };
    }).toList();

    // 최근 거래
    final recentRaw = await handler.getRecentTransactions(limit: 5);
    recentTransactions.value = recentRaw.map((r) {
      return {
        't_id': r['t_id'],
        'c_id': r['c_id'],
        't_name': r['t_name'],
        'date': r['date'],
        'type': r['type'],
        'amount': (r['amount'] as num?)?.toDouble() ?? 0.0, // 안전하게 double
        'memo': r['memo'],
        'isRecurring': r['isRecurring'] == 1,
      };
    }).toList();

    // reactive rebuild
    dataRefreshTrigger.value++;
  }

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
}