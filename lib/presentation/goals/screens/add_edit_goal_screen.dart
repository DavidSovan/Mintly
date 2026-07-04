import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:moneytrackerapp/domain/entities/goal.dart';
import 'package:moneytrackerapp/presentation/goals/providers/goals_provider.dart';
import 'package:moneytrackerapp/core/theme/design_system.dart';

class AddEditGoalScreen extends ConsumerStatefulWidget {
  final GoalEntity? goal;

  const AddEditGoalScreen({super.key, this.goal});

  @override
  ConsumerState<AddEditGoalScreen> createState() => _AddEditGoalScreenState();
}

class _AddEditGoalScreenState extends ConsumerState<AddEditGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late String _name;
  late double _targetAmount;
  late double _savedAmount;
  late DateTime _deadline;

  @override
  void initState() {
    super.initState();
    _name = widget.goal?.name ?? '';
    _targetAmount = widget.goal?.targetAmount ?? 0.0;
    _savedAmount = widget.goal?.savedAmount ?? 0.0;
    _deadline = widget.goal?.deadline ?? DateTime.now().add(const Duration(days: 30));
  }

  void _saveGoal() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final goal = GoalEntity(
        id: widget.goal?.id ?? const Uuid().v4(),
        name: _name,
        targetAmount: _targetAmount,
        savedAmount: _savedAmount,
        deadline: _deadline,
      );

      if (widget.goal == null) {
        ref.read(goalsProvider.notifier).addGoal(goal);
      } else {
        ref.read(goalsProvider.notifier).updateGoal(goal);
      }

      context.pop();
    }
  }

  void _deleteGoal() async {
    if (widget.goal != null) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Delete Goal', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text('Are you sure you want to delete "${widget.goal!.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
      if (confirm == true) {
        ref.read(goalsProvider.notifier).deleteGoal(widget.goal!.id);
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatDate = DateFormat.yMMMd();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(widget.goal == null ? 'New Goal' : 'Edit Goal', style: const TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          if (widget.goal != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: Colors.red.shade400,
              onPressed: _deleteGoal,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Goal Name Input
              Text('Goal Name', style: TextStyle(fontWeight: FontWeight.w600, color: colorScheme.onSurfaceVariant, fontSize: 14)),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: _name,
                decoration: InputDecoration(
                  hintText: 'e.g., Vacation, Emergency Fund...',
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
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a goal name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _name = value!;
                },
              ),
              const SizedBox(height: 24),
              
              // Target Amount Input
              Text('Target Amount', style: TextStyle(fontWeight: FontWeight.w600, color: colorScheme.onSurfaceVariant, fontSize: 14)),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: _targetAmount > 0 ? _targetAmount.toString() : '',
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
                  if (value == null || value.isEmpty) {
                    return 'Please enter target amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                onSaved: (value) {
                  _targetAmount = double.parse(value!);
                },
              ),
              const SizedBox(height: 24),
              
              // Deadline Selector
              Text('Deadline', style: TextStyle(fontWeight: FontWeight.w600, color: colorScheme.onSurfaceVariant, fontSize: 14)),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _deadline,
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now().add(const Duration(days: 3650)),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: colorScheme.copyWith(
                            primary: colorScheme.primary,
                            onPrimary: colorScheme.onPrimary,
                            surface: colorScheme.surface,
                            onSurface: colorScheme.onSurface,
                          ),
                          dialogBackgroundColor: colorScheme.surface,
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    setState(() {
                      _deadline = picked;
                    });
                  }
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, color: colorScheme.primary),
                      const SizedBox(width: 16),
                      Text(
                        formatDate.format(_deadline),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const Spacer(),
                      Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              
              // Save Button
              PrimaryButton(
                text: widget.goal == null ? 'Create Goal' : 'Save Changes',
                onPressed: _saveGoal,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
