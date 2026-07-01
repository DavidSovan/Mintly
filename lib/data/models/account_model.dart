import 'package:moneytrackerapp/domain/entities/account.dart';

class AccountModel extends AccountEntity {
  const AccountModel({
    required super.id,
    required super.name,
    required super.initialBalance,
    required super.iconCodePoint,
    required super.colorValue,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'],
      name: json['name'],
      initialBalance: json['initialBalance'],
      iconCodePoint: json['iconCodePoint'],
      colorValue: json['colorValue'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'initialBalance': initialBalance,
      'iconCodePoint': iconCodePoint,
      'colorValue': colorValue,
    };
  }

  factory AccountModel.fromEntity(AccountEntity entity) {
    return AccountModel(
      id: entity.id,
      name: entity.name,
      initialBalance: entity.initialBalance,
      iconCodePoint: entity.iconCodePoint,
      colorValue: entity.colorValue,
    );
  }
}
