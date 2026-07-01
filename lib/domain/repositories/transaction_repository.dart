import 'package:moneytrackerapp/domain/entities/transaction.dart';

abstract class TransactionRepository {
  Future<List<TransactionEntity>> getTransactions();
  Future<void> addTransaction(TransactionEntity transaction);
  Future<void> updateTransaction(TransactionEntity transaction);
  Future<void> deleteTransaction(String id);
}
