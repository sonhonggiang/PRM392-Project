import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../models/user_model.dart';
import '../../origami/origami_detail_screen.dart';
import '../my_learning_screen.dart';
import '../daily_challenge_screen.dart';
import '../admin_approval_screen.dart';

class HomeTab extends StatefulWidget {
  final VoidCallback? onNavigateToExplore;
  const HomeTab({super.key, this.onNavigateToExplore});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // ─── Tất cả mẫu (có thêm addedDate để sort mới nhất) ─────────────────────
  final List<Map<String, dynamic>> _allModels = const [
    {'name': 'Hoa Hồng', 'emoji': '🌺', 'difficulty': '⭐⭐⭐', 'time': '25 phút', 'rating': 4.7, 'category': 'Hoa cỏ', 'addedDaysAgo': 10},
    {'name': 'Hạc Giấy', 'emoji': '🦢', 'difficulty': '⭐⭐⭐⭐', 'time': '15 phút', 'rating': 4.9, 'category': 'Động vật', 'addedDaysAgo': 7},
    {'name': 'Rồng Lửa', 'emoji': '🐲', 'difficulty': '⭐⭐⭐⭐⭐', 'time': '60 phút', 'rating': 5.0, 'category': 'Động vật', 'addedDaysAgo': 3},
    {'name': 'Máy Bay', 'emoji': '✈️', 'difficulty': '⭐⭐', 'time': '10 phút', 'rating': 4.2, 'category': 'Đồ vật', 'addedDaysAgo': 15},
    {'name': 'Con Ếch', 'emoji': '🐸', 'difficulty': '⭐⭐⭐', 'time': '5 phút', 'rating': 4.5, 'category': 'Động vật', 'addedDaysAgo': 20},
    {'name': 'Trái Tim', 'emoji': '❤️', 'difficulty': '⭐⭐', 'time': '8 phút', 'rating': 4.6, 'category': 'Đồ vật', 'addedDaysAgo': 5},
    {'name': 'Cá Vàng', 'emoji': '🐠', 'difficulty': '⭐⭐⭐⭐', 'time': '20 phút', 'rating': 4.8, 'category': 'Động vật', 'addedDaysAgo': 1},
    {'name': 'Khủng Long', 'emoji': '🦖', 'difficulty': '⭐⭐⭐⭐⭐', 'time': '45 phút', 'rating': 4.9, 'category': 'Động vật', 'addedDaysAgo': 2},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Mẫu mới nhất (sort theo addedDaysAgo tăng dần → nhỏ nhất = mới nhất)
  Map<String, dynamic> get _newestModel {
    final sorted = List<Map<String, dynamic>>.from(_allModels);
    sorted.sort((a, b) => (a['addedDaysAgo'] as int).compareTo(b['addedDaysAgo'] as int));
    return sorted.first;
  }

  // ── Top 4 mẫu theo rating cao nhất
  List<Map<String, dynamic>> get _topRatedModels {
    final sorted = List<Map<String, dynamic>>.from(_allModels);
    sorted.sort((a, b) => (b['rating'] as double).compareTo(a['rating'] as double));
    return sorted.take(4).toList();
  }

  // ── Kết quả tìm kiếm
  List<Map<String, dynamic>> get _searchResults {
    if (_searchQuery.isEmpty) return [];
    return _allModels
        .where((m) => m['name'].toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final isGuest = user.role == UserRole.guest;
    final newest = _newestModel;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Search Bar ─────────────────────────────────────────────────
          TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Tìm mẫu gấp...',
              prefixIcon: const Icon(Icons.search, color: AppTheme.muted),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      })
                  : null,
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

          // ── Kết quả tìm kiếm ───────────────────────────────────────────
          if (_searchQuery.isNotEmpty) ...[
            Text(
              'Kết quả cho "$_searchQuery"',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.indigo),
            ),
            const SizedBox(height: 12),
            _searchResults.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text('Không tìm thấy mẫu nào 🔍',
                          style: TextStyle(color: AppTheme.muted)),
                    ))
                : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final item = _searchResults[index];
                      return _buildOrigamiCard(
                        context, item['emoji'], item['name'],
                        item['difficulty'], item['time'], item['rating'].toString(),
                      );
                    },
                  ),
            const SizedBox(height: 24),
          ],

          // ── Layout chính (khi không search) ────────────────────────────
          if (_searchQuery.isEmpty) ...[

            // ── Banner mẫu MỚI NHẤT (clickable) ──────────────────────────
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OrigamiDetailScreen()),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.indigo, AppTheme.indigoMid],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.indigo.withOpacity(0.3),
                      blurRadius: 16, offset: const Offset(0, 6),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Badge MỚI
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.teal,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text('✨ MỚI NHẤT',
                                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${newest['addedDaysAgo']} ngày trước',
                                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            newest['name'],
                            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Text(
                                newest['difficulty'],
                                style: const TextStyle(fontSize: 12),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '⏱️ ${newest['time']}',
                                style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  'Học ngay →',
                                  style: TextStyle(
                                    color: AppTheme.indigo,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Text(
                      newest['emoji'],
                      style: const TextStyle(fontSize: 64),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Quick Stats: Đang học / Đã xong ──────────────────────────
            if (!isGuest)
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MyLearningScreen()),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppTheme.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.amber.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.hourglass_bottom_rounded, color: AppTheme.amber, size: 20),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text('3', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.amber)),
                                Text('Đang làm dở', style: TextStyle(fontSize: 11, color: AppTheme.muted)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MyLearningScreen()),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppTheme.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.teal.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.check_circle_rounded, color: AppTheme.teal, size: 20),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text('12', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.teal)),
                                Text('Đã hoàn thành', style: TextStyle(fontSize: 11, color: AppTheme.muted)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 24),

            // ── Daily Challenge Card ──────────────────────────────────────
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DailyChallengeScreen()),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.teal, AppTheme.tealLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.teal.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Colors.white24,
                        shape: BoxShape.circle,
                      ),
                      child: const Text('🎯', style: TextStyle(fontSize: 24)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Thử thách hàng ngày!',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Hoàn thành mẫu hôm nay để nhận +100 XP',
                            style: TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Admin Banner ──────────────────────────────────────────────
            if (user.role == UserRole.admin) ...[
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminApprovalScreen()),
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.red.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.admin_panel_settings, color: AppTheme.red),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text('Bạn có 3 mẫu Origami chờ duyệt',
                            style: TextStyle(color: AppTheme.red, fontWeight: FontWeight.bold)),
                      ),
                      Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.red.withOpacity(0.7), size: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // ── Guest Banner ──────────────────────────────────────────────
            if (isGuest) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.amber.withOpacity(0.5)),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Đăng nhập để lưu tiến độ và xem các mẫu yêu thích!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.amber, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: () {
                        auth.logout();
                        Navigator.of(context).pushReplacementNamed('/');
                      },
                      style: FilledButton.styleFrom(backgroundColor: AppTheme.amber),
                      child: const Text('Đăng nhập ngay'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // ── Đề xuất Top Rating ────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '⭐ Đề xuất – Top Rating',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.indigo),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.amber.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('HOT 🔥', style: TextStyle(fontSize: 11, color: AppTheme.amber, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: _topRatedModels.length,
              itemBuilder: (context, index) {
                final item = _topRatedModels[index];
                return _buildOrigamiCard(
                  context, item['emoji'], item['name'],
                  item['difficulty'], item['time'], item['rating'].toString(),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }

  Widget _buildOrigamiCard(
    BuildContext context,
    String emoji,
    String title,
    String difficulty,
    String time,
    String rating,
  ) {
    return GestureDetector(
      onTap: () => Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const OrigamiDetailScreen())),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
          boxShadow: const [
            BoxShadow(color: Color(0x0D1A2F6E), blurRadius: 12, offset: Offset(0, 4)),
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
                child: Center(child: Text(emoji, style: const TextStyle(fontSize: 48))),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(difficulty, style: const TextStyle(fontSize: 10)),
                      const Spacer(),
                      const Icon(Icons.star, color: AppTheme.amber, size: 12),
                      const SizedBox(width: 2),
                      Text(rating,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('⏱️ $time',
                      style: const TextStyle(fontSize: 10, color: AppTheme.teal)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
