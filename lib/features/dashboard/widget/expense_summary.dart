import 'package:flutter/material.dart';

class ExpenseSummary extends StatelessWidget {
  final double expense;
  final VoidCallback onTap;
  final String Function(double) formatCurrency;
  final String title;

  const ExpenseSummary({
    super.key,
    required this.expense,
    required this.onTap,
    required this.formatCurrency, 
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16, 
              fontWeight: FontWeight.bold, 
              /// Visual affordance indicating the text is a navigable shortcut.
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        const SizedBox(height: 4),
        
        /// High-visibility value display for immediate financial awareness.
        Text(
          formatCurrency(expense),
          style: const TextStyle(
            fontSize: 18, 
            fontWeight: FontWeight.bold, 
            color: Colors.redAccent,
          ),
        ),
      ],
    );
  }
}