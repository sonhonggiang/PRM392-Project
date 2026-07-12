import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/api_service.dart';
import '../../../models/user_model.dart';
import '../../origami/origami_detail_screen.dart';
import '../my_learning_screen.dart';
import '../daily_challenge_screen.dart';
import '../admin_approval_screen.dart';
import '../components/gamification_section.dart';

class HomeTab extends StatefulWidget {
  final VoidCallback? onNavigateToExplore;
  const HomeTab({super.key, this.onNavigateToExplore});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Dữ liệu tải từ Backend API
  List<dynamic> _topRatedModels = [];
  List<dynamic> _searchResults = [];
  Map<String, dynamic>? _newestModel;
  int _inProgressCount = 0;
  int _completedCount = 0;
  int _pendingCount = 0;
  bool _isLoading = true;
  bool _isSearching = false;
  List<dynamic> _allModels = [];
  List<dynamic> _userProgressList = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Tải toàn bộ dữ liệu hiển thị trên Dashboard từ Backend
  Future<void> _loadDashboardData() async {
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;
    final isGuest = user.role == UserRole.guest;

    setState(() => _isLoading = true);

    try {
      // 1. Tải danh sách mẫu xếp hạng cao nhất (chỉ lấy mẫu 4-5 sao)
      final ratingList = await ApiService.getOrigamiList(sortBy: 'rating');
      _topRatedModels = ratingList.where((item) {
        final rating = double.tryParse((item['rating'] ?? '0.0').toString()) ?? 0.0;
        return rating >= 4.0;
      }).take(4).toList();

      // 2. Tải danh sách mẫu mới nhất
      final newestList = await ApiService.getOrigamiList(sortBy: 'newest');
      _allModels = newestList;
      if (newestList.isNotEmpty) {
        _newestModel = newestList.first;
      }

      // 3. Tải thông số tiến trình học tập nếu không phải Guest
      if (!isGuest) {
        final progressList = await ApiService.getProgress();
        _userProgressList = progressList;
        int inProgress = 0;
        int completed = 0;
        for (var prog in progressList) {
          if (prog['is_completed'] == 1 || prog['isCompleted'] == true) {
            completed++;
          } else {
            inProgress++;
          }
        }
        _inProgressCount = inProgress;
        _completedCount = completed;

        // 4. Nếu là Admin, tải thêm số lượng mẫu chờ phê duyệt
        if (user.role == UserRole.admin) {
          final pendingList = await ApiService.getPendingOrigami();
          _pendingCount = pendingList.length;
        }
      }
    } catch (e) {
      print('Lỗi tải dữ liệu Dashboard: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Thực hiện tìm kiếm qua API khi người dùng thay đổi từ khóa
  Future<void> _onSearchChanged(String query) async {
    setState(() {
      _searchQuery = query;
    });

    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    try {
      final results = await ApiService.getOrigamiList(search: query);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final isGuest = user.role == UserRole.guest;

    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      color: AppTheme.teal,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Search Bar ─────────────────────────────────────────────────
            TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Tìm mẫu gấp...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.muted),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
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
              _isSearching
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(color: AppTheme.teal),
                      ),
                    )
                  : _searchResults.isEmpty
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
                              context,
                              item['id'],
                              item['emoji'] ?? '📄',
                              item['name'] ?? '',
                              item['difficulty'] ?? 'Dễ',
                              '${item['estimated_time'] ?? item['estimatedTime'] ?? 10} phút',
                              (item['rating'] ?? 0.0).toString(),
                            );
                          },
                        ),
              const SizedBox(height: 24),
            ],

            // ── Layout chính (khi không search) ────────────────────────────
            if (_searchQuery.isEmpty) ...[
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 50),
                    child: CircularProgressIndicator(color: AppTheme.teal),
                  ),
                )
              else ...[
                // ── Banner mẫu MỚI NHẤT (clickable) ──────────────────────────
                if (_newestModel != null)
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OrigamiDetailScreen(origamiId: _newestModel!['id']),
                      ),
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
                            blurRadius: 16,
                            offset: const Offset(0, 6),
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
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  _newestModel!['name'] ?? '',
                                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Text(
                                      _newestModel!['difficulty'] ?? 'Dễ',
                                      style: const TextStyle(fontSize: 12, color: Colors.white),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      '⏱️ ${_newestModel!['estimated_time'] ?? _newestModel!['estimatedTime'] ?? 10} phút',
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
                            _newestModel!['emoji'] ?? '🦢',
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
                          ).then((_) => _loadDashboardData()),
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
                                  children: [
                                    Text('$_inProgressCount', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.amber)),
                                    const Text('Đang làm dở', style: TextStyle(fontSize: 11, color: AppTheme.muted)),
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
                          ).then((_) => _loadDashboardData()),
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
                                  children: [
                                    Text('$_completedCount', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.teal)),
                                    const Text('Đã hoàn thành', style: TextStyle(fontSize: 11, color: AppTheme.muted)),
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
                if (!isGuest) ...[
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DailyChallengeScreen()),
                    ).then((_) => _loadDashboardData()),
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
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
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
                  GamificationSection(
                    allModels: _allModels,
                    userProgress: _userProgressList,
                    onRefresh: _loadDashboardData,
                  ),
                  const SizedBox(height: 24),
                ],

                // ── Admin Banner ──────────────────────────────────────────────
                if (user.role == UserRole.admin && _pendingCount > 0) ...[
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AdminApprovalScreen()),
                    ).then((_) => _loadDashboardData()),
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
                          Expanded(
                            child: Text('Bạn có $_pendingCount mẫu Origami chờ duyệt',
                                style: const TextStyle(color: AppTheme.red, fontWeight: FontWeight.bold)),
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
                _topRatedModels.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text('Chưa có dữ liệu mẫu được xếp hạng 🌟',
                              style: TextStyle(color: AppTheme.muted)),
                        ),
                      )
                    : GridView.builder(
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
                            context,
                            item['id'],
                            item['emoji'] ?? '🦢',
                            item['name'] ?? '',
                            item['difficulty'] ?? 'Trung bình',
                            '${item['estimated_time'] ?? item['estimatedTime'] ?? 15} phút',
                            (item['rating'] ?? 0.0).toString(),
                          );
                        },
                      ),
                const SizedBox(height: 24),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOrigamiCard(
    BuildContext context,
    int id,
    String emoji,
    String title,
    String difficulty,
    String time,
    String rating,
  ) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OrigamiDetailScreen(origamiId: id),
        ),
      ).then((_) => _loadDashboardData()),
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
