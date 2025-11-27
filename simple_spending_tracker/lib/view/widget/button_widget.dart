import 'package:get_x/get.dart';
import 'package:flutter/material.dart';
import 'package:simple_spending_tracker/view/add_transactions.dart';

class ButtonWidget extends StatelessWidget {
  const ButtonWidget({super.key, required this.onTap});

  // Property
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: Icon(Icons.add, size: 32)),
      ),
    );
  }
}// END


