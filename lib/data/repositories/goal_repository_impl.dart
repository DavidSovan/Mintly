import 'package:moneytrackerapp/data/datasources/database_helper.dart';
import 'package:moneytrackerapp/data/models/goal_model.dart';
import 'package:moneytrackerapp/domain/entities/goal.dart';
import 'package:moneytrackerapp/domain/repositories/goal_repository.dart';

class GoalRepositoryImpl implements GoalRepository {
  final DatabaseHelper _dbHelper;

  GoalRepositoryImpl(this._dbHelper);

  @override
  Future<List<GoalEntity>> getGoals() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('goals');
    return List.generate(maps.length, (i) {
      return GoalModel.fromJson(maps[i]);
    });
  }

  @override
  Future<void> addGoal(GoalEntity goal) async {
    final db = await _dbHelper.database;
    final model = GoalModel.fromEntity(goal);
    await db.insert('goals', model.toJson());
  }

  @override
  Future<void> updateGoal(GoalEntity goal) async {
    final db = await _dbHelper.database;
    final model = GoalModel.fromEntity(goal);
    await db.update(
      'goals',
      model.toJson(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  @override
  Future<void> deleteGoal(String id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'goals',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
