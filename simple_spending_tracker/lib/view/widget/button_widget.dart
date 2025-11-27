import 'package:flutter/material.dart';

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
          color: Colors.white, // Match category card background
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 12,
              offset: Offset(4, 4),
            ),
          ],
        ),
        child: const Center(
          child: Icon(Icons.add, size: 32, color: Colors.black87),
        ),
      ),
    );
  }
}// END
