import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/api_service.dart';
import '../../../models/user_model.dart';
import '../../origami/origami_detail_screen.dart';

class FavoriteTab extends StatefulWidget {
  const FavoriteTab({super.key});

  @override
  State<FavoriteTab> createState() => _FavoriteTabState();
}

class _FavoriteTabState extends State<FavoriteTab> {
  List<dynamic> _favoriteList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  // Tải danh sách yêu thích từ API
  Future<void> _loadFavorites() async {
    final auth = context.read<AuthProvider>();
    if (auth.currentUser.role == UserRole.guest) {
      setState(() => _isLoading = false);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final list = await ApiService.getFavorites();
      if (mounted) {
        setState(() {
          _favoriteList = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Lỗi tải danh sách yêu thích: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Toggle favorite (bỏ thích trực tiếp tại màn hình này)
  Future<void> _handleToggleFavorite(int origamiId) async {
    final success = await ApiService.toggleFavorite(origamiId);
    if (success == false) {
      // Khi đã xóa khỏi favorites thành công (hoặc toggle về false)
      // Ta tải lại danh sách
      _loadFavorites();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã bỏ yêu thích mẫu này!'),
          backgroundColor: AppTheme.indigoMid,
        ),
      );
    } else {
      _loadFavorites();
    }
  }

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

    return _isLoading
        ? const Center(child: CircularProgressIndicator(color: AppTheme.teal))
        : RefreshIndicator(
            onRefresh: _loadFavorites,
            color: AppTheme.teal,
            child: _favoriteList.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _favoriteList.length,
                    itemBuilder: (context, index) {
                      final item = _favoriteList[index];
                      return _buildFavoriteItem(context, item);
                    },
                  ),
          );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text('❤️', style: TextStyle(fontSize: 64)),
              SizedBox(height: 16),
              Text(
                'Danh sách yêu thích trống!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.indigo),
              ),
              SizedBox(height: 8),
              Text(
                'Hãy khám phá và thả tim các mẫu Origami bạn thích nhé.',
                style: TextStyle(color: AppTheme.muted),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFavoriteItem(BuildContext context, dynamic item) {
    final id = item['id'];
    final name = item['name'] ?? '';
    final emoji = item['emoji'] ?? '🦢';
    final difficulty = item['difficulty'] ?? 'Dễ';
    final time = '${item['estimated_time'] ?? item['estimatedTime'] ?? 10} phút';
    final category = item['category_name'] ?? 'Mẫu xếp';

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => OrigamiDetailScreen(origamiId: id)),
        ).then((_) => _loadFavorites());
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
              child: Center(child: Text(emoji, style: const TextStyle(fontSize: 40))),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text('📁 $category', style: const TextStyle(fontSize: 12, color: AppTheme.muted)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text('Độ khó: $difficulty', style: const TextStyle(fontSize: 10, color: AppTheme.amber, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 12),
                      Text('⏱️ $time', style: const TextStyle(fontSize: 10, color: AppTheme.teal)),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.favorite, color: AppTheme.red),
              onPressed: () => _handleToggleFavorite(id),
            ),
          ],
        ),
      ),
    );
  }
}
