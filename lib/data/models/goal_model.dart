import 'package:moneytrackerapp/domain/entities/goal.dart';

class GoalModel extends GoalEntity {
  const GoalModel({
    required super.id,
    required super.name,
    required super.targetAmount,
    required super.savedAmount,
    required super.deadline,
  });

  factory GoalModel.fromJson(Map<String, dynamic> json) {
    return GoalModel(
      id: json['id'],
      name: json['name'],
      targetAmount: json['targetAmount'],
      savedAmount: json['savedAmount'],
      deadline: DateTime.parse(json['deadline']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'targetAmount': targetAmount,
      'savedAmount': savedAmount,
      'deadline': deadline.toIso8601String(),
    };
  }

  factory GoalModel.fromEntity(GoalEntity entity) {
    return GoalModel(
      id: entity.id,
      name: entity.name,
      targetAmount: entity.targetAmount,
      savedAmount: entity.savedAmount,
      deadline: entity.deadline,
    );
  }
}
