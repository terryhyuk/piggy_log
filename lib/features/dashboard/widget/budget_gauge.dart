import 'package:flutter/material.dart';

// -----------------------------------------------------------------------------
//  * Refactoring Intent: 
//    A reactive progress visualizer designed for financial compliance tracking.
//    Features a 'Context-Aware Styling' engine that synchronizes color gradients 
//    with the mascot's emotional states (Safe/Warning/Critical).
//
//  * TODO: 
//    - Implement a 'Pulse' animation when usage exceeds 100% for better affordance.
//    - Consider adding a 'Target Marker' overlay to indicate fixed savings goals.
// -----------------------------------------------------------------------------

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

    /// Calculation: Derives usage ratio and manages over-budget labeling.
    final double usageRatio = targetBudget > 0 ? (currentSpend / targetBudget) : 0.0;
    final double actualPercent = usageRatio * 100;
    
    String displayText;
    if (actualPercent > 100) {
      final int overPercent = (actualPercent - 100).toInt();
      displayText = "-$overPercent%"; 
    } else {
      displayText = "${actualPercent.toInt()}%";
    }

    /// Adaptive Theming: Maps gradient intensity to expenditure risk levels.
    final List<Color> gradientColors;
    if (usageRatio >= 0.7) {
      gradientColors = [Colors.orange, Colors.redAccent]; 
    } else if (usageRatio >= 0.5) {
      gradientColors = [Colors.yellow, Colors.orange]; 
    } else {
      gradientColors = [const Color(0xFF81F600), Colors.green]; 
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        // Background Track: Styled for theme-specific contrast.
        Container(
          height: 22,
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
        ),

        // Animated Progress Layer: Employs a cubic curve for a premium motion feel.
        LayoutBuilder(
          builder: (context, constraints) {
            // Clamping ensures the bar stays within the visual bounds even during spikes.
            final double barWidth = constraints.maxWidth * usageRatio.clamp(0.0, 1.0);
            
            return Align(
              alignment: Alignment.centerLeft,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic, 
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

        // Value Label: Dynamically adjusts color to ensure optimal readability.
        Text(
          displayText,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: (usageRatio > 0.5) ? Colors.white : theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}