import 'package:get_x/get.dart';
import 'package:piggy_log/core/db/calendar_handler.dart';
import 'package:piggy_log/features/settings/controller/setting_controller.dart';

// -----------------------------------------------------------------------------
//  * CalendarController.dart
//  * [Precision Data Manager]
//  -----------------------------------------------------------------------------
//  * [Development Diary]
//  * 1. Type Safety: Solved critical casting issues by ensuring all SQLite 'num' 
//  * types are safely converted to '.toDouble()' to prevent runtime crashes.
//  * 2. Key Synchronization: Implemented standardized dateKey logic with 
//  * padding (padLeft) to perfectly match the database string format.
//  * 3. Aggregation Logic: Developed real-time daily sum calculation that 
//  * distinguishes between 'expense' (negative) and 'income' (positive).
// -----------------------------------------------------------------------------

class CalendarController extends GetxController {
  final CalenderHandler calenderHandler = CalenderHandler();
  final SettingController settingsController = Get.find<SettingController>();

  // Stores daily spending/income totals for calendar markers
  RxMap<String, double> dailyTotals = <String, double>{}.obs;
  
  // Stores list of transactions for the currently selected day
  RxList<Map<String, dynamic>> selectedDateTransactions = <Map<String, dynamic>>[].obs;

  Rx<DateTime> selectedDay = DateTime.now().obs;
  Rx<DateTime> focusedDay = DateTime.now().obs;

  // Total balance for the selected date
  RxDouble selectedDayTotal = 0.0.obs;

  /// Generates a standardized key (YYYY-MM-DD) to match Database records.
  /// Critical for accurate map lookup.
  String dateKey(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  /// Fetches daily totals from DB to populate calendar markers (dots).
  /// [Asynchronous Hydration] Ensures UI markers stay in sync with the DB.
  Future<void> loadDailyTotals() async {
    // Fetch aggregated daily totals from the persistence handler
    final totals = await calenderHandler.getDailyTotals();
    
    // Update the observable map to trigger UI listeners
    dailyTotals.value = totals;
  }

  /// Triggered when a user taps a date. Fetches transactions and calculates net balance.
  Future<void> selectDate(DateTime date) async {
    selectedDay.value = date;
    focusedDay.value = date;
    final key = dateKey(date);
    
    // Fetch individual transaction records for the specific date key
    final transactions = await calenderHandler.getTransactionsByDate(key);
    selectedDateTransactions.value = transactions;

    // Calculate the net total for the day (Income - Expense)
    double total = 0.0;
    for (var tx in transactions) {
      // Safe type casting for SQLite 'num' types to prevent runtime errors
      final amount = (tx['amount'] as num?)?.toDouble() ?? 0.0;
      total += (tx['type'] == 'expense') ? -amount : amount;
    }
    selectedDayTotal.value = total;
  }
  
  /// Formats amount based on global currency settings from SettingController.
  String formatCurrency(double amount) {
    return settingsController.formatCurrency(amount);
  }

  /// Converts ISO strings to localized date formats based on user preference.
  String formatDate(String isoDate) {
    final dt = DateTime.tryParse(isoDate);
    if (dt == null) return isoDate;
    return settingsController.formatDate(dt);
  }
}