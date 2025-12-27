import 'package:flutter/material.dart';

/// A professional-grade progress bar that visualizes budget usage.
/// 
/// Features:
/// - Dynamic gradients synchronized with spending thresholds (50%, 70%).
/// - Smooth [AnimatedContainer] for width transitions.
/// - Over-budget visualization with negative percentage display.
/// 
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

    // Calculate usage ratio and percentage
    final double usageRatio = targetBudget > 0 ? (currentSpend / targetBudget) : 0.0;
    final double actualPercent = usageRatio * 100;
    
    // Determine display text: Show usage % or negative over-budget %
    String displayText;
    if (actualPercent > 100) {
      final int overPercent = (actualPercent - 100).toInt();
      displayText = "-$overPercent%"; 
    } else {
      displayText = "${actualPercent.toInt()}%";
    }

    // Configure gradient colors based on spending thresholds
    // Logic synchronized with BudgetPigWidget's emotional states
    final List<Color> gradientColors;
    if (usageRatio >= 0.7) {
      // Danger zone: Red gradient for high alert (Angry Pig state)
      gradientColors = [Colors.orange, Colors.redAccent];
    } else if (usageRatio >= 0.5) {
      // Warning zone: Orange gradient (Worried Pig state)
      gradientColors = [Colors.yellow, Colors.orange];
    } else {
      // Safe zone: Green gradient (Happy Pig state)
      gradientColors = [const Color(0xFF81F600), Colors.green];
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        // 1. Background Track
        Container(
          height: 22,
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        // 2. Animated Progress Bar with Gradient
        LayoutBuilder(
          builder: (context, constraints) {
            // Clamp bar width to a maximum of 100% (container width)
            final double barWidth = constraints.maxWidth * usageRatio.clamp(0.0, 1.0);
            
            return Align(
              alignment: Alignment.centerLeft,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic, // Smooth deceleration curve
                width: barWidth,
                height: 22,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            );
          },
        ),
        // 3. Label Overlay
        Text(
          displayText,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            // Dynamic color adjustment for readability against dark/light bars
            color: (usageRatio > 0.5) ? Colors.white : theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}