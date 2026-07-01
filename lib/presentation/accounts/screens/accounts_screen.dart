import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moneytrackerapp/presentation/accounts/providers/account_provider.dart';
import 'package:intl/intl.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsState = ref.watch(accountsProvider);
    final balances = ref.watch(accountBalancesProvider);
    final formatCurrency = NumberFormat.simpleCurrency();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Accounts', style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: accountsState.when(
        data: (accounts) {
          if (accounts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.account_balance_wallet_outlined, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No accounts found.',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: accounts.length,
            itemBuilder: (context, index) {
              final acc = accounts[index];
              final currentBalance = balances[acc.id] ?? 0.0;
              
              return Card(
                elevation: 0,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Color(acc.colorValue).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        IconData(acc.iconCodePoint, fontFamily: 'MaterialIcons'),
                        color: Color(acc.colorValue),
                        size: 26,
                      ),
                    ),
                    title: Text(
                      acc.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text('Current Balance', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          formatCurrency.format(currentBalance),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: currentBalance < 0 ? Colors.red.shade700 : Colors.green.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          onPressed: () {
                            context.push('/edit-account', extra: acc);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          color: Colors.red.shade400,
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                title: const Text('Delete Account'),
                                content: Text('Are you sure you want to delete "${acc.name}"?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  FilledButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: Colors.red.shade400,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              ref.read(accountsProvider.notifier).deleteAccount(acc.id);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/add-account');
        },
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.add),
        label: const Text('Add Account', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}
