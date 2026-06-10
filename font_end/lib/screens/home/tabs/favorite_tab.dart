import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../models/user_model.dart';
import '../../origami/origami_detail_screen.dart';

class FavoriteTab extends StatelessWidget {
  const FavoriteTab({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isGuest = auth.currentUser.role == UserRole.guest;

    if (isGuest) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('❤️', style: TextStyle(fontSize: 80)),
              const SizedBox(height: 24),
              const Text(
                'Chưa có mẫu yêu thích',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.indigo),
              ),
              const SizedBox(height: 12),
              const Text(
                'Vui lòng đăng nhập để lưu lại những mẫu Origami bạn yêu thích nhất.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.muted, height: 1.5),
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: () {
                  auth.logout();
                  Navigator.of(context).pushReplacementNamed('/');
                },
                child: const Text('Đăng nhập ngay'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) {
        return _buildFavoriteItem(context);
      },
    );
  }

  Widget _buildFavoriteItem(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const OrigamiDetailScreen()),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                color: AppTheme.bg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(child: Text('🦊', style: TextStyle(fontSize: 40))),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Cáo nhỏ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 4),
                  Text('🐦 Động vật', style: TextStyle(fontSize: 12, color: AppTheme.muted)),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Text('⭐⭐', style: TextStyle(fontSize: 10)),
                      SizedBox(width: 12),
                      Text('⏱️ 15 phút', style: TextStyle(fontSize: 10, color: AppTheme.teal)),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.favorite, color: AppTheme.red),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
