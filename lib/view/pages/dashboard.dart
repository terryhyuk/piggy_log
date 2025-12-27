import 'package:flutter/material.dart';
import 'package:get_x/get.dart';
import 'package:piggy_log/VM/monthly_budget_handler.dart';
import 'package:piggy_log/controller/dashboard_controller.dart';
import 'package:piggy_log/controller/setting_controller.dart';
import 'package:piggy_log/l10n/app_localizations.dart';
import 'package:piggy_log/view/widget/budget_gauge.dart';
import 'package:piggy_log/view/widget/budget_summary.dart';
import 'package:piggy_log/view/widget/budgetpigwidget.dart';
import 'package:piggy_log/view/widget/chart_widget.dart';
import 'package:piggy_log/view/widget/expense_summary.dart';
import 'package:piggy_log/view/widget/recent_transactions_list.dart';

///
/// Dashboard Page
/// 
/// Purpose: 
/// This is the main landing screen of the application. It provides a comprehensive 
/// overview of the user's financial status, including total expenses, monthly budget, 
/// spending analysis (charts), and recent transaction history.
/// 
/// Key Features:
/// - Real-time budget tracking with a visual gauge.
/// - Interactive expense analysis using Pie and Radar charts.
/// - Quick access to monthly budget settings and date range filtering.
/// - Reactive UI updates driven by DashboardController and SettingController.
///


class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  // Dependency Injection: Accessing controllers for state management
  final DashboardController dashbordcontroller = Get.find<DashboardController>();
  final SettingController settingsController = Get.find<SettingController>();
  final MonthlyBudgetHandler monthlyBudgetHandler = MonthlyBudgetHandler();

  // State variable to track the selected index in the Pie Chart
  int? selectedPieIndex;

  @override
  void initState() {
    super.initState();
    // Refresh all dashboard data when the page is first initialized
    dashbordcontroller.refreshDashboard();
  }

  // ==========================================
  // 1. UI Build Section
  // ==========================================
@override
Widget build(BuildContext context) {
  return SafeArea(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Obx(() {
        // 데이터 트리거
        settingsController.refreshTrigger.value;
        dashbordcontroller.dataRefreshTrigger.value;

        // 지출 퍼센트 계산 (돼지와 게이지 공통 사용)
        double currentPercent = (dashbordcontroller.monthlyBudget.value > 0)
            ? (dashbordcontroller.totalExpense.value / dashbordcontroller.monthlyBudget.value)
            : 0.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 상단 카드 섹션 ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // 1. 요약 정보 (지출액 | 예산)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ExpenseSummary(
                        expense: dashbordcontroller.totalExpense.value,
                        onTap: () => _showDateRangePicker(context),
                        formatCurrency: _formatCurrency,
                      ),
                      BudgetSummary(
                        budget: dashbordcontroller.monthlyBudget.value,
                        currentSpend: dashbordcontroller.totalExpense.value,
                        onBudgetTap: _showBudgetDialog,
                        formatCurrency: _formatCurrency,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),

                  // 2. 돼지 + 바 게이지 (에러 해결 핵심 구역)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end, // 바닥 라인 정렬
                    children: [
                      // 돼지 위젯
                      SizedBox(
                        width: 90,
                        height: 90,
                        child: BudgetPigWidget(percent: currentPercent),
                      ),
                      
                      const SizedBox(width: 8),

                      // 게이지 바 (Expanded를 써야 'Infinite width' 에러가 안 남!)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 15), // 돼지 발 위치에 맞게 바닥 띄움
                          child: BudgetGauge(
                            currentSpend: dashbordcontroller.totalExpense.value,
                            targetBudget: dashbordcontroller.monthlyBudget.value,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 28),

            // --- 차트 섹션 ---
            ChartsWidget(
              top3: dashbordcontroller.top3Categories,
              selectedPieIndex: selectedPieIndex,
              onTapCategory: _onSelectCategory,
              formatCurrency: _formatCurrency,
              dashbordcontroller: dashbordcontroller,
            ),
            
            const SizedBox(height: 24),

            // --- 최근 거래 내역 섹션 ---
            RecentTransactionsList(
              transactions: dashbordcontroller.recentTransactions,
              formatDate: settingsController.formatDate,
              formatCurrency: _formatCurrency,
            ),
          ],
        );
      }),
    ),
  );
}
// @override
// Widget build(BuildContext context) {
//   return SafeArea(
//     child: SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Obx(() {
//         // 데이터 트리거
//         settingsController.refreshTrigger.value;
//         dashbordcontroller.dataRefreshTrigger.value;

//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               padding: const EdgeInsets.all(20), // 카드 내부 여백
//               decoration: BoxDecoration(
//                 color: Theme.of(context).cardColor, // 다크모드 자동 대응
//                 borderRadius: BorderRadius.circular(24), // 부드러운 곡선
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.05),
//                     blurRadius: 15,
//                     offset: const Offset(0, 8),
//                   ),
//                 ],
//               ),
//               child: Container(
//                 padding:  const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   color: Theme.of(context).cardColor,
//                   borderRadius: BorderRadius.circular(24),
//                 ),
//                 child: Column(
//                   children: [
//                     // 기존의 요약 정보 (좌우 배치)
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         ExpenseSummary(
//                           expense: dashbordcontroller.totalExpense.value,
//                           onTap: () => _showDateRangePicker(context),
//                           formatCurrency: _formatCurrency,
//                         ),
//                         BudgetSummary(
//                           budget: dashbordcontroller.monthlyBudget.value,
//                           currentSpend: dashbordcontroller.totalExpense.value,
//                           onBudgetTap: _showBudgetDialog,
//                           formatCurrency: _formatCurrency,
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 12), // 텍스트와 게이지 사이 간격
                    
//                     Row(
//                       crossAxisAlignment: CrossAxisAlignment.end,
//                       children: [
//                         SizedBox(
//                           width: 90,
//                           height: 90,
//                           child: BudgetPigWidget(
//                             percent: (dashbordcontroller.monthlyBudget.value > 0)
//                             ? (dashbordcontroller.totalExpense.value / dashbordcontroller.monthlyBudget.value)
//                             : 0.0
//                             ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(width: 8,),
//                     // 이제 게이지가 카드 너비에 맞춰지면서 
//                     // '길어서 징그러운 느낌'이 사라지고 세련되게 변함!
//                     BudgetGauge(
//                       currentSpend: dashbordcontroller.totalExpense.value,
//                       targetBudget: dashbordcontroller.monthlyBudget.value,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
            
//             const SizedBox(height: 28), // 섹션 간 간격

//             // --- 나머지 섹션들은 그대로 유지 ---
//             ChartsWidget(
//               top3: dashbordcontroller.top3Categories,
//               selectedPieIndex: selectedPieIndex,
//               onTapCategory: _onSelectCategory,
//               formatCurrency: _formatCurrency,
//               dashbordcontroller: dashbordcontroller,
//             ),
//             const SizedBox(height: 24),

//             RecentTransactionsList(
//               transactions: dashbordcontroller.recentTransactions,
//               formatDate: settingsController.formatDate,
//               formatCurrency: _formatCurrency,
//             ),
//           ],
//         );
//       }),
//     ),
//   );
// }

  // -----Function------

  /// Formats numeric values into localized currency strings
  String _formatCurrency(dynamic amount) {
    final value = (amount as num?)?.toDouble() ?? 0.0;
    return settingsController.formatCurrency(value);
  }

  /// Handles category selection and updates the detailed breakdown for charts
  void _onSelectCategory(int index) async {
    if (index < 0 || index >= dashbordcontroller.categoryList.length) {
      dashbordcontroller.selectedBreakdown.clear();
      setState(() => selectedPieIndex = null);
      return;
    }
    selectedPieIndex = index;
    final selectedId = dashbordcontroller.categoryList[index]['id'] as int;
    await dashbordcontroller.loadBreakdown(selectedId);
    setState(() {});
  }

/// Displays a dialog to set the monthly budget.
  /// Uses AppLocalizations for all strings and Theme for styling.
  Future<void> _showBudgetDialog() async {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final currentBudget = dashbordcontroller.monthlyBudget.value;
    
    final TextEditingController dialogController =
        TextEditingController(text: currentBudget == 0 ? "" : currentBudget.toString());

    final result = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.setMonthlyBudget),
        content: TextField(
          controller: dialogController,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            hintText: l10n.enterMonthlyBudget,
            suffixIcon: Icon(Icons.edit, color: theme.colorScheme.primary),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: Text(l10n.cancel, style: TextStyle(color: theme.colorScheme.secondary))
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, double.tryParse(dialogController.text.trim())),
            child: Text(l10n.save, style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (result != null) {
      final now = DateTime.now();
      final yearMonth = "${now.year}-${now.month.toString().padLeft(2, '0')}";
      
      await monthlyBudgetHandler.saveMonthlyBudget(yearMonth, result);
      await settingsController.refreshAllData();
      dashbordcontroller.refreshDashboard(); 
    }
  }

  /// Opens a date range picker to filter total expenses for a specific period
  Future<void> _showDateRangePicker(BuildContext context) async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (range != null) {
      String start = range.start.toString().split(' ')[0];
      String end = range.end.toString().split(' ')[0];
      double newTotal = await dashbordcontroller.handler.getMonthlyTotalExpense(startDate: start, endDate: end);
      dashbordcontroller.totalExpense.value = newTotal;
    }
  }
}