import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:moneytrackerapp/domain/entities/budget.dart';
import 'package:moneytrackerapp/presentation/budgets/providers/budgets_provider.dart';
import 'package:moneytrackerapp/presentation/categories/providers/category_provider.dart';

class AddEditBudgetScreen extends ConsumerStatefulWidget {
  final BudgetEntity? budget;

  const AddEditBudgetScreen({super.key, this.budget});

  @override
  ConsumerState<AddEditBudgetScreen> createState() => _AddEditBudgetScreenState();
}

class _AddEditBudgetScreenState extends ConsumerState<AddEditBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  
  String _categoryId = 'all';
  String _period = 'monthly';

  @override
  void initState() {
    super.initState();
    if (widget.budget != null) {
      _amountController.text = widget.budget!.amount.toString();
      _categoryId = widget.budget!.categoryId;
      _period = widget.budget!.period;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _saveBudget() {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text);
      final id = widget.budget?.id ?? const Uuid().v4();

      final newBudget = BudgetEntity(
        id: id,
        categoryId: _categoryId,
        amount: amount,
        period: _period,
      );

      if (widget.budget == null) {
        ref.read(budgetsProvider.notifier).addBudget(newBudget);
      } else {
        ref.read(budgetsProvider.notifier).updateBudget(newBudget);
      }
      
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.budget != null;
    final categoriesState = ref.watch(categoriesProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Budget' : 'New Budget', style: const TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: Colors.red.shade400,
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    title: const Text('Delete Budget'),
                    content: const Text('Are you sure you want to delete this budget?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.red.shade400,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );

                if (confirm == true && context.mounted) {
                  ref.read(budgetsProvider.notifier).deleteBudget(widget.budget!.id);
                  context.pop();
                }
              },
            ),
        ],
      ),
      body: categoriesState.when(
        data: (categories) {
          final expenseCategories = categories.where((c) => c.type.name == 'expense').toList();
          
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Budget Amount Input
                  Text('Budget Amount', style: TextStyle(fontWeight: FontWeight.w600, color: colorScheme.onSurfaceVariant, fontSize: 14)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _amountController,
                    decoration: InputDecoration(
                      hintText: '0.00',
                      prefixText: '\$ ',
                      prefixStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: colorScheme.primary, width: 2),
                      ),
                      contentPadding: const EdgeInsets.all(20),
                    ),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Enter amount';
                      if (double.tryParse(value) == null) return 'Enter a valid number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Category Selection
                  Text('Category', style: TextStyle(fontWeight: FontWeight.w600, color: colorScheme.onSurfaceVariant, fontSize: 14)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: colorScheme.primary, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    ),
                    icon: Icon(Icons.expand_more, color: colorScheme.onSurfaceVariant),
                    initialValue: _categoryId,
                    items: [
                      const DropdownMenuItem(value: 'all', child: Text('Overall Budget (All Categories)', style: TextStyle(fontWeight: FontWeight.w500))),
                      ...expenseCategories.map((c) {
                        return DropdownMenuItem(value: c.id, child: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w500)));
                      }),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _categoryId = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Period Selection
                  Text('Period', style: TextStyle(fontWeight: FontWeight.w600, color: colorScheme.onSurfaceVariant, fontSize: 14)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: colorScheme.primary, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    ),
                    icon: Icon(Icons.expand_more, color: colorScheme.onSurfaceVariant),
                    initialValue: _period,
                    items: const [
                      DropdownMenuItem(value: 'monthly', child: Text('Monthly', style: TextStyle(fontWeight: FontWeight.w500))),
                      DropdownMenuItem(value: 'weekly', child: Text('Weekly', style: TextStyle(fontWeight: FontWeight.w500))),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _period = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 40),
                  
                  // Save Button
                  FilledButton(
                    onPressed: _saveBudget,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 2,
                    ),
                    child: Text(
                      isEditing ? 'Save Changes' : 'Create Budget', 
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error loading categories: $e')),
      ),
    );
  }
}
