import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:simple_spending_tracker/VM/database_handler.dart';
import 'package:simple_spending_tracker/model/settings.dart';
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

} // END