
import 'package:get_x/get.dart';
import 'package:simple_spending_tracker/VM/calender_handler.dart';
import 'package:simple_spending_tracker/controller/setting_Controller.dart';

class CalendarController extends GetxController {
  final CalenderHandler calenderHandler = CalenderHandler();
  final SettingsController settingsController = Get.find<SettingsController>();

  RxMap<String, double> dailyTotals = <String, double>{}.obs;
  RxList<Map<String, dynamic>> selectedDateTransactions = <Map<String, dynamic>>[].obs;

  Rx<DateTime> selectedDay = DateTime.now().obs;
  Rx<DateTime> focusedDay = DateTime.now().obs;

  // 선택일 총액
  RxDouble selectedDayTotal = 0.0.obs;

  /// DB와 일치하도록 key 생성
  String dateKey(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2,'0')}-${date.day.toString().padLeft(2,'0')}";
  }

  /// 하루별 총액 불러오기
  Future<void> loadDailyTotals() async {
    final totals = await calenderHandler.getDailyTotals();
    dailyTotals.value = totals;
  }

  /// 날짜 선택 시 해당 날짜 거래 불러오기
  Future<void> selectDate(DateTime date) async {
    selectedDay.value = date;
    focusedDay.value = date;
    final key = dateKey(date);
    print("선택 날짜 key: $key");

    // final key = dateKey(date);
    final transactions = await calenderHandler.getTransactionsByDate(key);
  print("가져온 거래 수: ${transactions.length}");
    selectedDateTransactions.value = transactions;

    double total = 0.0;
    for (var tx in transactions) {
      final amount = (tx['amount'] as num?)?.toDouble() ?? 0.0;
      total += (tx['type'] == 'expense') ? -amount : amount;
    }
    selectedDayTotal.value = total;
  }

  /// 화면용 포맷
  String formatCurrency(double amount) {
    return settingsController.formatCurrency(amount) ?? amount.toString();
  }

  String formatDate(String isoDate) {
    final dt = DateTime.tryParse(isoDate);
    if (dt == null) return isoDate;
    return settingsController.formatDate(dt) ?? isoDate;
  }
}