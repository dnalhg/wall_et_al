import 'dart:async';
import 'dart:math';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';


class ExpenseDatabase {
  static final Future<Database> database = _initDatabase();
  static const String dbTableName = 'expenses';
  static final Random r = Random.secure();
  static final int maxId = pow(2, 52).floor();

  const ExpenseDatabase();

  static Future<Database> _initDatabase() async {
    return openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), 'expense_database.db'),
      onCreate: (db, version) {
          return db.execute('CREATE TABLE $dbTableName(id INTEGER PRIMARY KEY, amount REAL, msSinceEpoch INTEGER, description STRING, category STRING)');
      },
      version: 1,
    );
  }

  /// Returns SQLITE_CONSTRAINT on failure.
  Future<int> insertExpense(ExpenseEntry e) async {
    final db = await database;

    return await db.insert(
      'dbTableName',
      e.toMap(),
      conflictAlgorithm: ConflictAlgorithm.rollback,
    );
  }

  int generateDbId() {
    return r.nextInt(maxId);
  }
}


class ExpenseEntry {
  final int id;
  final double amount;
  final int msSinceEpoch;
  final String description;
  final String category;

  const ExpenseEntry({
    required this.id,
    required this.amount,
    required this.msSinceEpoch,
    required this.description,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'msSinceEpoch': msSinceEpoch,
      'description': description,
      'category': category,
    };
  }

  @override
  String toString() {
    return "ExpenseEntry($id, $amount, $msSinceEpoch, $description, $category)";
  }
}