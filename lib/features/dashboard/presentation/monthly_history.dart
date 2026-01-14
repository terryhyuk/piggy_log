// [monthly_history.dart] 🍎
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:piggy_log/providers/dashboard_provider.dart';
import 'package:piggy_log/providers/record_provider.dart';
import 'package:piggy_log/providers/settings_provider.dart';
import 'package:provider/provider.dart';
import 'package:piggy_log/l10n/app_localizations.dart';

class MonthlyHistory extends StatefulWidget {
  const MonthlyHistory({super.key});

  @override
  State<MonthlyHistory> createState() => _MonthlyHistoryState();
}

class _MonthlyHistoryState extends State<MonthlyHistory> {
  late final DashboardProvider _dashboardProvider;
  late final RecordProvider _recordProvider;

  
  List<Map<String, dynamic>> _historyData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Initialize repositories properly from context
    _dashboardProvider = context.read<DashboardProvider>();
    _recordProvider = context.read<RecordProvider>();
    
    _loadHistory();
  }

Future<void> _loadHistory() async {
  if (!mounted) return;
  setState(() => _isLoading = true);

  try {
    final budgets = await _dashboardProvider
        .dashboardRepository
        .getAllMonthlyBudgets();

    List<Map<String, dynamic>> combinedList = [];

    for (var b in budgets) {
      final ym = b['year_month'];

      final parts = ym.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);

      final startDate = "$ym-01";
      final lastDay = DateTime(year, month + 1, 0);
      final endDate =
          "$ym-${lastDay.day.toString().padLeft(2, '0')}";

      final expense = await _recordProvider
          .recordRepository
          .getMonthlyTotalExpense(
            start: startDate,
            end: endDate,
          );

      combinedList.add({
        'month': ym,
        'budget': (b['target_amount'] as num).toDouble(),
        'expense': expense,
      });
    }

    combinedList.sort((a, b) => b['month'].compareTo(a['month']));

    if (!mounted) return;
    setState(() {
      _historyData = combinedList;
      _isLoading = false;
    });
  } catch (e, st) {
    debugPrint("Error loading history: $e\n$st");
    if (mounted) setState(() => _isLoading = false);
  }
}


  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final settings = context.watch<SettingProvider>();
    final theme = Theme.of(context);

    final String langCode = settings.locale?.languageCode ??
        Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(local.monthlyBudgetHistory),
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _historyData.isEmpty
              ? Center(child: Text(local.noTransactions))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _historyData.length,
                  itemBuilder: (context, index) {
                    final item = _historyData[index];
                    final String ym = item['month'];
                    final double budget = item['budget'];
                    final double expense = item['expense'];
                    final double remaining = budget - expense;

                    // Formatting date strings
                    final date = DateTime.parse("$ym-01");
                    final String yearStr = DateFormat.y(langCode).format(date);
                    final String monthStr = DateFormat.MMMM(langCode).format(date);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: theme.dividerColor.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  local.historyMonthTitle(monthStr, yearStr),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: (remaining >= 0 ? Colors.blue : Colors.red)
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    "${remaining >= 0 ? '+' : ''}${settings.formatCurrency(remaining)}",
                                    style: TextStyle(
                                      color: remaining >= 0 ? Colors.blue : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              child: Divider(),
                            ),
                            Row(
                              children: [
                                _buildInfoColumn(
                                  local.budget,
                                  settings.formatCurrency(budget),
                                  theme,
                                ),
                                const Spacer(),
                                _buildInfoColumn(
                                  local.expense,
                                  settings.formatCurrency(expense),
                                  theme,
                                  valColor: expense > budget ? Colors.red : null,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildInfoColumn(String label, String value, ThemeData theme, {Color? valColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: theme.hintColor, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: valColor,
          ),
        ),
      ],
    );
  }
}