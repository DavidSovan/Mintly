import 'package:moneytrackerapp/domain/entities/transaction.dart';

class CategoryEntity {
  final String id;
  final String name;
  final TransactionType type;
  final int iconCodePoint;
  final int colorValue;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.type,
    required this.iconCodePoint,
    required this.colorValue,
  });
}
