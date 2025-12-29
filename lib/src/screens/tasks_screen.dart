import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/task_provider.dart';
import '../widgets/task_stats.dart';
import 'add_edit_task_screen.dart';
import '../models/task_model.dart';
import '../models/category_model.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_searchController.text.isEmpty) {
      Provider.of<TaskProvider>(context, listen: false)
          .setSearchQuery('');
    }
  }

  void _performSearch() {
    Provider.of<TaskProvider>(context, listen: false)
        .setSearchQuery(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context);
    final tasks = provider.tasks;

    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Cari tugas...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _performSearch();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[100],
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: (value) => _performSearch(),
            onSubmitted: (value) => _performSearch(),
          ),
        ),

        // Statistics
        const TaskStats(),

        // Category Filter Chips
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: provider.categories.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                  child: FilterChip(
                    label: const Text('Semua'),
                    selected: provider.selectedCategoryId == null,
                    onSelected: (selected) async {
                      await provider.setSelectedCategory(
                        selected ? null : provider.selectedCategoryId,
                      );
                    },
                    selectedColor: Colors.indigo.withAlpha(50),
                    checkmarkColor: Colors.indigo,
                  ),
                );
              }
              final category = provider.categories[index - 1];
              return Padding(
                padding: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                child: FilterChip(
                  label: Text(category.name),
                  selected: provider.selectedCategoryId == category.id,
                  onSelected: (selected) async {
                    await provider.setSelectedCategory(
                      selected ? category.id : null,
                    );
                  },
                  selectedColor: Colors.indigo.withAlpha(50),
                  checkmarkColor: Colors.indigo,
                ),
              );
            },
          ),
        ),

        // Task List
        Expanded(
          child: tasks.isEmpty
              ? _buildEmptyState(context, provider)
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return _buildTaskCard(task, context);
                  },
                ),
        ),

        // Add Task Button
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text(
                'Tambah Tugas Baru',
                style: TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AddEditTaskScreen(),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskCard(TaskModel task, BuildContext context) {
    final provider = Provider.of<TaskProvider>(context, listen: false);
    final category = provider.categories
        .firstWhere((cat) => cat.id == task.categoryId, 
          orElse: () => CategoryModel(name: 'Tidak Diketahui', userId: 1));

    Color getPriorityColor() {
      switch (task.priority) {
        case 'Tinggi':
          return Colors.red;
        case 'Sedang':
          return Colors.orange;
        default:
          return Colors.green;
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Dismissible(
        key: ValueKey(task.id),
        background: Container(
          color: Colors.red,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 20),
          child: const Icon(Icons.delete, color: Colors.white, size: 30),
        ),
        direction: DismissDirection.startToEnd,
        confirmDismiss: (direction) async {
          return await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Hapus Tugas'),
              content: const Text('Apakah Anda yakin ingin menghapus tugas ini?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          );
        },
        onDismissed: (direction) async {
          await provider.deleteTask(task.id!);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Tugas berhasil dihapus'),
                backgroundColor: Colors.red[700],
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: Checkbox(
            value: task.isCompleted == 1,
            onChanged: (value) => provider.toggleComplete(task),
            shape: const CircleBorder(),
            fillColor: WidgetStateProperty.resolveWith<Color>(
              (states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.green;
                }
                return Colors.grey;
              },
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    decoration: task.isCompleted == 1
                        ? TextDecoration.lineThrough
                        : null,
                    color: task.isCompleted == 1
                        ? Colors.grey
                        : task.isOverdue
                            ? Colors.red
                            : Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: getPriorityColor().withAlpha(25),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: getPriorityColor().withAlpha(75)),
                ),
                child: Text(
                  task.priority,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: getPriorityColor(),
                  ),
                ),
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (task.description != null && task.description!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 4),
                  child: Text(
                    task.description!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.indigo.withAlpha(25),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      category.name,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.indigo,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (task.deadline != null)
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 12,
                          color: task.isOverdue ? Colors.red : Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('dd/MM/yy').format(
                            DateTime.parse(task.deadline!),
                          ),
                          style: TextStyle(
                            fontSize: 11,
                            color: task.isOverdue ? Colors.red : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.edit, size: 20),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AddEditTaskScreen(task: task),
                ),
              );
            },
            tooltip: 'Edit',
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, TaskProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          const Text(
            'Tidak ada tugas',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            provider.searchQuery.isNotEmpty
                ? 'Coba dengan kata kunci lain'
                : 'Ketuk + untuk menambahkan tugas pertama',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (provider.searchQuery.isNotEmpty)
            ElevatedButton(
              onPressed: () {
                _searchController.clear();
                _performSearch();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
              ),
              child: const Text('Hapus Pencarian'),
            ),
        ],
      ),
    );
  }
}