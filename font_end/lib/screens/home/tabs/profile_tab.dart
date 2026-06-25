import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../models/user_model.dart';
import '../analytics_badges_screen.dart';
import '../leaderboard_screen.dart';
import '../admin_approval_screen.dart';

// ─── Dữ liệu huy hiệu ───────────────────────────────────────────────────────
class BadgeData {
  final String emoji;
  final String name;
  final String description;
  final Color color;
  final bool earned;

  const BadgeData({
    required this.emoji,
    required this.name,
    required this.description,
    required this.color,
    required this.earned,
  });
}

const List<BadgeData> allBadges = [
  BadgeData(emoji: '🌱', name: 'Người mới', description: 'Hoàn thành mẫu đầu tiên', color: AppTheme.green, earned: true),
  BadgeData(emoji: '🦢', name: 'Fan Hạc giấy', description: 'Gấp hạc giấy 5 lần', color: AppTheme.indigo, earned: true),
  BadgeData(emoji: '🔥', name: 'Chuỗi 7 ngày', description: 'Học liên tục 7 ngày', color: AppTheme.red, earned: true),
  BadgeData(emoji: '⭐', name: 'Người học chăm chỉ', description: 'Hoàn thành 10 mẫu', color: AppTheme.amber, earned: false),
  BadgeData(emoji: '🏆', name: 'Bậc thầy Origami', description: 'Hoàn thành 50 mẫu', color: AppTheme.amber, earned: false),
  BadgeData(emoji: '🐲', name: 'Chinh phục Rồng', description: 'Hoàn thành Rồng Lửa', color: AppTheme.teal, earned: false),
];

// ─── Dữ liệu lịch sử học ────────────────────────────────────────────────────
const List<Map<String, dynamic>> _historyItems = [
  {'name': 'Hạc giấy Nhật Bản', 'emoji': '🦢', 'date': '23/06/2026', 'status': 'Hoàn thành', 'done': true},
  {'name': 'Trái tim đôi', 'emoji': '❤️', 'date': '21/06/2026', 'status': 'Hoàn thành', 'done': true},
  {'name': 'Con Ếch nhảy', 'emoji': '🐸', 'date': '18/06/2026', 'status': 'Hoàn thành', 'done': true},
  {'name': 'Rồng Lửa', 'emoji': '🐲', 'date': '15/06/2026', 'status': 'Đang học (Bước 5/30)', 'done': false},
  {'name': 'Máy Bay chiến đấu', 'emoji': '✈️', 'date': '10/06/2026', 'status': 'Hoàn thành', 'done': true},
];

// ─── Profile Tab chính ───────────────────────────────────────────────────────
class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  Uint8List? _avatarBytes;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickAvatar() async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      setState(() {
        _avatarBytes = bytes;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể chọn ảnh: $e'),
            backgroundColor: AppTheme.red,
          ),
        );
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
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppTheme.indigo.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Center(child: Text('👤', style: TextStyle(fontSize: 52))),
              ),
              const SizedBox(height: 20),
              const Text('Chưa đăng nhập', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.indigo)),
              const SizedBox(height: 8),
              const Text('Đăng nhập để theo dõi tiến trình,\ntích lũy huy hiệu và lưu yêu thích!',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.muted, height: 1.6)),
              const SizedBox(height: 28),
              FilledButton(
                onPressed: () {
                  auth.logout();
                  Navigator.of(context).pushReplacementNamed('/');
                },
                style: FilledButton.styleFrom(minimumSize: const Size(200, 50)),
                child: const Text('Đăng nhập ngay'),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // ── Header gradient ──────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.indigo, AppTheme.indigoMid],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: Column(
              children: [
                // Avatar (nhấn để chọn ảnh)
                Stack(
                  children: [
                    GestureDetector(
                      onTap: _pickAvatar,
                      child: Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          color: Colors.white.withOpacity(0.15),
                        ),
                        child: ClipOval(
                          child: _avatarBytes != null
                              ? Image.memory(
                                  _avatarBytes!,
                                  fit: BoxFit.cover,
                                  width: 88,
                                  height: 88,
                                )
                              : const Center(
                                  child: Text('👤', style: TextStyle(fontSize: 46))),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickAvatar,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(color: AppTheme.teal, shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 14),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(user.displayName,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 4),
                Text(user.email,
                  style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 13)),
                const SizedBox(height: 10),

                // Role badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Text(
                    _roleLabel(user.role),
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                // ── Thống kê ──────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.border),
                    boxShadow: const [BoxShadow(color: Color(0x0A1A2F6E), blurRadius: 10, offset: Offset(0, 4))],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStat('12', 'Đã gấp', Icons.auto_awesome, AppTheme.indigo),
                      _buildDivider(),
                      _buildStat('5', 'Yêu thích', Icons.favorite, AppTheme.red),
                      _buildDivider(),
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalyticsBadgesScreen())),
                        child: _buildStat('3', 'Huy hiệu', Icons.emoji_events, AppTheme.amber),
                      ),
                      _buildDivider(),
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LeaderboardScreen())),
                        child: _buildStat('7', 'Ngày liên tiếp', Icons.local_fire_department, AppTheme.teal),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Huy hiệu ──────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Huy hiệu', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.indigo)),
                    TextButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalyticsBadgesScreen())),
                      child: const Text('Xem tất cả', style: TextStyle(color: AppTheme.teal, fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildBadgesSection(context),
                const SizedBox(height: 24),

                // ── Tiến trình học tập ────────────────────────────────
                const Text('Tiến trình học tập', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.indigo)),
                const SizedBox(height: 12),
                _buildProgressSection(),
                const SizedBox(height: 24),

                // ── Menu ──────────────────────────────────────────────
                const Text('Tài khoản', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.indigo)),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Column(
                    children: [
                      _buildMenuAction(context, Icons.history_rounded, 'Lịch sử học tập',
                        AppTheme.indigo, () => _showHistory(context)),
                      _buildMenuDivider(),
                      _buildMenuAction(context, Icons.workspace_premium_rounded, 'Thống kê & Huy hiệu',
                        AppTheme.amber, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalyticsBadgesScreen()))),
                      _buildMenuDivider(),
                      _buildMenuAction(context, Icons.leaderboard_rounded, 'Bảng xếp hạng',
                        AppTheme.teal, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LeaderboardScreen()))),
                      if (user.role == UserRole.admin) ...[
                        _buildMenuDivider(),
                        _buildMenuAction(context, Icons.admin_panel_settings_rounded, 'Phê duyệt mẫu mới',
                          AppTheme.red, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminApprovalScreen()))),
                      ],
                      _buildMenuDivider(),
                      _buildMenuAction(context, Icons.settings_rounded, 'Cài đặt tài khoản',
                        AppTheme.muted, () => _showSettings(context)),
                      _buildMenuDivider(),
                      _buildMenuAction(context, Icons.help_outline_rounded, 'Trung tâm trợ giúp',
                        AppTheme.teal, () => _showHelp(context)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Đăng xuất ─────────────────────────────────────────
                OutlinedButton.icon(
                  onPressed: () {
                    auth.logout();
                    Navigator.of(context).pushReplacementNamed('/');
                  },
                  icon: const Icon(Icons.logout_rounded, size: 18),
                  label: const Text('Đăng xuất', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.red,
                    side: const BorderSide(color: AppTheme.red),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────
  String _roleLabel(UserRole role) {
    switch (role) {
      case UserRole.admin: return '👑 ADMIN';
      case UserRole.creator: return '✏️ CREATOR';
      default: return '🌟 THÀNH VIÊN';
    }
  }

  Widget _buildDivider() => Container(width: 1, height: 42, color: AppTheme.border);

  Widget _buildStat(String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.muted), textAlign: TextAlign.center),
      ],
    );
  }

  // ── Huy hiệu (hiện 3 earned + 1 preview chưa mở khóa) ───────────────────
  Widget _buildBadgesSection(BuildContext context) {
    final earned = allBadges.where((b) => b.earned).toList();
    final locked = allBadges.where((b) => !b.earned).first;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          // Earned badges
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ...earned.map((b) => Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _buildBadgeTile(b, context),
              )),
              // 1 huy hiệu chưa mở khóa, mờ đi
              _buildLockedBadge(locked, context),
            ],
          ),
          const SizedBox(height: 14),
          // Thanh tiến trình
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${earned.length}/${allBadges.length} huy hiệu',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.indigo)),
                  Text('Còn ${allBadges.length - earned.length} huy hiệu nữa!',
                    style: const TextStyle(fontSize: 11, color: AppTheme.muted)),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: earned.length / allBadges.length,
                  backgroundColor: AppTheme.gray,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.amber),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeTile(BadgeData b, BuildContext context) {
    return GestureDetector(
      onTap: () => _showBadgeDetail(context, b),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: b.color.withOpacity(0.12),
              border: Border.all(color: b.color.withOpacity(0.5), width: 2),
            ),
            child: Center(child: Text(b.emoji, style: const TextStyle(fontSize: 30))),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 60,
            child: Text(b.name, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center, maxLines: 2),
          ),
        ],
      ),
    );
  }

  Widget _buildLockedBadge(BadgeData b, BuildContext context) {
    return GestureDetector(
      onTap: () => _showBadgeDetail(context, b),
      child: Opacity(
        opacity: 0.38,
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.gray,
                border: Border.all(color: AppTheme.border, width: 2),
              ),
              child: const Center(child: Icon(Icons.lock_rounded, color: AppTheme.muted, size: 26)),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 60,
              child: Text(b.name, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.muted),
                textAlign: TextAlign.center, maxLines: 2),
            ),
          ],
        ),
      ),
    );
  }

  // ── Tiến trình học tập ───────────────────────────────────────────────────
  Widget _buildProgressSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          _buildProgressRow('Mẫu hoàn thành tuần này', 3, 5, AppTheme.teal),
          const SizedBox(height: 14),
          _buildProgressRow('Thời gian học tập (giờ)', 4, 10, AppTheme.indigo),
          const SizedBox(height: 14),
          _buildProgressRow('Mức độ khó hoàn thành', 2, 5, AppTheme.amber),
        ],
      ),
    );
  }

  Widget _buildProgressRow(String label, int current, int total, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.text)),
            Text('$current/$total', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: current / total,
            backgroundColor: AppTheme.gray,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 7,
          ),
        ),
      ],
    );
  }

  // ── Menu item ────────────────────────────────────────────────────────────
  Widget _buildMenuAction(BuildContext context, IconData icon, String title, Color iconColor, VoidCallback onTap) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.muted),
      onTap: onTap,
    );
  }

  Widget _buildMenuDivider() => const Divider(height: 1, indent: 58, endIndent: 16, color: AppTheme.border);

  // ══ Bottom Sheets ════════════════════════════════════════════════════════

  // 📋 Lịch sử học tập
  void _showHistory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        builder: (_, ctrl) => Container(
          decoration: const BoxDecoration(
            color: AppTheme.bg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              _sheetHandle(),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 4, 20, 16),
                child: Row(
                  children: [
                    Icon(Icons.history_rounded, color: AppTheme.indigo),
                    SizedBox(width: 10),
                    Text('Lịch sử học tập',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.indigo)),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: ctrl,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: _historyItems.length,
                  itemBuilder: (_, i) {
                    final item = _historyItems[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48, height: 48,
                            decoration: BoxDecoration(color: AppTheme.bg, borderRadius: BorderRadius.circular(10)),
                            child: Center(child: Text(item['emoji'], style: const TextStyle(fontSize: 26))),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                const SizedBox(height: 3),
                                Text(item['status'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: item['done'] ? AppTheme.teal : AppTheme.amber,
                                    fontWeight: FontWeight.w600,
                                  )),
                              ],
                            ),
                          ),
                          Text(item['date'],
                            style: const TextStyle(fontSize: 11, color: AppTheme.muted)),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 📌 Chi tiết 1 huy hiệu
  void _showBadgeDetail(BuildContext context, BadgeData b) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              b.earned
                ? Text(b.emoji, style: const TextStyle(fontSize: 56))
                : const Icon(Icons.lock_rounded, size: 56, color: AppTheme.muted),
              const SizedBox(height: 16),
              Text(b.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.indigo)),
              const SizedBox(height: 8),
              Text(b.description, textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.muted, fontSize: 14, height: 1.5)),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: b.earned ? AppTheme.teal.withOpacity(0.1) : AppTheme.gray,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  b.earned ? '✅ Đã đạt được' : '🔒 Chưa mở khóa',
                  style: TextStyle(
                    color: b.earned ? AppTheme.teal : AppTheme.muted,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Đóng'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ⚙️ Cài đặt tài khoản
  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.bg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sheetHandle(),
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Icon(Icons.settings_rounded, color: AppTheme.indigo),
                  SizedBox(width: 10),
                  Text('Cài đặt tài khoản',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.indigo)),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(color: AppTheme.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.border)),
              child: Column(
                children: [
                  _settingsTile(Icons.person_outline_rounded, 'Chỉnh sửa hồ sơ', AppTheme.indigo),
                  _divider(),
                  _settingsTile(Icons.notifications_outlined, 'Thông báo', AppTheme.teal),
                  _divider(),
                  _settingsTile(Icons.lock_outline_rounded, 'Đổi mật khẩu', AppTheme.amber),
                  _divider(),
                  _settingsTile(Icons.language_rounded, 'Ngôn ngữ: Tiếng Việt', AppTheme.muted),
                  _divider(),
                  _settingsTile(Icons.delete_outline_rounded, 'Xóa tài khoản', AppTheme.red),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ❓ Trung tâm trợ giúp
  void _showHelp(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.bg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sheetHandle(),
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Icon(Icons.help_outline_rounded, color: AppTheme.teal),
                  SizedBox(width: 10),
                  Text('Trung tâm trợ giúp',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.indigo)),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(color: AppTheme.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.border)),
              child: Column(
                children: [
                  _settingsTile(Icons.quiz_outlined, 'Câu hỏi thường gặp (FAQ)', AppTheme.indigo),
                  _divider(),
                  _settingsTile(Icons.chat_bubble_outline_rounded, 'Liên hệ hỗ trợ', AppTheme.teal),
                  _divider(),
                  _settingsTile(Icons.bug_report_outlined, 'Báo lỗi', AppTheme.red),
                  _divider(),
                  _settingsTile(Icons.star_outline_rounded, 'Đánh giá ứng dụng', AppTheme.amber),
                  _divider(),
                  _settingsTile(Icons.info_outline_rounded, 'Về ứng dụng v1.0.0', AppTheme.muted),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sheetHandle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        width: 40, height: 4,
        decoration: BoxDecoration(color: AppTheme.border, borderRadius: BorderRadius.circular(2)),
      ),
    );
  }

  Widget _settingsTile(IconData icon, String title, Color color) {
    return ListTile(
      leading: Icon(icon, color: color, size: 22),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.muted, size: 20),
      onTap: () {},
    );
  }

  Widget _divider() => const Divider(height: 1, indent: 54, endIndent: 16, color: AppTheme.border);
}
