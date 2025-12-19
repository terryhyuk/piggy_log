import 'package:flutter/material.dart';
import 'package:simple_spending_tracker/view/widget/animatedShake.dart';
import '../../model/category.dart';

/// Single Category Card widget
/// - Supports shaking animation in edit mode
/// - Shows Edit/Delete buttons in edit mode
/// - Provides tap & long press callbacks

class CategoryCard extends StatelessWidget {
  final Category category;
  final bool isEditMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback? onEditPress;
  final VoidCallback? onDeletePress;

  const CategoryCard({
    super.key,
    required this.category,
    required this.isEditMode,
    required this.onTap,
    required this.onLongPress,
    this.onEditPress,
    this.onDeletePress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = Color(int.parse(category.color, radix: 16));

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Stack(
        children: [
          // --- Card with optional shadow (light only) ---
          Positioned.fill(
            child: AnimatedShake(
              isActive: isEditMode,
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: theme.brightness == Brightness.dark
                      ? [
                          // Dark mode → 살짝 떠 있는 느낌
                          BoxShadow(
                            color: Colors.black.withAlpha((0.1 * 255).round()),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ]
                      : [
                          // Light mode → 기존 floating card 느낌
                          BoxShadow(
                            color: Colors.black.withAlpha((0.15 * 255).round()),
                            offset: const Offset(0, 5),
                            blurRadius: 12,
                            spreadRadius: 1,
                          ),
                          BoxShadow(
                            color: Colors.white.withAlpha((0.6 * 255).round()),
                            offset: const Offset(0, -2),
                            blurRadius: 4,
                          ),
                        ],
                ),
                child: Center(
                  child: Icon(
                    IconData(
                      category.iconCodePoint,
                      fontFamily: category.iconFontFamily,
                      fontPackage: category.iconFontPackage,
                    ),
                    size: 40,
                    color: color,
                  ),
                ),
              ),
            ),
          ),

          // --- Edit & Delete buttons (visible only in edit mode) ---
          if (isEditMode)
            Positioned(
              right: 4,
              top: 4,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: onEditPress,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: onDeletePress,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
