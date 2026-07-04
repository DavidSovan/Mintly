import 'package:flutter/material.dart';
import 'package:moneytrackerapp/core/theme/design_system.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:moneytrackerapp/domain/entities/transaction.dart';
import 'package:moneytrackerapp/core/utils/currency_formatter.dart';
import 'package:moneytrackerapp/domain/entities/settings.dart';
import 'package:moneytrackerapp/presentation/settings/providers/settings_provider.dart';
import 'package:moneytrackerapp/presentation/dashboard/providers/dashboard_provider.dart';

class TransactionItem extends ConsumerWidget {
  final TransactionEntity transaction;

  const TransactionItem({super.key, required this.transaction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final settings = ref.watch(settingsProvider).value ?? const SettingsEntity();

    final amountText = CurrencyFormatter.format(transaction.amount, settings);
    final isIncome = transaction.type.name == 'income';
    final amountColor = isIncome ? colorScheme.secondary : colorScheme.error;

    return Dismissible(
      key: Key(transaction.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Delete Transaction'),
              content: const Text('Are you sure you want to delete this transaction?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: FilledButton.styleFrom(backgroundColor: colorScheme.error),
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) {
        ref.read(transactionsProvider.notifier).deleteTransaction(transaction.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction deleted')),
        );
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        decoration: BoxDecoration(
          color: colorScheme.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          onTap: () => context.push('/edit-transaction', extra: transaction),
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: amountColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isIncome ? Icons.arrow_downward : Icons.arrow_upward,
              color: amountColor,
              size: 20,
            ),
          ),
          title: Text(
            transaction.title, 
            style: TextStyle(
              fontWeight: FontWeight.w700, 
              color: colorScheme.onSurface,
              fontSize: 15,
            ),
          ),
          subtitle: Text(
            DateFormat.yMMMd().format(transaction.date),
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${isIncome ? '+' : '-'}$amountText',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: amountColor,
                  fontSize: 16,
                  letterSpacing: -0.5,
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: colorScheme.onSurfaceVariant, size: 20),
                onSelected: (value) {
                  if (value == 'duplicate') {
                    final duplicatedTransaction = TransactionEntity(
                      id: const Uuid().v4(),
                      title: '${transaction.title} (Copy)',
                      amount: transaction.amount,
                      date: DateTime.now(),
                      type: transaction.type,
                      category: transaction.category,
                      note: transaction.note,
                      paymentMethod: transaction.paymentMethod,
                      accountId: transaction.accountId,
                      attachmentPath: transaction.attachmentPath,
                    );
                    ref.read(transactionsProvider.notifier).addTransaction(duplicatedTransaction);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Transaction duplicated')),
                    );
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'duplicate',
                    child: Text('Duplicate'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
