import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneytrackerapp/core/providers/global_providers.dart';
import 'package:moneytrackerapp/domain/entities/transaction.dart';

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
  return transactionsState.maybeWhen(
    data: (transactions) {
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));
      
      return transactions
          .where((t) => t.type == TransactionType.expense && t.date.isAfter(startOfWeek.subtract(const Duration(days: 1))) && t.date.isBefore(endOfWeek.add(const Duration(days: 1))))
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
