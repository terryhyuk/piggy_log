import 'package:get_x/get.dart';
import 'package:simple_spending_tracker/VM/database_handler.dart';
import 'package:simple_spending_tracker/controller/setting_Controller.dart';
import 'package:simple_spending_tracker/model/category.dart';
import 'package:sqflite/sqflite.dart';

class CategoryHandler {
  final DatabaseHandler databaseHandler = DatabaseHandler();

  // Insert Category
  Future<int> insertCategory(Category category) async {
    int result = 0;
    Database db = await databaseHandler.initializeDB();
    result = await db.rawInsert(
      """
      insert into categories (c_name, icon_codepoint, icon_font_family, icon_font_package, color) values (?, ?, ?, ?, ?)
      """,
      [
        category.c_name,
        category.iconCodePoint,
        category.iconFontFamily,
        category.iconFontPackage,
        category.color,
      ],
    );
    return result;
  }

  Future<List<Category>> queryCategory() async {
    final db = await databaseHandler.initializeDB();
    final List<Map<String, Object?>> queryCategory = await db.rawQuery("""
      select * from categories
      """);
    return queryCategory.map((e) => Category.fromMap(e)).toList();
  }

  // Update Category
  Future<int> updateCategory(Category category) async {
    int result = 0;
    Database db = await databaseHandler.initializeDB();
    result = await db.rawUpdate(
      """
      update categories set c_name = ?, icon_codepoint = ?, icon_font_family = ?, icon_font_package = ?, color = ? where id = ?
      """,
      [
        category.c_name,
        category.iconCodePoint,
        category.iconFontFamily,
        category.iconFontPackage,
        category.color,
        category.id,
      ],
    );
    return result;
  }

  // Delete Category + Its Transactions
Future<int> deleteCategory(int id) async {
  final db = await databaseHandler.initializeDB();

  // 1) 해당 카테고리의 거래내역 삭제 (참조 무결성 유지)
  await db.delete(
    'spending_transactions',
    where: 'c_id = ?',
    whereArgs: [id],
  );

  // 2) 카테고리 삭제
  final result = await db.delete(
    'categories',
    where: 'id = ?',
    whereArgs: [id],
  );

  // 3) ✅ 일괄 갱신 호출
  // 이제 개별 컨트롤러를 일일이 찾을 필요가 없습니다.
  final settingsController = Get.find<SettingsController>();
  await settingsController.refreshAllData();

  return result;
}

}// END