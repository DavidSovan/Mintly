
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:moneytrackerapp/data/datasources/database_helper.dart';

class DataManagementService {
  final DatabaseHelper _dbHelper;

  DataManagementService(this._dbHelper);

  Future<void> deleteAllData() async {
    final db = await _dbHelper.database;
    await db.delete('transactions');
    await db.delete('budgets');
    // Does not delete accounts or categories
  }

  Future<void> resetApp() async {
    final db = await _dbHelper.database;
    await db.delete('transactions');
    await db.delete('budgets');
    await db.delete('categories');
    await db.delete('accounts');
    
    // Trigger re-creation
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'money_tracker.db');
    
    await _dbHelper.close();
    await deleteDatabase(path);
    
    DatabaseHelper.resetInstance();
    // Re-initialize the DB
    await _dbHelper.database;
  }
  
  Future<String> getDatabasePath() async {
    final dbPath = await getDatabasesPath();
    return join(dbPath, 'money_tracker.db');
  }
}
