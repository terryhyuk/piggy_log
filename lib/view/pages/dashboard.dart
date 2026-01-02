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

// -----------------------------------------------------------------------------
//  * Refactoring Intent: 
//    The central landing hub of Piggy Log. It orchestrates real-time state 
//    updates between the DashboardController and UI components. 
//    Optimized for high-scannability and reactive visual feedback.
// -----------------------------------------------------------------------------

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  // Dependency Injection: Accessing specialized controllers for state management
  final DashboardController dashbordcontroller = Get.find<DashboardController>();
  final SettingController settingsController = Get.find<SettingController>();
  final MonthlyBudgetHandler monthlyBudgetHandler = MonthlyBudgetHandler();

  int? selectedPieIndex;

  @override
  void initState() {
    super.initState();
    // Synchronizes the data layer with the persistence storage on startup.
    dashbordcontroller.refreshDashboard();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          // Reactive Trigger: Ensures UI re-renders whenever observable values change.
          settingsController.refreshTrigger.value;
          dashbordcontroller.dataRefreshTrigger.value;

          // Consumption Ratio: Calculates the current financial health percentage.
          double currentPercent = (dashbordcontroller.monthlyBudget.value > 0)
              ? (dashbordcontroller.totalExpense.value /
                    dashbordcontroller.monthlyBudget.value)
              : 0.0;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Section 1: Financial Status Card ---
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

              // --- Section 2: Analytical Charts ---
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  border: Border.all(
                    color: theme.dividerColor.withValues(alpha: 0.05),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(20),
                  child: ChartsWidget(),
                ),
              ),

              const SizedBox(height: 32),

              // --- Section 3: Ledger History (Recent Transactions) ---
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

  // --- Logic Helpers ---

  /// Formats numeric values into localized currency strings via SettingController.
  String _formatCurrency(dynamic amount) {
    final value = (amount as num?)?.toDouble() ?? 0.0;
    return settingsController.formatCurrency(value);
  }

  /// Triggers a modal to update the target monthly budget.
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

  /// Filters financial data by a custom date range selected by the user.
  Future<void> _showDateRangePicker(BuildContext context) async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (range != null) {
      String start = range.start.toString().split(' ')[0];
      String end = range.end.toString().split(' ')[0];

      // Update observable dates to trigger dependent data re-fetches.
      dashbordcontroller.startDate.value = start;
      dashbordcontroller.endDate.value = end;

      await dashbordcontroller.refreshDashboard();
    }
  }
}