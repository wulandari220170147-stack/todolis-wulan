import 'package:flutter/material.dart';
import '../helpers/db_helper.dart';
import '../models/task_model.dart';
import '../models/category_model.dart';

class TaskProvider extends ChangeNotifier {
  final DBHelper _db = DBHelper();
  int currentUserId = 1; // Default ke user demo
  
  List<TaskModel> _tasks = [];
  List<CategoryModel> _categories = [];
  String _searchQuery = '';
  int? _selectedCategoryId;

  List<TaskModel> get tasks => _tasks;
  List<CategoryModel> get categories => _categories;
  String get searchQuery => _searchQuery;
  int? get selectedCategoryId => _selectedCategoryId;

  // Statistik
  int get totalTasks => _tasks.length;
  int get completedTasks => _tasks.where((t) => t.isCompleted == 1).length;
  int get pendingTasks => totalTasks - completedTasks;
  int get overdueTasks => _tasks.where((t) => t.isOverdue).length;

  Future<void> loadInitialData() async {
    try {
      _categories = await _db.getCategories(currentUserId);
      _tasks = await _db.getTasks(
        userId: currentUserId,
        categoryId: _selectedCategoryId,
        searchQuery: _searchQuery,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading data: $e');
      rethrow;
    }
  }

  Future<void> setSearchQuery(String query) async {
    _searchQuery = query;
    await loadInitialData();
  }

  Future<void> setSelectedCategory(int? categoryId) async {
    _selectedCategoryId = categoryId;
    await loadInitialData();
  }

  Future<void> clearFilters() async {
    _searchQuery = '';
    _selectedCategoryId = null;
    await loadInitialData();
  }

  // Operasi kategori
  Future<void> addCategory(CategoryModel c) async {
    try {
      await _db.insertCategory(c);
      await loadInitialData();
    } catch (e) {
      debugPrint('Error adding category: $e');
      rethrow;
    }
  }

  Future<void> updateCategory(CategoryModel c) async {
    try {
      await _db.updateCategory(c);
      await loadInitialData();
    } catch (e) {
      debugPrint('Error updating category: $e');
      rethrow;
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      await _db.deleteCategory(id);
      await loadInitialData();
    } catch (e) {
      debugPrint('Error deleting category: $e');
      rethrow;
    }
  }

  // Operasi tugas
  Future<void> addTask(TaskModel t) async {
    try {
      await _db.insertTask(t);
      await loadInitialData();
    } catch (e) {
      debugPrint('Error adding task: $e');
      rethrow;
    }
  }

  Future<void> updateTask(TaskModel t) async {
    try {
      await _db.updateTask(t);
      await loadInitialData();
    } catch (e) {
      debugPrint('Error updating task: $e');
      rethrow;
    }
  }

  Future<void> deleteTask(int id) async {
    try {
      await _db.deleteTask(id);
      await loadInitialData();
    } catch (e) {
      debugPrint('Error deleting task: $e');
      rethrow;
    }
  }

  Future<void> toggleComplete(TaskModel t) async {
    try {
      t.isCompleted = t.isCompleted == 0 ? 1 : 0;
      await _db.updateTask(t);
      await loadInitialData();
    } catch (e) {
      debugPrint('Error toggling task: $e');
      rethrow;
    }
  }

  Future<List<TaskModel>> getTodayTasks() async {
    return await _db.getTodayTasks(currentUserId);
  }

  Future<Map<String, dynamic>> getStats() async {
    return {
      'total': totalTasks,
      'completed': completedTasks,
      'pending': pendingTasks,
      'overdue': overdueTasks,
    };
  }
}