import 'package:moneytrackerapp/domain/entities/category.dart';
import 'package:moneytrackerapp/domain/entities/transaction.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.type,
    required super.iconCodePoint,
    required super.colorValue,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'],
      type: json['type'] == 'income' ? TransactionType.income : TransactionType.expense,
      iconCodePoint: json['iconCodePoint'],
      colorValue: json['colorValue'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type == TransactionType.income ? 'income' : 'expense',
      'iconCodePoint': iconCodePoint,
      'colorValue': colorValue,
    };
  }

  factory CategoryModel.fromEntity(CategoryEntity entity) {
    return CategoryModel(
      id: entity.id,
      name: entity.name,
      type: entity.type,
      iconCodePoint: entity.iconCodePoint,
      colorValue: entity.colorValue,
    );
  }
}
