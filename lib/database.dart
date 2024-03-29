import 'dart:async';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class ExpenseDatabase with ChangeNotifier {
  static final Future<Database> _database = _initDatabase();
  static const String _expenseTableName = 'expenses';
  static const String _categoriesTableName = 'categories';
  static const String _tagsTableName = 'tags';
  static const String _expensesToTagsTable = 'expenseTags';

  static final CategoryEntry nullCategory = CategoryEntry(
      name: "Other",
      icon: Icons.do_disturb_alt_sharp,
      color: Colors.red,
      id: 1);

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
        await db.execute('''
            CREATE TABLE $_expenseTableName(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              amount REAL,
              ms_since_epoch INTEGER, 
              description STRING, 
              category_id INTEGER NOT NULL,
              FOREIGN KEY (category_id) REFERENCES categories(id)
            )
            ''');
        await db.insert(_categoriesTableName, nullCategory.toMap());
        await db.execute('''
           CREATE TABLE $_tagsTableName (
             id INTEGER PRIMARY KEY AUTOINCREMENT,
             name TEXT NOT NULL UNIQUE
           )
        ''');
        await db.execute('''
           CREATE TABLE $_expensesToTagsTable (
             expense_id INTEGER,
             tag_id INTEGER,
             PRIMARY KEY (expense_id, tag_id),
             FOREIGN KEY (expense_id) REFERENCES $_expenseTableName(id),
             FOREIGN KEY (tag_id) REFERENCES $_tagsTableName(id)
           )
        ''');
      },
      version: 1,
    );
  }

  Future<int> insertExpense(ExpenseEntry e) async {
    final db = await _database;

    return await db
        .insert(
      _expenseTableName,
      e.toMap(),
      conflictAlgorithm: ConflictAlgorithm.rollback,
    )
        .then((value) {
      notifyListeners();
      return value;
    });
  }

  Future<int> updateExpense(ExpenseEntry e) async {
    final db = await _database;

    return await db.update(_expenseTableName, e.toMap(),
        where: 'id = ?', whereArgs: [e.id]).then((value) {
      notifyListeners();
      return value;
    });
  }

  Future<int> removeExpense(ExpenseEntry e) async {
    final db = await _database;

    return await db.delete(_expenseTableName,
        where: 'id = ?', whereArgs: [e.id]).then((value) {
      notifyListeners();
      return value;
    });
  }

  /// [timeFilter] is a string of the format 'startTime-endTime' where startTime
  /// is inclusive and endTime is exclusive
  Future<List<ExpenseEntry>> getExpenses(
      {String? timeFilter, Set<int>? includeCategories, Set<int>? includeTags}) async {
    if (timeFilter == null) return [];
    includeCategories ??= {};
    // if this is empty then dont add a line, otherwise add a line to filter
    includeTags ??= {};
    final db = await _database;
    List<String> timeRange = timeFilter.split('-');
    String startTime = timeRange.first;
    String endTime = timeRange.last;
    var categories = await getCategories();

    var query = '''
      SELECT DISTINCT e.*
      FROM $_expenseTableName e join $_expensesToTagsTable et
      ON e.id = et.expense_id
      WHERE
      e.ms_since_epoch >= $startTime AND e.ms_since_epoch < $endTime
    ''';

    if (includeCategories.isNotEmpty) {
      var includeCategoriesStr = includeCategories.join(',');
      query += " AND e.category_id IN ($includeCategoriesStr) ";
    }

    if (includeTags.isNotEmpty) {
      var includeTagStr = includeTags.join(",");
      query += " AND et.tag_id in ($includeTagStr) ";
    }

    var queryResult = db.rawQuery(query);

    List<ExpenseEntry> expenses =
        (await queryResult).map((m) => ExpenseEntry.fromMap(m)).toList();
    expenses.sort((e1, e2) => e1.msSinceEpoch.compareTo(e2.msSinceEpoch) * -1);
    return expenses;
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

    return await db.update(_categoriesTableName, e.toMap(),
        where: 'id = ?', whereArgs: [e.id]);
  }

  Future<int> removeCategory(CategoryEntry e) async {
    final db = await _database;
    await db.rawUpdate(
      'UPDATE expenses SET category_id = ? WHERE category_id = ?',
      [1, e.id],
    );
    return await db
        .delete(_categoriesTableName, where: 'id = ?', whereArgs: [e.id]);
  }

  Future<List<CategoryEntry>> getCategories() async {
    final db = await _database;
    return (await db.query(_categoriesTableName))
        .map((m) => CategoryEntry.fromMap(m))
        .toList();
  }

  Future<int> insertTag(int expenseId, TagEntry entry) async {
    final db = await _database;
    if (entry.id == null) {
      try {
        var id = await db.insert(
          _tagsTableName,
          entry.toMap(),
          conflictAlgorithm: ConflictAlgorithm.fail,
        );
        entry.id = id;
      } catch (e) {
        if (e is DatabaseException && e.isUniqueConstraintError()) {
          print("Tag name already exists. Retrieving existing id.");

          List<Map<String, dynamic>> maps = await db.query(
            _tagsTableName,
            where: "name = ?",
            whereArgs: [entry.tagName],
          );

          if (maps.isNotEmpty) {
            entry.id = maps.first['id'];
          }
        }
      }
    }

    await db.insert(
        _expensesToTagsTable, {'expense_id': expenseId, 'tag_id': entry.id!},
        conflictAlgorithm: ConflictAlgorithm.rollback);

    return entry.id!;
  }

  Future<int> deleteTag(int tagId) async {
    final db = await _database;
    await db.delete(
      _expensesToTagsTable,
      where: 'tag_id = ?',
      whereArgs: [tagId],
    );
    return await db.delete(_tagsTableName, where: 'id = ?', whereArgs: [tagId]);
  }

  Future<int> deleteTagFromExpense(int expenseId, int tagId) async {
    final db = await _database;
    // Delete the relationship from the linking table, so that the tag is no longer related to the expense
    int count = await db.delete(
      _expensesToTagsTable,
      where: 'expense_id = ? AND tag_id = ?',
      whereArgs: [expenseId, tagId],
    );

    // Check if the tag is still related to any expense
    List<Map<String, dynamic>> rows = await db.query(
      _expensesToTagsTable,
      where: 'tag_id = ?',
      whereArgs: [tagId],
    );

    // If the tag isn't related to any expense anymore, delete it from the tags table
    if (rows.isEmpty) {
      await db.delete(
        _tagsTableName,
        where: 'id = ?',
        whereArgs: [tagId],
      );
    }

    return count;
  }

  Future<List<TagEntry>> getTagsForExpense(int expenseId) async {
    final db = await _database; //get your database instance

    var result = await db.rawQuery(
      '''
    SELECT T.name, T.id
      FROM $_tagsTableName T 
      INNER JOIN $_expensesToTagsTable ET 
        ON T.id = ET.tag_id 
      WHERE ET.expense_id = $expenseId
    ''',
    );

    var results = result.map((item) => TagEntry.fromMap(item)).toList();
    return results;
  }

  Future<List<TagEntry>> getTags() async {
    final db = await _database; //get your database instance

    return (await db.query(_tagsTableName))
        .map((m) => TagEntry.fromMap(m))
        .toList();
  }

  Future<int> updateTag(TagEntry e) async {
    final db = await _database;

    return await db.update(_tagsTableName, e.toMap(),
        where: 'id = ?', whereArgs: [e.id]);
  }

}

class TagEntry {
  int? id;
  final String tagName;

  TagEntry({required String tagName, this.id})
      : tagName = tagName.trim().toLowerCase();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TagEntry &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          tagName == other.tagName;

  @override
  int get hashCode => id.hashCode ^ tagName.hashCode;

  Map<String, dynamic> toMap() {
    Map<String, dynamic> res = {
      'name': tagName,
    };
    if (id != null) {
      res['id'] = id;
    }
    return res;
  }

  factory TagEntry.fromMap(Map<String, dynamic> m) {
    return TagEntry(tagName: m['name'], id: m['id']);
  }

  @override
  String toString() {
    return 'TagEntry{id: $id, tagName: $tagName}';
  }
}

class CategoryEntry {
  int? id;
  final String name;
  final IconData icon;
  final Color color;

  CategoryEntry(
      {required this.name, required this.icon, required this.color, int? id}) {
    if (id != null) {
      this.id = id;
    }
  }

  factory CategoryEntry.fromMap(Map<String, dynamic> m) {
    return CategoryEntry(
        id: m['id'],
        name: m['name'],
        icon: IconData(m['icon'], fontFamily: "MaterialIcons"),
        color: Color(m['color']));
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> res = {
      'name': name,
      'icon': icon.codePoint,
      'color': color.value,
    };
    if (id != null) {
      res['id'] = id;
    }
    return res;
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
  final int? id;
  final double amount;
  final int msSinceEpoch;
  final String description;
  final int? categoryId;

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
    Map<String, dynamic> res = {
      'amount': amount,
      'ms_since_epoch': msSinceEpoch,
      'description': description,
      'category_id': categoryId,
    };
    if (id != null) {
      res['id'] = id;
    }
    return res;
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
    return other.id == id &&
        other.amount == amount &&
        other.msSinceEpoch == msSinceEpoch &&
        other.categoryId == categoryId &&
        other.description == description;
  }
}
