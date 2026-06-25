import 'package:flutter/material.dart';
import '../../core/theme.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _weeklyRankings = const [
    {'rank': 1, 'name': 'Nguyễn Hùng', 'avatar': '🙋‍♂️', 'xp': 450, 'isSelf': false},
    {'rank': 2, 'name': 'Minh Thư', 'avatar': '🙋‍♀️', 'xp': 410, 'isSelf': false},
    {'rank': 3, 'name': 'Thanh Sơn', 'avatar': '👨‍🎨', 'xp': 390, 'isSelf': false},
    {'rank': 4, 'name': 'Hoàng Long', 'avatar': '🧑‍💻', 'xp': 350, 'isSelf': false},
    {'rank': 5, 'name': 'Bích Trâm', 'avatar': '👩‍⚕️', 'xp': 320, 'isSelf': false},
    {'rank': 6, 'name': 'Khánh Nam', 'avatar': '👨‍🍳', 'xp': 300, 'isSelf': false},
    {'rank': 7, 'name': 'Linh Chi', 'avatar': '👩‍💼', 'xp': 280, 'isSelf': false},
    {'rank': 8, 'name': 'Quốc Anh', 'avatar': '👨‍✈️', 'xp': 260, 'isSelf': false},
    {'rank': 9, 'name': 'Ngọc Hải', 'avatar': '👩‍🎨', 'xp': 250, 'isSelf': false},
  ];

  final List<Map<String, dynamic>> _monthlyRankings = const [
    {'rank': 1, 'name': 'Linh Chi', 'avatar': '👩‍💼', 'xp': 1850, 'isSelf': false},
    {'rank': 2, 'name': 'Nguyễn Hùng', 'avatar': '🙋‍♂️', 'xp': 1720, 'isSelf': false},
    {'rank': 3, 'name': 'Minh Thư', 'avatar': '🙋‍♀️', 'xp': 1600, 'isSelf': false},
    {'rank': 4, 'name': 'Hoàng Long', 'avatar': '🧑‍💻', 'xp': 1420, 'isSelf': false},
    {'rank': 5, 'name': 'Thanh Sơn', 'avatar': '👨‍🎨', 'xp': 1300, 'isSelf': false},
    {'rank': 6, 'name': 'Sơn Giang', 'avatar': '👤', 'xp': 1250, 'isSelf': true},
    {'rank': 7, 'name': 'Bích Trâm', 'avatar': '👩‍⚕️', 'xp': 1100, 'isSelf': false},
    {'rank': 8, 'name': 'Khánh Nam', 'avatar': '👨‍🍳', 'xp': 950, 'isSelf': false},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLeaderboardTab(weekly: true),
          _buildLeaderboardTab(weekly: false),
          _buildLeaderboardTab(weekly: true), // Duplicate weekly for all-time
        ],
      ),
    );
  }

  Widget _buildLeaderboardTab({required bool weekly}) {
    final list = weekly ? _weeklyRankings : _monthlyRankings;
    
    // Top 3 separate
    final top1 = list.firstWhere((e) => e['rank'] == 1);
    final top2 = list.firstWhere((e) => e['rank'] == 2);
    final top3 = list.firstWhere((e) => e['rank'] == 3);

    // Rank 4+ list
    final lowerRanks = list.where((e) => e['rank'] > 3).toList();

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
                  _buildPodiumAvatar(item: top2, height: 75, crownColor: AppTheme.border, isFirst: false),
                  // 🥇 Rank 1
                  _buildPodiumAvatar(item: top1, height: 95, crownColor: AppTheme.amber, isFirst: true),
                  // 🥉 Rank 3
                  _buildPodiumAvatar(item: top3, height: 70, crownColor: const Color(0xFFCD7F32), isFirst: false),
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
                  return _buildLeaderboardRow(item);
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
                  child: const Text(
                    'Hạng #12',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
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
                        'Sơn Giang (Bạn)',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Cần thêm 15 XP để vượt hạng #11',
                        style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11),
                      ),
                    ],
                  ),
                ),
                
                // XP Score
                Text(
                  '185 XP',
                  style: TextStyle(
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
    required Map<String, dynamic> item,
    required double height,
    required Color crownColor,
    required bool isFirst,
  }) {
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
              item['avatar'],
              style: TextStyle(fontSize: height * 0.5),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          item['name'],
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.indigo),
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: isFirst ? AppTheme.teal.withOpacity(0.1) : AppTheme.gray,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '${item['xp']} XP',
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

  Widget _buildLeaderboardRow(Map<String, dynamic> item) {
    final bool isSelf = item['isSelf'] ?? false;
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
              '#${item['rank']}',
              style: const TextStyle(fontWeight: FontWeight.w900, color: AppTheme.muted, fontSize: 14),
            ),
          ),
          const SizedBox(width: 8),

          // Avatar
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(color: AppTheme.bg, shape: BoxShape.circle),
            child: Center(child: Text(item['avatar'], style: const TextStyle(fontSize: 20))),
          ),
          const SizedBox(width: 14),

          // Name
          Expanded(
            child: Text(
              item['name'] + (isSelf ? ' (Bạn)' : ''),
              style: TextStyle(
                fontWeight: isSelf ? FontWeight.bold : FontWeight.w600,
                fontSize: 13,
                color: AppTheme.text,
              ),
            ),
          ),

          // XP
          Text(
            '${item['xp']} XP',
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
