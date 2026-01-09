import 'package:flutter/material.dart';
import 'package:piggy_log/providers/settings_provider.dart';
import 'package:provider/provider.dart';
import 'package:piggy_log/l10n/app_localizations.dart';
import 'package:piggy_log/data/models/record_model.dart';
import 'package:piggy_log/features/calendar/widgets/calendar_build_widget.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:piggy_log/providers/calendar_provider.dart';
import 'package:piggy_log/features/record/presentation/records_detail.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  @override
  void initState() {
    super.initState();
    // Refresh data after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<CalendarProvider>().refresh();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    final calProvider = context.watch<CalendarProvider>();
    final settings = context.watch<SettingProvider>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            TableCalendar(
              firstDay: DateTime(2020),
              lastDay: DateTime(2100),
              focusedDay: calProvider.focusedDay,
              selectedDayPredicate: (day) => isSameDay(day, calProvider.selectedDay),

              onPageChanged: (focusedDay) {
                context.read<CalendarProvider>().onMonthChanged(focusedDay);
              },

              onDaySelected: (selectedDay, focusedDay) {
                context.read<CalendarProvider>().selectDate(selectedDay);
              },

              eventLoader: (day) {
                final key = _formatDateKey(day);
                return calProvider.dailyTotals.containsKey(key) ? [true] : [];
              },

              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              calendarStyle: const CalendarStyle(
                isTodayHighlighted: false,
                outsideDaysVisible: false,
              ),

              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, day, events) => const SizedBox.shrink(),
                defaultBuilder: (context, day, focusedDay) =>
                    _buildDayWidget(day, false, false, calProvider),
                todayBuilder: (context, day, focusedDay) =>
                    _buildDayWidget(day, false, true, calProvider),
                selectedBuilder: (context, day, focusedDay) => _buildDayWidget(
                  day,
                  true,
                  isSameDay(day, DateTime.now()),
                  calProvider,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Transaction List Section
            Expanded(
              child: calProvider.selectedDateTransactions.isEmpty
                  ? Center(child: Text(l10n.noTransactions))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: calProvider.selectedDateTransactions.length,
                      itemBuilder: (context, index) {
                        final tx = calProvider.selectedDateTransactions[index];
                        return _buildTransactionCard(tx, theme, settings);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper for date keys inside the view layer
  String _formatDateKey(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Widget _buildTransactionCard(
    Map<String, dynamic> tx,
    ThemeData theme,
    SettingProvider settings,
  ) {
    final amount = (tx['amount'] as num?)?.toDouble() ?? 0.0;
    final isExpense = tx['type'] == 'expense';
    final String memo = tx['memo']?.toString() ?? '';

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor.withAlpha(25)),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer.withAlpha(76),
          child: Icon(
            IconData(
              tx['icon_codepoint'] ?? 58714,
              fontFamily: tx['icon_font_family'] ?? 'MaterialIcons',
              fontPackage: tx['icon_font_package'],
            ),
            size: 20,
            color: theme.colorScheme.primary,
          ),
        ),
        title: Text(
          tx['name'] ?? 'No Name',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: memo.isNotEmpty
            ? Text(
                memo,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant.withAlpha(178),
                  fontSize: 12,
                ),
              )
            : null,
        trailing: Text(
          settings.formatCurrency(amount),
          style: TextStyle(
            color: isExpense ? Colors.redAccent : Colors.green,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        onTap: () => _navigateToDetail(tx),
      ),
    );
  }

  Widget _buildDayWidget(
    DateTime day,
    bool isSelected,
    bool isToday,
    CalendarProvider calProvider,
  ) {
    final key = _formatDateKey(day);
    final hasTx = calProvider.dailyTotals.containsKey(key);
    return CalendarBuildWidget(
      day: day,
      isSelected: isSelected,
      isToday: isToday,
      hasTx: hasTx,
      textColor: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black,
      markerColor: Theme.of(context).colorScheme.primary,
    );
  }

  void _navigateToDetail(Map<String, dynamic> tx) async {
    final recordObject = RecordModel(
      id: tx['id'],
      categoryId: tx['category_id'],
      name: tx['name']?.toString() ?? '',
      amount: (tx['amount'] as num?)?.toDouble() ?? 0.0,
      date: tx['date']?.toString() ?? DateTime.now().toIso8601String(),
      type: tx['type']?.toString() ?? 'expense',
      memo: tx['memo']?.toString() ?? '',
      isRecurring: tx['is_recurring'] == 1,
    );

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RecordsDetail(),
        settings: RouteSettings(arguments: recordObject),
      ),
    );

    if (result == true) {
      if (mounted) {
        context.read<CalendarProvider>().refresh();
      }
    }
  }
}