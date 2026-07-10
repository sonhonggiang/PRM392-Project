import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/services/api_service.dart';
import '../../core/providers/auth_provider.dart';
import '../../models/user_model.dart';
import 'tutorial_success_screen.dart';

class OrigamiTutorialScreen extends StatefulWidget {
  final int origamiId;
  final List<dynamic> steps;
  final bool isDailyChallenge;

  const OrigamiTutorialScreen({
    super.key,
    required this.origamiId,
    required this.steps,
    this.isDailyChallenge = false,
  });

  @override
  State<OrigamiTutorialScreen> createState() => _OrigamiTutorialScreenState();
}

class _OrigamiTutorialScreenState extends State<OrigamiTutorialScreen> {
  int _currentStepIndex = 0;
  late DateTime _startTime;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
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
      if (widget.isDailyChallenge) {
        // 1. Gọi API hoàn thành thử thách ngày
        final result = await ApiService.completeDailyChallenge();
        if (result != null) {
          xpEarned = result['rewardXp'] ?? 100;
        }
      } else {
        // 2. Gọi API hoàn thành mẫu thông thường
        final result = await ApiService.updateProgress(
          widget.origamiId, 
          widget.steps.length, 
          true,
          duration: durationSeconds
        );
        if (result != null) {
          xpEarned = result['xpReward'] ?? 50;
        }
      }

      if (mounted) {
        setState(() => _isLoading = false);
        
        // Cập nhật lại thông tin User trong Provider (XP mới)
        await auth.refreshProfile();
        
        // Chuyển hướng sang màn hình thành công kèm phần thưởng thực tế
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => TutorialSuccessScreen(
                modelName: 'Mẫu học gấp',
                emoji: '🏆',
                duration: durationStr,
                xpEarned: xpEarned,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        // Fallback chuyển hướng
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => TutorialSuccessScreen(
              modelName: 'Mẫu học gấp',
              emoji: '🏆',
              duration: durationStr,
              xpEarned: xpEarned,
            ),
          ),
        );
      }
    }
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
