import 'package:flutter/material.dart';
import 'package:piggy_log/core/utils/app_snackbar.dart';
import 'package:piggy_log/features/categort/widget/category_sheet.dart';
import 'package:piggy_log/features/record/presentation/records_history.dart';
import 'package:piggy_log/providers/record_provider.dart';
import 'package:provider/provider.dart';
import 'package:piggy_log/l10n/app_localizations.dart';
import 'package:piggy_log/providers/category_provider.dart';
import 'package:piggy_log/data/models/category_model.dart';
import 'package:piggy_log/features/categort/widget/category_card.dart';
import 'package:piggy_log/features/categort/widget/button_widget.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().fetchCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();
    final l10n = AppLocalizations.of(context)!;
    final bool isEditMode = categoryProvider.isEditMode;
    final List<CategoryModel> categories = categoryProvider.categories;

    return GestureDetector(
      onTap: () => categoryProvider.setEditModeFalse(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.categories),
          actions: [
            if (isEditMode)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: TextButton(
                  onPressed: () => categoryProvider.setEditModeFalse(),
                  child: Text(
                    l10n.done,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
        body: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: categories.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return ButtonWidget(onTap: () => _openCategorySheet(context));
            }

            final category = categories[index - 1];

            return CategoryCard(
              category: category,
              isEditMode: isEditMode,
              onTap: () {
                if (!isEditMode) {
                  final recordProvider = context.read<RecordProvider>();
                  Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder: (context) => ChangeNotifierProvider.value(
                        value: recordProvider,
                        child: const TransactionsHistory(),
                      ),
                      settings: RouteSettings(arguments: category),
                    ),
                  );
                } else {
                  categoryProvider.setEditModeFalse();
                }
              },
              onLongPress: () => categoryProvider.toggleEditMode(),
              onEditPress: () => _openCategorySheet(context, category: category),
              onDeletePress: () => _openDeleteDialog(context, category),
            );
          },
        ),
      ),
    );
  }

  void _openCategorySheet(BuildContext context, {CategoryModel? category}) {
    context.read<CategoryProvider>().setEditModeFalse();
    final Map<String, dynamic>? data = category == null
        ? null
        : {
            'id': category.id,
            'name': category.name,
            'icon_codepoint': category.iconCodePoint,
            'icon_font_family': category.iconFontFamily,
            'icon_font_package': category.iconFontPackage,
            'color': category.color,
          };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => CategorySheet(initialData: data),
    );
  }

  void _openDeleteDialog(BuildContext context, CategoryModel category) {
    final l10n = AppLocalizations.of(context)!;
    final categoryProvider = context.read<CategoryProvider>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteCategory),
        content: Text(l10n.deleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              if (category.id != null) {
                // Perform deletion via Provider
                await categoryProvider.deleteCategory(context, category.id!);

                if (ctx.mounted) Navigator.pop(ctx);
                
                // Show floating SnackBar after deletion
                if (context.mounted) {
                  AppSnackBar.show(
                    context, 
                    "${category.name} ${l10n.wasRemoved}", 
                    isError: true
                  );
                }
              }
            },
            child: Text(
              l10n.delete,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

}// END