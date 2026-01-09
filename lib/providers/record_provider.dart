import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:piggy_log/data/models/record_model.dart';
import 'package:piggy_log/core/database/repository/record_repository.dart';
import 'package:piggy_log/providers/settings_provider.dart';
import 'package:piggy_log/providers/dashboard_provider.dart';
import 'package:piggy_log/providers/calendar_provider.dart';

class RecordProvider with ChangeNotifier {
  final RecordRepository _repository;
  List<RecordModel> _records = [];
  bool _isAutoInserting = false;

  RecordProvider(this._repository);

  List<RecordModel> get records => _records;

  Future<void> fetchRecords(int categoryId) async {
    _records = await _repository.getRecordsByCategoryId(categoryId);
    notifyListeners();
  }

  Future<void> addRecord(BuildContext context, RecordModel record) async {
    await _repository.insertRecord(record);
    await _syncAll(context, record.categoryId);
  }

  Future<void> updateRecord(BuildContext context, RecordModel record) async {
    await _repository.updateRecord(record);
    await _syncAll(context, record.categoryId);
  }

  Future<void> deleteRecord(BuildContext context, int id, int categoryId) async {
    await _repository.deleteRecord(id);
    await _syncAll(context, categoryId);
  }

  Future<void> _processAutoInsert() async {
    if (_isAutoInserting) return;
    _isAutoInserting = true;

    try {
      final now = DateTime.now();
      final String currentMonth = DateFormat('yyyy-MM').format(now);
      final templates = await _repository.getRecurringTemplates();

      for (var temp in templates) {
        bool exists = await _repository.checkDuplicateRecord(
          temp['name'],
          (temp['amount'] as num).toDouble(),
          currentMonth,
        );

        if (!exists) {
          String dayPart = temp['date'].toString().split('-').last;
          await _repository.insertRecord(RecordModel(
            categoryId: temp['category_id'],
            name: temp['name'],
            amount: (temp['amount'] as num).toDouble(),
            date: "$currentMonth-$dayPart",
            type: temp['type'],
            memo: '[Auto] ${temp['memo'] ?? ""}',
            isRecurring: true,
          ));
        }
      }
    } catch (e) {
      debugPrint("Auto-insert error: $e");
    } finally {
      _isAutoInserting = false;
    }
  }

  Future<void> _syncAll(BuildContext context, int categoryId) async {
    // 1. Process auto-insert first
    await _processAutoInsert();

    // 2. Fetch latest records
    await fetchRecords(categoryId);

    // 3. Notify other providers
    if (context.mounted) {
      final settings = context.read<SettingProvider>();
      final dash = context.read<DashboardProvider>();
      final cal = context.read<CalendarProvider>();

      await settings.refreshAllData(
        dashboardProvider: dash,
        calendarProvider: cal,
      );
    }
  }
}