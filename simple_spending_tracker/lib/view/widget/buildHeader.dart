import 'package:flutter/material.dart';
import 'package:get_x/get.dart';
import 'package:simple_spending_tracker/model/category.dart';

class BuildHeader extends StatelessWidget {
  // Property
  final Category category;
  final VoidCallback onAddTap;

  const BuildHeader({
    super.key,
    required this.category,
    required this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Back button
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Get.back(),
        ),

        const SizedBox(width: 20),

        // Category Icon
        Icon(
          IconData(
            category.iconCodePoint,
            fontFamily: category.iconFontFamily,
            fontPackage: category.iconFontPackage,
          ),
          size: 40,
          color: Color(int.parse(category.color, radix: 16)),
        ),

        const SizedBox(width: 20),

        // Category Name
        Text(
          category.c_name,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(width: 20),

        // + Add button
        GestureDetector(
          onTap: onAddTap,
          child: const Text(
            " + Add",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
