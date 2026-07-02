class BudgetEntity {
  final String id;
  final List<String> categoryIds;
  final double amount;
  final String period; // 'monthly' or 'weekly'

  const BudgetEntity({
    required this.id,
    required this.categoryIds,
    required this.amount,
    required this.period,
  });
}
