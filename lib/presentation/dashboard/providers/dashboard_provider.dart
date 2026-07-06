import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneytrackerapp/core/providers/global_providers.dart';
import 'package:moneytrackerapp/domain/entities/transaction.dart';
import 'package:moneytrackerapp/domain/entities/settings.dart';
import 'package:moneytrackerapp/presentation/settings/providers/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
class TransactionNotifier extends AsyncNotifier<List<TransactionEntity>> {
  @override
  Future<List<TransactionEntity>> build() async {
    return _loadTransactions();
  }

  Future<List<TransactionEntity>> _loadTransactions() async {
    final repository = ref.read(transactionRepositoryProvider);
    return await repository.getTransactions();
  }

  Future<void> addTransaction(TransactionEntity transaction) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(transactionRepositoryProvider);
      await repository.addTransaction(transaction);
      final transactions = await _loadTransactions();
      state = AsyncValue.data(transactions);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> updateTransaction(TransactionEntity transaction) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(transactionRepositoryProvider);
      await repository.updateTransaction(transaction);
      final transactions = await _loadTransactions();
      state = AsyncValue.data(transactions);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> deleteTransaction(String id) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(transactionRepositoryProvider);
      await repository.deleteTransaction(id);
      final transactions = await _loadTransactions();
      state = AsyncValue.data(transactions);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

final transactionsProvider =
    AsyncNotifierProvider<TransactionNotifier, List<TransactionEntity>>(() {
  return TransactionNotifier();
});

final currentBalanceProvider = Provider<double>((ref) {
  final transactionsState = ref.watch(transactionsProvider);
  return transactionsState.maybeWhen(
    data: (transactions) {
      double balance = 0;
      for (var t in transactions) {
        if (t.type == TransactionType.income) {
          balance += t.amount;
        } else {
          balance -= t.amount;
        }
      }
      return balance;
    },
    orElse: () => 0.0,
  );
});

final totalIncomeProvider = Provider<double>((ref) {
  final transactionsState = ref.watch(transactionsProvider);
  return transactionsState.maybeWhen(
    data: (transactions) {
      return transactions
          .where((t) => t.type == TransactionType.income)
          .fold(0.0, (sum, t) => sum + t.amount);
    },
    orElse: () => 0.0,
  );
});

final totalExpenseProvider = Provider<double>((ref) {
  final transactionsState = ref.watch(transactionsProvider);
  return transactionsState.maybeWhen(
    data: (transactions) {
      return transactions
          .where((t) => t.type == TransactionType.expense)
          .fold(0.0, (sum, t) => sum + t.amount);
    },
    orElse: () => 0.0,
  );
});

// Calculate Monthly Savings
final monthlySavingsProvider = Provider<double>((ref) {
  final transactionsState = ref.watch(transactionsProvider);
  return transactionsState.maybeWhen(
    data: (transactions) {
      final now = DateTime.now();
      final thisMonth = transactions.where((t) => t.date.year == now.year && t.date.month == now.month);
      
      final income = thisMonth.where((t) => t.type == TransactionType.income).fold(0.0, (sum, t) => sum + t.amount);
      final expense = thisMonth.where((t) => t.type == TransactionType.expense).fold(0.0, (sum, t) => sum + t.amount);
      
      return income - expense;
    },
    orElse: () => 0.0,
  );
});

// Calculate Today's Spending
final todaySpendingProvider = Provider<double>((ref) {
  final transactionsState = ref.watch(transactionsProvider);
  return transactionsState.maybeWhen(
    data: (transactions) {
      final now = DateTime.now();
      return transactions
          .where((t) => t.type == TransactionType.expense && t.date.year == now.year && t.date.month == now.month && t.date.day == now.day)
          .fold(0.0, (sum, t) => sum + t.amount);
    },
    orElse: () => 0.0,
  );
});

// Calculate This Week's Spending
final weekSpendingProvider = Provider<double>((ref) {
  final transactionsState = ref.watch(transactionsProvider);
  final settings = ref.watch(settingsProvider).value ?? const SettingsEntity();
  
  return transactionsState.maybeWhen(
    data: (transactions) {
      final now = DateTime.now();
      int daysToSubtract = settings.firstDayOfWeek == 1 ? now.weekday - 1 : now.weekday % 7;
      final startOfWeek = DateTime(now.year, now.month, now.day - daysToSubtract);
      final endOfWeek = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day + 6);
      
      return transactions
          .where((t) => t.type == TransactionType.expense && (t.date.compareTo(startOfWeek) >= 0) && t.date.isBefore(DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day + 1)))
          .fold(0.0, (sum, t) => sum + t.amount);
    },
    orElse: () => 0.0,
  );
});

// Calculate This Month's Spending
final monthSpendingProvider = Provider<double>((ref) {
  final transactionsState = ref.watch(transactionsProvider);
  return transactionsState.maybeWhen(
    data: (transactions) {
      final now = DateTime.now();
      return transactions
          .where((t) => t.type == TransactionType.expense && t.date.year == now.year && t.date.month == now.month)
          .fold(0.0, (sum, t) => sum + t.amount);
    },
    orElse: () => 0.0,
  );
});

// Hide Balance Toggle
class HideBalanceNotifier extends Notifier<bool> {
  static const _prefsKey = 'hide_balance';

  @override
  bool build() {
    _loadState();
    return false;
  }
  
  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_prefsKey) ?? false;
  }
  
  Future<void> toggle() async {
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, state);
  }
}

final hideBalanceProvider = NotifierProvider<HideBalanceNotifier, bool>(() {
  return HideBalanceNotifier();
});

class DailySpending {
  final DateTime date;
  final double amount;
  DailySpending(this.date, this.amount);
}

// Calculate This Week's Spending Chart
final thisWeekChartProvider = Provider<List<DailySpending>>((ref) {
  final transactionsState = ref.watch(transactionsProvider);
  final settings = ref.watch(settingsProvider).value ?? const SettingsEntity();
  
  return transactionsState.maybeWhen(
    data: (transactions) {
      final now = DateTime.now();
      int daysToSubtract = settings.firstDayOfWeek == 1 ? now.weekday - 1 : now.weekday % 7;
      final startOfWeek = DateTime(now.year, now.month, now.day - daysToSubtract);
      
      final currentWeekDays = List.generate(7, (i) => DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day + i));
      
      return currentWeekDays.map((date) {
        final amount = transactions
            .where((t) => t.type == TransactionType.expense && t.date.year == date.year && t.date.month == date.month && t.date.day == date.day)
            .fold(0.0, (sum, t) => sum + t.amount);
        return DailySpending(date, amount);
      }).toList();
    },
    orElse: () => [],
  );
});
