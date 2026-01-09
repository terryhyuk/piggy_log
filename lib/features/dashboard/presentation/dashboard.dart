import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:piggy_log/core/utils/app_snackbar.dart';
import 'package:piggy_log/providers/dashboard_provider.dart';
import 'package:piggy_log/providers/settings_provider.dart';
import 'package:provider/provider.dart';
import 'package:piggy_log/features/dashboard/widget/budget_piggy_widget.dart';
import 'package:piggy_log/l10n/app_localizations.dart';
import 'package:piggy_log/features/dashboard/widget/budget_gauge.dart';
import 'package:piggy_log/features/dashboard/widget/budget_summary.dart';
import 'package:piggy_log/features/dashboard/widget/chart_widget.dart';
import 'package:piggy_log/features/dashboard/widget/expense_summary.dart';
import 'package:piggy_log/features/dashboard/widget/recent_records_list.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().refreshDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final dashProvider = context.watch<DashboardProvider>();
    final setProvider = context.watch<SettingProvider>();

    // --- [Dynamic Month Label Logic] ---
    final currentDateTime = dashProvider.startDate.isNotEmpty
        ? DateTime.parse(dashProvider.startDate)
        : DateTime.now();

    final now = DateTime.now();
    final bool isPastMonth =
        currentDateTime.year < now.year ||
        (currentDateTime.year == now.year && currentDateTime.month < now.month);

    final String localeCode =
        setProvider.locale?.languageCode ??
        Localizations.localeOf(context).languageCode;

    final String monthLabel = DateFormat.MMMM(
      localeCode,
    ).format(currentDateTime);

    double currentPercent = (dashProvider.monthlyBudget > 0)
        ? (dashProvider.totalExpense / dashProvider.monthlyBudget)
        : 0.0;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                      //"1월 총 지출" / "January Total Expense"
                      ExpenseSummary(
                        title: l10n.totalExpenseTitle(monthLabel),
                        expense: dashProvider.totalExpense,
                        onTap: () => _showDateRangePicker(context),
                        formatCurrency: (val) =>
                            setProvider.formatCurrency(val),
                      ),
                      // "1월 예산" / "January Budget"
                      BudgetSummary(
                        title: l10n.monthlyBudgetTitle(monthLabel),
                        budget: dashProvider.monthlyBudget,
                        currentSpend: dashProvider.totalExpense,
                        onBudgetTap: () {
                          if (!isPastMonth) {
                            _showBudgetDialog(dashProvider, setProvider);
                          }
                        },
                        formatCurrency: (val) =>
                            setProvider.formatCurrency(val),
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
                            currentSpend: dashProvider.totalExpense,
                            targetBudget: dashProvider.monthlyBudget,
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
                l10n.spendingAnalysis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
            ),
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
            RecentTransactionsList(
              transactions: dashProvider.recentTransactions,
              formatDate: (date) => setProvider.formatDate(date),
              formatCurrency: (val) => setProvider.formatCurrency(val),
            ),
          ],
        ),
      ),
    );
  }
  // --- Logic Helpers ---

  /// Triggers a modal to update the target monthly budget via Provider.
  Future<void> _showBudgetDialog(
    DashboardProvider dash,
    SettingProvider settings,
  ) async {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final currentBudget = dash.monthlyBudget;

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
          // [Logic] Restrict to numeric input
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
            onPressed: () {
              final String input = dialogController.text.trim();

              // [Logic] If empty, treat as 0.0 automatically
              if (input.isEmpty) {
                Navigator.pop(context, 0.0);
                return;
              }

              final double? parsed = double.tryParse(input);
              if (parsed == null || parsed < 0) {
                // Only show error for invalid characters or negative values
                AppSnackBar.show(context, l10n.invalidAmount, isError: true);
                return;
              }

              Navigator.pop(context, parsed);
            },
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
      final currentDateTime = dash.startDate.isNotEmpty
          ? DateTime.parse(dash.startDate)
          : DateTime.now();

      final yearMonth = DateFormat('yyyy-MM').format(currentDateTime);
      
      await dash.dashboardRepository.saveMonthlyBudget(yearMonth, result);
      await dash.refreshDashboard();

      if (mounted) {
        AppSnackBar.show(context, l10n.budgetUpdated);
      }
    }
  }

  /// Filters financial data by a custom date range.
  Future<void> _showDateRangePicker(BuildContext context) async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (range != null) {
      final dashProvider = context.read<DashboardProvider>();
      dashProvider.startDate = DateFormat('yyyy-MM-dd').format(range.start);
      dashProvider.endDate = DateFormat('yyyy-MM-dd').format(range.end);
      await dashProvider.refreshDashboard();
    }
  }
}
