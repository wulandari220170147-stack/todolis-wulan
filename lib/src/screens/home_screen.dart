import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import 'tasks_screen.dart';
import 'categories_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<Widget> _pages = const [
    TasksScreen(),
    CategoriesScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskProvider>(context, listen: false).loadInitialData();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wulan TodoList'),
        centerTitle: true,
        actions: [
          if (_selectedIndex == 0)
            IconButton(
              icon: const Icon(Icons.filter_alt),
              onPressed: () => _showFilterDialog(context),
              tooltip: 'Filter',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<TaskProvider>(context, listen: false).loadInitialData();
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.task),
            label: 'Tugas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Kategori',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context, listen: false);
    
    // Simpan selected category id sementara
    int? tempSelectedCategoryId = provider.selectedCategoryId;
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filter Tugas'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Radio diganti dengan ListTile yang lebih simple
              ListTile(
                title: const Text('Semua'),
                leading: Icon(
                  Icons.radio_button_checked,
                  color: tempSelectedCategoryId == null ? Colors.indigo : Colors.grey,
                ),
                onTap: () {
                  tempSelectedCategoryId = null;
                  Navigator.of(context).pop();
                  provider.setSelectedCategory(null);
                },
              ),
              const Divider(),
              ...provider.categories.map((category) => ListTile(
                    title: Text(category.name),
                    leading: Icon(
                      Icons.radio_button_checked,
                      color: tempSelectedCategoryId == category.id ? Colors.indigo : Colors.grey,
                    ),
                    onTap: () {
                      tempSelectedCategoryId = category.id;
                      Navigator.of(context).pop();
                      provider.setSelectedCategory(category.id);
                    },
                  )),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await provider.clearFilters();
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Hapus Semua'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }
}