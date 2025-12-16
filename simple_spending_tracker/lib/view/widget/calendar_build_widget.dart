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

    // 🔥 핵심: 화면 비율 기반 셀 사이즈
    final screenWidth = MediaQuery.of(context).size.width;
    final cellSize = (screenWidth / 7).clamp(40.0, 56.0);
    final innerSize = cellSize * 0.85;

    return SizedBox(
      width: cellSize,
      height: cellSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: innerSize,
            height: innerSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? primary.withOpacity(0.15)
                  : Colors.transparent,
              border: isToday
                  ? Border.all(color: primary, width: 2)
                  : null,
            ),
            alignment: Alignment.center,
            child: Text(
              '${day.day}',
              style: TextStyle(
                fontSize: innerSize * 0.4, // 비율 고정
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ),

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
