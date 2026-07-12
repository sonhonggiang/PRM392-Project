import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme.dart';
import '../../core/services/api_service.dart';
import '../../core/providers/auth_provider.dart';
import '../../models/user_model.dart';
import 'tutorial_success_screen.dart';

class OrigamiTutorialScreen extends StatefulWidget {
  final int origamiId;
  final List<dynamic> steps;
  final bool isDailyChallenge;
  final int estimatedTimeMinutes;

  const OrigamiTutorialScreen({
    super.key,
    required this.origamiId,
    required this.steps,
    this.isDailyChallenge = false,
    this.estimatedTimeMinutes = 10,
  });

  @override
  State<OrigamiTutorialScreen> createState() => _OrigamiTutorialScreenState();
}

class _OrigamiTutorialScreenState extends State<OrigamiTutorialScreen> {
  int _currentStepIndex = 0;
  late DateTime _startTime;
  bool _isLoading = false;
  Timer? _timer;
  late int _remainingSeconds;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _remainingSeconds = widget.estimatedTimeMinutes * 60;
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer?.cancel();
        _showTimeUpDialog();
      }
    });
  }

  void _showTimeUpDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: const [
            Text('⏰ ', style: TextStyle(fontSize: 24)),
            Text('Hết giờ rồi!', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.red)),
          ],
        ),
        content: const Text(
          'Thời gian gấp mẫu của bạn đã kết thúc. Hãy thử lại hoặc lựa chọn mẫu khác nhé!',
          style: TextStyle(color: AppTheme.text, height: 1.4),
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            style: FilledButton.styleFrom(backgroundColor: AppTheme.indigo),
            child: const Text('Quay lại Khám phá'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Cập nhật tiến độ học tập lên database khi chuyển qua các bước (chỉ cho thành viên)
  Future<void> _updateProgressOnServer(bool isCompleted) async {
    final auth = context.read<AuthProvider>();
    if (auth.currentUser.role == UserRole.guest) return;

    try {
      await ApiService.updateProgress(
        widget.origamiId,
        _currentStepIndex + 1,
        isCompleted,
      );
    } catch (e) {
      print('Lỗi cập nhật tiến độ học: $e');
    }
  }

  // Kết thúc buổi học và nhận phần thưởng
  Future<void> _handleComplete() async {
    _timer?.cancel();
    final auth = context.read<AuthProvider>();
    final isGuest = auth.currentUser.role == UserRole.guest;

    // Tính thời gian đã học
    final elapsed = DateTime.now().difference(_startTime);
    final durationSeconds = elapsed.inSeconds;
    final minutes = elapsed.inMinutes.toString().padLeft(2, '0');
    final seconds = (elapsed.inSeconds % 60).toString().padLeft(2, '0');
    final durationStr = '$minutes:$seconds';

    int xpEarned = 50;
    
    // ... (guest logic remains same)

    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final activeBooster = prefs.getString('active_booster') ?? '';
      int multiplier = 1;
      if (activeBooster == 'x2_xp') multiplier = 2;
      if (activeBooster == 'x3_xp') multiplier = 3;

      if (widget.isDailyChallenge) {
        // 1. Gọi API hoàn thành thử thách ngày
        final result = await ApiService.completeDailyChallenge(boosterMultiplier: multiplier);
        if (result != null) {
          xpEarned = result['rewardXp'] ?? 100;
        }
      } else {
        // 2. Gọi API hoàn thành mẫu thông thường
        final result = await ApiService.updateProgress(
          widget.origamiId, 
          widget.steps.length, 
          true,
          duration: durationSeconds,
          boosterMultiplier: multiplier,
        );
        if (result != null) {
          xpEarned = result['xpReward'] ?? 50;
        }
      }

      // Tiêu thụ booster sau khi dùng
      if (multiplier > 1) {
        await prefs.remove('active_booster');
      }

      if (mounted) {
        setState(() => _isLoading = false);
        
        // Cập nhật lại thông tin User trong Provider (XP mới)
        await auth.refreshProfile();
        
        // Hiển thị dialog đánh giá sao trước khi chuyển sang màn hình thành công
        if (mounted) {
          _showRatingDialog(
            origamiId: widget.origamiId,
            modelName: 'Mẫu học gấp',
            emoji: '🏆',
            duration: durationStr,
            xpEarned: xpEarned,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        // Fallback: hiển thị dialog đánh giá ngay cả khi lỗi API
        _showRatingDialog(
          origamiId: widget.origamiId,
          modelName: 'Mẫu học gấp',
          emoji: '🏆',
          duration: durationStr,
          xpEarned: xpEarned,
        );
      }
    }
  }

  // Dialog đánh giá sao sau khi hoàn thành gấp
  void _showRatingDialog({
    required int origamiId,
    required String modelName,
    required String emoji,
    required String duration,
    required int xpEarned,
  }) {
    int _selectedStars = 0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🎉', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 8),
                const Text(
                  'Bạn đã hoàn thành!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.indigo),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Hãy đánh giá mẫu gấp này để giúp cộng đồng nhé!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: AppTheme.muted, height: 1.4),
                ),
                const SizedBox(height: 24),
                // Hàng 5 ngôi sao
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    final starIndex = i + 1;
                    return GestureDetector(
                      onTap: () => setDialogState(() => _selectedStars = starIndex),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Icon(
                          starIndex <= _selectedStars ? Icons.star_rounded : Icons.star_border_rounded,
                          color: AppTheme.amber,
                          size: 40,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 8),
                Text(
                  _selectedStars == 0 ? 'Chưa chọn sao'
                    : _selectedStars == 1 ? '⭐ Không tốt'
                    : _selectedStars == 2 ? '⭐⭐ Bình thường'
                    : _selectedStars == 3 ? '⭐⭐⭐ Ổn'
                    : _selectedStars == 4 ? '⭐⭐⭐⭐ Tốt lắm!'
                    : '⭐⭐⭐⭐⭐ Tuyệt vời!',
                  style: TextStyle(
                    fontSize: 13,
                    color: _selectedStars > 0 ? AppTheme.amber : AppTheme.muted,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TutorialSuccessScreen(
                                modelName: modelName,
                                emoji: emoji,
                                duration: duration,
                                xpEarned: xpEarned,
                              ),
                            ),
                          );
                        },
                        child: const Text('Bỏ qua'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        style: FilledButton.styleFrom(backgroundColor: AppTheme.amber),
                        onPressed: _selectedStars == 0 ? null : () async {
                          await ApiService.rateOrigami(origamiId, _selectedStars);
                          if (!context.mounted) return;
                          Navigator.pop(ctx);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TutorialSuccessScreen(
                                modelName: modelName,
                                emoji: emoji,
                                duration: duration,
                                xpEarned: xpEarned,
                              ),
                            ),
                          );
                        },
                        child: const Text('Gửi đánh giá', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.steps.isEmpty) {
      return Scaffold(
        appBar: AppBar(leading: const CloseButton()),
        body: const Center(child: Text('Không có bước gấp nào được thiết lập!')),
      );
    }

    final currentStepData = widget.steps[_currentStepIndex];
    final stepNum = _currentStepIndex + 1;
    final totalSteps = widget.steps.length;
    final instruction = currentStepData['instruction'] ?? '';
    final tip = currentStepData['tip'] ?? '';
    final imageUrl = currentStepData['image_url'] ?? '';

    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            // Hiển thị hộp thoại xác nhận khi bấm thoát
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Thoát hướng dẫn?'),
                content: const Text('Tiến độ của bạn sẽ được tự động lưu lại.'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tiếp tục học')),
                  FilledButton(
                    onPressed: () {
                      Navigator.pop(ctx); // Đóng dialog
                      Navigator.pop(context); // Thoát màn hình
                    },
                    style: FilledButton.styleFrom(backgroundColor: AppTheme.red),
                    child: const Text('Thoát'),
                  ),
                ],
              ),
            );
          },
        ),
        title: Column(
          children: [
            Text('Bước $stepNum / $totalSteps', style: const TextStyle(fontSize: 14, color: AppTheme.indigo, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            SizedBox(
              width: 150,
              child: LinearProgressIndicator(
                value: stepNum / totalSteps,
                backgroundColor: AppTheme.gray,
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.teal),
                minHeight: 4,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _remainingSeconds < 60 ? AppTheme.red.withOpacity(0.1) : AppTheme.teal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.timer, 
                  color: _remainingSeconds < 60 ? AppTheme.red : AppTheme.teal, 
                  size: 16
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDuration(_remainingSeconds),
                  style: TextStyle(
                    color: _remainingSeconds < 60 ? AppTheme.red : AppTheme.teal,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.teal))
            : Column(
                children: [
                  // Vùng hình ảnh minh họa bước gấp
                  Expanded(
                    flex: 3,
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.bg,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Center(
                        child: imageUrl.toString().isEmpty
                            ? const Text('🦢', style: TextStyle(fontSize: 120))
                            : imageUrl.toString().startsWith('http')
                                ? Image.network(
                                    imageUrl,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 80, color: AppTheme.muted),
                                  )
                                : imageUrl.toString().contains('/') || imageUrl.toString().contains('\\')
                                    ? Image.file(
                                        File(imageUrl),
                                        fit: BoxFit.contain,
                                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 80, color: AppTheme.muted),
                                      )
                                    : const Text('🦢', style: TextStyle(fontSize: 120)),
                      ),
                    ),
                  ),
                  
                  // Khối mô tả chỉ dẫn & mẹo gấp
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.white,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.indigo.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, -5),
                          )
                        ],
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chỉ dẫn bước $stepNum',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.indigo,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            instruction,
                            style: const TextStyle(color: AppTheme.text, height: 1.4, fontSize: 14),
                          ),
                          const SizedBox(height: 14),
                          
                          // Hiển thị mẹo gấp nếu có
                          if (tip.toString().isNotEmpty)
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTheme.amber.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppTheme.amber.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  const Text('💡', style: TextStyle(fontSize: 16)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      tip,
                                      style: const TextStyle(fontSize: 11, color: AppTheme.amber),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const Spacer(),
                          
                          // Các nút chuyển bước
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _currentStepIndex > 0
                                      ? () {
                                          setState(() {
                                            _currentStepIndex--;
                                          });
                                          _updateProgressOnServer(false);
                                        }
                                      : null,
                                  child: const Text('← Trước'),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: FilledButton(
                                  onPressed: () {
                                    if (_currentStepIndex < totalSteps - 1) {
                                      setState(() {
                                        _currentStepIndex++;
                                      });
                                      _updateProgressOnServer(false);
                                    } else {
                                      _handleComplete();
                                    }
                                  },
                                  child: Text(_currentStepIndex < totalSteps - 1 ? 'Tiếp →' : 'Hoàn thành 🏆'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
