import 'package:flutter/material.dart';
import 'package:get_x/get.dart';
import 'package:piggy_log/l10n/app_localizations.dart';
import 'package:piggy_log/view/pages/monthly_history.dart';

///
/// BudgetSummary Widget
/// 
/// Purpose:
/// Displays the current monthly budget and provides navigation to history 
/// or a dialog to update the budget.
///
class BudgetSummary extends StatelessWidget {
  final double budget;
  final double currentSpend; // Added to compare with budget for the warning trigger
  final VoidCallback onBudgetTap;
  final String Function(double) formatCurrency;

  const BudgetSummary({
    super.key,
    required this.budget,
    required this.currentSpend,
    required this.onBudgetTap,
    required this.formatCurrency,
  });

  @override
  Widget build(BuildContext context) {
    // Check if the user has exceeded their assigned budget
    final bool isOverBudget = budget > 0 && currentSpend > budget;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Section Title: Navigate to Monthly History on tap
        GestureDetector(
          onTap: () => Get.to(() => const MonthlyHistory()),
          child: Text(
            AppLocalizations.of(context)!.monthlyBudget,
            style: const TextStyle(
              fontSize: 16, 
              fontWeight: FontWeight.bold, 
              decoration: TextDecoration.underline
            ),
          ),
        ),
        const SizedBox(height: 4),
        
        // Budget Amount: Show warning icon and change color if over budget
        GestureDetector(
          onTap: onBudgetTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Display a red warning triangle only when the budget is exceeded
                if (isOverBudget)
                  const Padding(
                    padding: EdgeInsets.only(right: 4),
                    child: Icon(
                      Icons.warning_amber_rounded, // The "Red Triangle" warning icon
                      color: Colors.red,
                      size: 20,
                    ),
                  ),
                
                // Formatted Budget Amount
                Text(
                  budget == 0 
                      ? AppLocalizations.of(context)!.setYourBudget 
                      : formatCurrency(budget),
                  style: TextStyle(
                    fontSize: 16, 
                    fontWeight: FontWeight.bold,
                    // Changes the text color to red if over budget to alert the user
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