import 'package:flutter/material.dart';
import '../../../../core/theme.dart';
import '../../../../core/services/gamification_service.dart';

class GamificationSection extends StatefulWidget {
  final List<dynamic> allModels;
  final List<dynamic> userProgress;
  final VoidCallback onRefresh;

  const GamificationSection({
    super.key,
    required this.allModels,
    required this.userProgress,
    required this.onRefresh,
  });

  @override
  State<GamificationSection> createState() => _GamificationSectionState();
}

class _GamificationSectionState extends State<GamificationSection> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _questsList = [];
  List<Map<String, dynamic>> _campaignsList = [];
  bool _isLoadingGamification = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadGamificationData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadGamificationData() async {
    try {
      final quests = await GamificationService.getQuests();
      final campaigns = await GamificationService.getCampaigns();
      if (mounted) {
        setState(() {
          _questsList = quests;
          _campaignsList = campaigns;
          _isLoadingGamification = false;
        });
      }
    } catch (e) {
      print('Lỗi tải dữ liệu Gamification: $e');
    }
  }

  // 1. Tính toán trạng thái các nhiệm vụ
  bool _evaluateQuest(Map<String, dynamic> quest) {
    final key = quest['key'];
    if (key == 'login') return true; // Đăng nhập luôn đúng
    if (key == 'fold') {
      return widget.userProgress.any((p) => p['is_completed'] == 1 || p['isCompleted'] == true);
    }
    if (key == 'fav') {
      return widget.userProgress.length >= 2;
    }
    // Nhiệm vụ tuỳ chỉnh: Trả về true nếu người dùng đã hoàn thành ít nhất 1 mẫu
    return widget.userProgress.any((p) => p['is_completed'] == 1 || p['isCompleted'] == true);
  }

  // 2. Tính toán tiến trình bộ sưu tập
  List<Map<String, dynamic>> _getCollections() {
    final List<Map<String, dynamic>> collections = [
      {
        'id': 1,
        'name': 'Bách Thú',
        'emoji': '🐰',
        'color': AppTheme.indigo,
        'reward': 'Badge Nghệ nhân Muông Thú + 200 XP',
      },
      {
        'id': 2,
        'name': 'Floral',
        'emoji': '🌺',
        'color': AppTheme.red,
        'reward': 'Badge Nghệ nhân Hoa Cỏ + 200 XP',
      },
      {
        'id': 3,
        'name': 'Đồ Vật',
        'emoji': '✈️',
        'color': AppTheme.teal,
        'reward': 'Badge Nghệ nhân Đồ Vật + 200 XP',
      },
    ];

    return collections.map((col) {
      final int catId = col['id'];
      final modelsInCat = widget.allModels.where((m) => m['category_id'] == catId || m['categoryId'] == catId).toList();
      final total = modelsInCat.length;

      int completed = 0;
      for (var model in modelsInCat) {
        final modelId = model['id'];
        final hasCompleted = widget.userProgress.any((p) => 
          (p['origami_id'] == modelId || p['origamiId'] == modelId) && 
          (p['is_completed'] == 1 || p['isCompleted'] == true)
        );
        if (hasCompleted) {
          completed++;
        }
      }

      return {
        ...col,
        'total': total == 0 ? 3 : total,
        'completed': completed,
      };
    }).toList();
  }

  // 3. Tính toán tiến trình chiến dịch
  int _evaluateCampaignProgress(Map<String, dynamic> camp) {
    final id = camp['id'];
    final title = camp['title']?.toString() ?? '';

    if (id == '1' || title.contains('Khởi đầu')) {
      final heartCompleted = widget.userProgress.any((p) => 
        (p['origami_id'] == 1 || p['origamiId'] == 1) && 
        (p['is_completed'] == 1 || p['isCompleted'] == true)
      );
      final swanCompleted = widget.userProgress.any((p) => 
        (p['origami_id'] == 2 || p['origamiId'] == 2) && 
        (p['is_completed'] == 1 || p['isCompleted'] == true)
      );
      return (heartCompleted ? 1 : 0) + (swanCompleted ? 1 : 0);
    }

    // Các chiến dịch khác: Dựa trên tổng số mẫu hoàn thành
    final totalCompleted = widget.userProgress.where((p) => p['is_completed'] == 1 || p['isCompleted'] == true).length;
    final int totalRequired = int.tryParse(camp['total'].toString()) ?? 3;
    return totalCompleted.clamp(0, totalRequired);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingGamification) {
      return const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator(color: AppTheme.teal)),
      );
    }

    // Đánh giá các nhiệm vụ
    final List<Map<String, dynamic>> evaluatedQuests = _questsList.map((q) {
      return {
        ...q,
        'isCompleted': _evaluateQuest(q),
      };
    }).toList();

    final completedQuestsCount = evaluatedQuests.where((q) => q['isCompleted'] == true).length;
    final collections = _getCollections();

    // Đánh giá chiến dịch
    final List<Map<String, dynamic>> evaluatedCampaigns = _campaignsList.map((c) {
      final progress = _evaluateCampaignProgress(c);
      final total = int.tryParse(c['total'].toString()) ?? 3;
      return {
        ...c,
        'progress': progress,
        'total': total,
      };
    }).toList();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
        boxShadow: const [
          BoxShadow(color: Color(0x081A2F6E), blurRadius: 16, offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Tab Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Text('🎖️', style: TextStyle(fontSize: 20)),
                    SizedBox(width: 8),
                    Text(
                      'Sự kiện & Nhiệm vụ',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.indigo),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.teal.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'ĐANG DIỄN RA',
                    style: TextStyle(color: AppTheme.teal, fontSize: 10, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
          
          // Custom Styled Tab Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppTheme.indigo,
              labelColor: AppTheme.indigo,
              unselectedLabelColor: AppTheme.muted,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              tabs: const [
                Tab(text: 'Nhiệm vụ'),
                Tab(text: 'Bộ sưu tập'),
                Tab(text: 'Chiến dịch'),
              ],
            ),
          ),

          // Tab Content Area
          SizedBox(
            height: 180,
            child: TabBarView(
              controller: _tabController,
              children: [
                // 1. Tab Nhiệm vụ
                _buildQuestsTab(evaluatedQuests, completedQuestsCount),

                // 2. Tab Bộ sưu tập
                _buildCollectionsTab(collections),

                // 3. Tab Chiến dịch
                _buildCampaignsTab(evaluatedCampaigns),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget vẽ Tab Nhiệm vụ
  Widget _buildQuestsTab(List<Map<String, dynamic>> evaluatedQuests, int completedCount) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nhiệm vụ hôm nay ($completedCount/${evaluatedQuests.length})',
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppTheme.text),
              ),
              const Text(
                'F5 mỗi ngày ⏳',
                style: TextStyle(fontSize: 10.5, color: AppTheme.muted),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: evaluatedQuests.isEmpty
                ? const Center(child: Text('Không có nhiệm vụ nào', style: TextStyle(color: AppTheme.muted, fontSize: 12)))
                : ListView.builder(
                    itemCount: evaluatedQuests.length,
                    itemBuilder: (context, index) {
                      final q = evaluatedQuests[index];
                      return _buildQuestItem(
                        q['title'] ?? '',
                        q['xp'] ?? '+40 XP',
                        q['isCompleted'] ?? false,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestItem(String title, String xp, bool isCompleted) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(
            isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            color: isCompleted ? AppTheme.teal : AppTheme.border,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: isCompleted ? AppTheme.muted : AppTheme.text,
                decoration: isCompleted ? TextDecoration.lineThrough : null,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            xp,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isCompleted ? AppTheme.muted : AppTheme.indigoMid,
            ),
          ),
        ],
      ),
    );
  }

  // Widget vẽ Tab Bộ sưu tập
  Widget _buildCollectionsTab(List<Map<String, dynamic>> collections) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: collections.length,
      itemBuilder: (context, index) {
        final col = collections[index];
        final completed = col['completed'] as int;
        final total = col['total'] as int;
        final double progress = (completed / total).clamp(0.0, 1.0);
        final isFinished = completed >= total;

        return Container(
          width: 140,
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(col['emoji'], style: const TextStyle(fontSize: 18)),
                  if (isFinished)
                    const Icon(Icons.stars_rounded, color: AppTheme.amber, size: 16),
                ],
              ),
              const Spacer(),
              Text(
                'Bộ ${col['name']}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.indigo),
              ),
              const SizedBox(height: 4),
              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppTheme.border,
                  valueColor: AlwaysStoppedAnimation<Color>(col['color']),
                  minHeight: 5,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$completed/$total mẫu',
                    style: const TextStyle(fontSize: 10, color: AppTheme.muted, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: col['color']),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Widget vẽ Tab Chiến dịch
  Widget _buildCampaignsTab(List<Map<String, dynamic>> campaigns) {
    if (campaigns.isEmpty) {
      return const Center(child: Text('Không có chiến dịch nào', style: TextStyle(color: AppTheme.muted, fontSize: 12)));
    }
    return PageView.builder(
      itemCount: campaigns.length,
      itemBuilder: (context, index) {
        final camp = campaigns[index];
        final progress = camp['progress'] as int;
        final total = camp['total'] as int;
        final double pct = (progress / total).clamp(0.0, 1.0);
        final isFinished = progress >= total;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Campaign Emoji Badge
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.amber.withOpacity(0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.amber.withOpacity(0.4)),
                ),
                child: Center(
                  child: Text(
                    camp['emoji']?.toString() ?? '🔥',
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      camp['title']?.toString() ?? '',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.indigo),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      camp['desc']?.toString() ?? '',
                      style: const TextStyle(fontSize: 10.5, color: AppTheme.muted, height: 1.35),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    // Progress & Reward
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: pct,
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
                    const SizedBox(height: 2),
                    Text(
                      '🎁 Phần thưởng: ${camp['reward']}',
                      style: TextStyle(
                        fontSize: 9.5, 
                        fontWeight: FontWeight.bold, 
                        color: isFinished ? AppTheme.teal : AppTheme.indigoMid
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
