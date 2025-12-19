import 'package:flutter/material.dart';
import 'package:piggy_log/l10n/app_localizations.dart';
import '../../model/category_colors.dart';
class ColorPickerSheet extends StatefulWidget {
  const ColorPickerSheet({super.key});

  @override
  State<ColorPickerSheet> createState() => _ColorPickerSheetState();
}

class _ColorPickerSheetState extends State<ColorPickerSheet> {
  late List<Color> palette;
  Color? selectedColor;

  @override
  void initState() {
    super.initState();
    palette = CategoryColors.palette;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double sheetHeight = MediaQuery.of(context).size.height * 0.45;

    return Container(
      height: sheetHeight,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ----- Header -----
          Row(
            children: [
              Text(
                AppLocalizations.of(context)!.selectColor,
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
                        color: isSelected 
                            ? theme.colorScheme.onSurface
                            : Colors.transparent,
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

  _onSelectColor(Color color) {
    selectedColor = color;
    setState(() {});
    Navigator.pop(context, color);
  }
}