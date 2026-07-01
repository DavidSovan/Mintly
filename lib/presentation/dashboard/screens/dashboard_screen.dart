import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moneytrackerapp/presentation/dashboard/widgets/dashboard_widgets.dart';
import 'package:moneytrackerapp/presentation/dashboard/providers/dashboard_provider.dart';
import 'package:moneytrackerapp/domain/entities/transaction.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Mintly',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet),
              title: const Text('Accounts'),
              onTap: () {
                Navigator.pop(context);
                context.push('/accounts');
              },
            ),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Categories'),
              onTap: () {
                Navigator.pop(context);
                context.push('/categories');
              },
            ),
            ListTile(
              leading: const Icon(Icons.flag),
              title: const Text('Goals'),
              onTap: () {
                Navigator.pop(context);
                context.push('/goals');
              },
            ),
            ListTile(
              leading: const Icon(Icons.pie_chart),
              title: const Text('Budgets'),
              onTap: () {
                Navigator.pop(context);
                context.push('/budgets');
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: const Text('Calendar'),
              onTap: () {
                Navigator.pop(context);
                context.push('/calendar');
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text('Reports'),
              onTap: () {
                Navigator.pop(context);
                context.push('/reports');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                context.push('/settings');
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
             // trigger a refresh of transactions
             ref.invalidate(transactionsProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SummaryCards(),
                const SizedBox(height: 16),
                _buildQuickActions(context),
                const SizedBox(height: 24),
                const SpendingOverview(),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Transactions',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {
                        context.push('/reports');
                      },
                      child: const Text('See All'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const RecentTransactions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: () {
              context.push('/add-transaction', extra: TransactionType.income);
            },
            icon: const Icon(Icons.arrow_downward),
            label: const Text('Add Income'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: FilledButton.icon(
            onPressed: () {
              context.push('/add-transaction', extra: TransactionType.expense);
            },
            icon: const Icon(Icons.arrow_upward),
            label: const Text('Add Expense'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ],
    );
  }
}
