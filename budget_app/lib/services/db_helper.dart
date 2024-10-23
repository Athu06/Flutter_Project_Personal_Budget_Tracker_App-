// services/db_helper.dart
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/expense_models.dart';

class DBHelper {
  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  Future<Database> initDB() async {
    final path = await getDatabasesPath();
    return await openDatabase(
      join(path, 'expenses.db'),
      onCreate: (db, version) async {
        await db.execute(
            'CREATE TABLE expenses (id INTEGER PRIMARY KEY AUTOINCREMENT, category TEXT, description TEXT, amount REAL, date TEXT)');
      },
      version: 1,
    );
  }

  Future<void> insertExpense(ExpenseData expense) async {
    final db = await database;
    await db.insert('expenses', expense.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<ExpenseData>> getExpenses() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('expenses');
    return List.generate(maps.length, (i) {
      return ExpenseData.fromMap(maps[i]);
    });
  }
}
