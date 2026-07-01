import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:moneytrackerapp/presentation/reports/providers/reports_provider.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(selectedReportPeriodProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Reports', style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: SegmentedButton<ReportPeriod>(
                style: SegmentedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  selectedForegroundColor: colorScheme.onPrimary,
                  selectedBackgroundColor: colorScheme.primary,
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                segments: const [
                  ButtonSegment(value: ReportPeriod.daily, label: Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('Day'))),
                  ButtonSegment(value: ReportPeriod.weekly, label: Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('Week'))),
                  ButtonSegment(value: ReportPeriod.monthly, label: Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('Month'))),
                  ButtonSegment(value: ReportPeriod.yearly, label: Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('Year'))),
                ],
                selected: {period},
                showSelectedIcon: false,
                onSelectionChanged: (Set<ReportPeriod> newSelection) {
                  ref.read(selectedReportPeriodProvider.notifier).setPeriod(newSelection.first);
                },
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: const [
                  SizedBox(height: 16),
                  _IncomeExpenseBarChart(),
                  SizedBox(height: 16),
                  _CategoryPieChart(),
                  SizedBox(height: 16),
                  _SpendingLineChart(),
                  SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IncomeExpenseBarChart extends ConsumerWidget {
  const _IncomeExpenseBarChart();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataState = ref.watch(incomeVsExpenseProvider);
    final formatCurrency = NumberFormat.compactSimpleCurrency();
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bar_chart, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text('Income vs Expense', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 200,
              child: dataState.when(
                data: (data) {
                  final income = data['income'] ?? 0.0;
                  final expense = data['expense'] ?? 0.0;
                  final maxVal = (income > expense ? income : expense) * 1.2;
                  
                  if (income == 0 && expense == 0) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.insert_chart_outlined, size: 48, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                          const SizedBox(height: 8),
                          Text('No data for this period', style: TextStyle(color: colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    );
                  }

                  return BarChart(
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
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  value == 0 ? 'Income' : 'Expense',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: colorScheme.onSurfaceVariant),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 44,
                            getTitlesWidget: (value, meta) {
                              if (value == 0 || value == maxVal) return const SizedBox();
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
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
                              color: Colors.green.shade500,
                              width: 32,
                              borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)),
                            ),
                          ],
                        ),
                        BarChartGroupData(
                          x: 1,
                          barRods: [
                            BarChartRodData(
                              toY: expense,
                              color: Colors.red.shade500,
                              width: 32,
                              borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text('Error: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryPieChart extends ConsumerWidget {
  const _CategoryPieChart();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataState = ref.watch(categoryExpenseProvider);
    final formatCurrency = NumberFormat.compactSimpleCurrency();
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.pie_chart, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text('Expense by Category', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 250,
              child: dataState.when(
                data: (data) {
                  if (data.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.donut_large, size: 48, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                          const SizedBox(height: 8),
                          Text('No expenses in this period', style: TextStyle(color: colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    );
                  }
                  
                  final total = data.fold(0.0, (sum, item) => sum + item.amount);

                  return Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 4,
                            centerSpaceRadius: 45,
                            sections: data.map((item) {
                              final percentage = (item.amount / total * 100);
                              return PieChartSectionData(
                                color: Color(item.colorValue),
                                value: item.amount,
                                title: '${percentage.toStringAsFixed(0)}%',
                                radius: 45,
                                titleStyle: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                badgeWidget: percentage > 5 ? null : const SizedBox(),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 4,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: data.length,
                          itemBuilder: (context, index) {
                            final item = data[index];
                            final percentage = (item.amount / total * 100).toStringAsFixed(0);
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: Color(item.colorValue),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.categoryName, 
                                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold), 
                                          overflow: TextOverflow.ellipsis
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              formatCurrency.format(item.amount), 
                                              style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant)
                                            ),
                                            Text(
                                              ' • $percentage%', 
                                              style: TextStyle(fontSize: 11, color: colorScheme.primary)
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text('Error: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpendingLineChart extends ConsumerWidget {
  const _SpendingLineChart();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataState = ref.watch(timeSeriesSpendingProvider);
    final period = ref.watch(selectedReportPeriodProvider);
    final formatCurrency = NumberFormat.compactSimpleCurrency();
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.timeline, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text('Spending Trend', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 220,
              child: dataState.when(
                data: (data) {
                  if (data.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.show_chart, size: 48, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                          const SizedBox(height: 8),
                          Text('No trend data available', style: TextStyle(color: colorScheme.onSurfaceVariant)),
                        ],
                      ),
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

                  return LineChart(
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
                                TextStyle(color: colorScheme.onInverseSurface, fontWeight: FontWeight.bold),
                              );
                            }).toList();
                          },
                        ),
                      ),
                      gridData: FlGridData(
                        show: true, 
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) => FlLine(color: colorScheme.outlineVariant.withValues(alpha: 0.2), strokeWidth: 1, dashArray: [5, 5]),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index < 0 || index >= data.length) return const SizedBox();
                              
                              // Show fewer labels if there are many data points
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
                                child: Text(label, style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold)),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 44,
                            getTitlesWidget: (value, meta) {
                              if (value == 0 || value == maxVal * 1.2) return const SizedBox();
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
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
                          color: Colors.red.shade500,
                          barWidth: 4,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 4,
                                color: Colors.white,
                                strokeWidth: 2,
                                strokeColor: Colors.red.shade500,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.red.shade500.withValues(alpha: 0.3),
                                Colors.red.shade500.withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                        ),
                      ],
                      minY: 0,
                      maxY: maxVal * 1.2,
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text('Error: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
