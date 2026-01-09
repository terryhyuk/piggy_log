import 'package:flutter/material.dart';
import 'package:piggy_log/l10n/app_localizations.dart';
import 'package:piggy_log/features/dashboard/presentation/monthly_history.dart';

class BudgetSummary extends StatelessWidget {
  final double budget;
  final double currentSpend; 
  final VoidCallback onBudgetTap;
  final String Function(double) formatCurrency;
  final String title;

  const BudgetSummary({
    super.key,
    required this.budget,
    required this.currentSpend,
    required this.onBudgetTap,
    required this.formatCurrency, 
    required this. title,
  });

  @override
  Widget build(BuildContext context) {
    final bool isOverBudget = budget > 0 && currentSpend > budget;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MonthlyHistory()),
            );
          },
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16, 
              fontWeight: FontWeight.bold, 
              decoration: TextDecoration.underline
            ),
          ),
        ),
        const SizedBox(height: 4),
        
        // Dynamic Budget Info: Interactive area for budget configuration.
        GestureDetector(
          onTap: onBudgetTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// Critical Alert: Visible only when spending exceeds the limit.
                if (isOverBudget)
                  const Padding(
                    padding: EdgeInsets.only(right: 4),
                    child: Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.red,
                      size: 20,
                    ),
                  ),
                
                Text(
                  budget == 0 
                      ? AppLocalizations.of(context)!.setYourBudget 
                      : formatCurrency(budget),
                  style: TextStyle(
                    fontSize: 16, 
                    fontWeight: FontWeight.bold,
                    color: isOverBudget ? Colors.red : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}