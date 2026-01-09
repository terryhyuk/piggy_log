import 'package:flutter/material.dart';
import 'package:piggy_log/data/models/category_model.dart';
import 'package:piggy_log/features/categort/widget/animated_shake.dart';

class CategoryCard extends StatelessWidget {
  final CategoryModel category; 
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
    final color = Color(int.parse(category.color, radix: 16));
    
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Stack(
        children: [
          Positioned.fill(
            child: AnimatedShake(
              isActive: isEditMode,
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: theme.brightness == Brightness.dark
                      ? [
                          BoxShadow(
                            color: Colors.black.withAlpha((0.1 * 255).round()),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ]
                      : [
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

          // Action overlays
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