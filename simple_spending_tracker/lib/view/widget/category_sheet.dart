import 'package:flutter/material.dart';
import 'package:get_x/get.dart';
import 'package:simple_spending_tracker/VM/category_handler.dart';
import 'package:simple_spending_tracker/controller/setting_Controller.dart';
import 'package:simple_spending_tracker/l10n/app_localizations.dart';
import 'package:simple_spending_tracker/model/category.dart';
import 'package:simple_spending_tracker/view/widget/color_picker_sheet.dart';
import 'icon_picker_sheet.dart';

/// CategorySheet
/// Responsive bottom sheet used for creating or editing a category.
/// Uses LayoutBuilder for adaptive sizing on iOS/Android devices.
class CategorySheet extends StatefulWidget {
  final Map<String, dynamic>? initialData;

  const CategorySheet({super.key, this.initialData});

  @override
  State<CategorySheet> createState() => _CategoryEditSheetState();
}

class _CategoryEditSheetState extends State<CategorySheet> {
  // Property
  late IconData selectedIcon = Icons.category;
  late Color selectedColor = Colors.grey;
  late TextEditingController c_nameController = TextEditingController();
  late String selectedHexColor; // For saving to DB

  @override
  void initState() {
    super.initState();

    // Always create initial hex color
    selectedHexColor = selectedColor.value.toRadixString(16).padLeft(8, '0');
    // Load existing category data (edit mode)
    if (widget.initialData != null) {
      c_nameController.text = widget.initialData!['c_name'];
      selectedColor = Color(int.parse(widget.initialData!['color'], radix: 16));

      selectedHexColor = selectedColor.value
          .toRadixString(16)
          .padLeft(8, '0'); // ← for saving to DB

      selectedIcon = IconData(
        widget.initialData!['icon_codepoint'],
        fontFamily: widget.initialData!['icon_font_family'],
        fontPackage: widget.initialData!['icon_font_package'],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      // prevent overlap with iPhone bottom area
      top: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          double maxW = constraints.maxWidth;
          // Responsive icon box size
          double iconBox = maxW * 0.26;
          double iconSize = maxW * 0.13;
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ---------- Header ----------
                Text(
                  widget.initialData == null ? AppLocalizations.of(context)!.addCategory : AppLocalizations.of(context)!.editCategory,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 22),
                // ---------- Icon + Name ----------
                Row(
                  children: [
                    // --- Icon Box (Square) ---
                    GestureDetector(
                      onTap: () async {
                        final result = await showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (_) => const IconPickerSheet(),
                        );
                        if (result != null) {
                          selectedIcon = result['icon'];
                          setState(() {});
                        }
                      },
                      child: Container(
                        width: iconBox,
                        height: iconBox,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(
                          selectedIcon,
                          size: iconSize,
                          color: selectedColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    // --- Category Name Input ---
                    Expanded(
                      child: TextField(
                        controller: c_nameController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.categoryName,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // ---------- Color Row ----------
                GestureDetector(
                  onTap: () async {
                    final Color? picked = await showModalBottomSheet<Color>(
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (_) => const ColorPickerSheet(),
                    );
                    if (picked != null) {
                      selectedColor = picked;
                      selectedHexColor = picked.value
                          .toRadixString(16)
                          .padLeft(8, '0');
                      setState(() {});
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        Text(
                          AppLocalizations.of(context)!.color, 
                          style: TextStyle(
                            fontSize: 16)),
                      SizedBox(width: maxW * 0.07), // responsive spacing
                      // --- Color Preview Circle ---
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
                // ---------- Buttons ----------
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Cancel
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade300,
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.cancel,
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    // Save
                    ElevatedButton(
                      onPressed: () {
                        if (widget.initialData == null) {
                          addCategory(); // add new category
                          showSnackBar(AppLocalizations.of(context)!.categoryCreated, AppLocalizations.of(context)!.newCategoryAdded, Colors.green);
                        } else {
                          editCategory_history(); // Update category
                          showSnackBar(AppLocalizations.of(context)!.categoryUpdated, AppLocalizations.of(context)!.changesSaved, Colors.blue);
                        } Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                      ),
                      child: Text(AppLocalizations.of(context)!.save),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  //--- Fuunctions---
  // 1. 추가(addCategory) 함수 수정
addCategory() async {
  Category category = Category(
    iconCodePoint: selectedIcon.codePoint,
    iconFontFamily: selectedIcon.fontFamily,
    iconFontPackage: selectedIcon.fontPackage,
    color: selectedHexColor,
    c_name: c_nameController.text,
  );
  
  // DB 저장
  await CategoryHandler().insertCategory(category);
  
  // ✅ 모든 페이지 데이터 일괄 갱신
  await Get.find<SettingsController>().refreshAllData();
}

// 2. 수정(editCategory_history) 함수 수정
editCategory_history() async {
  Category category = Category(
    id: widget.initialData!['id'],
    iconCodePoint: selectedIcon.codePoint,
    iconFontFamily: selectedIcon.fontFamily,
    iconFontPackage: selectedIcon.fontPackage,
    color: selectedHexColor,
    c_name: c_nameController.text,
  );
  
  // DB 업데이트
  await CategoryHandler().updateCategory(category);
  
  // ✅ 모든 페이지 데이터 일괄 갱신
  await Get.find<SettingsController>().refreshAllData();
}
  // addCategory() async {
  //   Category category = Category(
  //     iconCodePoint: selectedIcon.codePoint,
  //     iconFontFamily: selectedIcon.fontFamily,
  //     iconFontPackage: selectedIcon.fontPackage,
  //     color: selectedHexColor,
  //     c_name: c_nameController.text,
  //   );
  //   await CategoryHandler().insertCategory(category);
  // }

  // editCategory_history() async {
  //   // update category
  //   Category category = Category(
  //     id: widget.initialData!['id'],
  //     iconCodePoint: selectedIcon.codePoint,
  //     iconFontFamily: selectedIcon.fontFamily,
  //     iconFontPackage: selectedIcon.fontPackage,
  //     color: selectedHexColor,
  //     c_name: c_nameController.text,
  //   );
  //   await CategoryHandler().updateCategory(category);
  // }

  // deleteCategory_history() async {
  //   await CategoryHandler().deleteCategory(widget.initialData!['id']);
  //   final settingsController = Get.find<SettingsController>();
  //   settingsController.refreshTrigger.value++;

  // }


  showSnackBar(title, message, Color bgColor) {
  Get.snackbar(
    title,
    message,
    snackPosition: SnackPosition.top,
    duration: const Duration(seconds: 2),
    backgroundColor: bgColor,
    colorText: Colors.white,   // text color
  );
}

} // END
