import 'package:moneytrackerapp/data/datasources/database_helper.dart';
import 'package:moneytrackerapp/data/models/budget_model.dart';
import 'package:moneytrackerapp/domain/entities/budget.dart';
import 'package:moneytrackerapp/domain/repositories/budget_repository.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  final DatabaseHelper _dbHelper;

  BudgetRepositoryImpl(this._dbHelper);

  @override
  Future<List<BudgetEntity>> getBudgets() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('budgets');
    return List.generate(maps.length, (i) {
      return BudgetModel.fromJson(maps[i]);
    });
  }

  @override
  Future<void> addBudget(BudgetEntity budget) async {
    final db = await _dbHelper.database;
    final model = BudgetModel.fromEntity(budget);
    await db.insert('budgets', model.toJson());
  }

  @override
  Future<void> updateBudget(BudgetEntity budget) async {
    final db = await _dbHelper.database;
    final model = BudgetModel.fromEntity(budget);
    await db.update(
      'budgets',
      model.toJson(),
      where: 'id = ?',
      whereArgs: [budget.id],
    );
  }

  @override
  Future<void> deleteBudget(String id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'budgets',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
