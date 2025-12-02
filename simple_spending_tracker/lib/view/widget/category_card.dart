import 'package:flutter/material.dart';
import 'package:simple_spending_tracker/view/widget/animatedShake.dart';
import '../../model/category.dart';

/// Single Category Card widget
/// - Supports shaking animation in edit mode
/// - Shows Edit/Delete buttons in edit mode
/// - Provides tap & long press callbacks
class CategoryCard extends StatelessWidget {

  // property

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

    final color = Color(int.parse(category.color, radix: 16));

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Stack(
        children: [
          // Card body with shake animation
          Positioned.fill(
            child: AnimatedShake(
              isActive: isEditMode,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      offset: Offset(4, 4),
                      blurRadius: 8,
                      color: Colors.black12,
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
          // Edit & delete buttons (visible only in edit mode)
          if (isEditMode)
            Positioned(
              right: 4,
              top: 4,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: (){
                      if (onEditPress != null) {
                        onEditPress!();
                      }
                    }
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

} // END
