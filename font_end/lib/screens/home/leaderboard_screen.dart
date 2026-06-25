import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/api_service.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<dynamic> _rankings = [];
  bool _isLoading = true;
  int _myRank = 0;
  int _myXp = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadLeaderboard();
  }

  // Tải bảng xếp hạng từ API
  Future<void> _loadLeaderboard() async {
    setState(() => _isLoading = true);
    try {
      final list = await ApiService.getLeaderboard();
      final auth = context.read<AuthProvider>();
      final myId = auth.currentUser.id;

      // Tính vị trí xếp hạng của tôi
      int myRank = 0;
      int myXp = auth.currentUser.xp;
      for (int i = 0; i < list.length; i++) {
        if (list[i]['id'].toString() == myId) {
          myRank = i + 1;
          myXp = list[i]['xp'] ?? auth.currentUser.xp;
          break;
        }
      }

      setState(() {
        _rankings = list;
        _myRank = myRank;
        _myXp = myXp;
        _isLoading = false;
      });
    } catch (e) {
      print('Lỗi tải bảng xếp hạng: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppTheme.indigo),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Bảng xếp hạng',
          style: TextStyle(color: AppTheme.indigo, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.indigo,
          unselectedLabelColor: AppTheme.muted,
          indicatorColor: AppTheme.indigo,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: const [
            Tab(text: 'Tuần này'),
            Tab(text: 'Tháng này'),
            Tab(text: 'Mọi thời đại'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.teal))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildLeaderboardTab(),
                _buildLeaderboardTab(),
                _buildLeaderboardTab(),
              ],
            ),
    );
  }

  Widget _buildLeaderboardTab() {
    if (_rankings.isEmpty) {
      return const Center(child: Text('Chưa có dữ liệu bảng xếp hạng!', style: TextStyle(color: AppTheme.muted)));
    }

    // Top 3 (🥈 🥇 🥉)
    final top1 = _rankings.isNotEmpty ? _rankings[0] : null;
    final top2 = _rankings.length > 1 ? _rankings[1] : null;
    final top3 = _rankings.length > 2 ? _rankings[2] : null;

    // Rank 4+
    final lowerRanks = _rankings.length > 3 ? _rankings.sublist(3) : [];

    return Stack(
      children: [
        Column(
          children: [
            // 👑 TOP 3 Podium Section
            Container(
              color: AppTheme.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // 🥈 Rank 2
                  if (top2 != null)
                    _buildPodiumAvatar(item: top2, rank: 2, height: 75, crownColor: AppTheme.border, isFirst: false)
                  else
                    const SizedBox(width: 75),
                  // 🥇 Rank 1
                  if (top1 != null)
                    _buildPodiumAvatar(item: top1, rank: 1, height: 95, crownColor: AppTheme.amber, isFirst: true)
                  else
                    const SizedBox(width: 95),
                  // 🥉 Rank 3
                  if (top3 != null)
                    _buildPodiumAvatar(item: top3, rank: 3, height: 70, crownColor: const Color(0xFFCD7F32), isFirst: false)
                  else
                    const SizedBox(width: 70),
                ],
              ),
            ),

            // Scrollable ranks (4 to end)
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100), // padding bottom for sticky bar
                itemCount: lowerRanks.length,
                itemBuilder: (context, i) {
                  final item = lowerRanks[i];
                  final rank = i + 4; // Bắt đầu từ hạng #4
                  return _buildLeaderboardRow(item, rank);
                },
              ),
            ),
          ],
        ),

        // Sticky Bottom Personal Rank
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: AppTheme.indigo,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.indigo.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                )
              ],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                // Rank label
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _myRank > 0 ? 'Hạng #$_myRank' : 'Chưa xếp hạng',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                const SizedBox(width: 14),
                
                // Name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Bạn',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tiếp tục tích lũy thêm XP để thăng hạng!',
                        style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11),
                      ),
                    ],
                  ),
                ),
                
                // XP Score
                Text(
                  '$_myXp XP',
                  style: const TextStyle(
                    color: AppTheme.amber,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPodiumAvatar({
    required dynamic item,
    required int rank,
    required double height,
    required Color crownColor,
    required bool isFirst,
  }) {
    final name = item['displayName'] ?? item['display_name'] ?? 'Ẩn danh';
    final xp = item['xp'] ?? 0;
    final avatarEmoji = item['avatarUrl']?.toString().isNotEmpty == true ? item['avatarUrl'] : '👤';

    return Column(
      children: [
        if (isFirst)
          const Text('👑', style: TextStyle(fontSize: 22))
        else
          const Text('🎖️', style: TextStyle(fontSize: 18)),
        const SizedBox(height: 4),
        Container(
          width: height,
          height: height,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: crownColor, width: isFirst ? 4 : 2),
            color: AppTheme.bg,
          ),
          child: Center(
            child: Text(
              avatarEmoji,
              style: TextStyle(fontSize: height * 0.45),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: 80,
          child: Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.indigo),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: isFirst ? AppTheme.teal.withOpacity(0.1) : AppTheme.gray,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$xp XP',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: isFirst ? AppTheme.teal : AppTheme.indigo,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardRow(dynamic item, int rank) {
    final auth = context.read<AuthProvider>();
    final bool isSelf = item['id'].toString() == auth.currentUser.id;
    final name = item['displayName'] ?? item['display_name'] ?? 'Ẩn danh';
    final xp = item['xp'] ?? 0;
    final avatarEmoji = item['avatarUrl']?.toString().isNotEmpty == true ? item['avatarUrl'] : '👤';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isSelf ? AppTheme.indigo.withOpacity(0.05) : AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isSelf ? AppTheme.indigo : AppTheme.border),
      ),
      child: Row(
        children: [
          // Rank ID
          SizedBox(
            width: 28,
            child: Text(
              '#$rank',
              style: const TextStyle(fontWeight: FontWeight.w900, color: AppTheme.muted, fontSize: 14),
            ),
          ),
          const SizedBox(width: 8),

          // Avatar
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(color: AppTheme.bg, shape: BoxShape.circle),
            child: Center(child: Text(avatarEmoji, style: const TextStyle(fontSize: 20))),
          ),
          const SizedBox(width: 14),

          // Name
          Expanded(
            child: Text(
              name + (isSelf ? ' (Bạn)' : ''),
              style: TextStyle(
                fontWeight: isSelf ? FontWeight.bold : FontWeight.w600,
                fontSize: 13,
                color: AppTheme.text,
              ),
            ),
          ),

          // XP
          Text(
            '$xp XP',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.indigo,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
