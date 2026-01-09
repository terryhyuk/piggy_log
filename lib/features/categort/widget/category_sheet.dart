import 'package:flutter/material.dart';
import 'package:piggy_log/core/utils/app_snackbar.dart';
import 'package:piggy_log/providers/dashboard_provider.dart';
import 'package:provider/provider.dart';
import 'package:piggy_log/l10n/app_localizations.dart';
import 'package:piggy_log/features/categort/widget/color_picker_sheet.dart';
import 'package:piggy_log/providers/settings_provider.dart';
import 'package:piggy_log/providers/category_provider.dart';
import 'package:piggy_log/data/models/category_model.dart';
import 'icon_picker_sheet.dart';

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
  String selectedHexColor = 'ff9e9e9e';
  late AppLocalizations local;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    local = AppLocalizations.of(context)!;
  }

@override
  void initState() {
    super.initState();

    // [Init] Setting default hex color value (ARGB format)
    selectedColor = Color(int.parse(selectedHexColor, radix: 16));
    if (widget.initialData != null) {
      // [Update Mode] Data recovery from existing category metadata
      cnameController.text = widget.initialData!['name'] ?? '';
      
      // [Crucial] Parse hex string back to Color object with radix 16
      selectedHexColor = widget.initialData!['color'];
      selectedColor = Color(int.parse(selectedHexColor, radix: 16));

      // Reconstructing IconData from database metadata
      selectedIcon = IconData(
        widget.initialData!['icon_codepoint'],
        fontFamily: widget.initialData!['icon_font_family'],
        fontPackage: widget.initialData!['icon_font_package'],
      );
    }else{
      selectedHexColor = selectedColor.toARGB32().toRadixString(16);
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
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
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
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 22),

                  Row(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final result = await showModalBottomSheet<Map<String, dynamic>>(
                            context: context,
                            isScrollControlled: true,
                            builder: (_) => const IconPickerSheet(),
                          );
                          
                          if (result != null) {
                            // Reconstruct IconData from returned metadata 
                            selectedIcon = IconData(
                              result['icon_codepoint'],
                              fontFamily: result['icon_font_family'],
                              fontPackage: result['icon_font_package'],
                            );
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
                              color: theme.colorScheme.outline.withValues(alpha: 0.4),
                              width: 2,
                            ),
                          ),
                          child: selectedIcon == Icons.category
                              ? Icon(
                                  Icons.add,
                                  size: iconSize * 0.8,
                                  color: theme.colorScheme.onSurfaceVariant,
                                )
                              : Icon(
                                  selectedIcon,
                                  size: iconSize,
                                  color: selectedColor,
                                ),
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
                        selectedColor = picked;
                        selectedHexColor = picked.toARGB32().toRadixString(16).padLeft(8, '0');
                        setState(() {});
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

  Future<void> saveCategory() async {
    final name = cnameController.text.trim();
    final categoryProvider = context.read<CategoryProvider>();
    final settings = context.read<SettingProvider>();
    final dashProvider = context.read<DashboardProvider>();

    if (name.isEmpty) {
      AppSnackBar.show(context, local.pleaseEnterCategoryName, isError: true);
      return;
    }

    bool isDuplicate = categoryProvider.categories.any(
      (c) => c.name == name && (widget.initialData == null || c.id != widget.initialData!['id']),
    );

    if (isDuplicate) {
      AppSnackBar.show(context, local.categoryNameAlreadyExists, isError: true);
      return;
    }

    // [Mapping] Construct CategoryModel
    final newCategory = CategoryModel(
      id: widget.initialData?['id'], 
      name: name,
      iconCodePoint: selectedIcon.codePoint,
      iconFontFamily: selectedIcon.fontFamily,
      iconFontPackage: selectedIcon.fontPackage,
      color: selectedHexColor,
    );

    if (widget.initialData == null) {
      await categoryProvider.addCategory(newCategory);
      // Success snackbar
      if (mounted) AppSnackBar.show(context, local.categoryCreated);
    } else {
      await categoryProvider.updateCategory(newCategory);
      // Success snackbar
      if (mounted) AppSnackBar.show(context, local.categoryUpdated);
    }

    await settings.refreshAllData(dashboardProvider: dashProvider);

    if (mounted) Navigator.pop(context);
  }
}