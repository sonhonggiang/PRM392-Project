import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../models/user_model.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final isGuest = user.role == UserRole.guest;

    if (isGuest) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Vui lòng đăng nhập để xem hồ sơ', style: TextStyle(color: AppTheme.muted)),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                auth.logout();
                Navigator.of(context).pushReplacementNamed('/');
              },
              child: const Text('Đăng nhập'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Avatar & Name
          CircleAvatar(
            radius: 50,
            backgroundColor: AppTheme.indigo.withOpacity(0.1),
            child: const Text('👤', style: TextStyle(fontSize: 50)),
          ),
          const SizedBox(height: 16),
          Text(user.displayName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.indigo)),
          const SizedBox(height: 4),
          Text(user.email, style: const TextStyle(color: AppTheme.muted)),
          const SizedBox(height: 8),
          
          // Role Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: user.role == UserRole.admin ? AppTheme.red.withOpacity(0.1) : 
                     user.role == UserRole.creator ? AppTheme.amber.withOpacity(0.1) : AppTheme.teal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              user.role.name.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: user.role == UserRole.admin ? AppTheme.red : 
                       user.role == UserRole.creator ? AppTheme.amber : AppTheme.teal,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStat('12', 'Đã gấp'),
              Container(width: 1, height: 40, color: AppTheme.border),
              _buildStat('5', 'Yêu thích'),
              Container(width: 1, height: 40, color: AppTheme.border),
              _buildStat('3', 'Huy hiệu'),
            ],
          ),
          const SizedBox(height: 32),

          // Badges Section
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Huy hiệu đạt được', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.indigo)),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildBadge('🌱', 'Người mới'),
              const SizedBox(width: 12),
              _buildBadge('🦢', 'Fan Hạc giấy'),
              const SizedBox(width: 12),
              _buildBadge('🔥', 'Chuỗi 7 ngày'),
            ],
          ),
          const SizedBox(height: 32),

          // Menu Actions
          _buildMenuAction(Icons.history, 'Lịch sử học tập'),
          _buildMenuAction(Icons.settings, 'Cài đặt tài khoản'),
          _buildMenuAction(Icons.help_outline, 'Trung tâm trợ giúp'),
          const SizedBox(height: 24),
          
          OutlinedButton(
            onPressed: () {
              auth.logout();
              Navigator.of(context).pushReplacementNamed('/');
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.red,
              side: const BorderSide(color: AppTheme.red),
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('Đăng xuất', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.indigo)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.muted)),
      ],
    );
  }

  Widget _buildBadge(String emoji, String name) {
    return Column(
      children: [
        Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(
            color: AppTheme.amber.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.amber.withOpacity(0.5), width: 2),
          ),
          child: Center(child: Text(emoji, style: const TextStyle(fontSize: 32))),
        ),
        const SizedBox(height: 8),
        Text(name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildMenuAction(IconData icon, String title) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.indigo.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppTheme.indigo),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      trailing: const Icon(Icons.chevron_right, color: AppTheme.muted),
      onTap: () {},
    );
  }
}
