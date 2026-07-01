import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneytrackerapp/presentation/dashboard/providers/dashboard_provider.dart';
import 'package:moneytrackerapp/core/utils/currency_formatter.dart';
import 'package:moneytrackerapp/domain/entities/settings.dart';
import 'package:moneytrackerapp/presentation/settings/providers/settings_provider.dart';
import 'package:moneytrackerapp/presentation/transactions/widgets/transaction_item.dart';

class SummaryCards extends ConsumerWidget {
  const SummaryCards({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balance = ref.watch(currentBalanceProvider);
    final income = ref.watch(totalIncomeProvider);
    final expense = ref.watch(totalExpenseProvider);
    final saved = ref.watch(monthlySavingsProvider);
    final settings = ref.watch(settingsProvider).value ?? const SettingsEntity();

    return Column(
      children: [
        _buildBalanceCard(context, CurrencyFormatter.format(balance, settings), CurrencyFormatter.format(saved, settings)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildInfoCard(context, 'Income', CurrencyFormatter.format(income, settings), Colors.green)),
            const SizedBox(width: 16),
            Expanded(child: _buildInfoCard(context, 'Expense', CurrencyFormatter.format(expense, settings), Colors.red)),
          ],
        ),
      ],
    );
  }

  Widget _buildBalanceCard(BuildContext context, String amount, String saved) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Balance',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            'Saved this month: \$saved',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, String amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                ),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }
}

class SpendingOverview extends ConsumerWidget {
  const SpendingOverview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(todaySpendingProvider);
    final week = ref.watch(weekSpendingProvider);
    final month = ref.watch(monthSpendingProvider);
    final income = ref.watch(totalIncomeProvider);
    final expense = ref.watch(totalExpenseProvider);
    
    double progress = 0.0;
    if (income > 0) {
      progress = expense / income;
      if (progress > 1.0) progress = 1.0;
    }
    final settings = ref.watch(settingsProvider).value ?? const SettingsEntity();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Spending Overview',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildStatCol(context, 'Today', CurrencyFormatter.format(today, settings)),
            _buildStatCol(context, 'This Week', CurrencyFormatter.format(week, settings)),
            _buildStatCol(context, 'This Month', CurrencyFormatter.format(month, settings)),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Spending Progress (Expense / Income)',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          color: progress > 0.8 ? Colors.red : Theme.of(context).colorScheme.primary,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildStatCol(BuildContext context, String label, String amount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}

class RecentTransactions extends ConsumerWidget {
  const RecentTransactions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsState = ref.watch(transactionsProvider);
    return transactionsState.when(
      data: (transactions) {
        if (transactions.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text('No transactions yet.'),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: transactions.length > 5 ? 5 : transactions.length,
          itemBuilder: (context, index) {
            final t = transactions[index];
            return TransactionItem(transaction: t);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: $e')),
    );
  }
}
