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
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.account_balance_wallet, color: colorScheme.primary, size: 24),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Welcome back,', style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
                Text('Mintly', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
              ],
            ),
          ],
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: colorScheme.onSurfaceVariant),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: _buildModernDrawer(context),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
             ref.invalidate(transactionsProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SummaryCards(),
                const SizedBox(height: 24),
                _buildQuickActions(context),
                const SizedBox(height: 32),
                const SpendingOverview(),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Transactions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      onPressed: () => context.push('/reports'),
                      child: Text('See All', style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.primary)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const RecentTransactions(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernDrawer(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Drawer(
      backgroundColor: colorScheme.surface,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(24, 64, 24, 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [colorScheme.primary, colorScheme.secondary],
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.onPrimary.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.account_balance_wallet, size: 36, color: colorScheme.onPrimary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Mintly', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colorScheme.onPrimary)),
                      Text('Personal Finance', style: TextStyle(fontSize: 14, color: colorScheme.onPrimary.withValues(alpha: 0.8))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _buildDrawerItem(context, Icons.account_balance, 'Accounts', '/accounts'),
                _buildDrawerItem(context, Icons.category, 'Categories', '/categories'),
                _buildDrawerItem(context, Icons.flag, 'Goals', '/goals'),
                _buildDrawerItem(context, Icons.pie_chart, 'Budgets', '/budgets'),
                _buildDrawerItem(context, Icons.calendar_month, 'Calendar', '/calendar'),
                _buildDrawerItem(context, Icons.bar_chart, 'Reports', '/reports'),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Divider(),
                ),
                _buildDrawerItem(context, Icons.settings, 'Settings', '/settings'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, String route) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = GoRouterState.of(context).uri.toString() == route;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: ListTile(
        leading: Icon(icon, color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? colorScheme.primary : colorScheme.onSurface,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        tileColor: isSelected ? colorScheme.primary.withValues(alpha: 0.1) : null,
        onTap: () {
          Navigator.pop(context);
          context.push(route);
        },
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            context, 
            'Income', 
            Icons.arrow_downward, 
            Colors.green.shade600, 
            () => context.push('/add-transaction', extra: TransactionType.income)
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionButton(
            context, 
            'Expense', 
            Icons.arrow_upward, 
            Colors.red.shade600, 
            () => context.push('/add-transaction', extra: TransactionType.expense)
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
