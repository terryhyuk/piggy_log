import 'package:flutter/material.dart';
import 'package:get_x/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:simple_spending_tracker/controller/calendar_Controller.dart';
import 'package:simple_spending_tracker/controller/setting_Controller.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});
  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final CalendarController calController = Get.put(CalendarController());
  final SettingsController settingsController = Get.find<SettingsController>();

  @override
  void initState() {
    super.initState();
    calController.loadDailyTotals();

    // Settings 변경 시 날짜/통화 리렌더
    settingsController.refreshTrigger.listen((_) {
      calController.loadDailyTotals();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
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
                onDaySelected: (selectedDay, focusedDay) async {
                  await calController.selectDate(selectedDay);
                  setState(() {});
                },
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) {
                    final key = calController.dateKey(day);
                    final amount = calController.dailyTotals[key];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("${day.day}"),
                        if (amount != null && amount != 0)
                          Text(
                            calController.formatCurrency(amount),
                            style: const TextStyle(fontSize: 10, color: Colors.red),
                          ),
                      ],
                    );
                  },
                  todayBuilder: (context, day, focusedDay) {
                    final key = calController.dateKey(day);
                    final amount = calController.dailyTotals[key];
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("${day.day}"),
                          if (amount != null && amount != 0)
                            Text(
                              calController.formatCurrency(amount),
                              style: const TextStyle(fontSize: 10, color: Colors.red),
                            ),
                        ],
                      ),
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
                        title: Text(tx['t_name'] ?? ''),
                        subtitle: Text(tx['c_name'] ?? ''),
                        trailing: Text(
                          calController.formatCurrency(amount),
                          style: TextStyle(color: color, fontWeight: FontWeight.bold),
                        ),
                      );
                    },
                  );
                }),
              )
            ],
          );
        }),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:get_x/get.dart';
// import 'package:simple_spending_tracker/controller/calendar_Controller.dart';
// import 'package:simple_spending_tracker/controller/category_Controller.dart';
// import 'package:simple_spending_tracker/controller/setting_Controller.dart';
// import 'package:table_calendar/table_calendar.dart';

// class CalendarPage extends StatefulWidget {
//   const CalendarPage({super.key});

//   @override
//   State<CalendarPage> createState() => _CalendarPageState();
// }

// class _CalendarPageState extends State<CalendarPage> {
//   final CalendarController calendarController = Get.put(CalendarController());
//   final SettingsController settingsController = Get.find<SettingsController>();
//   final CategoryController categoryController = Get.put(CategoryController());

//   @override
//   void initState() {
//     super.initState();

//     // 초기 데이터 로드
//     calendarController.loadDailyTotals();
//     calendarController.selectDate(DateTime.now());

//     // Settings 변경 시 화면 갱신
//     settingsController.refreshTrigger.listen((_) => setState(() {}));

//     // 카테고리/거래 변경 시 화면 갱신
//     categoryController.refreshTrigger.listen((_) {
//       calendarController.loadDailyTotals();
//       calendarController.selectDate(calendarController.selectedDay.value);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Calendar')),
//       body: Column(
//         children: [
//           // -----------------------------
//           // TableCalendar
//           // -----------------------------
//           Obx(() {
//             return TableCalendar(
//               firstDay: DateTime.utc(2023, 1, 1),
//               lastDay: DateTime.utc(2030, 12, 31),
//               focusedDay: calendarController.focusedDay.value,
//               calendarFormat: calendarController.calendarFormat.value,
//               selectedDayPredicate: (day) =>
//                   isSameDay(day, calendarController.selectedDay.value),
//               onFormatChanged: (format) {
//                 calendarController.calendarFormat.value = format;
//               },
//               onDaySelected: (selectedDay, focusedDay) {
//                 calendarController.selectDate(selectedDay);
//               },
//               calendarBuilders: CalendarBuilders(
//                 defaultBuilder: (context, day, focusedDay) {
//                   final key =
//                       "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";
//                   final total = calendarController.dailyTotals[key] ?? 0.0;

//                   return Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text('${day.day}'),
//                       if (total != 0)
//                         Text(
//                           '${total >= 0 ? '+' : ''}${calendarController.formatCurrency(total)}',
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: total >= 0 ? Colors.green : Colors.red,
//                           ),
//                         ),
//                     ],
//                   );
//                 },
//               ),
//             );
//           }),

//           const SizedBox(height: 8),

//           // -----------------------------
//           // 선택 날짜 Total
//           // -----------------------------
//           Obx(() {
//             final total = calendarController.selectedDayTotal.value;
//             final selectedDayStr = calendarController.formatDate(
//                 calendarController.selectedDay.value.toIso8601String());

//             return Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     '$selectedDayStr Total:',
//                     style: const TextStyle(
//                         fontSize: 16, fontWeight: FontWeight.bold),
//                   ),
//                   Text(
//                     '${total >= 0 ? '+' : ''}${calendarController.formatCurrency(total)}',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: total >= 0 ? Colors.green : Colors.red,
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }),

//           const SizedBox(height: 8),

//           // -----------------------------
//           // 선택 날짜 거래 내역
//           // -----------------------------
//           Expanded(
//             child: Obx(() {
//               final transactions =
//                   calendarController.selectedDateTransactions;
//               if (transactions.isEmpty) {
//                 return const Center(
//                   child: Text('No transactions for selected day'),
//                 );
//               }

//               return ListView.builder(
//                 itemCount: transactions.length,
//                 itemBuilder: (context, index) {
//                   final tx = transactions[index];
//                   final isIncome = tx['type'] == '+' || tx['type'] == 'income';
//                   final sign = isIncome ? '+' : '-';

//                   return Card(
//                     margin: const EdgeInsets.symmetric(
//                         horizontal: 12, vertical: 6),
//                     child: ListTile(
//                       title: Text(tx['t_name'] ?? 'No Name'),
//                       subtitle:
//                           Text('Category: ${tx['c_id'] ?? 'Unknown'}'), // 필요 시 카테고리 이름 매핑
//                       trailing: Text(
//                         '$sign${calendarController.formatCurrency(tx['amount'] ?? 0)}',
//                         style: TextStyle(
//                           color: isIncome ? Colors.green : Colors.red,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               );
//             }),
//           ),
//         ],
//       ),
//     );
//   }
// }
