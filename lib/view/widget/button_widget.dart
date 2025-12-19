import 'package:flutter/material.dart';

class ButtonWidget extends StatelessWidget {
  const ButtonWidget({super.key, required this.onTap});

  // Property
  final VoidCallback onTap;

  @override
Widget build(BuildContext context) {
  final theme = Theme.of(context);

  return GestureDetector(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color.lerp(
              theme.colorScheme.surface,
              theme.colorScheme.shadow,
              0.12,
            )!,
            blurRadius: 12,
            offset: Offset(4, 4),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.add,
          size: 32,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    ),
  );
}
}
