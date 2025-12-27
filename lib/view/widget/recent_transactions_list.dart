import 'package:flutter/material.dart';
import 'package:piggy_log/l10n/app_localizations.dart';

class RecentTransactionsList extends StatelessWidget {
  final List transactions;
  final String Function(DateTime) formatDate;
  final String Function(double) formatCurrency;

  const RecentTransactionsList({
    super.key,
    required this.transactions,
    required this.formatDate,
    required this.formatCurrency,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)!.recentTransactions,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...transactions.map((trx) => Card(
              child: ListTile(
                title: Text(trx['t_name']),
                subtitle: Text(formatDate(DateTime.parse(trx['date']))),
                trailing: Text(formatCurrency(trx['amount']),
                    style: TextStyle(color: trx['type'] == 'expense' ? Colors.red : Colors.green)),
              ),
            )),
      ],
    );
  }
}