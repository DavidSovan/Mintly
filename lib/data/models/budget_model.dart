import 'package:moneytrackerapp/domain/entities/budget.dart';

class BudgetModel extends BudgetEntity {
  const BudgetModel({
    required super.id,
    required super.categoryId,
    required super.amount,
    required super.period,
  });

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'],
      categoryId: json['categoryId'],
      amount: json['amount'],
      period: json['period'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'amount': amount,
      'period': period,
    };
  }

  factory BudgetModel.fromEntity(BudgetEntity entity) {
    return BudgetModel(
      id: entity.id,
      categoryId: entity.categoryId,
      amount: entity.amount,
      period: entity.period,
    );
  }
}
