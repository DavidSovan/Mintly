import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneytrackerapp/presentation/dashboard/providers/dashboard_provider.dart';
import 'package:moneytrackerapp/presentation/categories/providers/category_provider.dart';
import 'package:moneytrackerapp/domain/entities/settings.dart';
import 'package:moneytrackerapp/presentation/settings/providers/settings_provider.dart';
enum ReportPeriod { daily, weekly, monthly, yearly }

class SelectedReportPeriodNotifier extends Notifier<ReportPeriod> {
  @override
  ReportPeriod build() => ReportPeriod.monthly;
  
  void setPeriod(ReportPeriod newPeriod) {
    state = newPeriod;
  }
}

final selectedReportPeriodProvider = NotifierProvider<SelectedReportPeriodNotifier, ReportPeriod>(() {
  return SelectedReportPeriodNotifier();
});

class CategoryExpense {
  final String categoryName;
  final double amount;
  final int colorValue;

  CategoryExpense(this.categoryName, this.amount, this.colorValue);
}

class TimeSeriesData {
  final DateTime date;
  final double amount;

  TimeSeriesData(this.date, this.amount);
}

final categoryExpenseProvider = Provider<AsyncValue<List<CategoryExpense>>>((ref) {
  final transactionsState = ref.watch(transactionsProvider);
  final categoriesState = ref.watch(categoriesProvider);
  final period = ref.watch(selectedReportPeriodProvider);

  if (transactionsState.isLoading || categoriesState.isLoading) return const AsyncValue.loading();
  if (transactionsState.hasError) return AsyncValue.error(transactionsState.error!, transactionsState.stackTrace!);
  if (categoriesState.hasError) return AsyncValue.error(categoriesState.error!, categoriesState.stackTrace!);

  final transactions = transactionsState.value ?? [];
  final categories = categoriesState.value ?? [];

  final now = DateTime.now();
  final Map<String, Map<String, dynamic>> categoryTotals = {};

  for (var t in transactions) {
    if (t.type.name != 'expense') continue;

    bool inPeriod = false;
    switch (period) {
      case ReportPeriod.daily:
        inPeriod = t.date.year == now.year && t.date.month == now.month && t.date.day == now.day;
        break;
      case ReportPeriod.weekly:
        final settings = ref.read(settingsProvider).value ?? const SettingsEntity();
        int daysToSubtract = settings.firstDayOfWeek == 1 ? now.weekday - 1 : now.weekday % 7;
        final startOfWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: daysToSubtract));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        inPeriod = t.date.isAfter(startOfWeek.subtract(const Duration(days: 1))) && 
                   t.date.isBefore(endOfWeek.add(const Duration(days: 1)));
        break;
      case ReportPeriod.monthly:
        inPeriod = t.date.year == now.year && t.date.month == now.month;
        break;
      case ReportPeriod.yearly:
        inPeriod = t.date.year == now.year;
        break;
    }

    if (inPeriod) {
      final cat = categories.where((c) => c.id == t.category || c.name == t.category).firstOrNull;
      String name = cat?.name ?? 'Unknown';
      
      // Fallback for Savings goals without a valid category
      if (cat == null && t.title.toLowerCase().startsWith('savings:')) {
        name = t.title;
      }
      
      // Store the color as well, defaulting to orange for savings, otherwise Grey
      final color = cat?.colorValue ?? (name.toLowerCase().startsWith('savings:') ? 0xFFFF9800 : 0xFF9E9E9E);
      
      if (!categoryTotals.containsKey(name)) {
        categoryTotals[name] = {'amount': 0.0, 'color': color};
      }
      categoryTotals[name]!['amount'] = (categoryTotals[name]!['amount'] as double) + t.amount;
    }
  }

  final result = categoryTotals.entries.map((e) {
    return CategoryExpense(e.key, e.value['amount'] as double, e.value['color'] as int);
  }).toList();

  result.sort((a, b) => b.amount.compareTo(a.amount));
  return AsyncValue.data(result);
});

final incomeVsExpenseProvider = Provider<AsyncValue<Map<String, double>>>((ref) {
  final transactionsState = ref.watch(transactionsProvider);
  final period = ref.watch(selectedReportPeriodProvider);

  if (transactionsState.isLoading) return const AsyncValue.loading();
  if (transactionsState.hasError) return AsyncValue.error(transactionsState.error!, transactionsState.stackTrace!);

  final transactions = transactionsState.value ?? [];
  final now = DateTime.now();

  double income = 0;
  double expense = 0;

  for (var t in transactions) {
    bool inPeriod = false;
    switch (period) {
      case ReportPeriod.daily:
        inPeriod = t.date.year == now.year && t.date.month == now.month && t.date.day == now.day;
        break;
      case ReportPeriod.weekly:
        final settings = ref.read(settingsProvider).value ?? const SettingsEntity();
        int daysToSubtract = settings.firstDayOfWeek == 1 ? now.weekday - 1 : now.weekday % 7;
        final startOfWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: daysToSubtract));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        inPeriod = t.date.isAfter(startOfWeek.subtract(const Duration(days: 1))) && 
                   t.date.isBefore(endOfWeek.add(const Duration(days: 1)));
        break;
      case ReportPeriod.monthly:
        inPeriod = t.date.year == now.year && t.date.month == now.month;
        break;
      case ReportPeriod.yearly:
        inPeriod = t.date.year == now.year;
        break;
    }

    if (inPeriod) {
      if (t.type.name == 'income') {
        income += t.amount;
      } else {
        expense += t.amount;
      }
    }
  }

  return AsyncValue.data({'income': income, 'expense': expense});
});

final timeSeriesSpendingProvider = Provider<AsyncValue<List<TimeSeriesData>>>((ref) {
  final transactionsState = ref.watch(transactionsProvider);
  final period = ref.watch(selectedReportPeriodProvider);

  if (transactionsState.isLoading) return const AsyncValue.loading();
  if (transactionsState.hasError) return AsyncValue.error(transactionsState.error!, transactionsState.stackTrace!);

  final transactions = transactionsState.value ?? [];
  final now = DateTime.now();
  final Map<DateTime, double> grouped = {};

  for (var t in transactions) {
    if (t.type.name != 'expense') continue;

    DateTime keyDate = now;
    bool inPeriod = false;

    switch (period) {
      case ReportPeriod.daily:
        // Show hours for today
        inPeriod = t.date.year == now.year && t.date.month == now.month && t.date.day == now.day;
        keyDate = DateTime(t.date.year, t.date.month, t.date.day, t.date.hour);
        break;
      case ReportPeriod.weekly:
        // Show days of this week
        final settings = ref.read(settingsProvider).value ?? const SettingsEntity();
        int daysToSubtract = settings.firstDayOfWeek == 1 ? now.weekday - 1 : now.weekday % 7;
        final startOfWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: daysToSubtract));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        inPeriod = t.date.isAfter(startOfWeek.subtract(const Duration(days: 1))) && 
                   t.date.isBefore(endOfWeek.add(const Duration(days: 1)));
        keyDate = DateTime(t.date.year, t.date.month, t.date.day);
        break;
      case ReportPeriod.monthly:
        // Show days of this month
        inPeriod = t.date.year == now.year && t.date.month == now.month;
        keyDate = DateTime(t.date.year, t.date.month, t.date.day);
        break;
      case ReportPeriod.yearly:
        // Show months of this year
        inPeriod = t.date.year == now.year;
        keyDate = DateTime(t.date.year, t.date.month, 1);
        break;
    }

    if (inPeriod) {
      grouped[keyDate] = (grouped[keyDate] ?? 0) + t.amount;
    }
  }

  final result = grouped.entries.map((e) => TimeSeriesData(e.key, e.value)).toList();
  result.sort((a, b) => a.date.compareTo(b.date));

  return AsyncValue.data(result);
});
