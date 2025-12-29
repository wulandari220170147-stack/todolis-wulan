import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/user_model.dart';
import '../models/category_model.dart';
import '../models/task_model.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'wulan_todolist.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    // Buat tabel users
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        email TEXT
      )
    ''');

    // Buat tabel categories
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        user_id INTEGER,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Buat tabel tasks
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        category_id INTEGER NOT NULL,
        user_id INTEGER NOT NULL,
        priority TEXT DEFAULT 'Rendah',
        deadline TEXT,
        is_completed INTEGER DEFAULT 0,
        created_at TEXT DEFAULT (datetime('now')),
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Insert user demo
    await db.insert('users', {
      'username': 'wulan',
      'password': 'wulan123',
      'email': 'wulan@example.com'
    });

    // Insert kategori default
    await db.insert('categories', {
      'name': 'Pribadi',
      'description': 'Tugas-tugas pribadi',
      'user_id': 1
    });
    await db.insert('categories', {
      'name': 'Pekerjaan',
      'description': 'Tugas terkait pekerjaan',
      'user_id': 1
    });
    await db.insert('categories', {
      'name': 'Belajar',
      'description': 'Tugas belajar',
      'user_id': 1
    });
    await db.insert('categories', {
      'name': 'Rumah',
      'description': 'Tugas rumah tangga',
      'user_id': 1
    });

    // Insert tugas demo
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    await db.insert('tasks', {
      'title': 'Selesaikan proyek Flutter',
      'description': 'Menyelesaikan aplikasi TodoList',
      'category_id': 2,
      'user_id': 1,
      'priority': 'Tinggi',
      'deadline': tomorrow.toIso8601String().split('T')[0],
      'is_completed': 0
    });

    await db.insert('tasks', {
      'title': 'Beli bahan makanan',
      'description': 'Susu, Telur, Roti',
      'category_id': 4,
      'user_id': 1,
      'priority': 'Sedang',
      'is_completed': 0
    });

    await db.insert('tasks', {
      'title': 'Belajar Dart',
      'description': 'Mempelajari konsep OOP',
      'category_id': 3,
      'user_id': 1,
      'priority': 'Sedang',
      'is_completed': 1
    });
  }

  // ========== METODE USER ==========
  Future<UserModel?> getUserByCredentials(String username, String password) async {
    final client = await db;
    final res = await client.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    if (res.isNotEmpty) return UserModel.fromMap(res.first);
    return null;
  }

  Future<int> insertUser(UserModel user) async {
    final client = await db;
    return await client.insert('users', user.toMap());
  }

  Future<bool> userExists(String username) async {
    final client = await db;
    final res = await client.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    return res.isNotEmpty;
  }

  // ========== METODE KATEGORI ==========
  Future<List<CategoryModel>> getCategories(int userId) async {
    final client = await db;
    final res = await client.query(
      'categories',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'name ASC',
    );
    return res.map((m) => CategoryModel.fromMap(m)).toList();
  }

  Future<int> insertCategory(CategoryModel c) async {
    final client = await db;
    return await client.insert('categories', c.toMap());
  }

  Future<int> updateCategory(CategoryModel c) async {
    final client = await db;
    return await client.update(
      'categories',
      c.toMap(),
      where: 'id = ?',
      whereArgs: [c.id],
    );
  }

  Future<int> deleteCategory(int id) async {
    final client = await db;
    return await client.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ========== METODE TUGAS ==========
  Future<List<TaskModel>> getTasks({
    required int userId,
    int? categoryId,
    String? searchQuery,
  }) async {
    final client = await db;
    
    const String where = 'user_id = ?'; // GANTI final MENJADI const
    final List<dynamic> whereArgs = [userId];
    
    String finalWhere = where;
    final List<dynamic> finalWhereArgs = List.from(whereArgs); // TAMBAHKAN final
    
    if (categoryId != null) {
      finalWhere += ' AND category_id = ?';
      finalWhereArgs.add(categoryId);
    }
    
    if (searchQuery != null && searchQuery.isNotEmpty) {
      finalWhere += ' AND (title LIKE ? OR description LIKE ?)';
      finalWhereArgs.add('%$searchQuery%');
      finalWhereArgs.add('%$searchQuery%');
    }
    
    final res = await client.query(
      'tasks',
      where: finalWhere,
      whereArgs: finalWhereArgs,
      orderBy: 'is_completed ASC, deadline ASC',
    );
    
    return res.map((m) => TaskModel.fromMap(m)).toList();
  }

  Future<List<TaskModel>> getTodayTasks(int userId) async {
    final client = await db;
    final today = DateTime.now().toIso8601String().split('T')[0];
    
    final res = await client.query(
      'tasks',
      where: 'user_id = ? AND deadline = ? AND is_completed = 0',
      whereArgs: [userId, today],
      orderBy: 'priority DESC',
    );
    
    return res.map((m) => TaskModel.fromMap(m)).toList();
  }

  Future<int> insertTask(TaskModel t) async {
    final client = await db;
    return await client.insert('tasks', t.toMap());
  }

  Future<int> updateTask(TaskModel t) async {
    final client = await db;
    return await client.update(
      'tasks',
      t.toMap(),
      where: 'id = ?',
      whereArgs: [t.id],
    );
  }

  Future<int> deleteTask(int id) async {
    final client = await db;
    return await client.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> getTaskCountByCategory(int categoryId) async {
    final client = await db;
    final res = await client.rawQuery(
      'SELECT COUNT(*) as count FROM tasks WHERE category_id = ?',
      [categoryId],
    );
    return Sqflite.firstIntValue(res) ?? 0;
  }

  // ========== METODE TAMBAHAN UNTUK STATISTIK ==========
  Future<int> getTotalTasksCount(int userId) async {
    final client = await db;
    final res = await client.rawQuery(
      'SELECT COUNT(*) as count FROM tasks WHERE user_id = ?',
      [userId],
    );
    return Sqflite.firstIntValue(res) ?? 0;
  }

  Future<int> getCompletedTasksCount(int userId) async {
    final client = await db;
    final res = await client.rawQuery(
      'SELECT COUNT(*) as count FROM tasks WHERE user_id = ? AND is_completed = 1',
      [userId],
    );
    return Sqflite.firstIntValue(res) ?? 0;
  }

  Future<int> getPendingTasksCount(int userId) async {
    final client = await db;
    final res = await client.rawQuery(
      'SELECT COUNT(*) as count FROM tasks WHERE user_id = ? AND is_completed = 0',
      [userId],
    );
    return Sqflite.firstIntValue(res) ?? 0;
  }

  Future<int> getOverdueTasksCount(int userId) async {
    final client = await db;
    final today = DateTime.now().toIso8601String().split('T')[0];
    final res = await client.rawQuery(
      '''
      SELECT COUNT(*) as count FROM tasks 
      WHERE user_id = ? AND is_completed = 0 
      AND deadline IS NOT NULL AND deadline < ?
      ''',
      [userId, today],
    );
    return Sqflite.firstIntValue(res) ?? 0;
  }
}