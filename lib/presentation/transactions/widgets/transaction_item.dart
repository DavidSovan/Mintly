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
import 'package:moneytrackerapp/presentation/categories/providers/category_provider.dart';
import 'package:moneytrackerapp/domain/entities/category.dart';

import 'package:moneytrackerapp/l10n/app_localizations.dart';
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

    final categories = ref.watch(categoriesProvider).value ?? [];
    CategoryEntity? category;
    try {
      category = categories.firstWhere((c) => c.id == transaction.category);
    } catch (_) {
      category = null;
    }
    
    final iconColor = category != null ? Color(category.colorValue) : amountColor;

    return Dismissible(
      key: Key(transaction.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.deleteTransaction),
              content: Text(AppLocalizations.of(context)!.areYouSureDeleteTransaction),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: FilledButton.styleFrom(backgroundColor: colorScheme.error),
                  child: Text(AppLocalizations.of(context)!.delete),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) {
        ref.read(transactionsProvider.notifier).deleteTransaction(transaction.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.transactionDeleted)),
        );
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        decoration: BoxDecoration(
          color: colorScheme.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      child: Container(
        clipBehavior: Clip.antiAlias,
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
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: amountColor, width: 6)),
          ),
          child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          onTap: () => context.push('/edit-transaction', extra: transaction),
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              category != null 
                  ? IconData(category.iconCodePoint, fontFamily: 'MaterialIcons') 
                  : (isIncome ? Icons.arrow_downward : Icons.arrow_upward),
              color: iconColor,
              size: 24,
            ),
          ),
          title: Text(
            category != null ? category.name : transaction.title, 
            style: TextStyle(
              fontWeight: FontWeight.w700, 
              color: colorScheme.onSurface,
              fontSize: 15,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              transaction.note.isNotEmpty 
                  ? '${transaction.note}  •  ${DateFormat.yMMMd().format(transaction.date)}'
                  : DateFormat.yMMMd().format(transaction.date),
              style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: amountColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: amountColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  '${isIncome ? '+' : '-'}$amountText',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: amountColor,
                    fontSize: 14,
                    letterSpacing: -0.5,
                  ),
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
                      SnackBar(content: Text(AppLocalizations.of(context)!.transactionDuplicated)),
                    );
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'duplicate',
                    child: Text(AppLocalizations.of(context)!.duplicate),
                  ),
                ],
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}
