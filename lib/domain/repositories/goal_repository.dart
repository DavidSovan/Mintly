import 'package:moneytrackerapp/domain/entities/goal.dart';

abstract class GoalRepository {
  Future<List<GoalEntity>> getGoals();
  Future<void> addGoal(GoalEntity goal);
  Future<void> updateGoal(GoalEntity goal);
  Future<void> deleteGoal(String id);
}
