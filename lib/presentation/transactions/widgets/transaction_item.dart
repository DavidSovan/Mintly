import 'package:flutter/material.dart';
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
    final isExpense = transaction.type == TransactionType.expense;
    
    final settings = ref.watch(settingsProvider).value ?? const SettingsEntity();

    final amountText = CurrencyFormatter.format(transaction.amount, settings);
    final isIncome = transaction.type.name == 'income';

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
                  style: FilledButton.styleFrom(backgroundColor: Colors.red),
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
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
        onTap: () {
          // Edit transaction
          context.push('/edit-transaction', extra: transaction);
        },
        leading: CircleAvatar(
          backgroundColor: isIncome ? Colors.green.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.2),
          child: Icon(
            isIncome ? Icons.arrow_downward : Icons.arrow_upward,
            color: isIncome ? Colors.green : Colors.red,
          ),
        ),
        title: Text(transaction.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(DateFormat.yMMMd().format(transaction.date)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${isIncome ? '+' : '-'}$amountText',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isExpense ? Colors.red : Colors.green,
                  ),
            ),
            PopupMenuButton<String>(
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
    );
  }
}
