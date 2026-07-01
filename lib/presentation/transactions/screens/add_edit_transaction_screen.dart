import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:moneytrackerapp/domain/entities/category.dart';
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
      accountId: _selectedAccountId ?? 'acc_cash', // Fallback to cash
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
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Transaction' : 'Add Transaction'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '\$ ',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter amount';
                  if (double.tryParse(value) == null) return 'Invalid number';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              categoriesState.when(
                data: (categories) {
                  final filteredCategories = categories.where((c) => c.type == _type).toList();
                  
                  // Ensure selected category is valid for current type
                  if (_selectedCategory != null && 
                      !filteredCategories.any((c) => c.name == _selectedCategory)) {
                    // We can't mutate state during build cleanly here, but we can let it be null.
                    // For simplicity, we just keep the invalid one or set it to null.
                  }

                  return DropdownButtonFormField<String>(
                    value: filteredCategories.any((c) => c.id == _selectedCategory || c.name == _selectedCategory) 
                        ? (filteredCategories.firstWhere((c) => c.id == _selectedCategory || c.name == _selectedCategory).id) 
                        : null,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: filteredCategories.map((cat) {
                      return DropdownMenuItem(
                        value: cat.id,
                        child: Row(
                          children: [
                            Icon(IconData(cat.iconCodePoint, fontFamily: 'MaterialIcons'), color: Color(cat.colorValue)),
                            const SizedBox(width: 8),
                            Text(cat.name),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedCategory = val;
                      });
                    },
                    validator: (value) => value == null ? 'Please select a category' : null,
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (e, st) => Text('Error loading categories: $e'),
              ),
              const SizedBox(height: 16),
              accountsState.when(
                data: (accounts) {
                  return DropdownButtonFormField<String>(
                    value: accounts.any((a) => a.id == _selectedAccountId) ? _selectedAccountId : null,
                    decoration: const InputDecoration(
                      labelText: 'Account',
                      border: OutlineInputBorder(),
                    ),
                    items: accounts.map((acc) {
                      return DropdownMenuItem(
                        value: acc.id,
                        child: Row(
                          children: [
                            Icon(IconData(acc.iconCodePoint, fontFamily: 'MaterialIcons'), color: Color(acc.colorValue)),
                            const SizedBox(width: 8),
                            Text(acc.name),
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
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.calendar_today),
                      label: Text(DateFormat.yMMMd().format(_selectedDate)),
                      onPressed: _pickDate,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.access_time),
                      label: Text(_selectedTime.format(context)),
                      onPressed: _pickTime,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Note (Optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _paymentMethodController,
                decoration: const InputDecoration(
                  labelText: 'Payment Method (e.g. Card, Cash)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                icon: const Icon(Icons.attach_file),
                label: Text(_attachmentPath == null ? 'Add Attachment' : 'Attachment Added'),
                onPressed: () {
                  setState(() {
                    _attachmentPath = '/fake/path/to/receipt.jpg';
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Simulated adding attachment')),
                  );
                },
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _saveTransaction,
                style: FilledButton.styleFrom(padding: const EdgeInsets.all(16)),
                child: Text(isEditing ? 'Update' : 'Save', style: const TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
