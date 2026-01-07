import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:piggy_log/core/db/database_handler.dart';
import 'package:piggy_log/features/settings/model/settings.dart';
import 'package:sqflite/sqflite.dart';

// -----------------------------------------------------------------------------
//  * Refactoring Intent: 
//    Managing global application preferences and core data migration tools.
//    Focuses on maintaining data integrity during bulk I/O operations.
//
//  * TODO: 
//    - Extract Backup/Restore logic into a specialized DataMigrationService.
//    - Implement asynchronous validation for imported data structures.
// -----------------------------------------------------------------------------

class SettingsHandler {
  final DatabaseHandler databaseHandler = DatabaseHandler();

  /// Private helper for stable DB instance retrieval.
  Future<Database> _getDb() async {
    return await databaseHandler.database; 
  }

  /// Inserts default settings based on the user's system environment.
  Future<int> insertDefaultSettings() async {
    final db = await _getDb();
    final systemLocale = WidgetsBinding.instance.platformDispatcher.locale.toString();

    return await db.insert(
      'settings',
      {
        'id': 1,
        'language': 'system',
        'currency_code': 'system',
        'currency_symbol': NumberFormat.simpleCurrency(locale: systemLocale).currencySymbol,
        'date_format': DateFormat.yMd(systemLocale).pattern,
        'theme_mode': 'system',
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  /// Updates global app preferences.
  Future<int> updateSettings(Settings settings) async {
    final db = await _getDb();
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

  /// Fetches the current settings object.
  Future<Settings?> getSettings() async {
    final db = await _getDb();
    final data = await db.query(
      'settings', 
      where: 'id = ?', 
      whereArgs: [1],
      limit: 1,
    );

    if (data.isNotEmpty) {
      return Settings.fromMap(data.first);
    }
    return null;
  }

  // --- [Backup & Restore Logic] ---

  /// Exports all application tables into a structured Map for backup.
  Future<Map<String, List<Map<String, dynamic>>>> getAllAppData() async {
    final db = await _getDb();
    
    return {
      'categories': await db.query('categories'),
      'spending_transactions': await db.query('spending_transactions'),
      'monthly_budget': await db.query('monthly_budget'),
      'settings': await db.query('settings'),
    };
  }

  /// Wipes user data before a restore operation.
  /// Resetting 'sqlite_sequence' ensures auto-increment IDs are synchronized.
  Future<void> clearAllAppData() async {
    final db = await _getDb();
    await db.transaction((txn) async {
      await txn.delete('spending_transactions');
      await txn.delete('monthly_budget');
      await txn.delete('categories');
      await txn.delete('sqlite_sequence'); 
    });
  }
  
  /// Performs bulk insertion while managing foreign key constraints for safety.
  Future<void> insertTableData(String tableName, List<Map<String, dynamic>> dataList) async {
    final db = await _getDb();
    await db.transaction((txn) async {
      // Temporarily disable constraints to prevent insertion order conflicts
      await txn.execute('PRAGMA foreign_keys = OFF');
      
      for (var data in dataList) {
        await txn.insert(
          tableName, 
          data, 
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      
      await txn.execute('PRAGMA foreign_keys = ON');
    });
  }
}