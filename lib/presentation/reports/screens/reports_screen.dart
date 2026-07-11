import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:moneytrackerapp/presentation/reports/providers/reports_provider.dart';

import 'package:moneytrackerapp/l10n/app_localizations.dart';
import 'package:moneytrackerapp/presentation/settings/providers/settings_provider.dart';
class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(selectedReportPeriodProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 0,
            pinned: true,
            backgroundColor: colorScheme.surface,
            elevation: 0,
            title: Text(AppLocalizations.of(context)!.reportsTitle, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
            centerTitle: true,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                children: [
                  // Period selector
                  _PeriodSelector(period: period, ref: ref),
                  const SizedBox(height: 20),
                  // Summary card
                  const _SummaryCard(),
                  const SizedBox(height: 20),
                  // Charts
                  const _IncomeExpenseBarChart(),
                  const SizedBox(height: 16),
                  const _CategoryPieChart(),
                  const SizedBox(height: 16),
                  const _SpendingLineChart(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  final ReportPeriod period;
  final WidgetRef ref;

  const _PeriodSelector({required this.period, required this.ref});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: ReportPeriod.values.map((p) {
          final isSelected = p == period;
          final labels = {
            ReportPeriod.daily: 'Day',
            ReportPeriod.weekly: 'Week',
            ReportPeriod.monthly: 'Month',
            ReportPeriod.yearly: 'Year',
          };
          return Expanded(
            child: GestureDetector(
              onTap: () => ref.read(selectedReportPeriodProvider.notifier).setPeriod(p),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? colorScheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isSelected
                      ? [BoxShadow(color: colorScheme.primary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))]
                      : [],
                ),
                child: Text(
                  labels[p]!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SummaryCard extends ConsumerWidget {
  const _SummaryCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataState = ref.watch(incomeVsExpenseProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final formatCurrency = NumberFormat.simpleCurrency(name: ref.watch(settingsProvider).value?.currency, decimalDigits: 0);

    return dataState.when(
      data: (data) {
        final income = data['income'] ?? 0.0;
        final expense = data['expense'] ?? 0.0;
        final net = income - expense;
        final isPositive = net >= 0;

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primaryContainer,
                colorScheme.secondaryContainer,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.netBalance,
                style: TextStyle(
                  color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatCurrency.format(net.abs()),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: (isPositive ? Colors.green : Colors.red).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPositive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                            size: 13,
                            color: isPositive ? Colors.green.shade700 : Colors.red.shade700,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            isPositive ? 'Surplus' : 'Deficit',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isPositive ? Colors.green.shade700 : Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _SummaryTile(
                      label: AppLocalizations.of(context)!.income,
                      amount: formatCurrency.format(income),
                      icon: Icons.arrow_downward_rounded,
                      color: Colors.green.shade600,
                    ),
                  ),
                  Container(width: 1, height: 40, color: colorScheme.onPrimaryContainer.withValues(alpha: 0.15)),
                  Expanded(
                    child: _SummaryTile(
                      label: AppLocalizations.of(context)!.expensesTitle,
                      amount: formatCurrency.format(expense),
                      icon: Icons.arrow_upward_rounded,
                      color: Colors.red.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => Container(
        height: 160,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => const SizedBox(),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final String amount;
  final IconData icon;
  final Color color;

  const _SummaryTile({required this.label, required this.amount, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: colorScheme.onPrimaryContainer.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                amount,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

// ─── Chart Card Shell ─────────────────────────────────────────────────────────

class _ChartCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget child;

  const _ChartCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    if (subtitle != null)
                      Text(subtitle!, style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            child,
          ],
        ),
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final Color color;

  const _EmptyState({required this.icon, required this.message, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, size: 32, color: color.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 12),
            Text(message, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

// ─── Income vs Expense Bar Chart ──────────────────────────────────────────────

class _IncomeExpenseBarChart extends ConsumerWidget {
  const _IncomeExpenseBarChart();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataState = ref.watch(incomeVsExpenseProvider);
    final formatCurrency = NumberFormat.compactSimpleCurrency(name: ref.watch(settingsProvider).value?.currency);
    final colorScheme = Theme.of(context).colorScheme;

    return _ChartCard(
      icon: Icons.bar_chart_rounded,
      iconColor: colorScheme.primary,
      title: AppLocalizations.of(context)!.incomeVsExpenses,
      subtitle: AppLocalizations.of(context)!.sideBySideComparison,
      child: dataState.when(
        data: (data) {
          final income = data['income'] ?? 0.0;
          final expense = data['expense'] ?? 0.0;

          if (income == 0 && expense == 0) {
            return _EmptyState(
              icon: Icons.bar_chart_outlined,
              message: AppLocalizations.of(context)!.noDataForPeriod,
              color: colorScheme.primary,
            );
          }

          final maxVal = (income > expense ? income : expense) * 1.25;

          return Column(
            children: [
              // Legend row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _LegendDot(color: Colors.green.shade500, label: AppLocalizations.of(context)!.income),
                  const SizedBox(width: 20),
                  _LegendDot(color: colorScheme.error, label: AppLocalizations.of(context)!.expensesTitle),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: maxVal == 0 ? 100 : maxVal,
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
                          getTitlesWidget: (double value, TitleMeta meta) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Text(
                                value == 0 ? 'Income' : 'Expenses',
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: colorScheme.onSurfaceVariant),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 50,
                          getTitlesWidget: (value, meta) {
                            if (value == 0 || value == maxVal) return const SizedBox();
                            return Padding(
                              padding: const EdgeInsets.only(right: 6.0),
                              child: Text(formatCurrency.format(value), style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant), textAlign: TextAlign.right),
                            );
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (value) => FlLine(color: colorScheme.outlineVariant.withValues(alpha: 0.2), strokeWidth: 1, dashArray: [5, 5]),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: [
                      BarChartGroupData(
                        x: 0,
                        barRods: [
                          BarChartRodData(
                            toY: income,
                            gradient: LinearGradient(
                              colors: [Colors.green.shade400, Colors.green.shade600],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                            width: 40,
                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
                          ),
                        ],
                      ),
                      BarChartGroupData(
                        x: 1,
                        barRods: [
                          BarChartRodData(
                            toY: expense,
                            gradient: LinearGradient(
                              colors: [colorScheme.error.withValues(alpha: 0.7), colorScheme.error],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                            width: 40,
                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

// ─── Category Pie Chart ───────────────────────────────────────────────────────

class _CategoryPieChart extends ConsumerWidget {
  const _CategoryPieChart();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataState = ref.watch(categoryExpenseProvider);
    final formatCurrency = NumberFormat.compactSimpleCurrency(name: ref.watch(settingsProvider).value?.currency);
    final colorScheme = Theme.of(context).colorScheme;

    return _ChartCard(
      icon: Icons.donut_large_rounded,
      iconColor: colorScheme.secondary,
      title: AppLocalizations.of(context)!.expensesByCategory,
      subtitle: AppLocalizations.of(context)!.whereYourMoneyGoes,
      child: dataState.when(
        data: (data) {
          if (data.isEmpty) {
            return _EmptyState(
              icon: Icons.pie_chart_outline_rounded,
              message: AppLocalizations.of(context)!.noExpensesPeriod,
              color: colorScheme.secondary,
            );
          }

          final total = data.fold(0.0, (sum, item) => sum + item.amount);

          return Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 5,
                    child: SizedBox(
                      height: 220,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 3,
                          centerSpaceRadius: 50,
                          sections: data.map((item) {
                            final percentage = (item.amount / total * 100);
                            return PieChartSectionData(
                              color: Color(item.colorValue),
                              value: item.amount,
                              title: percentage >= 8 ? '${percentage.toStringAsFixed(0)}%' : '',
                              radius: 52,
                              titleStyle: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [Shadow(color: Colors.black26, blurRadius: 4)],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 32),
                  Expanded(
                    flex: 4,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: data.map((item) {
                        final percentage = (item.amount / total * 100).toStringAsFixed(0);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: Color(item.colorValue),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.categoryName,
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      '${formatCurrency.format(item.amount)} · $percentage%',
                                      style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Total row
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.totalExpenses,
                      style: TextStyle(fontWeight: FontWeight.w600, color: colorScheme.onSurface),
                    ),
                    Text(
                      formatCurrency.format(total),
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: colorScheme.error),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const SizedBox(height: 220, child: Center(child: CircularProgressIndicator())),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

// ─── Spending Line Chart ──────────────────────────────────────────────────────

class _SpendingLineChart extends ConsumerWidget {
  const _SpendingLineChart();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataState = ref.watch(timeSeriesSpendingProvider);
    final period = ref.watch(selectedReportPeriodProvider);
    final formatCurrency = NumberFormat.compactSimpleCurrency(name: ref.watch(settingsProvider).value?.currency);
    final colorScheme = Theme.of(context).colorScheme;

    return _ChartCard(
      icon: Icons.trending_down_rounded,
      iconColor: colorScheme.error,
      title: AppLocalizations.of(context)!.spendingTrend,
      subtitle: AppLocalizations.of(context)!.expenseOverTime,
      child: dataState.when(
        data: (data) {
          if (data.isEmpty) {
            return _EmptyState(
              icon: Icons.show_chart_rounded,
              message: AppLocalizations.of(context)!.noTrendData,
              color: colorScheme.error,
            );
          }

          double maxVal = 0;
          for (var d in data) {
            if (d.amount > maxVal) maxVal = d.amount;
          }
          if (maxVal == 0) maxVal = 100;

          final spots = data.asMap().entries.map((e) {
            return FlSpot(e.key.toDouble(), e.value.amount);
          }).toList();

          return SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (group) => colorScheme.inverseSurface,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final date = data[spot.x.toInt()].date;
                        String dateStr = '';
                        if (period == ReportPeriod.daily) {
                          dateStr = DateFormat.jm().format(date);
                        } else if (period == ReportPeriod.yearly) {
                          dateStr = DateFormat.MMM().format(date);
                        } else {
                          dateStr = DateFormat.MMMd().format(date);
                        }
                        return LineTooltipItem(
                          '$dateStr\n${formatCurrency.format(spot.y)}',
                          TextStyle(color: colorScheme.onInverseSurface, fontWeight: FontWeight.bold, height: 1.6),
                        );
                      }).toList();
                    },
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.2),
                    strokeWidth: 1,
                    dashArray: [5, 5],
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= data.length) return const SizedBox();
                        if (data.length > 7 && index % 2 != 0) return const SizedBox();
                        final date = data[index].date;
                        String label = '';
                        if (period == ReportPeriod.daily) {
                          label = DateFormat.j().format(date);
                        } else if (period == ReportPeriod.yearly) {
                          label = DateFormat.MMM().format(date);
                        } else {
                          label = DateFormat.d().format(date);
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(label, style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600)),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) {
                        if (value == 0 || value == maxVal * 1.2) return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.only(right: 6.0),
                          child: Text(formatCurrency.format(value), style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant), textAlign: TextAlign.right),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: colorScheme.error,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: data.length <= 15,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: colorScheme.surface,
                          strokeWidth: 2.5,
                          strokeColor: colorScheme.error,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          colorScheme.error.withValues(alpha: 0.25),
                          colorScheme.error.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ],
                minY: 0,
                maxY: maxVal * 1.2,
              ),
            ),
          );
        },
        loading: () => const SizedBox(height: 220, child: Center(child: CircularProgressIndicator())),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ],
    );
  }
}
