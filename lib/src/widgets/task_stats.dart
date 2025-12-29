import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';

class TaskStats extends StatelessWidget {
  const TaskStats({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<TaskProvider>(context);
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              count: prov.totalTasks,
              label: 'Total',
              color: Colors.indigo,
              icon: Icons.list_alt,
            ),
            _buildStatItem(
              count: prov.completedTasks,
              label: 'Selesai',
              color: Colors.green,
              icon: Icons.check_circle,
            ),
            _buildStatItem(
              count: prov.pendingTasks,
              label: 'Menunggu',
              color: Colors.orange,
              icon: Icons.pending_actions,
            ),
            _buildStatItem(
              count: prov.overdueTasks,
              label: 'Terlambat',
              color: Colors.red,
              icon: Icons.warning,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required int count,
    required String label,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}