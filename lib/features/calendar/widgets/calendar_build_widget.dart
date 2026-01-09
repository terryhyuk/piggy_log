import 'package:flutter/material.dart';

class CalendarBuildWidget extends StatelessWidget {
  final DateTime day;
  final bool isSelected;
  final bool isToday;
  final bool hasTx;
  final Color textColor;
  final Color markerColor;

  const CalendarBuildWidget({
    super.key,
    required this.day,
    required this.isSelected,
    required this.isToday,
    required this.hasTx,
    required this.textColor,
    required this.markerColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    // [Logic] Responsive Geometry Engine
    // Ensuring consistent aspect ratio across various device widths.
    final screenWidth = MediaQuery.of(context).size.width;
    final cellSize = (screenWidth / 7).clamp(40.0, 56.0);
    final innerSize = cellSize * 0.85;

    return SizedBox(
      width: cellSize,
      height: cellSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Day Container: Implements visual blending for the selected state.
          Container(
            width: innerSize,
            height: innerSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // Subtle tinting via lerp to maintain visual hierarchy.
              color: isSelected
                  ? Color.lerp(Colors.transparent, primary, 0.15)!
                  : Colors.transparent,
              // High-contrast border to emphasize the current real-time date.
              border: isToday ? Border.all(color: primary, width: 2) : null,
            ),
            alignment: Alignment.center,
            child: Text(
              '${day.day}',
              style: TextStyle(
                fontSize: innerSize * 0.4,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ),

          // Event Marker: Provides non-intrusive feedback for transaction data.
          if (hasTx)
            Positioned(
              bottom: cellSize * 0.12,
              child: Container(
                width: cellSize * 0.12,
                height: cellSize * 0.12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: markerColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
