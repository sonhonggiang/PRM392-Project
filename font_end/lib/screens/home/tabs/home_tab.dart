import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../models/user_model.dart';
import '../../origami/origami_detail_screen.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final isGuest = user.role == UserRole.guest;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Tìm mẫu gấp...',
              prefixIcon: const Icon(Icons.search, color: AppTheme.muted),
              fillColor: AppTheme.white,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
          const SizedBox(height: 24),

          // Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.indigo, AppTheme.indigoMid],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.teal,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('MỚI', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 8),
                      const Text('Hạc Nghìn Con', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Khám phá truyền thuyết', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
                    ],
                  ),
                ),
                const Text('🕊️', style: TextStyle(fontSize: 48)),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Categories
          const Text('Danh mục', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.indigo)),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCategoryChip('🐦', 'Động vật', true),
                _buildCategoryChip('🌸', 'Hoa', false),
                _buildCategoryChip('🏯', 'Kiến trúc', false),
                _buildCategoryChip('⭐', 'Theo mùa', false),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Admin Section
          if (user.role == UserRole.admin) ...[
            const Text('Quản lý hệ thống', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.red)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppTheme.red.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
              child: const Row(
                children: [
                  Icon(Icons.admin_panel_settings, color: AppTheme.red),
                  SizedBox(width: 12),
                  Expanded(child: Text('Bạn có 5 mẫu Origami chờ duyệt', style: TextStyle(color: AppTheme.red, fontWeight: FontWeight.bold))),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Guest Banner
          if (isGuest) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppTheme.amber.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.amber.withOpacity(0.5))),
              child: Column(
                children: [
                  const Text('Đăng nhập để lưu tiến độ và xem các mẫu yêu thích!', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.amber, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: () {
                      auth.logout();
                      Navigator.of(context).pushReplacementNamed('/');
                    },
                    style: FilledButton.styleFrom(backgroundColor: AppTheme.amber),
                    child: const Text('Đăng nhập ngay'),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Continue Learning (Hidden for guests)
          if (!isGuest) ...[
            const Text('Tiếp tục học', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.indigo)),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const OrigamiDetailScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppTheme.bg, borderRadius: BorderRadius.circular(12)),
                      child: const Text('🦢', style: TextStyle(fontSize: 24)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Hạc giấy Nhật Bản', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 4),
                          Text('Bước 4/18', style: TextStyle(color: AppTheme.muted, fontSize: 12)),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: 4/18,
                            backgroundColor: AppTheme.gray,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.teal),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.play_circle_fill, color: AppTheme.indigo, size: 36),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Recommended Grid
          const Text('Đề xuất cho bạn', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.indigo)),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.85,
            children: [
              _buildOrigamiCard(context, '🦊', 'Cáo nhỏ', '⭐⭐', '15 phút', '4.8'),
              _buildOrigamiCard(context, '🐉', 'Rồng 3D', '⭐⭐⭐⭐⭐', '60 phút', '4.9'),
              _buildOrigamiCard(context, '🐸', 'Ếch nhảy', '⭐', '5 phút', '4.5'),
              _buildOrigamiCard(context, '🌺', 'Hoa hồng', '⭐⭐⭐', '25 phút', '4.7'),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String emoji, String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.indigo : AppTheme.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isSelected ? AppTheme.indigo : AppTheme.border),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppTheme.text,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrigamiCard(BuildContext context, String emoji, String title, String difficulty, String time, String rating) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const OrigamiDetailScreen()),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D1A2F6E),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppTheme.bg,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 48)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(difficulty, style: const TextStyle(fontSize: 10)),
                      const Spacer(),
                      const Icon(Icons.star, color: AppTheme.amber, size: 12),
                      const SizedBox(width: 2),
                      Text(rating, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('⏱️ $time', style: const TextStyle(fontSize: 10, color: AppTheme.teal)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
