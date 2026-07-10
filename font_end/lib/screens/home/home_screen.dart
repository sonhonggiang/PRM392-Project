import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/api_service.dart';
import '../../models/user_model.dart';
import '../origami/creator_workshop_screen.dart';
import 'tabs/home_tab.dart';
import 'tabs/explore_tab.dart';
import 'tabs/favorite_tab.dart';
import 'tabs/profile_tab.dart';

// ─── Model thông báo ────────────────────────────────────────────────────────
class AppNotification {
  final String id;
  final String type;     // 'new_model' | 'resume' | 'streak' | 'badge'
  final String title;
  final String body;
  final String emoji;
  final String time;
  bool isRead;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.emoji,
    required this.time,
    this.isRead = false,
  });
}

// ─── Dữ liệu thông báo mẫu ──────────────────────────────────────────────────
final List<AppNotification> _notifications = [
  AppNotification(
    id: '1', type: 'new_model', emoji: '🐠',
    title: 'Mẫu mới: Cá Vàng đã ra mắt!',
    body: 'Creator NamNguyen vừa thêm mẫu Cá Vàng – hãy thử ngay nhé.',
    time: '5 phút trước',
  ),
  AppNotification(
    id: '2', type: 'resume', emoji: '🐲',
    title: 'Bạn đang gấp dở Rồng Lửa',
    body: 'Bạn dừng ở bước 5/30. Tiếp tục để nhận huy hiệu "Chinh phục Rồng"!',
    time: '2 giờ trước',
  ),
  AppNotification(
    id: '3', type: 'streak', emoji: '🔥',
    title: 'Chuỗi học 7 ngày liên tiếp!',
    body: 'Tuyệt vời! Bạn đã duy trì được chuỗi học 7 ngày. Tiếp tục nhé!',
    time: 'Hôm nay 08:00',
  ),
  AppNotification(
    id: '4', type: 'new_model', emoji: '🦖',
    title: 'Mẫu mới: Khủng Long xuất hiện!',
    body: 'Admin vừa thêm mẫu Khủng Long 5 sao – độ khó: ⭐⭐⭐⭐⭐.',
    time: '1 ngày trước',
    isRead: true,
  ),
  AppNotification(
    id: '5', type: 'badge', emoji: '🦢',
    title: 'Bạn vừa mở khóa huy hiệu!',
    body: 'Chúc mừng! Bạn đã đạt huy hiệu "Fan Hạc giấy". Xem ngay trong hồ sơ.',
    time: '2 ngày trước',
    isRead: true,
  ),
];

// ─── HomeScreen ──────────────────────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  List<AppNotification> _notifs = [];
  bool _isLoadingNotifs = false;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final auth = context.read<AuthProvider>();
    if (auth.currentUser.role == UserRole.guest) return;

    setState(() => _isLoadingNotifs = true);
    try {
      final data = await ApiService.getNotifications();
      setState(() {
        _notifs = data.map((n) => AppNotification(
          id: n['id'].toString(),
          type: n['type'] ?? 'info',
          title: n['title'] ?? '',
          body: n['message'] ?? '',
          emoji: n['emoji'] ?? '🔔',
          time: _formatTime(n['created_at']),
          isRead: n['is_read'] == 1,
        )).toList();
      });
    } catch (e) {
      print('Lỗi tải thông báo: $e');
    } finally {
      setState(() => _isLoadingNotifs = false);
    }
  }

  String _formatTime(String? dateStr) {
    if (dateStr == null) return 'Vừa xong';
    final date = DateTime.parse(dateStr);
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    return '${diff.inDays} ngày trước';
  }

  int get _unreadCount => _notifs.where((n) => !n.isRead).length;

  void _onNavigateToExplore() {
    setState(() => _currentIndex = 1);
  }

  void _markAllRead() async {
    for (final n in _notifs) {
      if (!n.isRead) {
        await ApiService.markNotificationRead(n.id);
        n.isRead = true;
      }
    }
    setState(() {});
  }

  void _markRead(String id) async {
    final n = _notifs.firstWhere((n) => n.id == id);
    if (!n.isRead) {
      await ApiService.markNotificationRead(id);
      setState(() {
        n.isRead = true;
      });
    }
  }

  // ── Chuông thông báo ──────────────────────────────────────────────────────
  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) => DraggableScrollableSheet(
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
                // Handle
                Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 12, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.notifications_rounded, color: AppTheme.indigo),
                          SizedBox(width: 10),
                          Text('Thông báo',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.indigo)),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          _markAllRead();
                          setModalState(() {});
                        },
                        child: const Text('Đọc tất cả', style: TextStyle(color: AppTheme.teal, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
                // List
                Expanded(
                  child: _notifs.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('🔔', style: TextStyle(fontSize: 48)),
                            SizedBox(height: 12),
                            Text('Không có thông báo mới', style: TextStyle(color: AppTheme.muted)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: ctrl,
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: _notifs.length,
                        itemBuilder: (_, i) {
                          final n = _notifs[i];
                          return GestureDetector(
                            onTap: () {
                              _markRead(n.id);
                              setModalState(() {});
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: n.isRead ? AppTheme.white : AppTheme.indigo.withOpacity(0.04),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: n.isRead ? AppTheme.border : AppTheme.indigoLight.withOpacity(0.4),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Emoji icon
                                  Container(
                                    width: 46, height: 46,
                                    decoration: BoxDecoration(
                                      color: _notifColor(n.type).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(child: Text(n.emoji, style: const TextStyle(fontSize: 24))),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(n.title,
                                          style: TextStyle(
                                            fontWeight: n.isRead ? FontWeight.w600 : FontWeight.bold,
                                            fontSize: 13,
                                            color: AppTheme.text,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(n.body,
                                          style: const TextStyle(fontSize: 12, color: AppTheme.muted, height: 1.4),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 6),
                                        Text(n.time,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: _notifColor(n.type),
                                            fontWeight: FontWeight.w600,
                                          )),
                                      ],
                                    ),
                                  ),
                                  if (!n.isRead)
                                    Container(
                                      width: 8, height: 8,
                                      decoration: const BoxDecoration(
                                        color: AppTheme.indigoLight,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).then((_) => setState(() {}));
  }

  Color _notifColor(String type) {
    switch (type) {
      case 'new_model': return AppTheme.teal;
      case 'resume': return AppTheme.amber;
      case 'streak': return AppTheme.red;
      case 'badge': return AppTheme.indigo;
      default: return AppTheme.muted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final isGuest = user.role == UserRole.guest;

    final List<Widget> tabs = [
      HomeTab(onNavigateToExplore: _onNavigateToExplore),
      const ExploreTab(),
      const FavoriteTab(),
      const ProfileTab(),
    ];

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: _currentIndex == 0
        ? AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Xin chào 👋',
                    style: TextStyle(fontSize: 12, color: AppTheme.muted)),
                Text(user.displayName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.indigo)),
              ],
            ),
            actions: [
              if (!isGuest)
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_rounded, color: AppTheme.indigo, size: 26),
                      onPressed: () => _showNotifications(context),
                    ),
                    if (_unreadCount > 0)
                      Positioned(
                        top: 6, right: 6,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: AppTheme.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                          child: Text(
                            '$_unreadCount',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              const SizedBox(width: 8),
            ],
          )
        : AppBar(
            title: Text(
              _currentIndex == 1 ? 'Khám phá'
                  : _currentIndex == 2 ? 'Yêu thích'
                  : 'Hồ sơ cá nhân',
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.indigo),
            ),
          ),
      body: tabs[_currentIndex],
      floatingActionButton: (user.role == UserRole.admin || user.xp >= 1000)
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreatorWorkshopScreen()),
                );
              },
              backgroundColor: AppTheme.teal,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Tạo mẫu mới',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        backgroundColor: AppTheme.white,
        indicatorColor: AppTheme.indigoLight.withOpacity(0.2),
        destinations: const [
          NavigationDestination(icon: Text('🏠', style: TextStyle(fontSize: 20)), label: 'Home'),
          NavigationDestination(icon: Text('📚', style: TextStyle(fontSize: 20)), label: 'Khám phá'),
          NavigationDestination(icon: Text('⭐', style: TextStyle(fontSize: 20)), label: 'Yêu thích'),
          NavigationDestination(icon: Text('👤', style: TextStyle(fontSize: 20)), label: 'Hồ sơ'),
        ],
      ),
    );
  }
}
