import 'package:get_x/get.dart';
import 'package:piggy_log/VM/database_handler.dart';
import 'package:piggy_log/controller/setting_controller.dart';
import 'package:piggy_log/model/category.dart';
import 'package:sqflite/sqflite.dart';

// -----------------------------------------------------------------------------
//  * Refactoring Intent: 
//    Managing category metadata and enforcing referential integrity. 
//    Ensures data consistency by handling cascading deletions at the DAO level.
//
//  * TODO: 
//    - Abstract cascading logic into a Domain Service to remove UI controller 
//      dependency (Get.find) from the Data layer.
//    - Implement a Repository interface for better mock testing.
// -----------------------------------------------------------------------------

class CategoryHandler {
  final DatabaseHandler databaseHandler = DatabaseHandler();

  /// Private helper for stable DB instance retrieval.
  Future<Database> _getDb() async {
    return await databaseHandler.database;
  }

  /// Inserts a new category with visual metadata.
  Future<int> insertCategory(Category category) async {
    final db = await _getDb();
    return await db.rawInsert(
      """
      INSERT INTO categories (c_name, icon_codepoint, icon_font_family, icon_font_package, color) 
      VALUES (?, ?, ?, ?, ?)
      """,
      [
        category.c_name,
        category.iconCodePoint,
        category.iconFontFamily,
        category.iconFontPackage,
        category.color,
      ],
    );
  }

  /// Returns all categories as a list of Category objects.
  Future<List<Category>> getAllCategories() async {
    final db = await _getDb();
    final List<Map<String, dynamic>> maps = await db.query('categories');
    return maps.map((e) => Category.fromMap(e)).toList();
  }

  /// Queries all categories ordered by newest first.
  Future<List<Category>> queryCategory() async {
    final db = await _getDb();
    final List<Map<String, Object?>> queryCategory = await db.rawQuery("""
      SELECT * FROM categories ORDER BY id DESC
      """);
    return queryCategory.map((e) => Category.fromMap(e)).toList();
  }

  /// Updates existing category details.
  Future<int> updateCategory(Category category) async {
    final db = await _getDb();
    return await db.rawUpdate(
      """
      UPDATE categories SET c_name = ?, icon_codepoint = ?, icon_font_family = ?, icon_font_package = ?, color = ? 
      WHERE id = ?
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
  }

  /// Deletes a category and its associated transactions to maintain data integrity.
  Future<int> deleteCategory(int id) async {
    final db = await _getDb();

    // [Step 1] Cascading Delete: Remove all linked transactions first.
    await db.delete(
      'spending_transactions',
      where: 'c_id = ?',
      whereArgs: [id],
    );

    // [Step 2] Remove the category record.
    final result = await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );

    // [Step 3] Global State Synchronization
    final settingsController = Get.find<SettingController>();
    await settingsController.refreshAllData();

    return result;
  }
}