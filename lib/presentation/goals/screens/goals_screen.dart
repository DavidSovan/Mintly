import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:moneytrackerapp/domain/entities/goal.dart';
import 'package:moneytrackerapp/presentation/goals/providers/goals_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:moneytrackerapp/domain/entities/transaction.dart';
import 'package:moneytrackerapp/presentation/dashboard/providers/dashboard_provider.dart';
import 'package:moneytrackerapp/domain/entities/category.dart';
import 'package:moneytrackerapp/presentation/accounts/providers/account_provider.dart';
import 'package:moneytrackerapp/presentation/categories/providers/category_provider.dart';

class GoalsScreen extends ConsumerStatefulWidget {
  const GoalsScreen({super.key});

  @override
  ConsumerState<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends ConsumerState<GoalsScreen> {

  Future<void> _showAddFundsDialog(GoalEntity goal, WidgetRef ref) async {
    final amountController = TextEditingController();
    
    final accountsState = ref.read(accountsProvider);
    final accounts = accountsState.value ?? [];
    String? selectedAccountId = accounts.isNotEmpty ? accounts.first.id : null;
    
    final result = await showDialog<double>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: const Text('Add Funds', style: TextStyle(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      prefixText: '\$ ',
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)),
                    ),
                    autofocus: true,
                  ),
                  const SizedBox(height: 16),
                  if (accounts.isNotEmpty)
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'From Account',
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)),
                      ),
                      initialValue: selectedAccountId,
                      items: accounts.map((acc) {
                        return DropdownMenuItem(
                          value: acc.id,
                          child: Text(acc.name),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          selectedAccountId = val;
                        });
                      },
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final amount = double.tryParse(amountController.text);
                    if (amount != null && amount != 0 && selectedAccountId != null) {
                      Navigator.of(context).pop(amount);
                    }
                  },
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Add', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          }
        );
      },
    );

    if (result != null && result != 0 && selectedAccountId != null) {
      // 1. Update the goal saved amount
      final updatedGoal = GoalEntity(
        id: goal.id,
        name: goal.name,
        targetAmount: goal.targetAmount,
        savedAmount: goal.savedAmount + result,
        deadline: goal.deadline,
      );
      ref.read(goalsProvider.notifier).updateGoal(updatedGoal);
      
      // 2. Create an expense transaction to deduct from balance
      final categories = ref.read(categoriesProvider).value ?? [];
      
      // Fallback if no savings category exists
      var savingsCategory = categories.cast<CategoryEntity?>().firstWhere(
        (c) => c != null && c.name.toLowerCase() == 'savings' && c.type.name == 'expense',
        orElse: () => null,
      );
      
      if (savingsCategory == null) {
        // Create it dynamically if it doesn't exist
        savingsCategory = CategoryEntity(
          id: 'cat_savings_dynamic',
          name: 'Savings',
          type: TransactionType.expense,
          iconCodePoint: Icons.savings.codePoint,
          colorValue: 0xFFFF9800,
        );
        ref.read(categoriesProvider.notifier).addCategory(savingsCategory);
      }
      
      final categoryId = savingsCategory.id;
      
      final transaction = TransactionEntity(
        id: const Uuid().v4(),
        title: 'Savings: ${goal.name}',
        amount: result > 0 ? result : -result, // Ensure amount is positive
        date: DateTime.now(),
        type: result > 0 ? TransactionType.expense : TransactionType.income, // If negative funds added, it's income back
        category: categoryId,
        note: 'Goal Contribution',
        paymentMethod: 'Transfer',
        accountId: selectedAccountId!,
      );
      
      ref.read(transactionsProvider.notifier).addTransaction(transaction);
    }
  }

  @override
  Widget build(BuildContext context) {
    final goalsState = ref.watch(goalsProvider);
    
    // Watch these to ensure they are loaded and cached when the user clicks 'Add Funds'
    ref.watch(accountsProvider);
    ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Savings Goals', style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: goalsState.when(
        data: (goals) {
          if (goals.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.flag_outlined, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No savings goals yet.',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add a goal to start tracking!',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          final formatCurrency = NumberFormat.simpleCurrency();
          final formatDate = DateFormat.yMMMd();

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            itemCount: goals.length,
            itemBuilder: (context, index) {
              final goal = goals[index];
              final progress = goal.savedAmount / goal.targetAmount;
              final progressPercent = (progress * 100).clamp(0, 100).toInt();

              return Card(
                elevation: 0,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5)),
                ),
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
                              goal.name,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            onPressed: () {
                              context.push('/edit-goal', extra: goal);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Target: ${formatCurrency.format(goal.targetAmount)}', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500)),
                          Text('Saved: ${formatCurrency.format(goal.savedAmount)}', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Stack(
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
                                    final width = constraints.maxWidth * (progress > 1 ? 1 : progress);
                                    return AnimatedContainer(
                                      duration: const Duration(milliseconds: 500),
                                      curve: Curves.easeOutCubic,
                                      height: 12,
                                      width: width,
                                      decoration: BoxDecoration(
                                        color: progress >= 1 ? Colors.green.shade500 : Theme.of(context).colorScheme.primary,
                                        borderRadius: BorderRadius.circular(6),
                                        boxShadow: [
                                          BoxShadow(
                                            color: (progress >= 1 ? Colors.green.shade500 : Theme.of(context).colorScheme.primary).withValues(alpha: 0.4),
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
                          ),
                          const SizedBox(width: 16),
                          SizedBox(
                            width: 44,
                            child: Text(
                              '$progressPercent%',
                              style: TextStyle(fontWeight: FontWeight.bold, color: progress >= 1 ? Colors.green.shade700 : Theme.of(context).colorScheme.primary),
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.calendar_today_outlined, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                              const SizedBox(width: 6),
                              Text(
                                formatDate.format(goal.deadline),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          FilledButton.icon(
                            onPressed: () => _showAddFundsDialog(goal, ref),
                            icon: const Icon(Icons.add_circle_outline, size: 18),
                            label: const Text('Add Funds', style: TextStyle(fontWeight: FontWeight.bold)),
                            style: FilledButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/add-goal');
        },
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.add),
        label: const Text('Add Goal', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}
