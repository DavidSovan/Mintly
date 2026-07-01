import 'package:go_router/go_router.dart';
import 'package:moneytrackerapp/domain/entities/transaction.dart';
import 'package:moneytrackerapp/domain/entities/category.dart';
import 'package:moneytrackerapp/presentation/dashboard/screens/dashboard_screen.dart';
import 'package:moneytrackerapp/presentation/transactions/screens/add_edit_transaction_screen.dart';
import 'package:moneytrackerapp/presentation/categories/screens/categories_screen.dart';
import 'package:moneytrackerapp/presentation/categories/screens/add_edit_category_screen.dart';
import 'package:moneytrackerapp/presentation/accounts/screens/accounts_screen.dart';
import 'package:moneytrackerapp/presentation/accounts/screens/add_edit_account_screen.dart';
import 'package:moneytrackerapp/domain/entities/account.dart';
import 'package:moneytrackerapp/presentation/budgets/screens/budgets_screen.dart';
import 'package:moneytrackerapp/presentation/budgets/screens/add_edit_budget_screen.dart';
import 'package:moneytrackerapp/domain/entities/budget.dart';
import 'package:moneytrackerapp/presentation/reports/screens/reports_screen.dart';
import 'package:moneytrackerapp/presentation/calendar/screens/calendar_screen.dart';
import 'package:moneytrackerapp/presentation/settings/screens/settings_screen.dart';
import 'package:moneytrackerapp/presentation/goals/screens/goals_screen.dart';
import 'package:moneytrackerapp/presentation/goals/screens/add_edit_goal_screen.dart';
import 'package:moneytrackerapp/domain/entities/goal.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/add-transaction',
      builder: (context, state) {
        final initialType = state.extra as TransactionType?;
        return AddEditTransactionScreen(initialType: initialType);
      }
    ),
    GoRoute(
      path: '/edit-transaction',
      builder: (context, state) {
        final transaction = state.extra as TransactionEntity?;
        return AddEditTransactionScreen(transaction: transaction);
      },
    ),
    GoRoute(
      path: '/categories',
      builder: (context, state) => const CategoriesScreen(),
    ),
    GoRoute(
      path: '/add-category',
      builder: (context, state) => const AddEditCategoryScreen(),
    ),
    GoRoute(
      path: '/edit-category',
      builder: (context, state) {
        final category = state.extra as CategoryEntity?;
        return AddEditCategoryScreen(category: category);
      },
    ),
    GoRoute(
      path: '/accounts',
      builder: (context, state) => const AccountsScreen(),
    ),
    GoRoute(
      path: '/add-account',
      builder: (context, state) => const AddEditAccountScreen(),
    ),
    GoRoute(
      path: '/edit-account',
      builder: (context, state) {
        final account = state.extra as AccountEntity?;
        return AddEditAccountScreen(account: account);
      },
    ),
    GoRoute(
      path: '/budgets',
      builder: (context, state) => const BudgetsScreen(),
    ),
    GoRoute(
      path: '/add-budget',
      builder: (context, state) => const AddEditBudgetScreen(),
    ),
    GoRoute(
      path: '/edit-budget',
      builder: (context, state) {
        final budget = state.extra as BudgetEntity?;
        return AddEditBudgetScreen(budget: budget);
      },
    ),
    GoRoute(
      path: '/reports',
      builder: (context, state) => const ReportsScreen(),
    ),
    GoRoute(
      path: '/calendar',
      builder: (context, state) => const CalendarScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/goals',
      builder: (context, state) => const GoalsScreen(),
    ),
    GoRoute(
      path: '/add-goal',
      builder: (context, state) => const AddEditGoalScreen(),
    ),
    GoRoute(
      path: '/edit-goal',
      builder: (context, state) {
        final goal = state.extra as GoalEntity;
        return AddEditGoalScreen(goal: goal);
      },
    ),
  ],
);
