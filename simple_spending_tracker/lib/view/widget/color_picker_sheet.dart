import 'package:flutter/material.dart';
import '../../model/category_colors.dart';

class ColorPickerSheet extends StatefulWidget {
  const ColorPickerSheet({super.key});

  @override
  State<ColorPickerSheet> createState() => _ColorPickerSheetState();
}

class _ColorPickerSheetState extends State<ColorPickerSheet> {
  // Property
  late List<Color> palette;
  Color? selectedColor;

  @override
  void initState() {
    super.initState();
    palette = CategoryColors.palette;
  }

  @override
  Widget build(BuildContext context) {
    final double sheetHeight = MediaQuery.of(context).size.height * 0.45;

    return Container(
      height: sheetHeight,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ----- Header -----
          Row(
            children: [
              const Text(
                "Select Color",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: 16),

          /// ----- Grid of Colors -----
          Expanded(
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: palette.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
              ),
              itemBuilder: (context, index) {
                final Color color = palette[index];
                final bool isSelected = selectedColor == color;
                return GestureDetector(
                  onTap: () => _onSelectColor(color),
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.transparent,
                        width: 2.4,
                      ),
                    ),
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
  /// Handle color tap
    _onSelectColor(Color color) {
    selectedColor = color;
    setState(() {});
    /// Return selected color and close sheet
    Navigator.pop(context, color);
  }

  
}// END
