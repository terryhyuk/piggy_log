import 'package:flutter/material.dart';
import 'package:get_x/get.dart';
import 'package:piggy_log/features/settings/controller/setting_controller.dart';
import 'package:piggy_log/l10n/app_localizations.dart';
import 'package:piggy_log/features/transaction/model/spending_transaction.dart';
import 'package:piggy_log/features/calendar/widgets/calendar_build_widget.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:piggy_log/features/calendar/controller/calendar_controller.dart';
import 'package:piggy_log/features/transaction/presentation/transactions_detail.dart';

// -----------------------------------------------------------------------------
//  * Refactoring Intent: 
//    Implements a robust monthly ledger view. Features optimized event loading 
//    (markers) and bidirectional data synchronization between the calendar 
//    and transaction detail pages.
//
//  * TODO: 
//    - Implement multi-dot markers for combined income/expense visualization.
//    - Add 'Swipe-to-Action' for quick editing directly from the list.
// -----------------------------------------------------------------------------

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final CalendarController calController = Get.find<CalendarController>();
  final SettingController settingsController = Get.find<SettingController>();

@override
void initState() {
  super.initState();

  // Initialize calendar data on cold boot
  _initCalendar();

  // Listen for global refresh triggers (e.g., adding/deleting transactions)
  settingsController.refreshTrigger.listen((_) async {
    if (!mounted) return;

    // Fetch latest data and update the calendar state
    await calController.loadDailyTotals();
    calController.selectDate(calController.selectedDay.value);

    // Explicitly trigger a rebuild to reflect updated markers in the UI
    if (mounted) setState(() {});
  });
}

/// -----------------------------------------------------------------------------
/// [Asynchronous Initialization]
/// Ensures the database fetch is fully completed before the first frame
/// is rendered. This prevents 'Race Conditions' where the calendar 
/// might attempt to render markers before the underlying data is ready.
/// -----------------------------------------------------------------------------
Future<void> _initCalendar() async {
  // 1️⃣ Wait for the database to return daily transaction totals
  await calController.loadDailyTotals();

  // 2️⃣ Select the current date to populate the transaction list
  calController.selectDate(DateTime.now());

  // 3️⃣ Rebuild the view once the data hydration is complete
  if (mounted) setState(() {});
}

@override
Widget build(BuildContext context) {
  final theme = Theme.of(context);
  final textColor = theme.textTheme.bodyMedium?.color ?? Colors.black;
  final markerColor = theme.colorScheme.primary;

  return Scaffold(
    body: SafeArea(
      child: Obx(() {
        return Column(
          children: [
            // 1. TableCalendar: Main interactive calendar component
            TableCalendar(
              firstDay: DateTime(2020),
              lastDay: DateTime(2100),
              onPageChanged: (focusedDay) {
                calController.focusedDay.value = focusedDay;
                calController.selectedDay.value = focusedDay;
                calController.selectedDateTransactions.clear();
                calController.selectedDayTotal.value = 0.0;
              },
              focusedDay: calController.focusedDay.value,
              selectedDayPredicate: (day) =>
                  isSameDay(day, calController.selectedDay.value),
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
              // Loader logic for day markers (event dots)
              eventLoader: (day) {
                final key = calController.dateKey(day);
                final amount = calController.dailyTotals[key];
                // 불필요한 debugPrint 제거 완료
                return (amount != null && amount > 0) ? [amount] : [];
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
                defaultBuilder: (context, day, focusedDay) => _buildDayWidget(day, false, false),
                todayBuilder: (context, day, focusedDay) => _buildDayWidget(day, false, true),
                selectedBuilder: (context, day, focusedDay) => 
                    _buildDayWidget(day, true, isSameDay(day, DateTime.now())),
              ),
            ),
            const SizedBox(height: 8),
            
            // 2. Transaction List: Detailed records for the selected date
            Expanded(
              child: Obx(() {
                final txs = calController.selectedDateTransactions;
                
                if (txs.isEmpty) {
                  return Center(child: Text(AppLocalizations.of(context)!.noTransactions));
                }
                
                return ListView.separated(
                  itemCount: txs.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final tx = txs[index];
                    final amount = (tx['amount'] as num?)?.toDouble() ?? 0.0;
                    final type = tx['type'];
                    final color = type == 'expense' ? Colors.red : Colors.green;

                    return ListTile(
                      title: Text(
                        tx['t_name'] ?? '',
                        style: TextStyle(color: textColor),
                      ),
                      subtitle: tx['memo'] != null && tx['memo'].toString().isNotEmpty
                          ? Text(
                              tx['memo'],
                              style: TextStyle(
                                color: textColor.withValues(alpha: 0.7),
                              ),
                            )
                          : null,
                      trailing: Text(
                        calController.formatCurrency(amount),
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () => _navigateToDetail(tx),
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

  /// Helper to render custom day cells based on transaction status.
  Widget _buildDayWidget(DateTime day, bool isSelected, bool isToday) {
    final key = calController.dateKey(day);
    final hasTx = calController.dailyTotals.containsKey(key);
    return CalendarBuildWidget(
      day: day,
      isSelected: isSelected,
      isToday: isToday,
      hasTx: hasTx,
      textColor: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black,
      markerColor: Theme.of(context).colorScheme.primary,
    );
  }

  /// Handles navigation and ensures data consistency after modification.
  void _navigateToDetail(Map<String, dynamic> tx) {
    try {
      final trxObject = SpendingTransaction(
        t_id: tx['t_id'],
        c_id: tx['c_id'],
        t_name: tx['t_name']?.toString() ?? '',
        amount: (tx['amount'] as num?)?.toDouble() ?? 0.0,
        date: tx['date']?.toString() ?? DateTime.now().toIso8601String(),
        type: tx['type']?.toString() ?? 'expense',
        memo: tx['memo']?.toString() ?? '',
        isRecurring: tx['isRecurring'] == 1,
      );
      
      Get.to(
        () => const TransactionsDetail(),
        arguments: trxObject,
      )?.then((result) {
        if (result == true) {
          // Re-load totals to update markers and trigger global UI refresh.
          calController.loadDailyTotals();
          settingsController.refreshTrigger.value++;
        }
      });
    } catch (e) {
      Get.snackbar(
        '',
        AppLocalizations.of(context)!.errorTransactionDetail,
        snackPosition: SnackPosition.bottom,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}