import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneytrackerapp/data/datasources/database_helper.dart';
import 'package:moneytrackerapp/data/repositories/transaction_repository_impl.dart';
import 'package:moneytrackerapp/domain/repositories/transaction_repository.dart';
import 'package:moneytrackerapp/data/repositories/category_repository_impl.dart';
import 'package:moneytrackerapp/domain/repositories/category_repository.dart';
import 'package:moneytrackerapp/data/repositories/account_repository_impl.dart';
import 'package:moneytrackerapp/domain/repositories/account_repository.dart';
import 'package:moneytrackerapp/data/repositories/budget_repository_impl.dart';
import 'package:moneytrackerapp/domain/repositories/budget_repository.dart';
import 'package:moneytrackerapp/data/repositories/goal_repository_impl.dart';
import 'package:moneytrackerapp/domain/repositories/goal_repository.dart';
import 'package:moneytrackerapp/data/datasources/data_management_service.dart';

final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper.instance;
});

final dataManagementServiceProvider = Provider<DataManagementService>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return DataManagementService(dbHelper);
});

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return TransactionRepositoryImpl(dbHelper);
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return CategoryRepositoryImpl(dbHelper);
});

final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return AccountRepositoryImpl(dbHelper);
});

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return BudgetRepositoryImpl(dbHelper);
});

final goalRepositoryProvider = Provider<GoalRepository>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return GoalRepositoryImpl(dbHelper);
});
