import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';

class AddEditTaskScreen extends StatefulWidget {
  final TaskModel? task;
  const AddEditTaskScreen({super.key, this.task});

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _priority = 'Rendah';
  int? _categoryId;
  DateTime? _deadline;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleCtrl.text = widget.task!.title;
      _descCtrl.text = widget.task!.description ?? '';
      _priority = widget.task!.priority;
      _categoryId = widget.task!.categoryId;
      if (widget.task!.deadline != null) {
        _deadline = DateTime.tryParse(widget.task!.deadline!);
      }
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.indigo,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.indigo,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && context.mounted) {
      setState(() => _deadline = picked);
    }
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    final provider = Provider.of<TaskProvider>(context, listen: false);
    
    if (_categoryId == null && provider.categories.isNotEmpty) {
      _categoryId = provider.categories.first.id;
    }
    
    if (_categoryId == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Silakan pilih kategori')),
        );
      }
      return;
    }

    final task = TaskModel(
      id: widget.task?.id,
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      categoryId: _categoryId!,
      userId: provider.currentUserId,
      priority: _priority,
      deadline: _deadline != null
          ? DateFormat('yyyy-MM-dd').format(_deadline!)
          : null,
      isCompleted: widget.task?.isCompleted ?? 0,
    );

    try {
      if (widget.task == null) {
        await provider.addTask(task);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Tugas berhasil ditambahkan'),
              backgroundColor: Colors.green[700],
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        await provider.updateTask(task);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Tugas berhasil diperbarui'),
              backgroundColor: Colors.blue[700],
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
      
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context);
    final categories = provider.categories;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Tambah Tugas Baru' : 'Edit Tugas'),
        actions: [
          if (widget.task != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                final confirmed = await showDialog(
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
                
                if (confirmed == true && context.mounted) {
                  await provider.deleteTask(widget.task!.id!);
                  Navigator.of(context).pop();
                }
              },
              tooltip: 'Hapus',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Field Judul
              TextFormField(
                controller: _titleCtrl,
                decoration: InputDecoration(
                  labelText: 'Judul Tugas',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  prefixIcon: const Icon(Icons.title),
                  hintText: 'Masukkan judul tugas',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Judul harus diisi';
                  }
                  return null;
                },
                maxLength: 100,
                autofocus: widget.task == null,
              ),
              const SizedBox(height: 16),

              // Field Deskripsi
              TextFormField(
                controller: _descCtrl,
                decoration: InputDecoration(
                  labelText: 'Deskripsi (opsional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  prefixIcon: const Icon(Icons.description),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                maxLength: 500,
              ),
              const SizedBox(height: 16),

              // Dropdown Kategori
              DropdownButtonFormField<int>(
                initialValue: _categoryId ?? (categories.isNotEmpty ? categories.first.id : null),
                decoration: InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  prefixIcon: const Icon(Icons.category),
                ),
                items: categories
                    .map((category) => DropdownMenuItem<int>(
                          value: category.id,
                          child: Text(category.name),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _categoryId = value),
                validator: (value) {
                  if (value == null) {
                    return 'Silakan pilih kategori';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Prioritas
              const Text(
                'Prioritas',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Rendah'),
                      selected: _priority == 'Rendah',
                      selectedColor: Colors.green.withAlpha(50),
                      labelStyle: TextStyle(
                        color: _priority == 'Rendah' ? Colors.green : Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                      onSelected: (selected) {
                        setState(() => _priority = 'Rendah');
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Sedang'),
                      selected: _priority == 'Sedang',
                      selectedColor: Colors.orange.withAlpha(50),
                      labelStyle: TextStyle(
                        color: _priority == 'Sedang' ? Colors.orange : Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                      onSelected: (selected) {
                        setState(() => _priority = 'Sedang');
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Tinggi'),
                      selected: _priority == 'Tinggi',
                      selectedColor: Colors.red.withAlpha(50),
                      labelStyle: TextStyle(
                        color: _priority == 'Tinggi' ? Colors.red : Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                      onSelected: (selected) {
                        setState(() => _priority = 'Tinggi');
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Tenggat Waktu
              const Text(
                'Tenggat Waktu (opsional)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[50],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: _deadline != null ? Colors.indigo : Colors.grey,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _deadline != null
                              ? DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(_deadline!)
                              : 'Pilih tanggal',
                          style: TextStyle(
                            color: _deadline != null ? Colors.black : Colors.grey,
                          ),
                        ),
                      ),
                      if (_deadline != null)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            setState(() => _deadline = null);
                          },
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Tombol Aksi
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: const BorderSide(color: Colors.grey),
                      ),
                      child: const Text(
                        'Batal',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 4,
                      ),
                      child: Text(
                        widget.task == null ? 'Tambah Tugas' : 'Update Tugas',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}