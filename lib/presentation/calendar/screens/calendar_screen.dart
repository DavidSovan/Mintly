import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:moneytrackerapp/presentation/calendar/providers/calendar_provider.dart';
import 'package:moneytrackerapp/presentation/transactions/widgets/transaction_item.dart';
import 'package:moneytrackerapp/core/utils/currency_formatter.dart';
import 'package:moneytrackerapp/presentation/settings/providers/settings_provider.dart';
import 'package:moneytrackerapp/domain/entities/settings.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final selectedDay = ref.watch(selectedDateProvider);
    final transactionsState = ref.watch(transactionsForSelectedDateProvider);
    final totalsState = ref.watch(calendarDailyTotalsProvider);
    final settings = ref.watch(settingsProvider).value ?? const SettingsEntity();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Calendar', style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
              border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: CalendarFormat.month,
              startingDayOfWeek: settings.firstDayOfWeek == 1 ? StartingDayOfWeek.monday : StartingDayOfWeek.sunday,
              selectedDayPredicate: (day) => isSameDay(selectedDay, day),
              onDaySelected: (selected, focused) {
                ref.read(selectedDateProvider.notifier).setDate(selected);
                setState(() {
                  _focusedDay = focused;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                leftChevronIcon: Icon(Icons.chevron_left, color: colorScheme.onSurface),
                rightChevronIcon: Icon(Icons.chevron_right, color: colorScheme.onSurface),
                headerPadding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600, fontSize: 13),
                weekendStyle: TextStyle(color: colorScheme.error, fontWeight: FontWeight.w600, fontSize: 13),
              ),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                todayTextStyle: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
                selectedDecoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                ),
                weekendTextStyle: TextStyle(color: colorScheme.error.withValues(alpha: 0.8)),
                outsideDaysVisible: false,
                cellMargin: const EdgeInsets.all(4.0),
              ),
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  return totalsState.when(
                    data: (totals) {
                      final d = DateTime(date.year, date.month, date.day);
                      if (totals.containsKey(d)) {
                        final total = totals[d] ?? 0.0;
                        final isExpense = true; // Provider only tracks expenses
                        
                        return Positioned(
                          bottom: 2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              CurrencyFormatter.format(total, settings),
                              style: TextStyle(
                                fontSize: 8, 
                                color: isExpense ? Colors.red.shade700 : Colors.green.shade700, 
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                    loading: () => const SizedBox(),
                    error: (_, __) => const SizedBox(),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              children: [
                Text('Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                const Spacer(),
                totalsState.when(
                  data: (totals) {
                    final d = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
                    if (totals.containsKey(d)) {
                      final total = totals[d] ?? 0.0;
                      return Text(
                        CurrencyFormatter.format(total, settings),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700, // Provider only tracks expenses
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                  loading: () => const SizedBox(),
                  error: (_, __) => const SizedBox(),
                )
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: transactionsState.when(
              data: (transactions) {
                if (transactions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_busy_outlined, size: 64, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                        const SizedBox(height: 16),
                        Text(
                          'No transactions',
                          style: TextStyle(fontSize: 18, color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'You didn\'t spend or earn anything on this day.',
                          style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8)),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    return TransactionItem(transaction: transaction);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}
