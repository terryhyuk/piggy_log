import 'package:sqflite/sqflite.dart';
import 'package:piggy_log/core/database/database_service.dart';
import 'package:piggy_log/data/models/category_model.dart';

class CategoryRepository {
  // Use the central DatabaseService
  final DatabaseService _dbService = DatabaseService();

  // Getter for consistent database access across all methods
  Future<Database> get _db async => await _dbService.database;

  Future<List<CategoryModel>> getAllCategories() async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories', 
      orderBy: 'id DESC',
    );
    return maps.map((e) => CategoryModel.fromMap(e)).toList();
  }

  Future<int> insertCategory(CategoryModel category) async {
    final db = await _db;
    return await db.insert(
      'categories',
      {
        'name': category.name,
        'icon_codepoint': category.iconCodePoint,
        'icon_font_family': category.iconFontFamily,
        'icon_font_package': category.iconFontPackage,
        'color': category.color,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateCategory(CategoryModel category) async {
    final db = await _db;
    return await db.update(
      'categories',
      {
        'name': category.name,
        'icon_codepoint': category.iconCodePoint,
        'icon_font_family': category.iconFontFamily,
        'icon_font_package': category.iconFontPackage,
        'color': category.color,
      },
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> deleteCategory(int id) async {
    final db = await _db;
    return await db.transaction((txn) async {
      // Cascade delete: Remove related records first to maintain integrity
      await txn.delete('records', where: 'category_id = ?', whereArgs: [id]);
      return await txn.delete('categories', where: 'id = ?', whereArgs: [id]);
    });
  }
}