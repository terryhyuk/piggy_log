import 'package:flutter/material.dart';
import 'package:simple_spending_tracker/VM/category_handler.dart';
import 'package:simple_spending_tracker/view/widget/button_widget.dart';
import 'package:simple_spending_tracker/view/widget/category_sheet.dart';
import 'package:simple_spending_tracker/view/widget/category_card.dart';

import '../model/category.dart';

class Transactions extends StatefulWidget {
  const Transactions({super.key});

  @override
  State<Transactions> createState() => _TransactionsState();
}

class _TransactionsState extends State<Transactions> {
  // Properties
  final CategoryHandler categoryHandler = CategoryHandler();
  List<Category> categories = [];
  bool isEditMode = false;

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Exit edit mode when tapping outside
      onTap: () {
        if (isEditMode) {
          isEditMode = false;
          setState(() {});
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Transaction',
            ),
          ),
        body: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: categories.length + 1, // +1 for Add button
          itemBuilder: (context, index) {
            // Add Category button
            if (index == 0) {
              return ButtonWidget(onTap: openCategorySheet);
            }

            final category = categories[index - 1];

            return CategoryCard(
              category: category,
              isEditMode: isEditMode,
              // Normal tap → open edit sheet
              onTap: () {
                if (!isEditMode) {
                  openCategorySheet(category: category);
                }
              },
              // Long press → enter edit mode
              onLongPress: () {
                isEditMode = true;
                setState((){});
              },
              // Edit button (currently placeholder)
              onEditPress: () {
                // TODO: Connect edit functionality
              },
              // Delete button (currently placeholder)
              onDeletePress: () {
                // TODO: Connect delete functionality
              },
            );
          },
        ),
      ),
    );
  }

  // Load categories from database
  loadCategories() async {
    final list = await categoryHandler.queryCategory();
    categories = list;
    setState(() {});
  }

  // Open bottom sheet for creating or editing categories
  openCategorySheet({Category? category}) {
    final Map<String, dynamic>? data = category == null
        ? null
        : {
            'id': category.id,
            'c_name': category.c_name,
            'icon_codepoint': category.iconCodePoint,
            'icon_font_family': category.iconFontFamily,
            'icon_font_package': category.iconFontPackage,
            'color': category.color,
          };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => CategorySheet(initialData: data),
    ).then((_) => loadCategories());
  }
}// END
