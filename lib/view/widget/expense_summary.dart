import 'package:flutter/material.dart';
import 'package:piggy_log/l10n/app_localizations.dart';

class ExpenseSummary extends StatelessWidget {
  final double expense;
  final VoidCallback onTap;
  final String Function(double) formatCurrency;

  const ExpenseSummary({
    super.key,
    required this.expense,
    required this.onTap,
    required this.formatCurrency,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Text(
            AppLocalizations.of(context)!.totalExpense,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
          ),
        ),
        const SizedBox(height: 4),
        Text(formatCurrency(expense),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.redAccent)),
      ],
    );
  }
}