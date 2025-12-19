import 'package:flutter/material.dart';
import 'package:get_x/get.dart';
import 'package:piggy_log/VM/category_handler.dart';
import 'package:piggy_log/controller/setting_Controller.dart';
import 'package:piggy_log/l10n/app_localizations.dart';
import 'package:piggy_log/model/category.dart';
import 'package:piggy_log/view/widget/color_picker_sheet.dart';
import 'icon_picker_sheet.dart';

/**
 * CategorySheet - Category Add/Edit Bottom Sheet
 * 
 * Responsive bottom sheet for adding or editing categories in the allowance tracker app.
 * - Icon selection (calls IconPickerSheet)
 * - Color selection (calls ColorPickerSheet)
 * - Category name input
 * - iOS/Android responsive layout (uses LayoutBuilder)
 * - Full dark/light mode support
 * 
 * Usage:
 * Get.bottomSheet(CategorySheet());                    // Add new category
 * Get.bottomSheet(CategorySheet(initialData: data));  // Edit existing category
 */


/// CategorySheet
/// Responsive bottom sheet for creating/editing categories.
/// Icon picker maintained (search will be removed from IconPickerSheet).
class CategorySheet extends StatefulWidget {
  final Map<String, dynamic>? initialData;

  const CategorySheet({super.key, this.initialData});

  @override
  State<CategorySheet> createState() => _CategoryEditSheetState();
}

class _CategoryEditSheetState extends State<CategorySheet> {
  /// 카테고리 편집 상태 변수들
  late IconData selectedIcon = Icons.category;
  late Color selectedColor = Colors.grey;
  late TextEditingController c_nameController = TextEditingController();
  late String selectedHexColor; // For saving to DB

  @override
  void initState() {
    super.initState();

    /// 초기 hex 색상 생성 / 기존 카테고리 데이터 로드 (편집 모드)
    selectedHexColor = selectedColor.value.toRadixString(16).padLeft(8, '0');

    if (widget.initialData != null) {
      /// 편집 모드: 기존 데이터 로드
      c_nameController.text = widget.initialData!['c_name'];
      selectedColor = Color(int.parse(widget.initialData!['color'], radix: 16));
      selectedHexColor = selectedColor.value.toRadixString(16).padLeft(8, '0');

      selectedIcon = IconData(
        widget.initialData!['icon_codepoint'],
        fontFamily: widget.initialData!['icon_font_family'],
        fontPackage: widget.initialData!['icon_font_package'],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final local = AppLocalizations.of(context)!;

    return SafeArea(
      /// iPhone 하단 영역과 겹침 방지
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: LayoutBuilder(
          /// 반응형 크기 계산 (iOS/Android/태블릿 호환)
          builder: (context, constraints) {
            double maxW = constraints.maxWidth;
            double iconBox = maxW * 0.26;  /// 반응형 아이콘 박스 크기
            double iconSize = maxW * 0.13;
        
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(22),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// ---------- 헤더 ----------
                  Text(
                    widget.initialData == null
                        ? local.addCategory      /// "카테고리 추가"
                        : local.editCategory,    /// "카테고리 수정"
                    style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ) ?? const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 22),
        
                  /// ---------- 아이콘 + 이름 입력 ----------
                  Row(
                    children: [
                      /// 아이콘 선택 박스 (+ 모양 기본 표시)
                      GestureDetector(
                        onTap: () async {
                          final result = await showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (_) => const IconPickerSheet(),
                          );
                          if (result != null) {
                            setState(() {
                              /// 선택된 아이콘 업데이트
                              selectedIcon = result['icon'];
                            });
                          }
                        },
                        child: Container(
                          width: iconBox,
                          height: iconBox,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: theme.colorScheme.outline.withOpacity(0.4),
                              width: 2,
                            ),
                          ),
                          child: selectedIcon == Icons.category
                              ? Icon(
                                  Icons.add, // 기본 상태: + 모양
                                  size: iconSize * 0.8,
                                  color: theme.colorScheme.onSurfaceVariant,
                                )
                              : Icon(
                                  selectedIcon, // 선택된 사용자 아이콘
                                  size: iconSize,
                                  color: selectedColor,
                                ),
                        ),
                      ),
                      const SizedBox(width: 20),
        
                      /// 카테고리 이름 입력 필드
                      Expanded(
                        child: TextField(
                          controller: c_nameController,
                          decoration: InputDecoration(
                            labelText: local.categoryName,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
        
                  /// ---------- 색상 선택 영역 ----------
                  GestureDetector(
                    onTap: () async {
                      final Color? picked = await showModalBottomSheet<Color>(
                        context: context,
                        backgroundColor: Colors.transparent,
                        builder: (_) => const ColorPickerSheet(),
                      );
                      if (picked != null) {
                        setState(() {
                          /// 색상 선택 업데이트
                          selectedColor = picked;
                          selectedHexColor = picked.value
                              .toRadixString(16)
                              .padLeft(8, '0');
                        });
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(local.color, style: theme.textTheme.bodyMedium),
                        SizedBox(width: maxW * 0.07),
                        /// 색상 미리보기 원
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
        
                  /// ---------- 액션 버튼들 ----------
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      /// 취소 버튼
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.surfaceContainerHighest,
                          foregroundColor: theme.colorScheme.onSurface,
                        ),
                        child: Text(local.cancel),
                      ),
        
                      /// 저장 버튼
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

  /// 카테고리 저장 (추가/수정) 및 성공 피드백 표시
  Future<void> saveCategory() async {
    if (c_nameController.text.trim().isEmpty) return;

    final local = AppLocalizations.of(context)!;

    if (widget.initialData == null) {
      /// 새 카테고리 추가
      await addCategory();
      showSnackBar(local.categoryCreated, local.newCategoryAdded, Colors.green);
    } else {
      /// 기존 카테고리 수정
      await editCategory_history();
      showSnackBar(local.categoryUpdated, local.changesSaved, Colors.blue);
    }

    Navigator.pop(context);
  }

  /// 새 카테고리를 DB에 추가하고 모든 데이터 새로고침
  Future<void> addCategory() async {
    final category = Category(
      iconCodePoint: selectedIcon.codePoint,
      iconFontFamily: selectedIcon.fontFamily,
      iconFontPackage: selectedIcon.fontPackage,
      color: selectedHexColor,
      c_name: c_nameController.text.trim(),
    );

    await CategoryHandler().insertCategory(category);
    await Get.find<SettingsController>().refreshAllData();
  }

  /// 기존 카테고리를 DB에서 업데이트
  Future<void> editCategory_history() async {
    final category = Category(
      id: widget.initialData!['id'],
      iconCodePoint: selectedIcon.codePoint,
      iconFontFamily: selectedIcon.fontFamily,
      iconFontPackage: selectedIcon.fontPackage,
      color: selectedHexColor,
      c_name: c_nameController.text.trim(),
    );

    await CategoryHandler().updateCategory(category);
    await Get.find<SettingsController>().refreshAllData();
  }

  /// 사용자 피드백을 위한 스낵바 표시
  void showSnackBar(String title, String message, Color bgColor) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.top,
      duration: const Duration(seconds: 2),
      backgroundColor: bgColor,
      colorText: Colors.white,
    );
  }

  @override
  void dispose() {
    /// 컨트롤러 메모리 해제
    c_nameController.dispose();
    super.dispose();
  }
}