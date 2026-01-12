import 'package:flutter/material.dart';
import 'package:piggy_log/core/database/repository/calendar_repository.dart';

class CalendarProvider with ChangeNotifier {
  final CalendarRepository repository;

  CalendarProvider(this.repository);

  // --- [State Variables] ---
  Map<String, double> dailyTotals = {};
  List<Map<String, dynamic>> selectedDateTransactions = [];
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();
  double selectedDayTotal = 0.0;

  // Helper for consistent date formatting
  String _dateKey(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  /// Loads net totals for each day to show on the calendar
  Future<void> loadDailyTotals() async {
    dailyTotals = await repository.getDailyTotals();
    notifyListeners();
  }

  /// Selects a date and fetches all related records details
  Future<void> selectDate(DateTime date) async {
    selectedDay = date;
    focusedDay = date;
    final key = _dateKey(date);
    
    // Fetch data from synchronized repositories
    final transactions = await repository.getTransactionsByDate(key);
    final categories = await repository.getAllCategories();

    // Mapping records data with category details
    selectedDateTransactions = transactions.map((tx) {
      final category = categories.firstWhere(
        (c) => c['id'] == tx['category_id'],
        orElse: () => <String, dynamic>{},
      );

      return {
        ...tx,
        'category_name': category['name'] ?? 'Unknown',
        'icon_codepoint': category['icon_codepoint'],
        'icon_font_family': category['icon_font_family'],
        'icon_font_package': category['icon_font_package'],
        'color': category['color'],
      };
    }).toList();

    // Calculate the total balance for the selected day
    double total = 0.0;
    for (var tx in selectedDateTransactions) {
      final amount = (tx['amount'] as num?)?.toDouble() ?? 0.0;
      total += (tx['type'] == 'expense') ? -amount : amount;
    }
    selectedDayTotal = total;
    
    notifyListeners();
  }

  /// Syncs calendar state after data changes
  Future<void> refresh() async {
    await loadDailyTotals();
    await selectDate(selectedDay);
  }

  /// Handles view changes (e.g., month swipe)
  void onMonthChanged(DateTime day) {
    focusedDay = day;
    selectedDay = day; 
    selectedDateTransactions = [];
    selectedDayTotal = 0.0;
    notifyListeners(); 
  }
}