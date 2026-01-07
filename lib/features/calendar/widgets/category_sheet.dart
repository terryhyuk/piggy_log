import 'package:flutter/material.dart';
import 'package:get_x/get.dart';
import 'package:piggy_log/core/db/category_handler.dart';
import 'package:piggy_log/features/settings/controller/setting_controller.dart';
import 'package:piggy_log/l10n/app_localizations.dart';
import 'package:piggy_log/features/categort/controller/category.dart';
import 'package:piggy_log/features/calendar/widgets/color_picker_sheet.dart';
import '../../categort/widget/icon_picker_sheet.dart';

// -----------------------------------------------------------------------------
//  * Refactoring Intent: 
//    Unified form for category orchestration. Enforces data integrity through 
//    pre-persistence validation and maintains a consistent visual language 
//    via centralized picker integrations.
//
//  * TODO: 
//    - Offload business logic (validation, DB calls) to a dedicated Controller 
//      to transform this into a pure 'Dumb Widget'.
//    - Implement a 'Debounced' duplicate check for real-time user feedback.
// -----------------------------------------------------------------------------

class CategorySheet extends StatefulWidget {
  final Map<String, dynamic>? initialData;

  const CategorySheet({super.key, this.initialData});

  @override
  State<CategorySheet> createState() => _CategoryEditSheetState();
}

class _CategoryEditSheetState extends State<CategorySheet> {
  late IconData selectedIcon = Icons.category;
  late Color selectedColor = Colors.grey;
  late TextEditingController cnameController = TextEditingController();
  late String selectedHexColor; 
  late AppLocalizations local;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    local = AppLocalizations.of(context)!;
  }

  @override
  void initState() {
    super.initState();

    selectedHexColor = selectedColor.toARGB32().toRadixString(16).padLeft(8, '0');

    if (widget.initialData != null) {
      cnameController.text = widget.initialData!['c_name'];
      selectedColor = Color(int.parse(widget.initialData!['color'], radix: 16));
      selectedHexColor = widget.initialData!['color'];

      // Reconstructing IconData from stored database metadata.
      selectedIcon = IconData(
        widget.initialData!['icon_codepoint'],
        fontFamily: widget.initialData!['icon_font_family'],
        fontPackage: widget.initialData!['icon_font_package'],
      );
    }
  }

  @override
  void dispose() {
    cnameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        // Handles layout adjustments when the software keyboard is active.
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: LayoutBuilder(
          builder: (context, constraints) {
            double maxW = constraints.maxWidth;
            double iconBox = maxW * 0.26;
            double iconSize = maxW * 0.13;
        
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.initialData == null ? local.addCategory : local.editCategory,
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700) ?? 
                           const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 22),
        
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final result = await showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (_) => const IconPickerSheet(),
                          );
                          if (result != null) {
                            setState(() => selectedIcon = result['icon']);
                          }
                        },
                        child: Container(
                          width: iconBox,
                          height: iconBox,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: theme.colorScheme.outline.withValues(alpha: 0.4),
                              width: 2,
                            ),
                          ),
                          child: selectedIcon == Icons.category
                              ? Icon(Icons.add, size: iconSize * 0.8, color: theme.colorScheme.onSurfaceVariant)
                              : Icon(selectedIcon, size: iconSize, color: selectedColor),
                        ),
                      ),
                      const SizedBox(width: 20),
        
                      Expanded(
                        child: TextField(
                          controller: cnameController,
                          decoration: InputDecoration(
                            labelText: local.categoryName,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          textInputAction: TextInputAction.done,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
        
                  GestureDetector(
                    onTap: () async {
                      final Color? picked = await showModalBottomSheet<Color>(
                        context: context,
                        backgroundColor: Colors.transparent,
                        builder: (_) => const ColorPickerSheet(),
                      );
                      if (picked != null) {
                        setState(() {
                          selectedColor = picked;
                          selectedHexColor = picked.toARGB32().toRadixString(16).padLeft(8, '0');
                        });
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(local.color, style: theme.textTheme.bodyMedium),
                        SizedBox(width: maxW * 0.07),
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
        
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.surfaceContainerHighest,
                          foregroundColor: theme.colorScheme.onSurface,
                        ),
                        child: Text(local.cancel),
                      ),
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

  /// Orchestrates validation and persistence logic for the category record.
  Future<void> saveCategory() async {
    final name = cnameController.text.trim();

    if (name.isEmpty) {
      showSnackBar("", local.pleaseEnterCategoryName, Colors.orange);
      return;
    }

    final allCategories = await CategoryHandler().getAllCategories();
  
    // Ensuring category names remain unique within the user's dataset.
    bool isDuplicate = allCategories.any((category) => 
      category.c_name == name && 
      (widget.initialData == null || category.id != widget.initialData!['id'])
    );

    if (isDuplicate) {
      showSnackBar("", local.categoryNameAlreadyExists, Colors.redAccent);
      return;
    }

    try {
      if (widget.initialData == null) {
        await addCategory();
        showSnackBar(local.categoryCreated, local.newCategoryAdded, Colors.green);
      } else {
        await editCategoryhistory();
        showSnackBar(local.categoryUpdated, local.changesSaved, Colors.blue);
      }
      
      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint("Database Error: Failed to save category: $e");
    }
  }

  /// Maps state to Category model and performs database insertion.
  Future<void> addCategory() async {
    final category = Category(
      iconCodePoint: selectedIcon.codePoint,
      iconFontFamily: selectedIcon.fontFamily,
      iconFontPackage: selectedIcon.fontPackage,
      color: selectedHexColor,
      c_name: cnameController.text.trim(),
    );

    await CategoryHandler().insertCategory(category);
    await Get.find<SettingController>().refreshAllData();
  }

  /// Maps state to Category model and performs database update.
  Future<void> editCategoryhistory() async {
    final category = Category(
      id: widget.initialData!['id'],
      iconCodePoint: selectedIcon.codePoint,
      iconFontFamily: selectedIcon.fontFamily,
      iconFontPackage: selectedIcon.fontPackage,
      color: selectedHexColor,
      c_name: cnameController.text.trim(),
    );

    await CategoryHandler().updateCategory(category);
    await Get.find<SettingController>().refreshAllData();
  }

  /// Displays consistent system-level feedback to the user.
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