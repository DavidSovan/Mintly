import 'package:moneytrackerapp/domain/entities/transaction.dart';

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    required super.title,
    required super.amount,
    required super.date,
    required super.type,
    required super.category,
    required super.note,
    required super.paymentMethod,
    required super.accountId,
    super.attachmentPath,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      title: json['title'],
      amount: json['amount'],
      date: DateTime.parse(json['date']),
      type: json['type'] == 'income' ? TransactionType.income : TransactionType.expense,
      category: json['category'],
      note: json['note'] ?? '',
      paymentMethod: json['paymentMethod'] ?? '',
      accountId: json['accountId'] ?? 'acc_cash',
      attachmentPath: json['attachmentPath'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'type': type == TransactionType.income ? 'income' : 'expense',
      'category': category,
      'note': note,
      'paymentMethod': paymentMethod,
      'accountId': accountId,
      'attachmentPath': attachmentPath,
    };
  }

  factory TransactionModel.fromEntity(TransactionEntity entity) {
    return TransactionModel(
      id: entity.id,
      title: entity.title,
      amount: entity.amount,
      date: entity.date,
      type: entity.type,
      category: entity.category,
      note: entity.note,
      paymentMethod: entity.paymentMethod,
      accountId: entity.accountId,
      attachmentPath: entity.attachmentPath,
    );
  }
}
