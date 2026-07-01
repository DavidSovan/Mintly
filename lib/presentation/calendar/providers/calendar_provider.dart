import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneytrackerapp/domain/entities/transaction.dart';
import 'package:moneytrackerapp/presentation/dashboard/providers/dashboard_provider.dart';

class SelectedDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  void setDate(DateTime date) {
    state = DateTime(date.year, date.month, date.day);
  }
}

final selectedDateProvider = NotifierProvider<SelectedDateNotifier, DateTime>(() {
  return SelectedDateNotifier();
});

final transactionsForSelectedDateProvider = Provider<AsyncValue<List<TransactionEntity>>>((ref) {
  final selectedDate = ref.watch(selectedDateProvider);
  final transactionsState = ref.watch(transactionsProvider);

  if (transactionsState.isLoading) return const AsyncValue.loading();
  if (transactionsState.hasError) return AsyncValue.error(transactionsState.error!, transactionsState.stackTrace!);

  final transactions = transactionsState.value ?? [];

  final filtered = transactions.where((t) {
    return t.date.year == selectedDate.year &&
           t.date.month == selectedDate.month &&
           t.date.day == selectedDate.day;
  }).toList();
  
  filtered.sort((a, b) => b.date.compareTo(a.date));

  return AsyncValue.data(filtered);
});

final calendarDailyTotalsProvider = Provider<AsyncValue<Map<DateTime, double>>>((ref) {
  final transactionsState = ref.watch(transactionsProvider);

  if (transactionsState.isLoading) return const AsyncValue.loading();
  if (transactionsState.hasError) return AsyncValue.error(transactionsState.error!, transactionsState.stackTrace!);

  final transactions = transactionsState.value ?? [];
  final Map<DateTime, double> dailyTotals = {};

  for (var t in transactions) {
    if (t.type.name != 'expense') continue; // Only track expenses for markers

    final day = DateTime(t.date.year, t.date.month, t.date.day);
    dailyTotals[day] = (dailyTotals[day] ?? 0) + t.amount;
  }

  return AsyncValue.data(dailyTotals);
});
