import 'package:simple_spending_tracker/VM/database_handler.dart';
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

  // Delete Category
  Future<int> deleteCategory(int id) async {
    int result = 0;
    Database db = await databaseHandler.initializeDB();
    result = await db.rawDelete(
      """delete from categories where id = ?""",
      [id],
    );
    return result;
  }
}// END