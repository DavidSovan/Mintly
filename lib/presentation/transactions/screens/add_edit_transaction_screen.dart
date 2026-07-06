import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:moneytrackerapp/domain/entities/transaction.dart';
import 'package:moneytrackerapp/presentation/dashboard/providers/dashboard_provider.dart';
import 'package:moneytrackerapp/presentation/categories/providers/category_provider.dart';
import 'package:moneytrackerapp/presentation/accounts/providers/account_provider.dart';

class AddEditTransactionScreen extends ConsumerStatefulWidget {
  final TransactionEntity? transaction;
  final TransactionType? initialType;

  const AddEditTransactionScreen({super.key, this.transaction, this.initialType});

  @override
  ConsumerState<AddEditTransactionScreen> createState() => _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState extends ConsumerState<AddEditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  late TextEditingController _paymentMethodController;
  
  TransactionType _type = TransactionType.expense;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String? _attachmentPath;
  String? _selectedCategory;
  String? _selectedAccountId;

  @override
  void initState() {
    super.initState();
    final t = widget.transaction;
    _amountController = TextEditingController(text: t != null ? t.amount.toString() : '');
    _noteController = TextEditingController(text: t?.note ?? '');
    _paymentMethodController = TextEditingController(text: t?.paymentMethod ?? '');
    _selectedCategory = t?.category;
    _selectedAccountId = t?.accountId;
    
    if (t != null) {
      _type = t.type;
      _selectedDate = t.date;
      _selectedTime = TimeOfDay.fromDateTime(t.date);
      _attachmentPath = t.attachmentPath;
    } else if (widget.initialType != null) {
      _type = widget.initialType!;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _paymentMethodController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _saveTransaction() {
    if (!_formKey.currentState!.validate()) return;
    
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final date = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final transaction = TransactionEntity(
      id: widget.transaction?.id ?? const Uuid().v4(),
      title: _noteController.text.isNotEmpty ? _noteController.text : (_selectedCategory ?? 'Unknown'),
      amount: amount,
      date: date,
      type: _type,
      category: _selectedCategory ?? 'Unknown',
      note: _noteController.text,
      paymentMethod: _paymentMethodController.text,
      accountId: _selectedAccountId ?? (ref.read(accountsProvider).value?.isNotEmpty == true ? ref.read(accountsProvider).value!.first.id : 'acc_cash'),
      attachmentPath: _attachmentPath,
    );

    if (widget.transaction == null) {
      ref.read(transactionsProvider.notifier).addTransaction(transaction);
    } else {
      ref.read(transactionsProvider.notifier).updateTransaction(transaction);
    }
    
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.transaction != null;
    final categoriesState = ref.watch(categoriesProvider);
    final accountsState = ref.watch(accountsProvider);
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Transaction' : 'Add Transaction', style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          if (isEditing)
            IconButton(
              icon: Icon(Icons.delete_outline, color: colorScheme.error),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete Transaction'),
                    content: const Text('Are you sure you want to delete this transaction?'),
                    actions: [
                      TextButton(
                        onPressed: () => ctx.pop(),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          ref.read(transactionsProvider.notifier).deleteTransaction(widget.transaction!.id);
                          ctx.pop(); // close dialog
                          context.pop(); // close screen
                        },
                        child: Text('Delete', style: TextStyle(color: colorScheme.error)),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: _type == TransactionType.income ? colorScheme.secondary.withValues(alpha: 0.1) : colorScheme.error.withValues(alpha: 0.1),
              ),
              child: Column(
                children: [
                  SegmentedButton<TransactionType>(
                    segments: const [
                      ButtonSegment(value: TransactionType.expense, label: Text('Expense')),
                      ButtonSegment(value: TransactionType.income, label: Text('Income')),
                    ],
                    selected: {_type},
                    onSelectionChanged: (selection) {
                      setState(() {
                        _type = selection.first;
                        _selectedCategory = null; // reset category on type change
                      });
                    },
                    style: SegmentedButton.styleFrom(
                      selectedForegroundColor: Colors.white,
                      selectedBackgroundColor: _type == TransactionType.income ? colorScheme.secondary : colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Form(
                    key: _formKey,
                    child: TextFormField(
                      controller: _amountController,
                      autofocus: !isEditing,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 48, fontWeight: FontWeight.w800, color: _type == TransactionType.income ? colorScheme.secondary : colorScheme.error),
                      decoration: InputDecoration(
                        hintText: '0.00',
                        prefixText: '\$ ',
                        prefixStyle: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: colorScheme.onSurface.withValues(alpha: 0.5)),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        filled: false,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Please enter amount';
                        final val = double.tryParse(value);
                        if (val == null || val <= 0) return 'Invalid amount';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Category', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 12),
                    categoriesState.when(
                      data: (categories) {
                        final filteredCategories = categories.where((c) => c.type == _type).toList();
                        return Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: filteredCategories.map((cat) {
                            final isSelected = _selectedCategory == cat.id || _selectedCategory == cat.name;
                            return ChoiceChip(
                              label: Text(cat.name),
                              selected: isSelected,
                              avatar: Icon(IconData(cat.iconCodePoint, fontFamily: 'MaterialIcons'), color: isSelected ? Colors.white : Color(cat.colorValue), size: 18),
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    _selectedCategory = cat.id;
                                  });
                                }
                              },
                              selectedColor: colorScheme.primary,
                              labelStyle: TextStyle(color: isSelected ? Colors.white : colorScheme.onSurface),
                            );
                          }).toList(),
                        );
                      },
                      loading: () => const CircularProgressIndicator(),
                      error: (e, st) => Text('Error loading categories: $e'),
                    ),
                    const SizedBox(height: 24),
                    Text('Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 12),
                    accountsState.when(
                      data: (accounts) {
                        return DropdownButtonFormField<String>(
                          initialValue: accounts.any((a) => a.id == _selectedAccountId) ? _selectedAccountId : (accounts.isNotEmpty ? accounts.first.id : null),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            filled: true,
                            fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                          ),
                          items: accounts.map((acc) {
                            return DropdownMenuItem(
                              value: acc.id,
                              child: Row(
                                children: [
                                  Icon(IconData(acc.iconCodePoint, fontFamily: 'MaterialIcons'), color: Color(acc.colorValue)),
                                  const SizedBox(width: 12),
                                  Text(acc.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedAccountId = val;
                            });
                          },
                          validator: (value) => value == null ? 'Please select an account' : null,
                        );
                      },
                      loading: () => const CircularProgressIndicator(),
                      error: (e, st) => Text('Error loading accounts: $e'),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: _pickDate,
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.calendar_today, size: 20, color: colorScheme.primary),
                                  const SizedBox(width: 8),
                                  Text(DateFormat.yMMMd().format(_selectedDate), style: const TextStyle(fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: _pickTime,
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.access_time, size: 20, color: colorScheme.primary),
                                  const SizedBox(width: 8),
                                  Text(_selectedTime.format(context), style: const TextStyle(fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _noteController,
                      decoration: InputDecoration(
                        labelText: 'Note (Optional)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          if (_selectedCategory == null) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a category')));
                            return;
                          }
                          _saveTransaction();
                        },
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text(isEditing ? 'Update Transaction' : 'Save Transaction', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
