class GoalEntity {
  final String id;
  final String name;
  final double targetAmount;
  final double savedAmount;
  final DateTime deadline;

  const GoalEntity({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.savedAmount,
    required this.deadline,
  });
}
