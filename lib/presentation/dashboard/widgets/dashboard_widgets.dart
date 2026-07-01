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
            Expanded(child: _buildInfoCard(context, 'Income', CurrencyFormatter.format(income, settings), Colors.green, Icons.arrow_downward)),
            const SizedBox(width: 16),
            Expanded(child: _buildInfoCard(context, 'Expense', CurrencyFormatter.format(expense, settings), Colors.red, Icons.arrow_upward)),
          ],
        ),
      ],
    );
  }

  Widget _buildBalanceCard(BuildContext context, String amount, String saved) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.primary.withValues(alpha: 0.8),
            colorScheme.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Balance',
                style: TextStyle(
                  fontSize: 16,
                  color: colorScheme.onPrimary.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: colorScheme.onPrimary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.savings, size: 14, color: colorScheme.onPrimary),
                    const SizedBox(width: 4),
                    Text(
                      'Saved $saved',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            amount,
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: colorScheme.onPrimary,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Updated just now',
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onPrimary.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, String amount, Color color, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  amount,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
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
    final colorScheme = Theme.of(context).colorScheme;
    
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
          'Overview',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildStatCard(context, 'Today', CurrencyFormatter.format(today, settings))),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard(context, 'This Week', CurrencyFormatter.format(week, settings))),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard(context, 'This Month', CurrencyFormatter.format(month, settings))),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Spending vs Income',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              '${(progress * 100).toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: progress > 0.8 ? Colors.red : colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 12,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOutCubic,
              height: 12,
              width: MediaQuery.of(context).size.width * progress,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: progress > 0.8 
                      ? [Colors.orange, Colors.red] 
                      : [colorScheme.primary.withValues(alpha: 0.6), colorScheme.primary],
                ),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String amount) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class RecentTransactions extends ConsumerWidget {
  const RecentTransactions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsState = ref.watch(transactionsProvider);
    final colorScheme = Theme.of(context).colorScheme;
    
    return transactionsState.when(
      data: (transactions) {
        if (transactions.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                children: [
                  Icon(Icons.receipt_long, size: 64, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
                  const SizedBox(height: 16),
                  Text(
                    'No transactions yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first income or expense!',
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: transactions.length > 5 ? 5 : transactions.length,
          itemBuilder: (context, index) {
            final t = transactions[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: TransactionItem(transaction: t),
            );
          },
        );
      },
      loading: () => const Center(child: Padding(padding: EdgeInsets.all(32.0), child: CircularProgressIndicator())),
      error: (e, st) => Center(child: Text('Error: $e')),
    );
  }
}
