import 'package:flutter/material.dart';
import 'package:get_x/get.dart';
import 'package:piggy_log/l10n/app_localizations.dart';
import 'package:piggy_log/features/dashboard/presentation/monthly_history.dart';

// -----------------------------------------------------------------------------
//  * Refactoring Intent: 
//    Financial compliance monitor that provides real-time budget status.
//    Implements a 'Alert-driven UI' pattern where visual elements react 
//    dynamically to spending thresholds (Over-budget state).
//
//  * TODO: 
//    - Add a progress bar (LinearProgressIndicator) to visualize budget consumption.
//    - Move 'isOverBudget' logic to the controller for better state consistency.
// -----------------------------------------------------------------------------

class BudgetSummary extends StatelessWidget {
  final double budget;
  final double currentSpend; 
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
    /// Evaluation Logic: Identifies critical budget violations.
    final bool isOverBudget = budget > 0 && currentSpend > budget;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Navigation Header: Entry point to historical data review.
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
                    /// Reactive Styling: Visual shift to Red for immediate recognition.
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