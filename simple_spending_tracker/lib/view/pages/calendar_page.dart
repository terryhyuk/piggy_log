import 'package:flutter/material.dart';
import 'package:get_x/get.dart';
import 'package:simple_spending_tracker/model/spending_transaction.dart';
import 'package:simple_spending_tracker/view/widget/calendar_build_widget.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:simple_spending_tracker/controller/calendar_Controller.dart';
import 'package:simple_spending_tracker/controller/setting_Controller.dart';
import 'package:simple_spending_tracker/view/pages/transactions_%20detail.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final CalendarController calController = Get.find<CalendarController>();
  final SettingsController settingsController = Get.find<SettingsController>();

  @override
  void initState() {
    super.initState();
    calController.loadDailyTotals();
    calController.selectDate(DateTime.now());

    // Settings 변경 시 날짜/통화 리렌더
    settingsController.refreshTrigger.listen((_) {
      print("===== SETTINGS REFRESH TRIGGERED (CalendarPage) =====");
      calController.loadDailyTotals();
      calController.selectDate(calController.selectedDay.value);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;
    final markerColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          return Column(
            children: [
              TableCalendar(
                firstDay: DateTime(2020),
                lastDay: DateTime(2100),
                focusedDay: calController.focusedDay.value,
                selectedDayPredicate: (day) => isSameDay(day, calController.selectedDay.value),
                onDaySelected: (selectedDay, focusedDay) {
                  calController.selectDate(selectedDay);
                },
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
                calendarStyle: const CalendarStyle(
                  isTodayHighlighted: false,
                  outsideDaysVisible: false,
                ),
                eventLoader: (day) {
                  final key = calController.dateKey(day);
                  return calController.dailyTotals[key] != null && calController.dailyTotals[key]! > 0
                      ? [calController.dailyTotals[key]!]
                      : [];
                },
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, day, events) {
                    if (events.isNotEmpty) {
                      return Positioned(
                        bottom: 4,
                        child: CircleAvatar(
                          radius: 3,
                          backgroundColor: markerColor,
                        ),
                      );
                    }
                    return null;
                  },
                  defaultBuilder: (context, day, focusedDay) {
                    final key = calController.dateKey(day);
                    final hasTx = calController.dailyTotals.containsKey(key);
                    return CalendarBuildWidget(
                      day: day,
                      isSelected: false,
                      isToday: false,
                      hasTx: hasTx,
                      textColor: textColor,
                      markerColor: markerColor,
                    );
                  },
                  todayBuilder: (context, day, focusedDay) {
                    final key = calController.dateKey(day);
                    final hasTx = calController.dailyTotals.containsKey(key);
                    return CalendarBuildWidget(
                      day: day,
                      isSelected: false,
                      isToday: true,
                      hasTx: hasTx,
                      textColor: textColor,
                      markerColor: markerColor,
                    );
                  },
                  selectedBuilder: (context, day, focusedDay) {
                    final key = calController.dateKey(day);
                    final hasTx = calController.dailyTotals.containsKey(key);
                    return CalendarBuildWidget(
                      day: day,
                      isSelected: true,
                      isToday: isSameDay(day, DateTime.now()),
                      hasTx: hasTx,
                      textColor: textColor,
                      markerColor: markerColor,
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Obx(() {
                  final txs = calController.selectedDateTransactions;
                  if (txs.isEmpty) return const Center(child: Text("No transactions"));

                  return ListView.separated(
                    itemCount: txs.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final tx = txs[index];
                      final amount = (tx['amount'] as num?)?.toDouble() ?? 0.0;
                      final type = tx['type'];
                      final color = type == 'expense' ? Colors.red : Colors.green;

                      return ListTile(
                        title: Text(tx['t_name'] ?? '', style: TextStyle(color: textColor)),
                        subtitle: tx['memo'] != null && tx['memo'].toString().isNotEmpty
                            ? Text(tx['memo'], style: TextStyle(color: textColor.withOpacity(0.7)))
                            : null,
                        trailing: Text(
                          calController.formatCurrency(amount),
                          style: TextStyle(color: color, fontWeight: FontWeight.bold),
                        ),
onTap: () {
  try {
    // 1. Map 데이터를 안전하게 SpendingTransaction 객체로 변환
    final trxObject = SpendingTransaction(
      t_id: tx['t_id'], 
      c_id: tx['c_id'] ?? 0, // null일 경우 기본값 0
      t_name: tx['t_name']?.toString() ?? '', // null일 경우 빈 문자열
      amount: (tx['amount'] as num?)?.toDouble() ?? 0.0,
      date: tx['date']?.toString() ?? DateTime.now().toIso8601String(), // 날짜 null 방지
      type: tx['type']?.toString() ?? 'expense',
      memo: tx['memo']?.toString() ?? '',
      isRecurring: tx['isRecurring'] == 1 || tx['isRecurring'] == true,
    );

    // 2. 객체 전달
    Get.to(
      () => const TransactionsDetail(),
      arguments: trxObject,
    )?.then((result) {
      if (result == true) {
        calController.loadDailyTotals();
        settingsController.refreshTrigger.value++;
      }
    });
  } catch (e) {
    print("Error creating Transaction object: $e");
    // 어디서 null 에러가 났는지 콘솔에서 확인 가능합니다.
  }
},
                        // onTap: () {
                        //   // Map 그대로 전달
                        //   Get.to(() => const TransactionsDetail(), arguments: tx)?.then((result) {
                        //     if (result == true) calController.loadDailyTotals();
                        //   });
                        // },
                      );
                    },
                  );
                }),
              ),
            ],
          );
        }),
      ),
    );
  }
}

