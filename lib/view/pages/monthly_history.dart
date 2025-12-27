import 'package:flutter/material.dart';
import 'package:get_x/get.dart';
import 'package:piggy_log/VM/dashboard_handler.dart';
import 'package:piggy_log/VM/monthly_budget_handler.dart';
import 'package:piggy_log/controller/setting_controller.dart';
import 'package:piggy_log/l10n/app_localizations.dart';

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

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);

    // 1. 모든 예산 기록 가져오기 (이 함수가 구현되어 있다고 가정)
    // 예: [{yearMonth: "2025-12", budget: 4000.0}, ...]
    final budgets = await _budgetHandler.getAllMonthlyBudgets();

    List<Map<String, dynamic>> combinedList = [];

    for (var b in budgets) {
      String ym = b['yearMonth'];
      // 2. 해당 월의 시작일과 종료일 계산 (예: 2025-12-01 ~ 2025-12-31)
      String startDate = "$ym-01";
      DateTime lastDay = DateTime(
        int.parse(ym.split('-')[0]),
        int.parse(ym.split('-')[1]) + 1,
        0,
      );
      String endDate = "$ym-${lastDay.day.toString().padLeft(2, '0')}";

      // 3. 테리님의 통합 함수로 해당 월의 총 지출액 가져오기
      double expense = await _dbHandler.getMonthlyTotalExpense(
        startDate: startDate,
        endDate: endDate,
      );

      combinedList.add({
        'month': ym,
        'budget': b['targetAmount'], // b['budget'] -> b['targetAmount']로 변경
        'expense': expense,
      });
    }

    setState(() {
      _historyData = combinedList;
      _isLoading = false;
    });
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    // 1. AppBar 타이틀에 바로 적용
    appBar: AppBar(
      title: Text(AppLocalizations.of(context)!.monthlyBudgetHistory),
    ),
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
                title: Text(item['month'], style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 2. monthlyBudget 바로 쓰기
                    Text("${AppLocalizations.of(context)!.monthlyBudget}: ${_format(item['budget'])}"), 
                    // 3. expense 바로 쓰기
                    Text("${AppLocalizations.of(context)!.expense}: ${_format(item['expense'])}", 
                         style: TextStyle(color: item['expense'] > item['budget'] ? Colors.red : Colors.black)),
                  ],
                ),
                trailing: Text(
                  remaining >= 0 ? "+${_format(remaining)}" : _format(remaining),
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

  String _format(double value) =>
      _settingsController.formatCurrency(value);
}
