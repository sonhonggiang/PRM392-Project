import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/api_service.dart';
import '../../../models/user_model.dart';
import '../leaderboard_screen.dart';

class AchievementTab extends StatefulWidget {
  const AchievementTab({super.key});

  @override
  State<AchievementTab> createState() => _AchievementTabState();
}

class _AchievementTabState extends State<AchievementTab> {
  List<dynamic> _badges = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBadges();
  }

  Future<void> _loadBadges() async {
    final auth = context.read<AuthProvider>();
    if (auth.currentUser.role == UserRole.guest) {
      setState(() => _isLoading = false);
      return;
    }
    
    setState(() => _isLoading = true);
    try {
      await auth.refreshProfile();
      final list = await ApiService.getUserBadges();
      setState(() {
        _badges = list;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final isGuest = user.role == UserRole.guest;

    if (isGuest) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🏆', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 16),
              const Text(
                'Thành tựu của bạn',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.indigo),
              ),
              const SizedBox(height: 8),
              const Text(
                'Đăng nhập để xem huy chương, cúp đạt được và bộ sưu tập huy hiệu Origami!',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.muted, fontSize: 13),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () {
                  auth.logout();
                  Navigator.of(context).pushReplacementNamed('/');
                },
                style: FilledButton.styleFrom(backgroundColor: AppTheme.indigo),
                child: const Text('Đăng nhập ngay'),
              ),
            ],
          ),
        ),
      );
    }

    // Các huy hiệu
    final earnedCount = _badges.where((b) => b['earned'] == true || b['earned'] == 1).length;

    return RefreshIndicator(
      onRefresh: _loadBadges,
      color: AppTheme.teal,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HÀNG CÚP VÀ HUY CHƯƠNG ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.indigo, AppTheme.indigoMid],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: AppTheme.indigo.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        const Text('🏆 Cúp Tuần', style: TextStyle(color: AppTheme.amber, fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 10),
                        Text(
                          '${user.weeklyTrophies}',
                          style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 4),
                        const Text('Top 1, 2, 3 bảng tuần', style: TextStyle(color: Colors.white70, fontSize: 10)),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 70, color: Colors.white24),
                  Expanded(
                    child: Column(
                      children: [
                        const Text('🏅 Huy chương Ngày', style: TextStyle(color: AppTheme.tealLight, fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 10),
                        Text(
                          '${user.dailyMedals}',
                          style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 4),
                        const Text('Top 1 bảng hàng ngày', style: TextStyle(color: Colors.white70, fontSize: 10)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- BẢNG XẾP HẠNG CÁ NHÂN ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '📊 Bảng xếp hạng học tập',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.indigo),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
                    );
                  },
                  icon: const Icon(Icons.leaderboard_rounded, size: 16, color: AppTheme.teal),
                  label: const Text('Xem đầy đủ', style: TextStyle(fontSize: 13, color: AppTheme.teal, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppTheme.indigoLight,
                    child: Text(user.avatarUrl.isNotEmpty ? user.avatarUrl : '👤', style: const TextStyle(fontSize: 22)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.displayName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.indigo)),
                        const SizedBox(height: 4),
                        Text('Tích luỹ: ${user.xp} XP • Chuỗi học: ${user.streakCount} ngày', style: const TextStyle(fontSize: 11, color: AppTheme.muted)),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.muted),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- BỘ SƯU TẬP HUY HIỆU ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '🏅 Huy hiệu của tôi',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.indigo),
                ),
                Text(
                  'Đã đạt: $earnedCount/${_badges.length}',
                  style: const TextStyle(fontSize: 12, color: AppTheme.muted, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),

            _isLoading
                ? const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator(color: AppTheme.teal)))
                : _badges.isEmpty
                    ? const Center(child: Text('Chưa có huy hiệu khả dụng', style: TextStyle(color: AppTheme.muted)))
                    : GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: _badges.length,
                        itemBuilder: (context, index) {
                          final badge = _badges[index];
                          final bool isEarned = badge['earned'] == true || badge['earned'] == 1;

                          return Container(
                            decoration: BoxDecoration(
                              color: isEarned ? AppTheme.white : AppTheme.bg,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: isEarned ? AppTheme.teal.withOpacity(0.4) : AppTheme.border),
                              boxShadow: isEarned
                                  ? [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 3))]
                                  : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Emoji
                                Text(
                                  badge['emoji'] ?? '🏅',
                                  style: TextStyle(
                                    fontSize: 32,
                                    color: isEarned ? null : Colors.grey.withOpacity(0.5),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Name
                                Text(
                                  badge['name'] ?? '',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                    color: isEarned ? AppTheme.indigo : Colors.grey,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                // Status label
                                Text(
                                  isEarned ? 'Đã nhận' : 'Khóa 🔒',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: isEarned ? AppTheme.teal : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ],
        ),
      ),
    );
  }
}
