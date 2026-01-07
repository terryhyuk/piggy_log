import 'package:flutter/material.dart';
import 'package:get_x/get.dart';
import 'package:piggy_log/features/categort/controller/category.dart';
import 'package:piggy_log/l10n/app_localizations.dart';

class BuildHeader extends StatelessWidget {
  final Category category;
  final VoidCallback onAddTap;

  const BuildHeader({
    super.key,
    required this.category,
    required this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              SizedBox(
                width: 40,
                child: IconButton(
                  alignment: Alignment.centerLeft,
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                  onPressed: () => Get.back(),
                ),
              ),
              Expanded(
                child: Text(
                  category.c_name,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IntrinsicWidth(
                child: GestureDetector(
                  onTap: onAddTap,
                  child: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      '+ ${AppLocalizations.of(context)!.add}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}