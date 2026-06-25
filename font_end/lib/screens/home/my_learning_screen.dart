import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../origami/origami_detail_screen.dart';

// ─── Dữ liệu mẫu "Đang học" và "Đã hoàn thành" ─────────────────────────────
final List<Map<String, dynamic>> inProgressModels = [
  {'name': 'Rồng Lửa', 'emoji': '🐲', 'step': 5, 'total': 30, 'category': 'Động vật', 'date': '20/06/2026'},
  {'name': 'Hạc giấy Nhật Bản', 'emoji': '🦢', 'step': 4, 'total': 18, 'category': 'Động vật', 'date': '23/06/2026'},
  {'name': 'Hoa Hồng Cổ Điển', 'emoji': '🌺', 'step': 7, 'total': 20, 'category': 'Hoa cỏ', 'date': '22/06/2026'},
];

final List<Map<String, dynamic>> completedModels = [
  {'name': 'Trái tim đôi', 'emoji': '❤️', 'step': 12, 'total': 12, 'category': 'Đồ vật', 'date': '21/06/2026'},
  {'name': 'Con Ếch nhảy', 'emoji': '🐸', 'step': 8, 'total': 8, 'category': 'Động vật', 'date': '18/06/2026'},
  {'name': 'Máy Bay chiến đấu', 'emoji': '✈️', 'step': 10, 'total': 10, 'category': 'Đồ vật', 'date': '10/06/2026'},
  {'name': 'Hạc Giấy Đơn', 'emoji': '🦢', 'step': 6, 'total': 6, 'category': 'Động vật', 'date': '05/06/2026'},
];

// ─── Màn hình "Tiếp tục học" ────────────────────────────────────────────────
class MyLearningScreen extends StatefulWidget {
  const MyLearningScreen({super.key});

  @override
  State<MyLearningScreen> createState() => _MyLearningScreenState();
}

class _MyLearningScreenState extends State<MyLearningScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
          'Tiếp tục học',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.indigo),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.indigo,
          unselectedLabelColor: AppTheme.muted,
          indicatorColor: AppTheme.indigo,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.hourglass_bottom_rounded, size: 16),
                  const SizedBox(width: 6),
                  Text('Đang làm dở (${inProgressModels.length})'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_rounded, size: 16),
                  const SizedBox(width: 6),
                  Text('Đã hoàn thành (${completedModels.length})'),
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ── Tab 1: Đang làm dở ────────────────────────────────────────
          _buildInProgressTab(),
          // ── Tab 2: Đã hoàn thành ──────────────────────────────────────
          _buildCompletedTab(),
        ],
      ),
    );
  }

  // ── Tab đang học ─────────────────────────────────────────────────────────
  Widget _buildInProgressTab() {
    if (inProgressModels.isEmpty) {
      return _buildEmptyState(
        emoji: '📚',
        title: 'Chưa có mẫu đang học',
        subtitle: 'Hãy bắt đầu học một mẫu mới nhé!',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: inProgressModels.length,
      itemBuilder: (context, i) {
        final item = inProgressModels[i];
        final double progress = (item['step'] as int) / (item['total'] as int);
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const OrigamiDetailScreen()),
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.border),
              boxShadow: const [BoxShadow(color: Color(0x0A1A2F6E), blurRadius: 10, offset: Offset(0, 4))],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // Emoji thumbnail
                    Container(
                      width: 60, height: 60,
                      decoration: BoxDecoration(
                        color: AppTheme.bg,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(child: Text(item['emoji'], style: const TextStyle(fontSize: 30))),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['name'],
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.text)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.indigo.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(item['category'],
                                  style: const TextStyle(fontSize: 11, color: AppTheme.indigo, fontWeight: FontWeight.w600)),
                              ),
                              const SizedBox(width: 8),
                              Text('Cập nhật: ${item['date']}',
                                style: const TextStyle(fontSize: 11, color: AppTheme.muted)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Play button
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(color: AppTheme.indigo, shape: BoxShape.circle),
                      child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Progress bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Bước ${item['step']}/${item['total']}',
                          style: const TextStyle(fontSize: 12, color: AppTheme.muted)),
                        Text('${(progress * 100).toInt()}%',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.teal)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: AppTheme.gray,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.teal),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Tab đã hoàn thành ────────────────────────────────────────────────────
  Widget _buildCompletedTab() {
    if (completedModels.isEmpty) {
      return _buildEmptyState(
        emoji: '🏆',
        title: 'Chưa hoàn thành mẫu nào',
        subtitle: 'Hoàn thành mẫu đầu tiên để nhận huy hiệu!',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: completedModels.length,
      itemBuilder: (context, i) {
        final item = completedModels[i];
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const OrigamiDetailScreen()),
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.teal.withOpacity(0.3)),
              boxShadow: const [BoxShadow(color: Color(0x0A1A2F6E), blurRadius: 10, offset: Offset(0, 4))],
            ),
            child: Row(
              children: [
                // Emoji
                Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(color: AppTheme.teal.withOpacity(0.08), borderRadius: BorderRadius.circular(14)),
                  child: Center(child: Text(item['emoji'], style: const TextStyle(fontSize: 30))),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['name'],
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.text)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.teal.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('✅ Hoàn thành',
                              style: TextStyle(fontSize: 11, color: AppTheme.teal, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('Hoàn thành: ${item['date']}',
                        style: const TextStyle(fontSize: 11, color: AppTheme.muted)),
                    ],
                  ),
                ),
                // Replay icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.teal.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.replay_rounded, color: AppTheme.teal, size: 20),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState({required String emoji, required String title, required String subtitle}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 60)),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.indigo)),
          const SizedBox(height: 8),
          Text(subtitle, style: const TextStyle(color: AppTheme.muted), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
