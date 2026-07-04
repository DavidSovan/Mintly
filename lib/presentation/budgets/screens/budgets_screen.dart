import 'package:flutter/material.dart';
import 'package:moneytrackerapp/core/theme/design_system.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:moneytrackerapp/presentation/budgets/providers/budgets_provider.dart';

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressState = ref.watch(budgetProgressListProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Budgets', style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: progressState.when(
        data: (progressList) {
          if (progressList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.pie_chart_outline, size: 64, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6)),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No budgets configured.',
                    style: TextStyle(fontSize: 20, color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w700, letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Set a budget to manage your spending!',
                    style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: progressList.length,
            itemBuilder: (context, index) {
              final bp = progressList[index];
              return _buildBudgetCard(context, bp, ref);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/add-budget');
        },
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.add),
        label: const Text('Add Budget', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildBudgetCard(BuildContext context, BudgetProgress bp, WidgetRef ref) {
    final formatCurrency = NumberFormat.simpleCurrency();
    final bool isExceeded = bp.progressPercentage >= 1.0;
    final bool isWarning = bp.progressPercentage >= 0.8 && !isExceeded;
    
    Color progressColor = Theme.of(context).colorScheme.primary;
    if (isExceeded) {
      progressColor = Colors.red.shade500;
    } else if (isWarning) {
      progressColor = Colors.orange.shade500;
    }

    return Card(
      elevation: 4,
      shadowColor: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          context.push('/edit-budget', extra: bp.budget);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${bp.categoryName} Budget',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      bp.budget.period.toUpperCase(),
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Stack(
                children: [
                  Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth * (bp.progressPercentage > 1.0 ? 1.0 : bp.progressPercentage);
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOutCubic,
                        height: 12,
                        width: width,
                        decoration: BoxDecoration(
                          color: progressColor,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: progressColor.withValues(alpha: 0.4),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                      );
                    }
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _StatText(label: 'Budget', amount: formatCurrency.format(bp.budget.amount)),
                  _StatText(label: 'Spent', amount: formatCurrency.format(bp.spent)),
                  _StatText(
                    label: 'Remaining', 
                    amount: formatCurrency.format(bp.remaining),
                    color: bp.remaining < 0 ? Colors.red.shade700 : Colors.green.shade700,
                  ),
                ],
              ),
              if (isExceeded)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Budget Exceeded!',
                          style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                )
              else if (isWarning)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.orange.shade700, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Approaching Limit!',
                          style: TextStyle(color: Colors.orange.shade700, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatText extends StatelessWidget {
  final String label;
  final String amount;
  final Color? color;

  const _StatText({required this.label, required this.amount, this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
      ],
    );
  }
}
