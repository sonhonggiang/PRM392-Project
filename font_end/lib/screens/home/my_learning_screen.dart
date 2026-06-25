import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../core/services/api_service.dart';
import '../origami/origami_detail_screen.dart';

class MyLearningScreen extends StatefulWidget {
  const MyLearningScreen({super.key});

  @override
  State<MyLearningScreen> createState() => _MyLearningScreenState();
}

class _MyLearningScreenState extends State<MyLearningScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _progressList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadProgress();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadProgress() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final progress = await ApiService.getProgress();
      if (mounted) {
        setState(() {
          _progressList = progress;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Lỗi tải tiến trình học: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<dynamic> get inProgressModels => _progressList
      .where((p) => p['is_completed'] == 0 || p['is_completed'] == false)
      .toList();

  List<dynamic> get completedModels => _progressList
      .where((p) => p['is_completed'] == 1 || p['is_completed'] == true)
      .toList();

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
                  Text('Đang làm dở (${_isLoading ? '...' : inProgressModels.length})'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_rounded, size: 16),
                  const SizedBox(width: 6),
                  Text('Đã hoàn thành (${_isLoading ? '...' : completedModels.length})'),
                ],
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.indigo))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildInProgressTab(),
                _buildCompletedTab(),
              ],
            ),
    );
  }

  Widget _buildInProgressTab() {
    final list = inProgressModels;
    if (list.isEmpty) {
      return _buildEmptyState(
        emoji: '📚',
        title: 'Chưa có mẫu đang học',
        subtitle: 'Hãy bắt đầu học một mẫu mới nhé!',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, i) {
        final item = list[i];
        
        int totalSteps = 5;
        if (item['difficulty'] == 'Trung bình') {
          totalSteps = 10;
        } else if (item['difficulty'] == 'Khó') {
          totalSteps = 20;
        }
        int currentStep = item['current_step'] ?? 1;
        if (currentStep > totalSteps) {
          totalSteps = currentStep;
        }
        final double progress = currentStep / totalSteps;

        final dateStr = item['updated_at'] != null 
            ? item['updated_at'].toString().split('T')[0] 
            : '';

        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OrigamiDetailScreen(origamiId: item['origami_id']),
            ),
          ).then((_) => _loadProgress()),
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
                    Container(
                      width: 60, height: 60,
                      decoration: BoxDecoration(
                        color: AppTheme.bg,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(child: Text(item['emoji'] ?? '📄', style: const TextStyle(fontSize: 30))),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['name'] ?? '',
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
                                child: Text('Độ khó: ${item['difficulty'] ?? 'Dễ'}',
                                  style: const TextStyle(fontSize: 11, color: AppTheme.indigo, fontWeight: FontWeight.w600)),
                              ),
                              const SizedBox(width: 8),
                              if (dateStr.isNotEmpty)
                                Text('Cập nhật: $dateStr',
                                  style: const TextStyle(fontSize: 11, color: AppTheme.muted)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(color: AppTheme.indigo, shape: BoxShape.circle),
                      child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Bước $currentStep/$totalSteps',
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

  Widget _buildCompletedTab() {
    final list = completedModels;
    if (list.isEmpty) {
      return _buildEmptyState(
        emoji: '🏆',
        title: 'Chưa hoàn thành mẫu nào',
        subtitle: 'Hoàn thành mẫu đầu tiên để nhận huy hiệu!',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, i) {
        final item = list[i];
        final dateStr = item['completed_at'] != null 
            ? item['completed_at'].toString().split('T')[0] 
            : (item['updated_at'] != null ? item['updated_at'].toString().split('T')[0] : '');

        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OrigamiDetailScreen(origamiId: item['origami_id']),
            ),
          ).then((_) => _loadProgress()),
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
                Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(color: AppTheme.teal.withOpacity(0.08), borderRadius: BorderRadius.circular(14)),
                  child: Center(child: Text(item['emoji'] ?? '🏆', style: const TextStyle(fontSize: 30))),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['name'] ?? '',
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
                      if (dateStr.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text('Hoàn thành: $dateStr',
                          style: const TextStyle(fontSize: 11, color: AppTheme.muted)),
                      ],
                    ],
                  ),
                ),
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
