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
  RxString startDate = "".obs;
  RxString endDate = "".obs;

  // Radar chart only
  RxList<RadarEntry> radarDataEntries = <RadarEntry>[].obs;
  RxList<String> radarLabels = <String>[].obs;
  RxnInt selectedPieIndex = RxnInt(); // 선택된 인덱스 저장

  // Trigger variable to force UI rebuilds when necessary
  RxInt dataRefreshTrigger = 0.obs;

@override
  void onInit() {
    super.onInit();

    // 1. Initial date setup when the controller is first created
    // 앱을 켰을 때 초기 날짜를 이번 달 1일부터 오늘까지로 미리 세팅합니다.
    final now = DateTime.now();
    startDate.value = DateFormat('yyyy-MM-01').format(now);
    endDate.value = DateFormat('yyyy-MM-dd').format(now);

    // 2. Listener for setting changes
    // 환경 설정이 바뀌었을 때(환율, 언어 등) 날짜를 다시 맞추고 리프레시합니다.
    ever(Get.find<SettingController>().refreshTrigger, (_) {
      startDate.value = DateFormat('yyyy-MM-01').format(now);
      endDate.value = DateFormat('yyyy-MM-dd').format(now);
      refreshDashboard();
    });

    // 3. Initial data fetch
    // 설정된 날짜를 바탕으로 첫 데이터를 불러옵니다.
    refreshDashboard();
  }
  // onInit() {
  //   super.onInit();
  //   ever(Get.find<SettingController>().refreshTrigger, (_) {
  //     final now = DateTime.now();
  //   refreshDashboard();
  // });

  // refreshDashboard();
  // }

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

    // final top3Raw = await handler.getTop3Categories(DateFormat('yyyy-MM').format(DateTime.now()));
    // top3Categories.value = top3Raw.map((r) {
      // return {
        // 'id': r['id'],
        // 'name': r['name'],
        // 'total': (r['total'] as num?)?.toDouble() ?? 0.0,
      // };
    // }).toList();
  }

/// Refresh all dashboard data using the selected date range.
  /// Updated to sync charts, budget, and transactions based on startDate/endDate.
  Future<void> refreshDashboard() async {
    final now = DateTime.now();
    // 💡 날짜가 선택되지 않았을 경우를 대비한 기본값 설정
    if (startDate.value.isEmpty) startDate.value = DateFormat('yyyy-MM-01').format(now);
    if (endDate.value.isEmpty) endDate.value = DateFormat('yyyy-MM-dd').format(now);

    // 예산 조회를 위해 시작 날짜의 년-월 추출 (예: 2025-12)
    final String budgetYearMonth = startDate.value.substring(0, 7);

    // 1. Process recurring payments (이번 달 기준으로 자동 입력 실행)
    await _internalAutoInsert(DateFormat('yyyy-MM').format(now));

    // 2. Clear old selection data
    selectedBreakdown.clear();
    categoryBreakdown.clear();
    selectedPieIndex.value = null; // 날짜 바뀌면 선택된 인덱스 초기화

    // 3. Fetch Total Expense by Range
    // Using the reactive startDate and endDate values.
    totalExpense.value = await handler.getMonthlyTotalExpense(
      startDate: startDate.value,
      endDate: endDate.value,
    );

    // 4. Fetch Categories by Range (This updates the Pie Chart)
    // 파이차트 데이터의 원천인 categoryList를 선택한 기간 데이터로 갱신합니다.
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

    // 5. Fetch Budget for the selected period
    // 선택된 기간의 시작월에 해당하는 예산을 가져와 게이지에 반영합니다.
    monthlyBudget.value = await monthlyBudgetHandler.getMonthlyBudget(budgetYearMonth);
    
    // 6. Fetch Recent Transactions
    // 최근 거래 내역 5개 로드 (UI 메타데이터 포함)
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

    // 7. Recalculate totals and notify UI
    _calculateTotals(categoryList);
    dataRefreshTrigger.value++;
  }
// /// Refresh all dashboard data using the selected date range.
//   /// Explains: Optimized version including Budget and Recent Transactions.
//   Future<void> refreshDashboard() async {
//     final now = DateTime.now();
//     final currentYearMonth = DateFormat('yyyy-MM').format(now);

//     // 1. Initial date setup if empty
//     // 날짜가 비어있으면 이번 달 1일부터 오늘까지로 설정합니다.
//     if (startDate.value.isEmpty) startDate.value = DateFormat('yyyy-MM-01').format(now);
//     if (endDate.value.isEmpty) endDate.value = DateFormat('yyyy-MM-dd').format(now);

//     // 2. Process recurring payments
//     await _internalAutoInsert(currentYearMonth);

//     selectedBreakdown.clear();
//     categoryBreakdown.clear();

//     // 3. Fetch Total Expense (Reusing your handler function)
//     // 오빠가 재활용한 그 부분! 기간별 총액을 가져옵니다.
//     totalExpense.value = await handler.getMonthlyTotalExpense(
//       startDate: startDate.value,
//       endDate: endDate.value,
//     );

//     // 4. Fetch Categories by Range
//     // 기간별 카테고리 지출 내역을 가져옵니다.
//     final categoriesRaw = await handler.getCategoryExpenseByRange(
//       startDate.value, 
//       endDate.value
//     );
    
//     categoryList.value = categoriesRaw.map((r) {
//       return {
//         'id': r['id'],
//         'name': r['name'],
//         'total_expense': (r['total_expense'] as num?)?.toDouble() ?? 0.0,
//         'total_income': (r['total_income'] as num?)?.toDouble() ?? 0.0,
//       };
//     }).toList();

//     // 5. 💡 Fetch Budget & Recent Transactions (Added back)
//     // 돼지 게이지와 최근 내역 리스트를 위해 데이터를 다시 채워줍니다.
//     monthlyBudget.value = await monthlyBudgetHandler.getMonthlyBudget(currentYearMonth);
    
//     final recentRaw = await handler.getRecentTransactions(limit: 5);
//     recentTransactions.value = recentRaw.map((r) {
//       return {
//         't_id': r['t_id'], 
//         'c_id': r['c_id'], 
//         't_name': r['t_name'],
//         'date': r['date'], 
//         'type': r['type'], 
//         'amount': (r['amount'] as num?)?.toDouble() ?? 0.0,
//         'memo': r['memo'], 
//         'isRecurring': r['isRecurring'] == 1,
//         // 💡 [여기 필드들이 빠져있었어!] 
//         // Adding the missing category UI metadata.
//         'icon_codepoint': r['icon_codepoint'], 
//         'icon_font_family': r['icon_font_family'],
//         'icon_font_package': r['icon_font_package'],
//         'color': r['color'], 
//       };
//     }).toList();

//     // 6. Calculate totals and trigger UI update
//     _calculateTotals(categoryList);
//     dataRefreshTrigger.value++;
//   }

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


  // Todo : move to transaction_handler
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

  /// Returns the category name ONLY when selected.
  /// Explains: Returns an empty string if no slice is tapped.
  String getSelectedCategoryName(int? index) {
    if (index == null || index < 0 || index >= categoryList.length) {
      return ""; // 💡 평소에는 아무 글자도 안 나오게 비워둡니다.
    }
    return categoryList[index]['name'] ?? "";
  }

  /// Returns the amount ONLY when selected.
  /// Explains: Returns 0.0 or a value that indicates 'hidden' when not tapped.
  double? getSelectedCategoryAmount(int? index) {
    if (index == null || index < 0 || index >= categoryList.length) {
      return null; // 💡 금액도 표시하지 않기 위해 null을 반환합니다.
    }
    return (categoryList[index]['total_expense'] as num?)?.toDouble() ?? 0.0;
  }

// DashboardController.dart 의 loadRadarData 함수 수정

Future<void> loadRadarData(int index) async {
  selectedPieIndex.value = index;
  int categoryId = categoryList[index]['id'];

  final data = await handler.getCategoryBreakdown(categoryId);
  categoryBreakdown.value = data;

  // 1. Sort by amount and take top 5
  var sorted = data.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
  var top5 = sorted.take(5).toList();

  // 2. 💡 Make exactly 5 slots
  // 데이터가 5개 미만이어도 빈 슬롯을 채워 오각형을 유지합니다.
  List<RadarEntry> entries = [];
  List<String> labels = [];

  for (int i = 0; i < 5; i++) {
    if (i < top5.length) {
      // Real data exists
      entries.add(RadarEntry(value: top5[i].value));
      labels.add(top5[i].key);
    } else {
      // 💡 Empty slot: Value 0, Label ""
      // 데이터가 없는 꼭짓점은 0점과 빈 문자로 처리해 화면을 깔끔하게 만듭니다.
      entries.add(const RadarEntry(value: 0));
      labels.add(""); 
    }
  }

  radarDataEntries.value = entries;
  radarLabels.value = labels;
}
  
}// END