import 'package:flutter/material.dart';
import 'package:moneytrackerapp/core/theme/design_system.dart';
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
        title: const Text('Calendar', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22, letterSpacing: -0.5)),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: colorScheme.surface,
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            padding: const EdgeInsets.only(bottom: 12.0),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
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
                titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: colorScheme.onSurface, letterSpacing: -0.5),
                leftChevronIcon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.chevron_left, color: colorScheme.onSurface, size: 20),
                ),
                rightChevronIcon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.chevron_right, color: colorScheme.onSurface, size: 20),
                ),
                headerPadding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w700, fontSize: 13),
                weekendStyle: TextStyle(color: colorScheme.error.withValues(alpha: 0.8), fontWeight: FontWeight.w700, fontSize: 13),
              ),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3), width: 1.5),
                ),
                todayTextStyle: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w800),
                selectedDecoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colorScheme.primary, colorScheme.primary.withValues(alpha: 0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ]
                ),
                selectedTextStyle: TextStyle(color: colorScheme.onPrimary, fontWeight: FontWeight.w800),
                defaultTextStyle: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w500),
                weekendTextStyle: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w500),
                outsideDaysVisible: false,
                cellMargin: const EdgeInsets.all(6.0),
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
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: colorScheme.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              CurrencyFormatter.format(total, settings),
                              style: TextStyle(
                                fontSize: 9, 
                                color: colorScheme.error, 
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.2,
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
                Text('Transactions', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: colorScheme.onSurface, letterSpacing: -0.5)),
                const Spacer(),
                totalsState.when(
                  data: (totals) {
                    final d = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
                    if (totals.containsKey(d)) {
                      final total = totals[d] ?? 0.0;
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          CurrencyFormatter.format(total, settings),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.red.shade700, // Provider only tracks expenses
                            letterSpacing: -0.5,
                          ),
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
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.event_available, size: 48, color: colorScheme.primary.withValues(alpha: 0.6)),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'No transactions',
                          style: TextStyle(fontSize: 20, color: colorScheme.onSurface, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'You didn\'t spend or earn anything on this day.',
                          style: TextStyle(fontSize: 15, color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500),
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
