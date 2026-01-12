import 'package:package_info_plus/package_info_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'package:piggy_log/core/database/database_service.dart';
import 'package:piggy_log/data/models/settings.dart';

class SettingsRepository {
  final DatabaseService _dbService = DatabaseService();

  Future<Database> get _db async => await _dbService.database;
  

  Future<SettingsModel?> getSettings() async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'settings',
      where: 'id = ?',
      whereArgs: [1],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return SettingsModel.fromMap(maps.first);
    }
    return null;
  }

  Future<int> insertDefaultSettings(SettingsModel defaultSettings) async {
    final db = await _db;
    return await db.insert(
      'settings',
      defaultSettings.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<int> updateSettings(SettingsModel settings) async {
    final db = await _db;
    return await db.update(
      'settings',
      settings.toMap(),
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  Future<String> getAppVersion() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  // 보간법 $ 표시 꼭 확인!
  return "${packageInfo.version}+${packageInfo.buildNumber}";
}

}
