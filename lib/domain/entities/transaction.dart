enum TransactionType { income, expense }

class TransactionEntity {
  final String id;
  final String title; // Let's keep title for summary, or use note. We'll add note as well.
  final double amount;
  final DateTime date;
  final TransactionType type;
  final String category;
  final String note;
  final String paymentMethod;
  final String accountId;
  final String? attachmentPath;

  const TransactionEntity({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
    required this.category,
    required this.note,
    required this.paymentMethod,
    required this.accountId,
    this.attachmentPath,
  });
}
