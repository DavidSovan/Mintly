import 'package:flutter/material.dart';
import 'package:moneytrackerapp/core/theme/design_system.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:moneytrackerapp/domain/entities/category.dart';
import 'package:moneytrackerapp/domain/entities/transaction.dart';
import 'package:moneytrackerapp/presentation/categories/providers/category_provider.dart';

import 'package:moneytrackerapp/l10n/app_localizations.dart';
class AddEditCategoryScreen extends ConsumerStatefulWidget {
  final CategoryEntity? category;

  const AddEditCategoryScreen({super.key, this.category});

  @override
  ConsumerState<AddEditCategoryScreen> createState() => _AddEditCategoryScreenState();
}

class _AddEditCategoryScreenState extends ConsumerState<AddEditCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  TransactionType _type = TransactionType.expense;
  
  int _selectedIconCode = Icons.category.codePoint;
  int _selectedColor = 0xFF2196F3; // Default blue

  final List<IconData> _availableIcons = [
    // Food & Dining
    Icons.restaurant, Icons.fastfood, Icons.local_cafe, Icons.local_bar, Icons.local_pizza, Icons.local_grocery_store,
    // Transportation
    Icons.directions_car, Icons.local_gas_station, Icons.flight, Icons.train, Icons.directions_bus, Icons.pedal_bike, Icons.local_taxi,
    // Shopping
    Icons.shopping_bag, Icons.shopping_cart, Icons.checkroom, Icons.watch, Icons.diamond,
    // Bills & Utilities
    Icons.receipt, Icons.phone, Icons.wifi, Icons.water_drop, Icons.bolt, Icons.home, Icons.apartment,
    // Entertainment
    Icons.movie, Icons.music_note, Icons.sports_esports, Icons.tv, Icons.theater_comedy, Icons.subscriptions, Icons.palette, Icons.camera_alt,
    // Health & Fitness
    Icons.local_hospital, Icons.health_and_safety, Icons.fitness_center, Icons.sports_tennis, Icons.spa, Icons.medication,
    // Education & Work
    Icons.school, Icons.work, Icons.auto_stories, Icons.computer, Icons.business_center,
    // Family & Personal
    Icons.pets, Icons.child_care, Icons.stroller, Icons.local_florist, Icons.card_giftcard, Icons.favorite,
    // Finance
    Icons.attach_money, Icons.savings, Icons.account_balance, Icons.credit_card, Icons.account_balance_wallet, Icons.currency_exchange, Icons.trending_up, Icons.trending_down,
    // Others
    Icons.star, Icons.build, Icons.cleaning_services, Icons.security, Icons.more_horiz,
  ];

  final List<int> _availableColors = [
    0xFFF44336, 0xFFE91E63, 0xFF9C27B0, 0xFF673AB7,
    0xFF3F51B5, 0xFF2196F3, 0xFF03A9F4, 0xFF00BCD4,
    0xFF009688, 0xFF4CAF50, 0xFF8BC34A, 0xFFCDDC39,
    0xFFFFEB3B, 0xFFFFC107, 0xFFFF9800, 0xFFFF5722
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    if (widget.category != null) {
      _type = widget.category!.type;
      _selectedIconCode = widget.category!.iconCodePoint;
      _selectedColor = widget.category!.colorValue;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveCategory() {
    if (!_formKey.currentState!.validate()) return;
    
    final category = CategoryEntity(
      id: widget.category?.id ?? const Uuid().v4(),
      name: _nameController.text,
      type: _type,
      iconCodePoint: _selectedIconCode,
      colorValue: _selectedColor,
    );

    if (widget.category == null) {
      ref.read(categoriesProvider.notifier).addCategory(category);
    } else {
      ref.read(categoriesProvider.notifier).updateCategory(category);
    }
    
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.category != null;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Category' : 'New Category', style: const TextStyle(fontWeight: FontWeight.w600)),
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
              // Type Selection
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(8),
                child: SegmentedButton<TransactionType>(
                  style: SegmentedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    selectedForegroundColor: colorScheme.onPrimary,
                    selectedBackgroundColor: colorScheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(value: TransactionType.expense, label: Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(AppLocalizations.of(context)!.expenseType, style: TextStyle(fontWeight: FontWeight.w600)),
                    )),
                    ButtonSegment(value: TransactionType.income, label: Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(AppLocalizations.of(context)!.incomeType, style: TextStyle(fontWeight: FontWeight.w600)),
                    )),
                  ],
                  selected: {_type},
                  onSelectionChanged: (selection) {
                    setState(() {
                      _type = selection.first;
                    });
                  },
                ),
              ),
              const SizedBox(height: 24),
              
              // Name Input
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.categoryName,
                  hintText: AppLocalizations.of(context)!.eG_Groceries,
                  floatingLabelBehavior: FloatingLabelBehavior.always,
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
                  if (value == null || value.trim().isEmpty) return AppLocalizations.of(context)!.enterName;
                  return null;
                },
              ),
              const SizedBox(height: 32),
              
              // Icon Selection
              Row(
                children: [
                  Text(AppLocalizations.of(context)!.icon, style: TextStyle(fontWeight: FontWeight.w600, color: colorScheme.onSurfaceVariant, fontSize: 14)),
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
              Text(AppLocalizations.of(context)!.color, style: TextStyle(fontWeight: FontWeight.w600, color: colorScheme.onSurfaceVariant, fontSize: 14)),
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
                  onPressed: _saveCategory,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    isEditing ? 'Save Changes' : 'Create Category', 
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
