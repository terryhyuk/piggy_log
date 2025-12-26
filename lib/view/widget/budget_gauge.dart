import 'package:flutter/material.dart';

/// A widget that displays a progress bar (gauge) comparing current spending against a target budget.
/// It shows the used percentage within the bar and switches to a negative "over-budget" percentage
/// if the spending exceeds the target.
class BudgetGauge extends StatelessWidget {
  final double currentSpend;
  final double targetBudget;

  const BudgetGauge({
    super.key,
    required this.currentSpend,
    required this.targetBudget,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // 1. Progress Logic
    // barPercent controls the UI of the LinearProgressIndicator (clamped between 0.0 and 1.0)
    double barPercent = targetBudget > 0 ? (currentSpend / targetBudget).clamp(0.0, 1.0) : 0.0;
    
    // actualUsedRatio represents the raw calculation of spending vs budget
    double actualUsedRatio = targetBudget > 0 ? (currentSpend / targetBudget) : 0.0;
    double actualPercent = actualUsedRatio * 100;
    
    // 2. Display Text Logic (Based on Terry's requirement)
    String displayText;
    if (actualPercent > 100) {
      // If over budget, calculate the exceeded percentage and show with a minus sign (e.g., -300%)
      int overPercent = (actualPercent - 100).toInt();
      displayText = "-$overPercent%"; 
    } else {
      // If within budget, show the current usage percentage (e.g., 40%)
      displayText = "${actualPercent.toInt()}%";
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        // Background Progress Bar
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: LinearProgressIndicator(
            value: barPercent, // Visual progress stops at 100%
            minHeight: 22,
            backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
            // Turn the bar red if budget is exceeded
            valueColor: AlwaysStoppedAnimation<Color>(
              actualPercent > 100 ? Colors.redAccent : theme.colorScheme.primary,
            ),
          ),
        ),
        // Overlay Text: Centered over the progress bar
        Text(
          displayText,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            // Ensure contrast: use white text if bar is filled more than 50%
            color: (actualPercent > 50) ? Colors.white : theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}