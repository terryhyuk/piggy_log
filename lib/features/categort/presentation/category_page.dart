

// -----------------------------------------------------------------------------
//  * Refactoring Intent: 
//    Managing the spending category grid. This page handles dynamic list 
//    sorting, global edit-mode transitions via GetX, and ensures data 
//    consistency across the dashboard through forced refreshes after deletion.
// -----------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:get_x/get.dart';
import 'package:piggy_log/features/categort/controller/category_controller.dart';
import 'package:piggy_log/features/settings/controller/setting_controller.dart';
import 'package:piggy_log/core/controller/tabbar_controller.dart';
import 'package:piggy_log/core/db/category_handler.dart';
import 'package:piggy_log/features/calendar/widgets/category_sheet.dart';
import 'package:piggy_log/features/categort/controller/category.dart';
import 'package:piggy_log/features/categort/widget/button_widget.dart';
import 'package:piggy_log/features/categort/widget/category_card.dart';
import 'package:piggy_log/features/transaction/presentation/transactions_history.dart';
import 'package:piggy_log/l10n/app_localizations.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final CategoryHandler categoryHandler = CategoryHandler();
  final TabbarController tabController = Get.find<TabbarController>();

  // Local state to manage the category list for fast UI updates.
  List<Category> categories = [];

  final settingsController = Get.find<SettingController>();
  final categoryController = Get.find<CategoryController>();

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // UX: Exit edit mode automatically when tapping outside of action cards.
      onTap: () {
        if (tabController.isCategoryEditMode.value) {
          tabController.isCategoryEditMode.value = false;
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.categories)),
        body: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: categories.length + 1, 
          itemBuilder: (context, index) {
            // Index 0 is reserved for the 'Add Category' trigger button.
            if (index == 0) {
              return ButtonWidget(onTap: _openCategorySheet);
            }

            // Offset by 1 to map the remaining grid items to the category list.
            final category = categories[index - 1];

            return Obx(() {
              final bool currentIsEditMode = tabController.isCategoryEditMode.value;

              return CategoryCard(
                category: category,
                isEditMode: currentIsEditMode,
                onTap: () {
                  if (!currentIsEditMode) {
                    Get.to(() => const TransactionsHistory(), arguments: category);
                  }
                },
                onLongPress: () {
                  tabController.isCategoryEditMode.value = true;
                },
                onEditPress: () => _openCategorySheet(category: category),
                onDeletePress: () => _openDeleteDialog(category),
              );
            });
          },
        ),
      ),
    );
  }

  /// Fetches category records from the database and updates the local state.
  Future<void> _loadCategories() async {
    final list = await categoryHandler.queryCategory();
    
    // sorting logic: Ensure that the 'categories' reflect the order from the DB.
    categories = list;
    
    if (mounted) {
      setState(() {});
    }
  }

  /// Displays the BottomSheet for either creating a new category or editing an existing one.
  void _openCategorySheet({Category? category}) {
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
    ).then((_) {
      _loadCategories();
    });
  }

  /// Confirmation dialog for permanent category deletion.
  void _openDeleteDialog(Category category) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteCategory),
        content: Text("${AppLocalizations.of(context)!.delete} '${category.c_name}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () async {
              await categoryHandler.deleteCategory(category.id!);
              _loadCategories();
              
              // Multi-Controller Sync: Updates total budget and UI triggers across the app.
              await settingsController.refreshAllData();
              categoryController.notifyChange();

              if (mounted) Navigator.pop(context);

              Get.snackbar(
                AppLocalizations.of(context)!.deleteCategory,
                "${AppLocalizations.of(context)!.delete} '${category.c_name}'",
                snackPosition: SnackPosition.top,
                backgroundColor: Theme.of(context).colorScheme.errorContainer,
                colorText: Theme.of(context).colorScheme.onErrorContainer,
                duration: const Duration(seconds: 1),
              );
            },
            child: Text(
              AppLocalizations.of(context)!.delete,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}