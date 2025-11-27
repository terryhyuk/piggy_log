import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../model/category_icons.dart';

class IconPickerSheet extends StatefulWidget {
  const IconPickerSheet({super.key});

  @override
  State<IconPickerSheet> createState() => _IconPickerSheetState();
}

class _IconPickerSheetState extends State<IconPickerSheet> {
  // The full list of icons the user can choose from
  late List<Map<String, dynamic>> allIcons;

  // The list of icons after applying the search filter
  late List<Map<String, dynamic>> filteredIcons;

  // Controller for the search text field
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    // Load icons from CategoryIcons
    allIcons = CategoryIcons.icons;

    // Start with all icons visible
    filteredIcons = List.from(allIcons);
    super.initState();
  }

  /// Filters the icon list whenever the user types in the search box

  @override
  Widget build(BuildContext context) {
    // Bottom sheet takes up 75% of the screen height
    final double sheetHeight = MediaQuery.of(context).size.height * 0.75;

    return Container(
      height: sheetHeight,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        // Rounded top corners for the bottom sheet look
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------- Header ----------
          Row(
            children: [
              const Text(
                "Select Icon",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              // Close button (X)
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ---------- Search Bar ----------
          TextField(
            controller: searchController,
            onChanged: filterIcons, // Real-time filtering
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: "Search icons",
              filled: true,
              fillColor: Colors.grey.shade100,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ---------- Icon Grid ----------
          Expanded(
            child: GridView.builder(
              itemCount: filteredIcons.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, // 4 icons per row
                childAspectRatio: 1, // Square cells
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),

              itemBuilder: (context, index) {
                final iconData = filteredIcons[index];

                return GestureDetector(
                  onTap: () {
                    // Return the selected icon back to the caller
                    Navigator.pop(context, iconData);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Circular icon background
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          iconData['icon'],
                          size: 26,
                          color: Colors.black87,
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

  // --- Functions ---
  filterIcons(String query) {
    filteredIcons = allIcons
        .where(
          (icon) => icon['name'].toString().toLowerCase().contains(
            query.toLowerCase(),
          ),
        )
        .toList();
    setState(() {});
  }
} // END
