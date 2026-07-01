import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneytrackerapp/core/providers/global_providers.dart';
import 'package:moneytrackerapp/domain/entities/account.dart';
import 'package:moneytrackerapp/domain/entities/transaction.dart';
import 'package:moneytrackerapp/presentation/dashboard/providers/dashboard_provider.dart';

class AccountNotifier extends AsyncNotifier<List<AccountEntity>> {
  @override
  Future<List<AccountEntity>> build() async {
    return _loadAccounts();
  }

  Future<List<AccountEntity>> _loadAccounts() async {
    final repository = ref.read(accountRepositoryProvider);
    return await repository.getAccounts();
  }

  Future<void> addAccount(AccountEntity account) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(accountRepositoryProvider);
      await repository.addAccount(account);
      final accounts = await _loadAccounts();
      state = AsyncValue.data(accounts);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> updateAccount(AccountEntity account) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(accountRepositoryProvider);
      await repository.updateAccount(account);
      final accounts = await _loadAccounts();
      state = AsyncValue.data(accounts);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> deleteAccount(String id) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(accountRepositoryProvider);
      await repository.deleteAccount(id);
      final accounts = await _loadAccounts();
      state = AsyncValue.data(accounts);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

final accountsProvider = AsyncNotifierProvider<AccountNotifier, List<AccountEntity>>(() {
  return AccountNotifier();
});

// A provider that calculates the real-time balance of each account
final accountBalancesProvider = Provider<Map<String, double>>((ref) {
  final accountsState = ref.watch(accountsProvider);
  final transactionsState = ref.watch(transactionsProvider);

  final Map<String, double> balances = {};
  
  if (accountsState is AsyncData && transactionsState is AsyncData) {
    for (var acc in accountsState.value!) {
      balances[acc.id] = acc.initialBalance;
    }
    
    for (var t in transactionsState.value!) {
      if (balances.containsKey(t.accountId)) {
        if (t.type == TransactionType.income) {
          balances[t.accountId] = balances[t.accountId]! + t.amount;
        } else {
          balances[t.accountId] = balances[t.accountId]! - t.amount;
        }
      }
    }
  }
  return balances;
});
