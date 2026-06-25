import 'package:flutter/material.dart';
import '../../core/theme.dart';

class TutorialSuccessScreen extends StatefulWidget {
  final String modelName;
  final String emoji;
  final String duration;
  final int xpEarned;

  const TutorialSuccessScreen({
    super.key,
    this.modelName = 'Hạc giấy Nhật Bản',
    this.emoji = '🦢',
    this.duration = '08:24',
    this.xpEarned = 50,
  });

  @override
  State<TutorialSuccessScreen> createState() => _TutorialSuccessScreenState();
}

class _TutorialSuccessScreenState extends State<TutorialSuccessScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _hasShared = false;
  bool _hasUploadedImage = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.indigo,
      body: SafeArea(
        child: Stack(
          children: [
            // Decorative background circles
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.indigoLight.withOpacity(0.2),
                ),
              ),
            ),
            Positioned(
              bottom: -50,
              left: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.teal.withOpacity(0.15),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),

                  // Celebration Trophy / Badge Icon with scale animation
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.amber.withOpacity(0.6), width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.amber.withOpacity(0.3),
                            blurRadius: 30,
                            spreadRadius: 5,
                          )
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(widget.emoji, style: const TextStyle(fontSize: 80)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Celebration texts
                  const Text(
                    'TUYỆT VỜI!',
                    style: TextStyle(
                      color: AppTheme.amber,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Hoàn Thành Tác Phẩm',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.modelName,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Stat Cards (Time, XP, Bonus)
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          icon: Icons.timer_outlined,
                          title: 'Thời gian',
                          value: widget.duration,
                          color: AppTheme.tealLight,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatItem(
                          icon: Icons.offline_bolt_rounded,
                          title: 'Kinh nghiệm',
                          value: '+${widget.xpEarned} XP',
                          color: AppTheme.amber,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Interactive upload photo area
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _hasUploadedImage = true;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('📸 Đã chụp ảnh thành phẩm thành công và lưu vào thư viện!'),
                          backgroundColor: AppTheme.teal,
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _hasUploadedImage ? AppTheme.teal : Colors.white.withOpacity(0.2),
                          style: _hasUploadedImage ? BorderStyle.solid : BorderStyle.solid,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _hasUploadedImage ? Icons.check_circle_rounded : Icons.add_a_photo_rounded,
                            color: _hasUploadedImage ? AppTheme.tealLight : Colors.white70,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _hasUploadedImage
                                ? 'Đã lưu ảnh thành phẩm'
                                : 'Chụp ảnh khoe thành phẩm của bạn',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Bottom Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _hasShared = true;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('🔗 Link chia sẻ đã được sao chép vào bộ nhớ tạm!'),
                                backgroundColor: AppTheme.indigoLight,
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white38),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            foregroundColor: Colors.white,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.share_outlined, size: 18),
                              const SizedBox(width: 8),
                              Text(_hasShared ? 'Đã chia sẻ' : 'Chia sẻ'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            // Pop tutorial flow back to HomeScreen
                            Navigator.of(context).popUntil((route) => route.isFirst);
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: AppTheme.teal,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Về Trang Chủ', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
