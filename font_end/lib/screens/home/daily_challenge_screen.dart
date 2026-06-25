import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../origami/origami_detail_screen.dart';

class DailyChallengeScreen extends StatefulWidget {
  const DailyChallengeScreen({super.key});

  @override
  State<DailyChallengeScreen> createState() => _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends State<DailyChallengeScreen> {
  late Timer _timer;
  Duration _timeLeft = const Duration(hours: 12, minutes: 44, seconds: 12);

  // Month mock days: true = completed challenge, false = not completed
  final List<bool> _completedDays = [
    true, true, false, true, true, false, true, // Week 1
    true, false, true, true, true, false, true, // Week 2
    true, true, true, false, true, true, true, // Week 3
    true, true, false, false, false, false, false, // Week 4 (up to 28 days)
  ];

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_timeLeft.inSeconds > 0) {
            _timeLeft = _timeLeft - const Duration(seconds: 1);
          } else {
            _timeLeft = const Duration(hours: 24);
          }
        });
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Banner Thử thách lớn ───────────────────────────────────────
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
                  const Text(
                    '🐲 Rồng Lửa Khổng Lồ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Gấp thành công mẫu Rồng Lửa hôm nay để nhận thêm phần thưởng đặc biệt!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
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
                      _buildRewardChip(text: '+100 XP', color: AppTheme.amber),
                      const SizedBox(width: 10),
                      _buildRewardChip(text: 'Huy hiệu Rồng Lửa 🔥', color: AppTheme.tealLight),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Start Challenge Button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const OrigamiDetailScreen()),
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.teal,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Bắt Đầu Thử Thách', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ─── Lịch sử hoàn thành Thử thách tháng này ──────────────────────
            const Text(
              'Lịch sử thử thách tháng 6/2026',
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
                  // Week headers
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
                      
                      // Highlight current day (25th day of month, index 24)
                      final bool isToday = index == 24;

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
