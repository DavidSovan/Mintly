import 'package:moneytrackerapp/domain/entities/budget.dart';

abstract class BudgetRepository {
  Future<List<BudgetEntity>> getBudgets();
  Future<void> addBudget(BudgetEntity budget);
  Future<void> updateBudget(BudgetEntity budget);
  Future<void> deleteBudget(String id);
}
