import 'package:moneytrackerapp/domain/entities/budget.dart';

class BudgetModel extends BudgetEntity {
  const BudgetModel({
    required super.id,
    required super.categoryIds,
    required super.amount,
    required super.period,
  });

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'],
      categoryIds: (json['categoryId'] as String).split(','),
      amount: json['amount'],
      period: json['period'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryIds.join(','),
      'amount': amount,
      'period': period,
    };
  }

  factory BudgetModel.fromEntity(BudgetEntity entity) {
    return BudgetModel(
      id: entity.id,
      categoryIds: entity.categoryIds,
      amount: entity.amount,
      period: entity.period,
    );
  }
}
