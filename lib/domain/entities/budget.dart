class BudgetEntity {
  final String id;
  final String categoryId;
  final double amount;
  final String period; // 'monthly' or 'weekly'

  const BudgetEntity({
    required this.id,
    required this.categoryId,
    required this.amount,
    required this.period,
  });
}
