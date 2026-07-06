import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:moneytrackerapp/presentation/dashboard/providers/dashboard_provider.dart';
import 'package:moneytrackerapp/core/utils/currency_formatter.dart';
import 'package:moneytrackerapp/domain/entities/settings.dart';
import 'package:moneytrackerapp/domain/entities/transaction.dart';
import 'package:moneytrackerapp/presentation/settings/providers/settings_provider.dart';
import 'package:moneytrackerapp/presentation/transactions/widgets/transaction_item.dart';

import 'package:moneytrackerapp/l10n/app_localizations.dart';
class SummaryCards extends ConsumerWidget {
  const SummaryCards({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balance = ref.watch(currentBalanceProvider);
    final income = ref.watch(totalIncomeProvider);
    final expense = ref.watch(totalExpenseProvider);
    final saved = ref.watch(monthlySavingsProvider);
    final settings = ref.watch(settingsProvider).value ?? const SettingsEntity();
    final isBalanceHidden = ref.watch(hideBalanceProvider);

    return Column(
      children: [
        _buildBalanceCard(
          context, 
          ref,
          CurrencyFormatter.format(balance, settings), 
          CurrencyFormatter.format(saved, settings),
          isBalanceHidden,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildInfoCard(context, AppLocalizations.of(context)!.income, isBalanceHidden ? '••••' : CurrencyFormatter.format(income, settings), Theme.of(context).colorScheme.secondary, Icons.arrow_downward)),
            const SizedBox(width: 16),
            Expanded(child: _buildInfoCard(context, AppLocalizations.of(context)!.expense, isBalanceHidden ? '••••' : CurrencyFormatter.format(expense, settings), Theme.of(context).colorScheme.error, Icons.arrow_upward)),
          ],
        ),
      ],
    );
  }

  Widget _buildBalanceCard(BuildContext context, WidgetRef ref, String amount, String saved, bool isHidden) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.primary.withValues(alpha: 0.85),
            colorScheme.tertiary,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 12),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.totalBalance,
                      style: TextStyle(
                        fontSize: 16,
                        color: colorScheme.onPrimary.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        ref.read(hideBalanceProvider.notifier).toggle();
                      },
                      child: Icon(
                        isHidden ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                        color: colorScheme.onPrimary.withValues(alpha: 0.7),
                        size: 20,
                      ),
                    ),
                  ],
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
                      isHidden ? AppLocalizations.of(context)!.savedHidden : AppLocalizations.of(context)!.savedAmount(saved),
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
          const SizedBox(height: 16),
          Text(
            isHidden ? '••••••••' : amount,
            style: TextStyle(
              fontSize: 44,
              fontWeight: FontWeight.w800,
              color: colorScheme.onPrimary,
              letterSpacing: -1.5,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.updatedJustNow,
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  amount,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                    letterSpacing: -0.5,
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
    final thisWeekDays = ref.watch(thisWeekChartProvider);
    final colorScheme = Theme.of(context).colorScheme;
    
    double progress = 0.0;
    if (income > 0) {
      progress = expense / income;
      if (progress > 1.0) progress = 1.0;
    }
    final settings = ref.watch(settingsProvider).value ?? const SettingsEntity();
    final formatCurrency = NumberFormat.compactSimpleCurrency(name: ref.watch(settingsProvider).value?.currency);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.overview,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildStatCard(context, AppLocalizations.of(context)!.today, CurrencyFormatter.format(today, settings))),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard(context, AppLocalizations.of(context)!.thisWeek, CurrencyFormatter.format(week, settings))),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard(context, AppLocalizations.of(context)!.thisMonth, CurrencyFormatter.format(month, settings))),
          ],
        ),
        const SizedBox(height: 24),
        // Spending Chart
        if (thisWeekDays.isNotEmpty && thisWeekDays.any((d) => d.amount > 0)) ...[
          Text(
            AppLocalizations.of(context)!.thisWeekPeriod,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 150,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: thisWeekDays.map((d) => d.amount).reduce((a, b) => a > b ? a : b) * 1.2,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => colorScheme.inverseSurface,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        formatCurrency.format(rod.toY),
                        TextStyle(color: colorScheme.onInverseSurface, fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= thisWeekDays.length) return const SizedBox();
                        final date = thisWeekDays[index].date;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            DateFormat.E().format(date),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: thisWeekDays.asMap().entries.map((e) {
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: e.value.amount,
                        gradient: LinearGradient(
                          colors: [colorScheme.error.withValues(alpha: 0.7), colorScheme.error],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        width: 14,
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.spendingVsIncome,
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
                color: progress > 0.8 ? colorScheme.error : colorScheme.primary,
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
              duration: const Duration(milliseconds: 1200),
              curve: Curves.fastOutSlowIn,
              height: 12,
              width: MediaQuery.of(context).size.width * progress,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: progress > 0.8 
                      ? [Colors.orange, colorScheme.error] 
                      : [colorScheme.primary, colorScheme.tertiary],
                ),
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: (progress > 0.8 ? colorScheme.error : colorScheme.primary).withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
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
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
              letterSpacing: -0.5,
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
                    AppLocalizations.of(context)!.noTransactionsYet,
                    style: TextStyle(
                      fontSize: 16,
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.addFirstIncomeExpense,
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

        final recentTxs = transactions.take(8).toList();
        
        final Map<String, List<TransactionEntity>> grouped = {};
        final now = DateTime.now();
        final yesterday = now.subtract(const Duration(days: 1));
        
        for (var t in recentTxs) {
          final tDate = t.date;
          String dateLabel;
          
          if (tDate.year == now.year && tDate.month == now.month && tDate.day == now.day) {
            dateLabel = 'Today';
          } else if (tDate.year == yesterday.year && tDate.month == yesterday.month && tDate.day == yesterday.day) {
            dateLabel = 'Yesterday';
          } else {
            dateLabel = DateFormat.yMMMd().format(tDate);
          }
          
          grouped.putIfAbsent(dateLabel, () => []).add(t);
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: grouped.length,
          itemBuilder: (context, index) {
            final dateLabel = grouped.keys.elementAt(index);
            final dayTxs = grouped[dateLabel]!;
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4, top: 16, bottom: 8),
                  child: Text(
                    dateLabel,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                ...dayTxs.map((t) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: TransactionItem(transaction: t),
                )),
              ],
            );
          },
        );
      },
      loading: () => const Center(child: Padding(padding: EdgeInsets.all(32.0), child: CircularProgressIndicator())),
      error: (e, st) => Center(child: Text('Error: $e')),
    );
  }
}
