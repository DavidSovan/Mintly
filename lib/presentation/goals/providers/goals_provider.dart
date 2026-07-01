import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneytrackerapp/domain/entities/goal.dart';
import 'package:moneytrackerapp/core/providers/global_providers.dart';

class GoalsNotifier extends AsyncNotifier<List<GoalEntity>> {
  @override
  Future<List<GoalEntity>> build() async {
    return _fetchGoals();
  }

  Future<List<GoalEntity>> _fetchGoals() async {
    final repository = ref.read(goalRepositoryProvider);
    return repository.getGoals();
  }

  Future<void> addGoal(GoalEntity goal) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(goalRepositoryProvider);
      await repository.addGoal(goal);
      return _fetchGoals();
    });
  }

  Future<void> updateGoal(GoalEntity goal) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(goalRepositoryProvider);
      await repository.updateGoal(goal);
      return _fetchGoals();
    });
  }

  Future<void> deleteGoal(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(goalRepositoryProvider);
      await repository.deleteGoal(id);
      return _fetchGoals();
    });
  }
}

final goalsProvider = AsyncNotifierProvider<GoalsNotifier, List<GoalEntity>>(() {
  return GoalsNotifier();
});
