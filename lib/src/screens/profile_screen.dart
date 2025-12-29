import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header Profil
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.indigo.withAlpha(25),
                      border: Border.all(
                        color: Colors.indigo.withAlpha(75),
                        width: 3,
                      ),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.indigo,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Wulan',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'wulan@example.com',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.indigo.withAlpha(25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Akun Premium',
                      style: TextStyle(
                        color: Colors.indigo,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Ringkasan Statistik
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ringkasan Tugas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        value: provider.totalTasks.toString(),
                        label: 'Total',
                        icon: Icons.list_alt,
                        color: Colors.blue,
                      ),
                      _buildStatItem(
                        value: provider.completedTasks.toString(),
                        label: 'Selesai',
                        icon: Icons.check_circle,
                        color: Colors.green,
                      ),
                      _buildStatItem(
                        value: provider.pendingTasks.toString(),
                        label: 'Menunggu',
                        icon: Icons.pending_actions,
                        color: Colors.orange,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Opsi Pengaturan
          Card(
            elevation: 2,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.settings, color: Colors.blue),
                  title: const Text('Pengaturan Aplikasi'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showSettingsDialog(context),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.help, color: Colors.green),
                  title: const Text('Bantuan & Dukungan'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showHelpDialog(context),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.info, color: Colors.purple),
                  title: const Text('Tentang Aplikasi'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showAboutDialog(context),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Aksi Cepat
          Card(
            elevation: 2,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.bug_report, color: Colors.orange),
                  title: const Text('Laporkan Bug'),
                  onTap: () => _showBugReportDialog(context),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.share, color: Colors.teal),
                  title: const Text('Bagikan Aplikasi'),
                  onTap: () => _showShareDialog(context),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Tombol Logout
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text(
                'Keluar',
                style: TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              onPressed: () => _showLogoutDialog(context),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Versi Aplikasi
          const Text(
            'Wulan TodoList v1.0.0',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          const Text(
            '© 2024 - Semua hak dilindungi undang-undang',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
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

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pengaturan Aplikasi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pengaturan akan tersedia di update selanjutnya.'),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Mode Gelap'),
              value: false,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: const Text('Notifikasi'),
              value: true,
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bantuan & Dukungan'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Pertanyaan yang Sering Diajukan:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('Q: Bagaimana cara menambah tugas baru?'),
              Text('A: Ketuk tombol "+" di layar Tugas'),
              SizedBox(height: 8),
              Text('Q: Bagaimana cara menandai tugas selesai?'),
              Text('A: Ketuk kotak centang di samping tugas'),
              SizedBox(height: 8),
              Text('Q: Bagaimana cara menghapus tugas?'),
              Text('A: Geser ke kiri pada tugas'),
              SizedBox(height: 16),
              Text(
                'Untuk bantuan lebih lanjut, hubungi:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Email: support@wulantodolist.com'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tentang Wulan TodoList'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Wulan TodoList v1.0.0',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Aplikasi manajemen tugas lengkap yang dibangun dengan Flutter.',
              ),
              SizedBox(height: 16),
              Text('Fitur Utama:'),
              Text('• Manajemen tugas lengkap'),
              Text('• Organisasi kategori'),
              Text('• Tingkat prioritas'),
              Text('• Pelacakan tenggat waktu'),
              Text('• Autentikasi pengguna'),
              SizedBox(height: 16),
              Text('Teknologi:'),
              Text('• Flutter SDK'),
              Text('• Database SQLite'),
              Text('• Provider state management'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showBugReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Laporkan Bug'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Deskripsikan masalah yang Anda temui:'),
            const SizedBox(height: 12),
            TextFormField(
              maxLines: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Masukkan deskripsi bug...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Laporan bug telah dikirim. Terima kasih!'),
                ),
              );
            },
            child: const Text('Kirim'),
          ),
        ],
      ),
    );
  }

  void _showShareDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bagikan Aplikasi'),
        content: const Text('Bagikan Wulan TodoList dengan teman-teman Anda!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fitur berbagi akan segera hadir!'),
                ),
              );
            },
            child: const Text('Bagikan'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
              Navigator.of(context).pushReplacementNamed('/login');
            },
            child: const Text(
              'Keluar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}