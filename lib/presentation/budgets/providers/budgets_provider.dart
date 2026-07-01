import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneytrackerapp/core/providers/global_providers.dart';
import 'package:moneytrackerapp/domain/entities/budget.dart';
import 'package:moneytrackerapp/presentation/dashboard/providers/dashboard_provider.dart';
import 'package:moneytrackerapp/presentation/categories/providers/category_provider.dart';

class BudgetsNotifier extends AsyncNotifier<List<BudgetEntity>> {
  @override
  Future<List<BudgetEntity>> build() async {
    return _loadBudgets();
  }

  Future<List<BudgetEntity>> _loadBudgets() async {
    final repository = ref.read(budgetRepositoryProvider);
    return await repository.getBudgets();
  }

  Future<void> addBudget(BudgetEntity budget) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(budgetRepositoryProvider);
      await repository.addBudget(budget);
      final budgets = await _loadBudgets();
      state = AsyncValue.data(budgets);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateBudget(BudgetEntity budget) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(budgetRepositoryProvider);
      await repository.updateBudget(budget);
      final budgets = await _loadBudgets();
      state = AsyncValue.data(budgets);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteBudget(String id) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(budgetRepositoryProvider);
      await repository.deleteBudget(id);
      final budgets = await _loadBudgets();
      state = AsyncValue.data(budgets);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final budgetsProvider = AsyncNotifierProvider<BudgetsNotifier, List<BudgetEntity>>(() {
  return BudgetsNotifier();
});

class BudgetProgress {
  final BudgetEntity budget;
  final double spent;
  final double remaining;
  final double progressPercentage;
  final String categoryName;
  
  BudgetProgress({
    required this.budget,
    required this.spent,
    required this.categoryName,
  }) : remaining = budget.amount - spent,
       progressPercentage = (budget.amount > 0) ? (spent / budget.amount).clamp(0.0, 1.0) : 0.0;
}

final budgetProgressListProvider = Provider<AsyncValue<List<BudgetProgress>>>((ref) {
  final budgetsState = ref.watch(budgetsProvider);
  final transactionsState = ref.watch(transactionsProvider);
  final categoriesState = ref.watch(categoriesProvider);
  
  if (budgetsState.isLoading || transactionsState.isLoading || categoriesState.isLoading) {
    return const AsyncValue.loading();
  }
  
  if (budgetsState.hasError) return AsyncValue.error(budgetsState.error!, budgetsState.stackTrace!);
  if (transactionsState.hasError) return AsyncValue.error(transactionsState.error!, transactionsState.stackTrace!);
  if (categoriesState.hasError) return AsyncValue.error(categoriesState.error!, categoriesState.stackTrace!);
  
  final budgets = budgetsState.value ?? [];
  final transactions = transactionsState.value ?? [];
  final categories = categoriesState.value ?? [];
  
  final now = DateTime.now();
  
  final progressList = budgets.map((budget) {
    // Filter transactions for this budget's period
    final periodTransactions = transactions.where((t) {
      if (t.type.name != 'expense') return false; // Budgets only apply to expenses
      if (budget.period == 'monthly') {
        return t.date.year == now.year && t.date.month == now.month;
      } else if (budget.period == 'weekly') {
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        return t.date.isAfter(startOfWeek.subtract(const Duration(days: 1))) && 
               t.date.isBefore(endOfWeek.add(const Duration(days: 1)));
      }
      return false;
    });
    
    // Filter by category
    final relevantTransactions = periodTransactions.where((t) {
      if (budget.categoryId == 'all') return true;
      return t.category == budget.categoryId;
    });
    
    final spent = relevantTransactions.fold(0.0, (sum, t) => sum + t.amount);
    
    String catName = 'Overall';
    if (budget.categoryId != 'all') {
      final cat = categories.where((c) => c.id == budget.categoryId).firstOrNull;
      catName = cat?.name ?? 'Unknown';
    }
    
    return BudgetProgress(
      budget: budget,
      spent: spent,
      categoryName: catName,
    );
  }).toList();
  
  return AsyncValue.data(progressList);
});
