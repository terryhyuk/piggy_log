import 'package:flutter/material.dart';
import 'package:get_x/get.dart';
import 'package:piggy_log/VM/monthly_budget_handler.dart';
import 'package:piggy_log/controller/dashboard_controller.dart';
import 'package:piggy_log/controller/setting_controller.dart';
import 'package:piggy_log/l10n/app_localizations.dart';
import 'package:piggy_log/view/pages/monthly_history.dart';
import 'package:piggy_log/view/widget/budget_gauge.dart';
import 'package:piggy_log/view/widget/chart_widget.dart';

/// This page serves as the main Dashboard of the application.
/// It displays a summary of monthly expenses, budget status via a gauge bar,
/// expense distribution charts (Pie/Radar), and a list of recent transactions.
/// It utilizes GetX for reactive state management.


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

  int? selectedPieIndex;

  @override
  void initState() {
    super.initState();
    // Refresh all dashboard data when the page is first initialized
    dashbordcontroller.refreshDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          // Reactive triggers to rebuild UI when data changes in controllers
          settingsController.refreshTrigger.value;
          dashbordcontroller.dataRefreshTrigger.value;

          final monthlyExpense = dashbordcontroller.totalExpense.value;
          final top3Categories = dashbordcontroller.top3Categories;
          final recentTransactions = dashbordcontroller.recentTransactions;
          final currentBudget = dashbordcontroller.monthlyBudget.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Summary Section: Displays Total Expense and Monthly Budget
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left side: Total Expense details
                  _buildExpenseSummary(context, monthlyExpense),
                  // Right side: Monthly Budget details
                  _buildBudgetSummary(context, currentBudget),
                ],
              ),

              const SizedBox(height: 16),

              // 2. Budget Progress Section: Visualizes spending vs budget
              BudgetGauge(
                currentSpend: monthlyExpense,
                targetBudget: currentBudget,
              ),

              const SizedBox(height: 24),

              // 3. Analytics Section: Charts and Top 3 Expense Categories
              _buildChartSection(context, top3Categories),

              const SizedBox(height: 24),

              // 4. Activity Section: Shows the latest transaction history
              _buildRecentTransactions(context, recentTransactions),
            ],
          );
        }),
      ),
    );
  }

  // --- UI Component Helpers ---

  /// Builds the expense summary column with a date picker trigger
  Widget _buildExpenseSummary(BuildContext context, double expense) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _showDateRangePicker(context),
          child: Text(
            AppLocalizations.of(context)!.totalExpense,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
          ),
        ),
        const SizedBox(height: 4),
        Text(_formatCurrency(expense),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.redAccent)),
      ],
    );
  }

  /// Builds the budget summary column with a budget setup dialog trigger
  Widget _buildBudgetSummary(BuildContext context, double budget) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: () => Get.to(() => const MonthlyHistory()),
          child: Text(
            AppLocalizations.of(context)!.monthlyBudget,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
          ),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () => _showBudgetDialog(),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Text(
              budget == 0 ? AppLocalizations.of(context)!.setYourBudget : _formatCurrency(budget),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the chart section including Pie and Radar charts
  Widget _buildChartSection(BuildContext context, List top3) {
    if (dashbordcontroller.categoryList.isEmpty) {
      return Center(child: Text(AppLocalizations.of(context)!.noTransactions));
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: ChartsWidget(
            pieData: dashbordcontroller.makePieData(selectedIndex: selectedPieIndex),
            onTapCategory: _onSelectCategory,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...top3.asMap().entries.map((entry) {
                final item = entry.value;
                final color = dashbordcontroller.categoryColors[entry.key % dashbordcontroller.categoryColors.length];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text('${item['name']} - ${_formatCurrency(item['total'])}',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: color)),
                );
              }),
              const SizedBox(height: 8),
              Obx(() {
                final breakdown = Map<String, double>.from(dashbordcontroller.selectedBreakdown);
                if (breakdown.isEmpty) return const SizedBox.shrink();
                return ChartsWidget(radarData: breakdown);
              }),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds the list of recent transactions using Cards
  Widget _buildRecentTransactions(BuildContext context, List transactions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)!.recentTransactions,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...transactions.map((trx) => Card(
              child: ListTile(
                title: Text(trx['t_name']),
                subtitle: Text(settingsController.formatDate(DateTime.parse(trx['date'])) ?? trx['date']),
                trailing: Text(_formatCurrency(trx['amount']),
                    style: TextStyle(color: trx['type'] == 'expense' ? Colors.red : Colors.green)),
              ),
            )),
      ],
    );
  }

  // --- Logic & Event Handlers ---

  /// Formats double values to localized currency strings
  String _formatCurrency(dynamic amount) {
    final value = (amount as num?)?.toDouble() ?? 0.0;
    return settingsController.formatCurrency(value) ?? value.toString();
  }

  /// Handles category selection to update the Radar chart breakdown
  void _onSelectCategory(int index) async {
    if (index < 0 || index >= dashbordcontroller.categoryList.length) {
      dashbordcontroller.selectedBreakdown.clear();
      selectedPieIndex = null;
      setState(() {});
      return;
    }
    selectedPieIndex = index;
    final selectedId = dashbordcontroller.categoryList[index]['id'] as int;
    await dashbordcontroller.loadBreakdown(selectedId);
    setState(() {});
  }

  /// Opens a dialog to input and save the monthly budget
  Future<void> _showBudgetDialog() async {
    final currentBudget = dashbordcontroller.monthlyBudget.value;
    final TextEditingController dialogController =
        TextEditingController(text: currentBudget == 0 ? "" : currentBudget.toString());

    final result = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.setMonthlyBudget),
        content: TextField(
          controller: dialogController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(hintText: AppLocalizations.of(context)!.enterMonthlyBudget),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context)!.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(context, double.tryParse(dialogController.text.trim())),
            child: Text(AppLocalizations.of(context)!.save),
          ),
        ],
      ),
    );

    if (result != null) {
      final now = DateTime.now();
      final yearMonth = "${now.year}-${now.month.toString().padLeft(2, '0')}";
      // Save budget to Database
      await monthlyBudgetHandler.saveMonthlyBudget(yearMonth, result);
      // Trigger global refresh to update all UI components
      await settingsController.refreshAllData();
    }
  }

  /// Opens a date range picker to filter total expenses by specific dates
  Future<void> _showDateRangePicker(BuildContext context) async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      // Custom builder logic for styling (omitted for brevity)
    );

    if (range != null) {
      String start = range.start.toString().split(' ')[0];
      String end = range.end.toString().split(' ')[0];
      double newTotal = await dashbordcontroller.handler.getMonthlyTotalExpense(startDate: start, endDate: end);
      dashbordcontroller.totalExpense.value = newTotal;
    }
  }
}