import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/services/api_service.dart';
import '../origami/origami_detail_screen.dart';

class DailyChallengeScreen extends StatefulWidget {
  const DailyChallengeScreen({super.key});

  @override
  State<DailyChallengeScreen> createState() => _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends State<DailyChallengeScreen> {
  late Timer _timer;
  Duration _timeLeft = const Duration(hours: 12);
  
  Map<String, dynamic>? _challengeData;
  bool _isLoading = true;

  List<bool> _completedDays = [];

  @override
  void initState() {
    super.initState();
    _calculateTimeLeft();
    _startTimer();
    _loadChallenge();
  }

  // Tải thử thách ngày hôm nay và lịch sử hoàn thành trong tháng từ API
  Future<void> _loadChallenge() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getDailyChallenge();
      final history = await ApiService.getDailyChallengeHistory();
      
      final now = DateTime.now();
      final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
      final totalDays = lastDayOfMonth.day;
      
      final List<bool> completed = List.generate(totalDays, (index) => false);
      for (var item in history) {
        if (item['date'] != null) {
          final date = DateTime.parse(item['date']);
          if (date.month == now.month && date.year == now.year) {
            final day = date.day;
            if (day <= totalDays) {
              completed[day - 1] = item['is_completed'] == 1 || item['is_completed'] == true;
            }
          }
        }
      }

      setState(() {
        _challengeData = data;
        _completedDays = completed;
        _isLoading = false;
      });
    } catch (e) {
      print('Lỗi tải thử thách ngày: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }


  // Tính toán thời gian còn lại đến cuối ngày (23:59:59)
  void _calculateTimeLeft() {
    final now = DateTime.now();
    final endOfDay = DateTime(now.year, now.month, now.day + 1);
    setState(() {
      _timeLeft = endOfDay.difference(now);
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        _calculateTimeLeft();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(d.inHours);
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final isChallengeDone = _challengeData != null && (_challengeData!['isCompleted'] == true || _challengeData!['is_completed'] == 1);

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
          'Thách thức hàng ngày',
          style: TextStyle(color: AppTheme.indigo, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.teal))
          : RefreshIndicator(
              onRefresh: _loadChallenge,
              color: AppTheme.teal,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ─── Banner Thử thách lớn ───────────────────────────────────────
                    if (_challengeData != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.indigo, AppTheme.indigoMid],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.indigo.withOpacity(0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'THỬ THÁCH HÔM NAY',
                              style: TextStyle(
                                color: AppTheme.amber,
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '${_challengeData!['emoji'] ?? '🎯'} ${_challengeData!['name'] ?? ''}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Gấp thành công mẫu ${_challengeData!['name'] ?? ''} hôm nay để nhận thêm phần thưởng đặc biệt!',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
                            ),
                            const SizedBox(height: 20),

                            // Timer Counter Display
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.alarm_rounded, color: AppTheme.amber, size: 18),
                                const SizedBox(width: 8),
                                const Text(
                                  'Thời gian còn lại: ',
                                  style: TextStyle(color: Colors.white70, fontSize: 13),
                                ),
                                Text(
                                  _formatDuration(_timeLeft),
                                  style: const TextStyle(
                                    color: AppTheme.amber,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Rewards Badge Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildRewardChip(text: '+${_challengeData!['reward_xp'] ?? 100} XP', color: AppTheme.amber),
                                const SizedBox(width: 10),
                                _buildRewardChip(text: 'Huy hiệu đặc biệt 🏅', color: AppTheme.tealLight),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Start Challenge Button
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: isChallengeDone
                                    ? null
                                    : () {
                                        final origamiId = _challengeData!['origami_id'] ?? _challengeData!['origamiId'];
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => OrigamiDetailScreen(
                                              origamiId: origamiId,
                                              isDailyChallenge: true,
                                            ),
                                          ),
                                        ).then((_) => _loadChallenge());
                                      },
                                style: FilledButton.styleFrom(
                                  backgroundColor: isChallengeDone ? Colors.grey : AppTheme.teal,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                child: Text(
                                  isChallengeDone ? 'Đã Hoàn Thành Thử Thách Hôm Nay ✅' : 'Bắt Đầu Thử Thách',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      const Center(child: Text('Không tìm thấy thông tin thử thách ngày', style: TextStyle(color: AppTheme.muted))),
                    const SizedBox(height: 24),

                    // ─── Lịch sử hoàn thành Thử thách tháng này ──────────────────────
                    const Text(
                      'Lịch sử thử thách tháng này',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.indigo),
                    ),
                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.border),
                        boxShadow: const [
                          BoxShadow(color: Color(0x051A2F6E), blurRadius: 10, offset: Offset(0, 4))
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: const [
                              Text('T2', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.muted)),
                              Text('T3', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.muted)),
                              Text('T4', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.muted)),
                              Text('T5', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.muted)),
                              Text('T6', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.muted)),
                              Text('T7', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.muted)),
                              Text('CN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.muted)),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Calendar Grid (28 days mock)
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 7,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                            ),
                            itemCount: _completedDays.length,
                            itemBuilder: (context, index) {
                              final bool isDone = _completedDays[index];
                              final int dayNumber = index + 1;
                              
                              // Ngày hiện tại thực tế
                              final bool isToday = index == DateTime.now().day - 1;


                              return Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isDone
                                      ? AppTheme.teal.withOpacity(0.15)
                                      : isToday
                                          ? AppTheme.indigo.withOpacity(0.1)
                                          : Colors.transparent,
                                  border: Border.all(
                                    color: isDone
                                        ? AppTheme.teal
                                        : isToday
                                            ? AppTheme.indigo
                                            : AppTheme.border,
                                    width: isToday ? 2 : 1,
                                  ),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        dayNumber.toString(),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: (isDone || isToday) ? FontWeight.bold : FontWeight.normal,
                                          color: isDone
                                              ? AppTheme.teal
                                              : isToday
                                                  ? AppTheme.indigo
                                                  : AppTheme.text,
                                        ),
                                      ),
                                      if (isDone)
                                        const Text('🔥', style: TextStyle(fontSize: 6)),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildRewardChip({required String text, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}
