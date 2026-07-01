import 'package:moneytrackerapp/domain/entities/transaction.dart';
import 'package:moneytrackerapp/domain/repositories/transaction_repository.dart';
import 'package:moneytrackerapp/data/models/transaction_model.dart';
import 'package:moneytrackerapp/data/datasources/database_helper.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final DatabaseHelper dbHelper;

  TransactionRepositoryImpl(this.dbHelper);

  @override
  Future<List<TransactionEntity>> getTransactions() async {
    final db = await dbHelper.database;
    final result = await db.query('transactions', orderBy: 'date DESC');
    return result.map((json) => TransactionModel.fromJson(json)).toList();
  }

  @override
  Future<void> addTransaction(TransactionEntity transaction) async {
    final db = await dbHelper.database;
    final model = TransactionModel.fromEntity(transaction);
    await db.insert('transactions', model.toJson());
  }

  @override
  Future<void> updateTransaction(TransactionEntity transaction) async {
    final db = await dbHelper.database;
    final model = TransactionModel.fromEntity(transaction);
    await db.update(
      'transactions',
      model.toJson(),
      where: 'id = ?',
      whereArgs: [model.id],
    );
  }

  @override
  Future<void> deleteTransaction(String id) async {
    final db = await dbHelper.database;
    await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
