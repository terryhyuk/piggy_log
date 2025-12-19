import 'package:flutter/material.dart';
import 'package:get_x/get.dart';
import 'package:simple_spending_tracker/VM/category_handler.dart';
import 'package:simple_spending_tracker/controller/calendar_Controller.dart';
import 'package:simple_spending_tracker/controller/category_Controller.dart';
import 'package:simple_spending_tracker/controller/dashboard_Controller.dart';
import 'package:simple_spending_tracker/controller/setting_Controller.dart';
import 'package:simple_spending_tracker/controller/tabbar_controller.dart';
import 'package:simple_spending_tracker/l10n/app_localizations.dart';
import 'package:simple_spending_tracker/model/category.dart';
import 'package:simple_spending_tracker/view/pages/transactions_history.dart';
import 'package:simple_spending_tracker/view/widget/button_widget.dart';
import 'package:simple_spending_tracker/view/widget/category_card.dart';
import 'package:simple_spending_tracker/view/widget/category_sheet.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  // Properties
  final CategoryHandler categoryHandler = CategoryHandler();
  final TabbarController tabController = Get.find<TabbarController>();

  // 1. categories 리스트는 StatefulWidget 로컬 상태(List<Category>)로 복원합니다.
  List<Category> categories = [];

  // 로컬 isEditMode 변수는 제거하고, TabbarController의 상태를 사용합니다.

  // 다른 컨트롤러들을 미리 찾아서 로직에 사용합니다.
  final dashboardController = Get.find<DashboardController>();
  final calController = Get.find<CalendarController>();
  final settingsController = Get.find<SettingsController>();
  final categoryController = Get.find<CategoryController>();

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Exit edit mode when tapping outside
      onTap: () {
        // TabbarController의 상태를 확인하고 변경합니다.
        // 이 변경은 아래 GridView 내부의 Obx를 트리거합니다.
        if (tabController.isCategoryEditMode.value) {
          tabController.isCategoryEditMode.value = false;
        }
      },
      // 2. Scaffold 전체를 감싸던 Obx를 제거합니다.
      child: Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.categories)),
        body: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: categories.length + 1, // categories 로컬 상태 사용
          itemBuilder: (context, index) {
            // Add Category button
            if (index == 0) {
              return ButtonWidget(onTap: _openCategorySheet);
            }

            final category = categories[index - 1];

            // 3. Obx를 CategoryCard만 감싸도록 최소화하여 GetX 오류를 피합니다.
            // -> isCategoryEditMode.value의 변화에만 반응합니다.
            return Obx(() {
              final bool currentIsEditMode =
                  tabController.isCategoryEditMode.value;

              return CategoryCard(
                category: category,
                // Obx 내부에서 구독하는 상태를 전달합니다.
                isEditMode: currentIsEditMode,

                // Normal tap → open edit sheet
                onTap: () {
                  // 편집 모드가 아닐 때만 이동
                  if (!currentIsEditMode) {
                    Get.to(() => TransactionsHistory(), arguments: category);
                  }
                },
                // Long press → enter edit mode
                onLongPress: () {
                  // GetX 상태 변경만 합니다.
                  tabController.isCategoryEditMode.value = true;
                  // setState()는 필요 없습니다. Obx가 알아서 CategoryCard를 업데이트합니다.
                },
                // Edit button
                onEditPress: () {
                  _openCategorySheet(category: category);
                },
                // Delete button
                onDeletePress: () {
                  _openDeleteDialog(category);
                },
              );
            });
          },
        ),
      ),
    );
  }

  // Load categories from database
  _loadCategories() async {
    final list = await categoryHandler.queryCategory();
    // 4. categories 업데이트는 StatefulWidget의 setState()를 사용합니다.
    categories = list;
    setState(() {});
  }

  // Open bottom sheet for creating or editing categories
  _openCategorySheet({Category? category}) {
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
    ).then(
      (_) => _loadCategories(),
    ); // 카테고리 추가/수정 후 setState()를 포함한 _loadCategories 호출
  }

  _openDeleteDialog(Category category) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteCategory),
        content: Text(
          "${AppLocalizations.of(context)!.delete} '${category.c_name}'?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () async {
              // 1. DB에서 카테고리 삭제
              await categoryHandler.deleteCategory(category.id!);

              // 2. 현재 페이지의 카테고리 목록(List) 업데이트
              _loadCategories();

              // 3. ✅ 핵심: 모든 컨트롤러 싹 다 새로고침 (SettingsController에 만든 함수)
              await settingsController.refreshAllData();
              // 4. (추가로 필요한 경우에만 유지)
              categoryController.notifyChange();

              Navigator.pop(context); // 다이얼로그 닫기

              // 스낵바 알림
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
} // END
