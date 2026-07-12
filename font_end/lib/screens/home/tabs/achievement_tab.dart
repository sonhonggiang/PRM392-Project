import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/api_service.dart';
import '../../../models/user_model.dart';
import '../../../core/services/gamification_service.dart';
import '../leaderboard_screen.dart';

class AchievementTab extends StatefulWidget {
  const AchievementTab({super.key});

  @override
  State<AchievementTab> createState() => _AchievementTabState();
}

class _AchievementTabState extends State<AchievementTab> {
  List<dynamic> _badges = [];
  List<dynamic> _userProgress = [];
  List<Map<String, dynamic>> _campaignsList = [];
  Map<String, bool> _claimedCampaigns = {};
  String _activeBooster = '';
  int _boosterQtyX2 = 0;
  int _boosterQtyX3 = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBadges();
    _loadGamificationData();
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
      final progressList = await ApiService.getProgress();
      setState(() {
        _badges = list;
        _userProgress = progressList;
        _isLoading = false;
      });
      await _loadGamificationData();
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadGamificationData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final campaigns = await GamificationService.getCampaigns();
      
      final Map<String, bool> claimed = {};
      for (final c in campaigns) {
        final id = c['id'].toString();
        claimed[id] = prefs.getBool('campaign_claimed_$id') ?? false;
      }
      
      final active = prefs.getString('active_booster') ?? '';
      final qtyX2 = prefs.getInt('booster_qty_x2_xp') ?? 0;
      final qtyX3 = prefs.getInt('booster_qty_x3_xp') ?? 0;
      
      if (mounted) {
        setState(() {
          _campaignsList = campaigns;
          _claimedCampaigns = claimed;
          _activeBooster = active;
          _boosterQtyX2 = qtyX2;
          _boosterQtyX3 = qtyX3;
        });
      }
    } catch (e) {
      print('Lỗi tải dữ liệu gamification: $e');
    }
  }

  int _getCampaignProgress(Map<String, dynamic> camp, List<dynamic> progressList) {
    final id = camp['id'].toString();
    final title = camp['title']?.toString() ?? '';

    if (id == '1' || title.contains('Khởi đầu')) {
      final heartCompleted = progressList.any((p) => 
        (p['origami_id'] == 1 || p['origamiId'] == 1) && 
        (p['is_completed'] == 1 || p['isCompleted'] == true)
      );
      final swanCompleted = progressList.any((p) => 
        (p['origami_id'] == 2 || p['origamiId'] == 2) && 
        (p['is_completed'] == 1 || p['isCompleted'] == true)
      );
      return (heartCompleted ? 1 : 0) + (swanCompleted ? 1 : 0);
    }

    final totalCompleted = progressList.where((p) => p['is_completed'] == 1 || p['isCompleted'] == true).length;
    final int totalRequired = int.tryParse(camp['total'].toString()) ?? 3;
    return totalCompleted.clamp(0, totalRequired);
  }

  Future<void> _claimCampaignReward(String campId, int xpVal, String boosterType) async {
    setState(() => _isLoading = true);
    try {
      final result = await ApiService.claimCampaign(campId);
      if (result != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('campaign_claimed_$campId', true);
        
        final currentQty = prefs.getInt('booster_qty_$boosterType') ?? 0;
        await prefs.setInt('booster_qty_$boosterType', currentQty + 1);
        
        await context.read<AuthProvider>().refreshProfile();
        await _loadBadges();
        
        if (mounted) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('🎉 Chúc mừng!', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.teal)),
              content: Text('Bạn đã nhận được +$xpVal XP và nhận thành công 1 Thẻ nhân ${boosterType == 'x2_xp' ? '2' : '3'} XP vào Túi đồ bổ trợ!'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Tuyệt vời', style: TextStyle(color: AppTheme.teal, fontWeight: FontWeight.bold)),
                )
              ],
            ),
          );
        }
      }
    } catch (e) {
      print('Lỗi nhận quà: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _activateBooster(String boosterType) async {
    final prefs = await SharedPreferences.getInstance();
    final currentQty = prefs.getInt('booster_qty_$boosterType') ?? 0;
    if (currentQty <= 0) return;
    
    await prefs.setInt('booster_qty_$boosterType', currentQty - 1);
    await prefs.setString('active_booster', boosterType);
    
    await _loadGamificationData();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🚀 Kích hoạt thành công! Lượt gấp Origami tiếp theo sẽ nhân ${boosterType == 'x2_xp' ? 'X2' : 'X3'} XP!'),
          backgroundColor: AppTheme.teal,
        ),
      );
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
                    child: ClipOval(
                      child: user.avatarUrl.isEmpty
                          ? const Text('👤', style: TextStyle(fontSize: 22))
                          : (user.avatarUrl.startsWith('http')
                              ? Image.network(
                                  user.avatarUrl,
                                  fit: BoxFit.cover,
                                  width: 48,
                                  height: 48,
                                  errorBuilder: (c, e, s) => const Text('👤', style: TextStyle(fontSize: 22)),
                                )
                              : (user.avatarUrl.contains('/') || user.avatarUrl.contains('\\'))
                                  ? Image.file(
                                      File(user.avatarUrl),
                                      fit: BoxFit.cover,
                                      width: 48,
                                      height: 48,
                                      errorBuilder: (c, e, s) => const Text('👤', style: TextStyle(fontSize: 22)),
                                    )
                                  : Text(user.avatarUrl, style: const TextStyle(fontSize: 22))),
                    ),
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
            const SizedBox(height: 32),

            // --- CÚP CHIẾN DỊCH & QUÀ TẶNG ---
            const Text(
              '🏆 Cúp & Phần Thưởng Chiến Dịch',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.indigo),
            ),
            const SizedBox(height: 4),
            const Text(
              'Hoàn thành các chiến dịch gấp giấy đặc biệt để nhận Cúp và Khóa bổ trợ nhân điểm kinh nghiệm XP.',
              style: TextStyle(fontSize: 11, color: AppTheme.muted),
            ),
            const SizedBox(height: 12),
            
            _campaignsList.isEmpty
                ? const Center(child: Text('Không có chiến dịch nào', style: TextStyle(color: AppTheme.muted, fontSize: 12)))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _campaignsList.length,
                    itemBuilder: (context, index) {
                      final camp = _campaignsList[index];
                      final String id = camp['id'].toString();
                      final progress = _getCampaignProgress(camp, _userProgress);
                      final total = int.tryParse(camp['total'].toString()) ?? 3;
                      final bool isCompleted = progress >= total;
                      final bool isClaimed = _claimedCampaigns[id] ?? false;
                      final boosterType = id == '1' ? 'x2_xp' : 'x3_xp';
                      final xpBonus = id == '1' ? 150 : 200;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isCompleted ? AppTheme.white : AppTheme.bg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isCompleted ? AppTheme.amber.withOpacity(0.4) : AppTheme.border,
                            width: isCompleted ? 1.5 : 1,
                          ),
                          boxShadow: isCompleted
                              ? [BoxShadow(color: AppTheme.amber.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))]
                              : null,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(camp['emoji'] ?? '🔥', style: const TextStyle(fontSize: 30)),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    camp['title'] ?? '',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: AppTheme.indigo),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    camp['desc'] ?? '',
                                    style: const TextStyle(fontSize: 11, color: AppTheme.muted, height: 1.35),
                                  ),
                                  const SizedBox(height: 12),
                                  // Progress bar
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(4),
                                          child: LinearProgressIndicator(
                                            value: (progress / total).clamp(0.0, 1.0),
                                            backgroundColor: AppTheme.border,
                                            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.amber),
                                            minHeight: 6,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '$progress/$total',
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.indigo),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '🎁 Quà: ${camp['reward']}',
                                    style: TextStyle(
                                      fontSize: 10, 
                                      fontWeight: FontWeight.bold, 
                                      color: isCompleted ? AppTheme.teal : AppTheme.indigoMid
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Claim Button
                            Column(
                              children: [
                                if (isCompleted && !isClaimed)
                                  ElevatedButton(
                                    onPressed: () => _claimCampaignReward(id, xpBonus, boosterType),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.amber,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                      textStyle: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    child: const Text('Nhận quà'),
                                  )
                                else if (isClaimed)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppTheme.teal.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'Đã nhận',
                                      style: TextStyle(color: AppTheme.teal, fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  )
                                else
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppTheme.border,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'Chưa đạt',
                                      style: TextStyle(color: AppTheme.muted, fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  )
                              ],
                            )
                          ],
                        ),
                      );
                    },
                  ),
            const SizedBox(height: 28),

            // --- TÚI ĐỒ BỔ TRỢ (BOOSTER INVENTORY) ---
            const Text(
              '⚡ Túi Đồ Bổ Trợ (XP Boosters)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.indigo),
            ),
            const SizedBox(height: 4),
            const Text(
              'Sử dụng các thẻ bổ trợ nhận được từ chiến dịch để nhân điểm XP nhận được khi gấp Origami.',
              style: TextStyle(fontSize: 11, color: AppTheme.muted),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                children: [
                  _buildBoosterRow(
                    emoji: '🚀',
                    title: 'Thẻ nhân 2 (X2 XP Booster)',
                    description: 'Nhân đôi điểm XP nhận được khi hoàn thành mẫu gấp tiếp theo.',
                    qty: _boosterQtyX2,
                    isActive: _activeBooster == 'x2_xp',
                    onActivate: () => _activateBooster('x2_xp'),
                    canActivate: _activeBooster.isEmpty && _boosterQtyX2 > 0,
                  ),
                  const Divider(color: AppTheme.border),
                  _buildBoosterRow(
                    emoji: '⚡',
                    title: 'Thẻ nhân 3 (X3 XP Booster)',
                    description: 'Nhân ba điểm XP nhận được khi hoàn thành mẫu gấp tiếp theo.',
                    qty: _boosterQtyX3,
                    isActive: _activeBooster == 'x3_xp',
                    onActivate: () => _activateBooster('x3_xp'),
                    canActivate: _activeBooster.isEmpty && _boosterQtyX3 > 0,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // --- CÂY KỸ NĂNG ORIGAMI ---
            const Text(
              '🌳 Cây kỹ năng Origami (Skill Tree)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.indigo),
            ),
            const SizedBox(height: 6),
            const Text(
              'Gấp các mẫu và tích lũy XP để thăng cấp, mở khóa các nhánh kỹ năng cao cấp hơn.',
              style: TextStyle(fontSize: 11, color: AppTheme.muted),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                children: [
                  _buildSkillNode(
                    title: 'Giấy Cơ Bản (Paper Beginner)',
                    desc: 'Làm quen với các nếp gấp cơ bản. Mở khóa mẫu Trái Tim & Hạc Giấy.',
                    emoji: '📄',
                    isActive: true,
                    reqLevel: 1,
                    currentLevel: (user.xp ~/ 100) + 1,
                    isLast: false,
                  ),
                  _buildSkillNode(
                    title: 'Xếp Hình Thú (Animal Folder)',
                    desc: 'Có kỹ năng xếp các hình thú sinh động như thỏ con, cá vàng.',
                    emoji: '🐰',
                    isActive: ((user.xp ~/ 100) + 1) >= 5,
                    reqLevel: 5,
                    currentLevel: (user.xp ~/ 100) + 1,
                    isLast: false,
                  ),
                  _buildSkillNode(
                    title: 'Bậc Thầy Hoa Cỏ (Flower Expert)',
                    desc: 'Chinh phục các kết cấu cánh hoa tinh xảo như hoa hồng, hoa sen.',
                    emoji: '🌺',
                    isActive: ((user.xp ~/ 100) + 1) >= 10,
                    reqLevel: 10,
                    currentLevel: (user.xp ~/ 100) + 1,
                    isLast: false,
                  ),
                  _buildSkillNode(
                    title: 'Nghệ Nhân Origami (Origami Master)',
                    desc: 'Đạt cấp bậc cao nhất. Mở khóa quyền tự do đăng tải bài viết sáng tạo.',
                    emoji: '👑',
                    isActive: ((user.xp ~/ 100) + 1) >= 20,
                    reqLevel: 20,
                    currentLevel: (user.xp ~/ 100) + 1,
                    isLast: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillNode({
    required String title,
    required String desc,
    required String emoji,
    required bool isActive,
    required int reqLevel,
    required int currentLevel,
    required bool isLast,
  }) {
    final statusColor = isActive ? AppTheme.teal : AppTheme.border;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator (Left)
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isActive ? AppTheme.teal.withOpacity(0.12) : AppTheme.bg,
                  shape: BoxShape.circle,
                  border: Border.all(color: statusColor, width: 2),
                ),
                child: Center(
                  child: Text(
                    emoji,
                    style: TextStyle(fontSize: 16, color: isActive ? null : Colors.grey),
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: statusColor,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          // Content (Right)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isActive ? AppTheme.indigo : AppTheme.muted,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isActive ? AppTheme.teal.withOpacity(0.1) : AppTheme.gray,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isActive ? 'Đã học' : 'Cần Cấp $reqLevel 🔒',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: isActive ? AppTheme.teal : AppTheme.muted,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    style: const TextStyle(fontSize: 11, color: AppTheme.muted, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoosterRow({
    required String emoji,
    required String title,
    required String description,
    required int qty,
    required bool isActive,
    required VoidCallback onActivate,
    required bool canActivate,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.indigo),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(fontSize: 10.5, color: AppTheme.muted, height: 1.3),
                ),
                const SizedBox(height: 4),
                Text(
                  'Số lượng có: $qty',
                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppTheme.teal),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (isActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.teal.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '🔥 ĐANG DÙNG',
                style: TextStyle(color: AppTheme.teal, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            )
          else
            ElevatedButton(
              onPressed: canActivate ? onActivate : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.indigo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              ),
              child: const Text('Kích hoạt'),
            ),
        ],
      ),
    );
  }
}
