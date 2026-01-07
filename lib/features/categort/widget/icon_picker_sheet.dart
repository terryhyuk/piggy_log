import 'package:flutter/material.dart';
import 'package:piggy_log/features/categort/controller/category_icons.dart';
import 'package:piggy_log/l10n/app_localizations.dart';

// -----------------------------------------------------------------------------
//  * Refactoring Intent: 
//    Provides an optimized grid interface for category icon selection. 
//    Focuses on rendering performance and searchable state management.
//
//  * TODO: 
//    - Implement 'Debouncing' for the search filter to minimize UI rebuilds.
//    - Migrate icon metadata to a local JSON/Asset for better decoupling.
// -----------------------------------------------------------------------------

class IconPickerSheet extends StatefulWidget {
  const IconPickerSheet({super.key});

  @override
  State<IconPickerSheet> createState() => _IconPickerSheetState();
}

class _IconPickerSheetState extends State<IconPickerSheet> {
  late List<Map<String, dynamic>> allIcons;
  late List<Map<String, dynamic>> filteredIcons;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-loading icon collection for immediate display.
    allIcons = CategoryIcons.icons;
    filteredIcons = List.from(allIcons);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double sheetHeight = MediaQuery.of(context).size.height * 0.75;

    return Container(
      height: sheetHeight,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Row(
            children: [
              Text(
                AppLocalizations.of(context)!.searchIcons,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ) ?? const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.close, color: theme.colorScheme.onSurface),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Icon Grid: Uses Builder for efficient memory management via lazy loading.
          Expanded(
            child: GridView.builder(
              itemCount: filteredIcons.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, 
                childAspectRatio: 1,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                final iconData = filteredIcons[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context, iconData);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          iconData['icon'],
                          size: 26,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Filters the icon list based on user input.
  void filterIcons(String query) {
    filteredIcons = allIcons
        .where(
          (icon) => icon['name'].toString().toLowerCase().contains(
            query.toLowerCase(),
          ),
        )
        .toList();
    setState(() {});
  }
}