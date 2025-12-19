import 'package:flutter/material.dart';
import 'package:get_x/get.dart';
import 'package:simple_spending_tracker/l10n/app_localizations.dart';
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
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              onPressed: () => Get.back(),
            ),

            const Spacer(),

            Expanded(
              child: Text(
                category.c_name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const Spacer(),

            GestureDetector(
              onTap: onAddTap,
              child: Text(
                '+ ${AppLocalizations.of(context)!.add}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
