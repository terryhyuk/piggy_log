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
  final DashboardController dashbordcontroller =
      Get.find<DashboardController>();
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
    final theme = Theme.of(context); // 💡 테마 변수 추출

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          settingsController.refreshTrigger.value;
          dashbordcontroller.dataRefreshTrigger.value;

          double currentPercent = (dashbordcontroller.monthlyBudget.value > 0)
              ? (dashbordcontroller.totalExpense.value /
                    dashbordcontroller.monthlyBudget.value)
              : 0.0;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. 상단 예산 요약 카드 ---
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadowColor.withValues(alpha: 0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
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

                    const SizedBox(height: 16),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: 90,
                          height: 90,
                          child: BudgetPigWidget(percent: currentPercent),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: BudgetGauge(
                              currentSpend:
                                  dashbordcontroller.totalExpense.value,
                              targetBudget:
                                  dashbordcontroller.monthlyBudget.value,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 12),
                child: Text(
                  AppLocalizations.of(context)!.spendingAnalysis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              ),

              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.cardColor, // 💡 카드 배경색 사용
                  borderRadius: BorderRadius.circular(24),
                  // 💡 핵심: 다른 카드들과 통일감을 주는 그림자 설정
                  // Adding BoxShadow to create a 'floating' elevation effect.
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05), // 아주 연한 검정색
                      blurRadius: 15, // 그림자 퍼짐 정도
                      offset: const Offset(0, 8), // 그림자 방향 (아래쪽으로)
                    ),
                  ],
                  // 선택사항: 아주 연한 테두리를 추가하면 더 선명해 보여
                  border: Border.all(
                    color: theme.dividerColor.withValues(alpha: 0.05),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20), // 내부 여백도 넉넉히!
                  child: ChartsWidget(),
                ),
              ),

              const SizedBox(height: 32),

              // --- 3. 최근 거래 내역 섹션 ---
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

  // -----Function------

  /// Formats numeric values into localized currency strings
  String _formatCurrency(dynamic amount) {
    final value = (amount as num?)?.toDouble() ?? 0.0;
    return settingsController.formatCurrency(value);
  }

  // /// Handles category selection and updates the detailed breakdown for charts
  // void _onSelectCategory(int index) async {
  //   if (index < 0 || index >= dashbordcontroller.categoryList.length) {
  //     dashbordcontroller.selectedBreakdown.clear();
  //     setState(() => selectedPieIndex = null);
  //     return;
  //   }
  //   selectedPieIndex = index;
  //   final selectedId = dashbordcontroller.categoryList[index]['id'] as int;
  //   await dashbordcontroller.loadBreakdown(selectedId);
  //   setState(() {});
  // }

  /// Displays a dialog to set the monthly budget.
  /// Uses AppLocalizations for all strings and Theme for styling.
  Future<void> _showBudgetDialog() async {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final currentBudget = dashbordcontroller.monthlyBudget.value;

    final TextEditingController dialogController = TextEditingController(
      text: currentBudget == 0 ? "" : currentBudget.toString(),
    );

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
            child: Text(
              l10n.cancel,
              style: TextStyle(color: theme.colorScheme.secondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(
              context,
              double.tryParse(dialogController.text.trim()),
            ),
            child: Text(
              l10n.save,
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
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
      // 💡 1. 날짜 형식을 yyyy-MM-dd로 추출
      String start = range.start.toString().split(' ')[0];
      String end = range.end.toString().split(' ')[0];

      // 💡 2. 컨트롤러의 RxString에 먼저 값을 저장 (이게 핵심!)
      // Updating the controller's observable dates before refreshing.
      dashbordcontroller.startDate.value = start;
      dashbordcontroller.endDate.value = end;

      // 💡 3. 그 다음 리프레시 호출 (파이차트 데이터도 여기서 다시 불러옴)
      await dashbordcontroller.refreshDashboard();
    }
  }

  // Future<void> _showDateRangePicker(BuildContext context) async {
  //   final range = await showDateRangePicker(
  //     context: context,
  //     firstDate: DateTime(2020),
  //     lastDate: DateTime.now(),
  //   );

  //   if (range != null) {
  //     String start = range.start.toString().split(' ')[0];
  //     String end = range.end.toString().split(' ')[0];
  //     double newTotal = await dashbordcontroller.handler.getMonthlyTotalExpense(startDate: start, endDate: end);
  //     dashbordcontroller.totalExpense.value = newTotal;
  //   }
  // }
}
