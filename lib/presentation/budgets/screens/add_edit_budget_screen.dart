import 'package:flutter/material.dart';
import 'package:moneytrackerapp/core/theme/design_system.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:moneytrackerapp/domain/entities/budget.dart';
import 'package:moneytrackerapp/presentation/budgets/providers/budgets_provider.dart';
import 'package:moneytrackerapp/presentation/categories/providers/category_provider.dart';

import 'package:moneytrackerapp/l10n/app_localizations.dart';
import 'package:moneytrackerapp/core/utils/localization_helper.dart';
class AddEditBudgetScreen extends ConsumerStatefulWidget {
  final BudgetEntity? budget;

  const AddEditBudgetScreen({super.key, this.budget});

  @override
  ConsumerState<AddEditBudgetScreen> createState() => _AddEditBudgetScreenState();
}

class _AddEditBudgetScreenState extends ConsumerState<AddEditBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  
  List<String> _categoryIds = ['all'];
  String _period = 'monthly';

  @override
  void initState() {
    super.initState();
    if (widget.budget != null) {
      _amountController.text = widget.budget!.amount.toString();
      _categoryIds = List.from(widget.budget!.categoryIds);
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
      if (_categoryIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.pleaseSelectAtLeastOneCategory)));
        return;
      }
      
      final amount = double.parse(_amountController.text);
      final id = widget.budget?.id ?? const Uuid().v4();

      final newBudget = BudgetEntity(
        id: id,
        categoryIds: _categoryIds,
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
              icon: Icon(Icons.delete_outline),
              color: Colors.red.shade400,
              onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: Text(AppLocalizations.of(context)!.deleteBudgetAction, style: TextStyle(fontWeight: FontWeight.bold)),
                  content: Text(AppLocalizations.of(context)!.areYouSureDeleteBudget),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(AppLocalizations.of(context)!.cancel),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: FilledButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(AppLocalizations.of(context)!.delete),
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
                  Text(AppLocalizations.of(context)!.budgetAmount, style: TextStyle(fontWeight: FontWeight.w600, color: colorScheme.onSurfaceVariant, fontSize: 14)),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _amountController,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.zeroAmount,
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
                  SizedBox(height: 24),
                  
                  // Category Selection
                  Text(AppLocalizations.of(context)!.categoriesSelect, style: TextStyle(fontWeight: FontWeight.w600, color: colorScheme.onSurfaceVariant, fontSize: 14)),
                  SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilterChip(
                        label: Text(AppLocalizations.of(context)!.overallBudget),
                        selected: _categoryIds.contains('all'),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _categoryIds = ['all'];
                            } else {
                              _categoryIds.remove('all');
                            }
                          });
                        },
                      ),
                      ...expenseCategories.map((c) {
                        return FilterChip(
                          label: Text(c.name.getLocalized(context)),
                          selected: _categoryIds.contains(c.id),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _categoryIds.remove('all');
                                _categoryIds.add(c.id);
                              } else {
                                _categoryIds.remove(c.id);
                              }
                            });
                          },
                        );
                      }),
                    ],
                  ),
                  SizedBox(height: 24),
                  
                  // Period Selection
                  Text(AppLocalizations.of(context)!.period, style: TextStyle(fontWeight: FontWeight.w600, color: colorScheme.onSurfaceVariant, fontSize: 14)),
                  SizedBox(height: 8),
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
                    items: [
                      DropdownMenuItem(value: 'monthly', child: Text(AppLocalizations.of(context)!.monthlyPeriod, style: TextStyle(fontWeight: FontWeight.w500))),
                      DropdownMenuItem(value: 'weekly', child: Text(AppLocalizations.of(context)!.weeklyPeriod, style: TextStyle(fontWeight: FontWeight.w500))),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _period = value;
                        });
                      }
                    },
                  ),
                  SizedBox(height: 40),
                  
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
                  SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error loading categories: $e')),
      ),
    );
  }
}
