import 'package:simple_spending_tracker/VM/database_handler.dart';
import 'package:simple_spending_tracker/model/settings.dart';
import 'package:sqflite/sql.dart';

class SettingsHandler {
  final DatabaseHandler databaseHandler = DatabaseHandler();

/// Insert default settings on first app launch
  Future<int> insertDefaultSettings() async {
    final db = await databaseHandler.initializeDB();

    return await db.insert(
      'settings',
      {
        'id': 1,
        'language': 'system',
        'currency_code': 'system',  // default currency
        'currency_symbol': '\$',
        'date_format': 'yyyy-MM-dd',
        'theme_mode': 'system',
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  /// Fetch settings
  Future<Settings?> getSettings() async {
    final db = await databaseHandler.initializeDB();
    final data = await db.query('settings', where: 'id = ?', whereArgs: [1]);

    if (data.isNotEmpty) {
      return Settings.fromMap(data.first);
    }
    return null;
  }

}