import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';


class DatabaseUtils {
  static final Random _rand = Random.secure();

  static String createCryptoRandomString([int length = 32]) {
    var values = List<int>.generate(length, (i) => _rand.nextInt(256));

    return base64Url.encode(values);
  }
}

class ExpenseDatabase {
  static final Future<Database> database = _initDatabase();
  static const String dbTableName = 'expenses';

  const ExpenseDatabase();

  static Future<Database> _initDatabase() async {
    String dbPath = join(await getDatabasesPath(), 'expense_database.db');
    // databaseFactory.deleteDatabase(dbPath);
    return openDatabase(
      dbPath,
      onCreate: (db, version) {
          return db.execute('CREATE TABLE $dbTableName(id STRING PRIMARY KEY, amount REAL, msSinceEpoch INTEGER, description STRING, category STRING)');
      },
      version: 1,
    );
  }

  Future<int> insertExpense(ExpenseEntry e) async {
    final db = await database;

    return await db.insert(
      dbTableName,
      e.toMap(),
      conflictAlgorithm: ConflictAlgorithm.rollback,
    );
  }

  Future<List<ExpenseEntry>> getExpenses(String filter) async {
    final db = await database;
    return (await db.query(dbTableName)).map((m) => ExpenseEntry.fromMap(m)).toList();
  }
}


class ExpenseEntry {
  final String id;
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

  static ExpenseEntry fromMap(Map<String, dynamic> m) {
    return ExpenseEntry(
      id: m['id'],
      amount: m['amount'],
      msSinceEpoch: m['msSinceEpoch'],
      description: m['description'],
      category: m['category'],
    );
  }

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