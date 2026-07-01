import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('money_tracker.db');
    return _database!;
  }

  static void resetInstance() {
    _database = null;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 6,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE transactions ADD COLUMN note TEXT DEFAULT ""');
      await db.execute('ALTER TABLE transactions ADD COLUMN paymentMethod TEXT DEFAULT ""');
      await db.execute('ALTER TABLE transactions ADD COLUMN attachmentPath TEXT');
    }
    if (oldVersion < 3) {
      await _createCategoriesTable(db);
      await _insertDefaultCategories(db);
    }
    if (oldVersion < 4) {
      await _createAccountsTable(db);
      await _insertDefaultAccounts(db);
      await db.execute('ALTER TABLE transactions ADD COLUMN accountId TEXT DEFAULT "acc_cash"');
    }
    if (oldVersion < 5) {
      await _createBudgetsTable(db);
    }
    if (oldVersion < 6) {
      await _createGoalsTable(db);
    }
  }

  Future<void> _createGoalsTable(Database db) async {
    await db.execute('''
      CREATE TABLE goals (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        targetAmount REAL NOT NULL,
        savedAmount REAL NOT NULL,
        deadline TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createBudgetsTable(Database db) async {
    await db.execute('''
      CREATE TABLE budgets (
        id TEXT PRIMARY KEY,
        categoryId TEXT NOT NULL,
        amount REAL NOT NULL,
        period TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createAccountsTable(Database db) async {
    await db.execute('''
      CREATE TABLE accounts (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        initialBalance REAL NOT NULL,
        iconCodePoint INTEGER NOT NULL,
        colorValue INTEGER NOT NULL
      )
    ''');
  }

  Future<void> _insertDefaultAccounts(Database db) async {
    final defaultAccounts = [
      {'id': 'acc_cash', 'name': 'Cash', 'initialBalance': 0.0, 'iconCodePoint': 0xe3f8, 'colorValue': 0xFF4CAF50}, // Icons.money
      {'id': 'acc_bank', 'name': 'Bank', 'initialBalance': 0.0, 'iconCodePoint': 0xe0d4, 'colorValue': 0xFF2196F3}, // Icons.account_balance
      {'id': 'acc_credit', 'name': 'Credit Card', 'initialBalance': 0.0, 'iconCodePoint': 0xe19f, 'colorValue': 0xFF9C27B0}, // Icons.credit_card
      {'id': 'acc_savings', 'name': 'Savings', 'initialBalance': 0.0, 'iconCodePoint': 0xe532, 'colorValue': 0xFFFF9800}, // Icons.savings
      {'id': 'acc_ewallet', 'name': 'E-Wallet', 'initialBalance': 0.0, 'iconCodePoint': 0xe020, 'colorValue': 0xFFE91E63}, // Icons.account_balance_wallet
    ];
    
    for (var acc in defaultAccounts) {
      await db.insert('accounts', acc);
    }
  }

  Future<void> _createCategoriesTable(Database db) async {
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        iconCodePoint INTEGER NOT NULL,
        colorValue INTEGER NOT NULL
      )
    ''');
  }

  Future<void> _insertDefaultCategories(Database db) async {
    final defaultCategories = [
      {'id': 'cat_food', 'name': 'Food', 'type': 'expense', 'iconCodePoint': 0xe556, 'colorValue': 0xFFF44336}, // Icons.restaurant
      {'id': 'cat_transport', 'name': 'Transport', 'type': 'expense', 'iconCodePoint': 0xe1d5, 'colorValue': 0xFF2196F3}, // Icons.directions_car
      {'id': 'cat_shopping', 'name': 'Shopping', 'type': 'expense', 'iconCodePoint': 0xe5fc, 'colorValue': 0xFF9C27B0}, // Icons.shopping_bag
      {'id': 'cat_bills', 'name': 'Bills', 'type': 'expense', 'iconCodePoint': 0xe506, 'colorValue': 0xFFFF9800}, // Icons.receipt
      {'id': 'cat_entertainment', 'name': 'Entertainment', 'type': 'expense', 'iconCodePoint': 0xe410, 'colorValue': 0xFFE91E63}, // Icons.movie
      {'id': 'cat_education', 'name': 'Education', 'type': 'expense', 'iconCodePoint': 0xe562, 'colorValue': 0xFF009688}, // Icons.school
      {'id': 'cat_health', 'name': 'Health', 'type': 'expense', 'iconCodePoint': 0xe3e6, 'colorValue': 0xFF4CAF50}, // Icons.local_hospital
      {'id': 'cat_gift', 'name': 'Gift', 'type': 'expense', 'iconCodePoint': 0xe13d, 'colorValue': 0xFFFFEB3B}, // Icons.card_giftcard
      {'id': 'cat_salary', 'name': 'Salary', 'type': 'income', 'iconCodePoint': 0xe0b2, 'colorValue': 0xFF4CAF50}, // Icons.attach_money
      {'id': 'cat_freelance', 'name': 'Freelance', 'type': 'income', 'iconCodePoint': 0xe1af, 'colorValue': 0xFF03A9F4}, // Icons.computer
      {'id': 'cat_bonus', 'name': 'Bonus', 'type': 'income', 'iconCodePoint': 0xe5e1, 'colorValue': 0xFFFFC107}, // Icons.star
      {'id': 'cat_investment', 'name': 'Investment', 'type': 'income', 'iconCodePoint': 0xe62e, 'colorValue': 0xFF8BC34A}, // Icons.trending_up
      {'id': 'cat_savings_dynamic', 'name': 'Savings', 'type': 'expense', 'iconCodePoint': 0xe532, 'colorValue': 0xFFFF9800}, // Icons.savings
    ];
    
    for (var cat in defaultCategories) {
      await db.insert('categories', cat);
    }
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        note TEXT NOT NULL,
        paymentMethod TEXT NOT NULL,
        attachmentPath TEXT,
        accountId TEXT NOT NULL
      )
    ''');
    
    await _createCategoriesTable(db);
    await _createAccountsTable(db);
    await _createBudgetsTable(db);
    await _createGoalsTable(db);
    
    await _insertDefaultCategories(db);
    await _insertDefaultAccounts(db);
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
