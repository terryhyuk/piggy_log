import 'package:flutter/material.dart';
import 'package:get_x/get.dart';
import 'package:piggy_log/VM/category_handler.dart';
import 'package:piggy_log/controller/setting_controller.dart';
import 'package:piggy_log/l10n/app_localizations.dart';
import 'package:piggy_log/model/category.dart';
import 'package:piggy_log/view/widget/color_picker_sheet.dart';
import 'icon_picker_sheet.dart';

// --------------------------------------------------------------
//  * CategorySheet - Category Creation & Edition Bottom Sheet
//  * * A responsive UI component for managing expense categories.
//  * - Icon selection via IconPickerSheet
//  * - Color selection via ColorPickerSheet
//  * - Category name input with validation
//  * - Cross-platform responsive layout (iOS/Android/Tablet)
//  * - Dynamic theme support (Light/Dark mode)
//  --------------------------------------------------------------

class CategorySheet extends StatefulWidget {
  final Map<String, dynamic>? initialData;

  const CategorySheet({super.key, this.initialData});

  @override
  State<CategorySheet> createState() => _CategoryEditSheetState();
}

class _CategoryEditSheetState extends State<CategorySheet> {
  /// Properties for managing category state
  late IconData selectedIcon = Icons.category;
  late Color selectedColor = Colors.grey;
  late TextEditingController c_nameController = TextEditingController();
  late String selectedHexColor; // For DB storage in Hex format

  @override
  void initState() {
    super.initState();

    /// Initialize default hex color and load existing data if in Edit Mode
    selectedHexColor = selectedColor.value.toRadixString(16).padLeft(8, '0');

    if (widget.initialData != null) {
      /// Edit Mode: Populating existing data into fields
      c_nameController.text = widget.initialData!['c_name'];
      selectedColor = Color(int.parse(widget.initialData!['color'], radix: 16));
      selectedHexColor = selectedColor.value.toRadixString(16).padLeft(8, '0');

      selectedIcon = IconData(
        widget.initialData!['icon_codepoint'],
        fontFamily: widget.initialData!['icon_font_family'],
        fontPackage: widget.initialData!['icon_font_package'],
      );
    }
  }

  @override
  void dispose() {
    /// Clean up controller to prevent memory leaks
    c_nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final local = AppLocalizations.of(context)!;

    return SafeArea(
      /// Prevents UI overlap with iOS bottom home indicator
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: LayoutBuilder(
          /// Calculating responsive sizes for cross-device compatibility
          builder: (context, constraints) {
            double maxW = constraints.maxWidth;
            double iconBox = maxW * 0.26;  /// Responsive container size
            double iconSize = maxW * 0.13;
        
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(22),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// ---------- Header ----------
                  Text(
                    widget.initialData == null
                        ? local.addCategory      /// "Add Category"
                        : local.editCategory,    /// "Edit Category"
                    style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ) ?? const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 22),
        
                  /// ---------- Icon & Name Input Section ----------
                  Row(
                    children: [
                      /// Icon Selection Trigger (Displays '+' by default)
                      GestureDetector(
                        onTap: () async {
                          final result = await showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (_) => const IconPickerSheet(),
                          );
                          if (result != null) {
                              /// Update UI with the selected icon
                              selectedIcon = result['icon'];
                            setState(() {});
                          }
                        },
                        child: Container(
                          width: iconBox,
                          height: iconBox,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: theme.colorScheme.outline.withOpacity(0.4),
                              width: 2,
                            ),
                          ),
                          child: selectedIcon == Icons.category
                              ? Icon(
                                  Icons.add, // Placeholder '+' icon
                                  size: iconSize * 0.8,
                                  color: theme.colorScheme.onSurfaceVariant,
                                )
                              : Icon(
                                  selectedIcon, // Selected category icon
                                  size: iconSize,
                                  color: selectedColor,
                                ),
                        ),
                      ),
                      const SizedBox(width: 20),
        
                      /// Category Name TextField
                      Expanded(
                        child: TextField(
                          controller: c_nameController,
                          decoration: InputDecoration(
                            labelText: local.categoryName,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
        
                  /// ---------- Color Picker Section ----------
                  GestureDetector(
                    onTap: () async {
                      final Color? picked = await showModalBottomSheet<Color>(
                        context: context,
                        backgroundColor: Colors.transparent,
                        builder: (_) => const ColorPickerSheet(),
                      );
                      if (picked != null) {
                        setState(() {
                          /// Sync selected color and generate Hex string
                          selectedColor = picked;
                          selectedHexColor = picked.value
                              .toRadixString(16)
                              .padLeft(8, '0');
                        });
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(local.color, style: theme.textTheme.bodyMedium),
                        SizedBox(width: maxW * 0.07),
                        /// Color Preview Circle
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: selectedColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 38),
        
                  /// ---------- Action Buttons ----------
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      /// Cancel Action
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.surfaceContainerHighest,
                          foregroundColor: theme.colorScheme.onSurface,
                        ),
                        child: Text(local.cancel),
                      ),
        
                      /// Save Action (Create or Update)
                      ElevatedButton(
                        onPressed: saveCategory,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: theme.colorScheme.onPrimary,
                          backgroundColor: theme.colorScheme.primary,
                        ),
                        child: Text(local.save),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Handles category persistence and provides UI feedback
  Future<void> saveCategory() async {
    /// Basic validation for category name
    final local = AppLocalizations.of(context)!;
    final name = c_nameController.text.trim();

    if(name.isEmpty){
      showSnackBar(
        "",
        local.pleaseEnterCategoryName, 
        Colors.orange,
        );
        return;
    }


    if (widget.initialData == null) {
      /// Logic for creating a new category
      await addCategory();
      showSnackBar(local.categoryCreated, local.newCategoryAdded, Colors.green);
    } else {
      /// Logic for updating existing category history
      await editCategory_history();
      showSnackBar(local.categoryUpdated, local.changesSaved, Colors.blue);
    }

    Navigator.pop(context);
  }

  /// Persists a new category record to the database
  Future<void> addCategory() async {
    final category = Category(
      iconCodePoint: selectedIcon.codePoint,
      iconFontFamily: selectedIcon.fontFamily,
      iconFontPackage: selectedIcon.fontPackage,
      color: selectedHexColor,
      c_name: c_nameController.text.trim(),
    );

    await CategoryHandler().insertCategory(category);
    await Get.find<SettingsController>().refreshAllData();
  }

  /// Updates an existing category record in the database
  Future<void> editCategory_history() async {
    final category = Category(
      id: widget.initialData!['id'],
      iconCodePoint: selectedIcon.codePoint,
      iconFontFamily: selectedIcon.fontFamily,
      iconFontPackage: selectedIcon.fontPackage,
      color: selectedHexColor,
      c_name: c_nameController.text.trim(),
    );

    await CategoryHandler().updateCategory(category);
    await Get.find<SettingsController>().refreshAllData();
  }

  /// Global Snackbar for user action feedback
  void showSnackBar(String title, String message, Color bgColor) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.top,
      duration: const Duration(seconds: 2),
      backgroundColor: bgColor,
      colorText: Colors.white,
    );
  }
}