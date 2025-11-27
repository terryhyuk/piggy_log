import 'package:flutter/material.dart';
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
  late TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load existing category data (edit mode)
    if (widget.initialData != null) {
      nameController.text = widget.initialData!['name'];
      selectedColor = Color(int.parse(widget.initialData!['color']));
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
                const Text(
                  "Add Category",
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
                          setState(() => selectedIcon = result['icon']);
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
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    // --- Category Name Input ---
                    Expanded(
                      child: TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: "Category Name",
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Color", style: TextStyle(fontSize: 16)),
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
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    // Save
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, {
                          'name': nameController.text,
                          'icon': selectedIcon,
                          'color': selectedColor.toString(),
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                      ),
                      child: const Text("Save"),
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
  addCategory(){
    //
  }

}// END
