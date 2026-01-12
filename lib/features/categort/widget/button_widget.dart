import 'package:flutter/material.dart';

class ButtonWidget extends StatelessWidget {
  final VoidCallback onTap;

  const ButtonWidget({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: theme.brightness == Brightness.dark
              ? [
                  BoxShadow(
                    color: Colors.black.withAlpha(50),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withAlpha(38),
                    offset: const Offset(0, 5),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                  BoxShadow(
                    color: Colors.white.withAlpha(153),
                    offset: const Offset(0, -2),
                    blurRadius: 4,
                  ),
                ],
          border: theme.brightness == Brightness.dark
              ? Border.all(color: Colors.white.withAlpha(20), width: 0.8)
              : null,
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
