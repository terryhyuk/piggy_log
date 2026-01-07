import 'package:flutter/material.dart';
import 'package:get_x/get.dart';
import 'package:piggy_log/core/db/dashboard_handler.dart';
import 'package:piggy_log/core/db/monthly_budget_handler.dart';
import 'package:piggy_log/features/settings/controller/setting_controller.dart';
import 'package:piggy_log/l10n/app_localizations.dart';

// -----------------------------------------------------------------------------
//  * Refactoring Intent: 
//    Provides a comparative analysis of historical budgets vs actual expenses.
//    Aggregates data by synchronizing the MonthlyBudget table with the 
//    Transaction ledger through dynamic date range calculations.
//
//  * TODO: 
//    - Implement 'Swipe-to-Delete' for specific history months.
//    - Add a visual progress bar within each list item for better UX.
// -----------------------------------------------------------------------------

class MonthlyHistory extends StatefulWidget {
  const MonthlyHistory({super.key});

  @override
  State<MonthlyHistory> createState() => _MonthlyHistoryState();
}

class _MonthlyHistoryState extends State<MonthlyHistory> {
  final MonthlyBudgetHandler _budgetHandler = MonthlyBudgetHandler();
  final DashboardHandler _dbHandler = DashboardHandler();
  final SettingController _settingsController = Get.find<SettingController>();

  List<Map<String, dynamic>> _historyData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  /// Aggregates budget records and computes corresponding expense sums.
  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);

    // Fetch all budget records persisted in the database.
    final budgets = await _budgetHandler.getAllMonthlyBudgets();
    List<Map<String, dynamic>> combinedList = [];

    for (var b in budgets) {
      String ym = b['yearMonth']; // Format: YYYY-MM

      // [Logic] Calculate the date range for the current iteration month.
      String startDate = "$ym-01";
      DateTime lastDay = DateTime(
        int.parse(ym.split('-')[0]),
        int.parse(ym.split('-')[1]) + 1,
        0, // Returns the last day of the previous month.
      );
      String endDate = "$ym-${lastDay.day.toString().padLeft(2, '0')}";

      // Intersect with transaction ledger to find total expenditure.
      double expense = await _dbHandler.getMonthlyTotalExpense(
        startDate: startDate,
        endDate: endDate,
      );

      combinedList.add({
        'month': ym,
        'budget': b['targetAmount'],
        'expense': expense,
      });
    }

    if (mounted) {
      setState(() {
        _historyData = combinedList;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(local.monthlyBudgetHistory)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _historyData.length,
              itemBuilder: (context, index) {
                final item = _historyData[index];
                final double remaining = item['budget'] - item['expense'];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(
                      item['month'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${local.monthlyBudget}: ${_format(item['budget'])}",
                        ),
                        Text(
                          "${local.expense}: ${_format(item['expense'])}",
                          style: TextStyle(
                            color: item['expense'] > item['budget']
                                ? Colors.red
                                : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    trailing: Text(
                      remaining >= 0
                          ? "+${_format(remaining)}"
                          : _format(remaining),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: remaining >= 0 ? Colors.blue : Colors.red,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  String _format(double value) => _settingsController.formatCurrency(value);
}