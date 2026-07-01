import 'package:moneytrackerapp/domain/entities/account.dart';
import 'package:moneytrackerapp/domain/repositories/account_repository.dart';
import 'package:moneytrackerapp/data/models/account_model.dart';
import 'package:moneytrackerapp/data/datasources/database_helper.dart';

class AccountRepositoryImpl implements AccountRepository {
  final DatabaseHelper dbHelper;

  AccountRepositoryImpl(this.dbHelper);

  @override
  Future<List<AccountEntity>> getAccounts() async {
    final db = await dbHelper.database;
    final result = await db.query('accounts', orderBy: 'name ASC');
    return result.map((json) => AccountModel.fromJson(json)).toList();
  }

  @override
  Future<void> addAccount(AccountEntity account) async {
    final db = await dbHelper.database;
    final model = AccountModel.fromEntity(account);
    await db.insert('accounts', model.toJson());
  }

  @override
  Future<void> updateAccount(AccountEntity account) async {
    final db = await dbHelper.database;
    final model = AccountModel.fromEntity(account);
    await db.update(
      'accounts',
      model.toJson(),
      where: 'id = ?',
      whereArgs: [model.id],
    );
  }

  @override
  Future<void> deleteAccount(String id) async {
    final db = await dbHelper.database;
    await db.delete(
      'accounts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
