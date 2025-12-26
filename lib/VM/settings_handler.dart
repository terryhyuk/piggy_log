import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:piggy_log/VM/database_handler.dart';
import 'package:piggy_log/model/settings.dart';
import 'package:sqflite/sql.dart';

class SettingsHandler {
  final DatabaseHandler databaseHandler = DatabaseHandler();

/// Insert default settings on first app launch
  Future<int> insertDefaultSettings() async {
  final db = await databaseHandler.initializeDB();
  final systemLocale =
      WidgetsBinding.instance.platformDispatcher.locale.toString();

  return await db.insert(
    'settings',
    {
      'id': 1,
      'language': 'system',
      'currency_code': 'system',
      'currency_symbol':
          NumberFormat.simpleCurrency(locale: systemLocale).currencySymbol,
      'date_format': DateFormat.yMd(systemLocale).pattern,
      'theme_mode': 'system',
    },
    conflictAlgorithm: ConflictAlgorithm.ignore,
  );
}


  // Update DB with settings
  Future<int> updateSettings(Settings settings) async {
    final db = await databaseHandler.initializeDB();
    return await db.update(
      'settings',
      {
        'language': settings.language,
        'currency_code': settings.currency_code,
        'currency_symbol': settings.currency_symbol,
        'date_format': settings.date_format,
        'theme_mode': settings.theme_mode,
      },
      where: 'id = ?',
      whereArgs: [1],
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


  // --- Backup All Tables ---

  /// Get all data from all tables for a full backup
  Future<Map<String, List<Map<String, dynamic>>>> getAllAppData() async {
    final db = await databaseHandler.initializeDB();
    return {
      'categories': await db.query('categories'),
      'spending_transactions': await db.query('spending_transactions'),
      'monthly_budget': await db.query('monthly_budget'),
      'settings': await db.query('settings'),
    };
  }

  /// Wipe everything before restore (except settings if you want to keep current)
  Future<void> clearAllAppData() async {
    final db = await databaseHandler.initializeDB();
    await db.transaction((txn) async {
      await txn.delete('spending_transactions');
      await txn.delete('monthly_budget');
      await txn.delete('categories');
      // Reset auto-increment sequences
      await txn.delete('sqlite_sequence');
    });
  }
  
  /// Bulk insert for any table
  Future<void> insertTableData(String tableName, List<Map<String, dynamic>> dataList) async {
    final db = await databaseHandler.initializeDB();
    await db.transaction((txn) async {
      await txn.execute('PRAGMA foreign_keys = OFF');
      for (var data in dataList) {
        await txn.insert(tableName, data, conflictAlgorithm: ConflictAlgorithm.replace);
      }
      await txn.execute('PRAGMA foreign_keys = ON');
    });
  }

} // END