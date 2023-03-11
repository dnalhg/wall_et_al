import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
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
  static final Future<Database> _database = _initDatabase();
  static const String _expenseTableName = 'expenses';
  static const String _categoriesTableName = 'categories';

  static ExpenseDatabase instance = ExpenseDatabase();

  static Future<Database> _initDatabase() async {
    String dbPath = join(await getDatabasesPath(), 'expense_database.db');
    // databaseFactory.deleteDatabase(dbPath);
    return openDatabase(
      dbPath,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_categoriesTableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            icon INTEGER NOT NULL,
            color INTEGER NOT NULL
          )
        ''');
        await db.execute(
            '''
            CREATE TABLE $_expenseTableName(
              id STRING PRIMARY KEY,
              amount REAL,
              ms_since_epoch INTEGER, 
              description STRING, 
              category_id INTEGER NOT NULL,
              FOREIGN KEY (category_id) REFERENCES categories(id)
            )
            '''
        );
        final nullCategory = CategoryEntry(name: "None", icon: Icons.do_disturb_alt_sharp, color: Colors.red);
        await db.insert(_categoriesTableName, nullCategory.toMap());
      },
      version: 1,
    );
  }

  Future<int> insertExpense(ExpenseEntry e) async {
    final db = await _database;

    return await db.insert(
      _expenseTableName,
      e.toMap(),
      conflictAlgorithm: ConflictAlgorithm.rollback,
    );
  }

  Future<int> updateExpense(ExpenseEntry e) async {
    final db = await _database;

    return await db.update(
        _expenseTableName, e.toMap(), where: 'id = ?', whereArgs: [e.id]);
  }

  Future<int> removeExpense(ExpenseEntry e) async {
    final db = await _database;

    return await db.delete(
        _expenseTableName, where: 'id = ?', whereArgs: [e.id]);
  }

  Future<List<ExpenseEntry>> getExpenses(String filter) async {
    final db = await _database;
    return (await db.query(_expenseTableName)).map((m) =>
        ExpenseEntry.fromMap(m)).toList();
  }

  Future<int> addCategory(CategoryEntry e) async {
    final db = await _database;
    return await db.insert(
      _categoriesTableName,
      e.toMap(),
      conflictAlgorithm: ConflictAlgorithm.rollback,
    );
  }

  Future<int> updateCategory(CategoryEntry e) async {
    final db = await _database;

    return await db.update(
        _categoriesTableName, e.toMap(), where: 'id = ?', whereArgs: [e.id]);
  }

  Future<int> removeCategory(CategoryEntry e) async {
    final db = await _database;

    return await db.delete(
        _categoriesTableName, where: 'id = ?', whereArgs: [e.id]);
  }

  Future<List<CategoryEntry>> getCategories() async {
    final db = await _database;
    return (await db.query(_categoriesTableName)).map((m) =>
        CategoryEntry.fromMap(m)).toList();
  }
}

class CategoryEntry {
  late final int? id;
  final String name;
  final IconData icon;
  final Color color;

  CategoryEntry({required this.name, required this.icon, required this.color, int? id}) {
    if (id != null) {
      this.id = id;
    }
  }

  factory CategoryEntry.fromMap(Map<String, dynamic> m) {
    return CategoryEntry(
      id: m['id'],
      name: m['name'],
      icon: IconData(m['icon'], fontFamily: "MaterialIcons"),
      color: Color(m['color'])
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name' : name,
      'icon' : icon.codePoint,
      'color' : color.value,
    };
  }

  @override
  String toString() {
    return 'CategoryEntry{id: $id, name: $name, icon: $icon, color: $color}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryEntry &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          icon == other.icon &&
          color == other.color;

  @override
  int get hashCode =>
      id.hashCode ^ name.hashCode ^ icon.hashCode ^ color.hashCode;
}


class ExpenseEntry {
  final String id;
  final double amount;
  final int msSinceEpoch;
  final String description;
  final int categoryId;

  const ExpenseEntry({
    required this.id,
    required this.amount,
    required this.msSinceEpoch,
    required this.description,
    required this.categoryId,
  });

  static ExpenseEntry fromMap(Map<String, dynamic> m) {
    return ExpenseEntry(
      id: m['id'],
      amount: m['amount'],
      msSinceEpoch: m['ms_since_epoch'],
      description: m['description'],
      categoryId: m['category_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'ms_since_epoch': msSinceEpoch,
      'description': description,
      'category_id': categoryId,
    };
  }

  @override
  String toString() {
    return "ExpenseEntry($id, $amount, $msSinceEpoch, $description, $categoryId)";
  }

  @override
  bool operator ==(Object other) {
    if (other is! ExpenseEntry) {
      return false;
    }
    return other.id == id && other.amount == amount &&
        other.msSinceEpoch == msSinceEpoch && other.categoryId == categoryId;
  }
}