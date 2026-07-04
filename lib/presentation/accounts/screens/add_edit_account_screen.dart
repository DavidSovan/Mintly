import 'package:flutter/material.dart';
import 'package:moneytrackerapp/core/theme/design_system.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:moneytrackerapp/domain/entities/account.dart';
import 'package:moneytrackerapp/presentation/accounts/providers/account_provider.dart';

class AddEditAccountScreen extends ConsumerStatefulWidget {
  final AccountEntity? account;

  const AddEditAccountScreen({super.key, this.account});

  @override
  ConsumerState<AddEditAccountScreen> createState() => _AddEditAccountScreenState();
}

class _AddEditAccountScreenState extends ConsumerState<AddEditAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _balanceController;
  
  int _selectedIconCode = Icons.account_balance.codePoint;
  int _selectedColor = 0xFF4CAF50;

  final List<IconData> _availableIcons = [
    Icons.money, Icons.account_balance, Icons.credit_card,
    Icons.savings, Icons.account_balance_wallet, Icons.wallet,
    Icons.payments, Icons.currency_bitcoin, Icons.store,
    Icons.phone_android, Icons.account_circle, Icons.work,
    Icons.business_center, Icons.language, Icons.euro, Icons.attach_money
  ];

  final List<int> _availableColors = [
    0xFF4CAF50, 0xFF2196F3, 0xFF9C27B0, 0xFFFF9800,
    0xFFE91E63, 0xFFF44336, 0xFF00BCD4, 0xFF009688,
    0xFF8BC34A, 0xFFCDDC39, 0xFFFFEB3B, 0xFFFFC107,
    0xFF673AB7, 0xFF3F51B5, 0xFF03A9F4, 0xFF607D8B
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.account?.name ?? '');
    _balanceController = TextEditingController(text: widget.account != null ? widget.account!.initialBalance.toString() : '');
    
    if (widget.account != null) {
      _selectedIconCode = widget.account!.iconCodePoint;
      _selectedColor = widget.account!.colorValue;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  void _saveAccount() {
    if (!_formKey.currentState!.validate()) return;
    
    final initialBalance = double.tryParse(_balanceController.text) ?? 0.0;

    final account = AccountEntity(
      id: widget.account?.id ?? const Uuid().v4(),
      name: _nameController.text,
      initialBalance: initialBalance,
      iconCodePoint: _selectedIconCode,
      colorValue: _selectedColor,
    );

    if (widget.account == null) {
      ref.read(accountsProvider.notifier).addAccount(account);
    } else {
      ref.read(accountsProvider.notifier).updateAccount(account);
    }
    
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.account != null;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Account' : 'New Account', style: const TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Account Name Input
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Account Name',
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  hintText: 'e.g., Main Checking, Cash...',
                  filled: true,
                  fillColor: colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: colorScheme.outlineVariant),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: colorScheme.outlineVariant),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: colorScheme.primary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.all(20),
                ),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Please enter a name';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              // Initial Balance Input
              TextFormField(
                controller: _balanceController,
                decoration: InputDecoration(
                  labelText: 'Initial Balance',
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  hintText: '0.00',
                  prefixText: '\$ ',
                  prefixStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  filled: true,
                  fillColor: colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: colorScheme.outlineVariant),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: colorScheme.outlineVariant),
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
                  if (value == null || value.isEmpty) return 'Please enter initial balance';
                  if (double.tryParse(value) == null) return 'Invalid number';
                  return null;
                },
              ),
              const SizedBox(height: 32),
              
              // Icon Selection
              Row(
                children: [
                  Text('Icon', style: TextStyle(fontWeight: FontWeight.w600, color: colorScheme.onSurfaceVariant, fontSize: 14)),
                  const Spacer(),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Color(_selectedColor).withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(IconData(_selectedIconCode, fontFamily: 'MaterialIcons'), size: 18, color: Color(_selectedColor)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: _availableIcons.map((icon) {
                    final isSelected = _selectedIconCode == icon.codePoint;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedIconCode = icon.codePoint;
                        });
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isSelected ? Color(_selectedColor).withValues(alpha: 0.2) : colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? Color(_selectedColor) : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: isSelected ? [] : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: Icon(
                          icon,
                          color: isSelected ? Color(_selectedColor) : colorScheme.onSurfaceVariant,
                          size: 24,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 32),
              
              // Color Selection
              Text('Color', style: TextStyle(fontWeight: FontWeight.w600, color: colorScheme.onSurfaceVariant, fontSize: 14)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: _availableColors.map((colorValue) {
                    final isSelected = _selectedColor == colorValue;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedColor = colorValue;
                        });
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Color(colorValue),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? colorScheme.onSurface : Colors.transparent,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color(colorValue).withValues(alpha: 0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 24) : null,
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 40),
              
              // Save Button
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [colorScheme.primary, colorScheme.primary.withValues(alpha: 0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _saveAccount,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    isEditing ? 'Save Changes' : 'Create Account', 
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.onPrimary, letterSpacing: 0.5)
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
