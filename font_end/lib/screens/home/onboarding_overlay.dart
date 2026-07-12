import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme.dart';
import '../../core/providers/auth_provider.dart';

class OnboardingStep {
  final String title;
  final String description;
  final String emoji;
  final int tabIndex;

  OnboardingStep({
    required this.title,
    required this.description,
    required this.emoji,
    required this.tabIndex,
  });
}

class OnboardingOverlay extends StatefulWidget {
  final VoidCallback onCompleted;
  final Function(int) onStepChanged;

  const OnboardingOverlay({
    super.key,
    required this.onCompleted,
    required this.onStepChanged,
  });

  @override
  State<OnboardingOverlay> createState() => _OnboardingOverlayState();
}

class _OnboardingOverlayState extends State<OnboardingOverlay> {
  int _currentStepIndex = 0;

  final List<OnboardingStep> _steps = [
    OnboardingStep(
      title: 'Trang chủ (Home)',
      description: 'Nơi theo dõi chuỗi ngày học tập (Streak 🔥), tham gia Thử thách hàng ngày nhận quà và xem các mẫu gấp nổi bật nhất.',
      emoji: '🏠',
      tabIndex: 0,
    ),
    OnboardingStep(
      title: 'Nhiệm vụ & Sự kiện',
      description: 'Làm các Nhiệm vụ hàng ngày nhận XP, sưu tầm Bộ sưu tập (Bách Thú, Floral, Đồ Vật) và hoàn thành các Chiến dịch gấp giấy đặc biệt để thăng cấp cực nhanh.',
      emoji: '🎖️',
      tabIndex: 0,
    ),
    OnboardingStep(
      title: 'Khám phá (Explore)',
      description: 'Tìm kiếm và lọc các mẫu Origami. Hỗ trợ Tải ngoại tuyến (Offline Mode) giúp bạn lưu và học gấp không cần kết nối mạng!',
      emoji: '📚',
      tabIndex: 1,
    ),
    OnboardingStep(
      title: 'Yêu thích (Favorites)',
      description: 'Lưu trữ nhanh các mẫu Origami bạn yêu thích để dễ dàng luyện tập lại bất cứ khi nào bạn muốn.',
      emoji: '⭐',
      tabIndex: 2,
    ),
    OnboardingStep(
      title: 'Góc Sáng Tạo (Creator)',
      description: 'Đóng đóng các mẫu gấp của riêng bạn! Tính năng này sẽ được mở khóa khi bạn đạt tối thiểu 1,000 XP hoặc là Admin.',
      emoji: '✍️',
      tabIndex: 3,
    ),
    OnboardingStep(
      title: 'Thành tựu (Achievements)',
      description: 'Theo dõi bảng xếp hạng, huy chương và khám phá Cây kỹ năng (Skill Tree) phân nhánh cấp độ cực kỳ trực quan.',
      emoji: '🏆',
      tabIndex: 4,
    ),
    OnboardingStep(
      title: 'Hồ sơ cá nhân (Profile)',
      description: 'Quản lý tài khoản, theo dõi Nhật ký học tập (Study Log) hôm nay/tuần này và chat hỗ trợ trực tiếp với Admin.',
      emoji: '👤',
      tabIndex: 5,
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Gọi callback để đổi tab đầu tiên cho khớp
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onStepChanged(_steps[_currentStepIndex].tabIndex);
    });
  }

  void _nextStep() {
    if (_currentStepIndex < _steps.length - 1) {
      setState(() {
        _currentStepIndex++;
      });
      widget.onStepChanged(_steps[_currentStepIndex].tabIndex);
    } else {
      _completeOnboarding();
    }
  }

  void _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;
    final key = 'has_completed_onboarding_${user.email.isNotEmpty ? user.email : "guest"}';
    await prefs.setBool(key, true);
    widget.onCompleted();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    // Tính toán tọa độ X, Y và bán kính của vùng nổi bật
    final isMiddleHighlight = _currentStepIndex == 1;
    final double centerX;
    final double centerY;
    final double holeRadius;

    if (isMiddleHighlight) {
      centerX = size.width / 2;
      centerY = size.height * 0.55;
      holeRadius = 140.0;
    } else {
      final bottomIndex = _currentStepIndex > 1 ? _currentStepIndex - 1 : _currentStepIndex;
      final itemWidth = size.width / 6;
      centerX = itemWidth * bottomIndex + itemWidth / 2;
      centerY = size.height - 45 - bottomPadding;
      holeRadius = 36.0;
    }
    
    final currentStep = _steps[_currentStepIndex];

    return Stack(
      children: [
        // Dark Overlay with Hole
        IgnorePointer(
          ignoring: false,
          child: CustomPaint(
            size: size,
            painter: HolePainter(
              centerX: centerX,
              centerY: centerY,
              holeRadius: holeRadius,
            ),
          ),
        ),
        
        // Coach Mark Popup Card
        Positioned(
          left: 20,
          right: 20,
          top: isMiddleHighlight ? MediaQuery.of(context).padding.top + 20 : null,
          bottom: isMiddleHighlight ? null : bottomPadding + 95, // Vị trí nằm ngay phía trên thanh NavigationBar
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  )
                ],
                border: Border.all(color: AppTheme.indigoLight.withOpacity(0.3), width: 1),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header: Icon + Title + Skip button
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.indigo.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          currentStep.emoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          currentStep.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.indigo,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _completeOnboarding,
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.muted,
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(50, 30),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Bỏ qua',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Description
                  Text(
                    currentStep.description,
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: AppTheme.text,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Bottom Actions: Step indicators & Next button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Step Indicators
                      Row(
                        children: List.generate(_steps.length, (index) {
                          final isActive = index == _currentStepIndex;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: isActive ? 16 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: isActive ? AppTheme.teal : AppTheme.border,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          );
                        }),
                      ),
                      
                      // Next Button
                      ElevatedButton(
                        onPressed: _nextStep,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.teal,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _currentStepIndex == _steps.length - 1 ? 'Hoàn thành' : 'Tiếp theo',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.arrow_forward_rounded, size: 14),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class HolePainter extends CustomPainter {
  final double centerX;
  final double centerY;
  final double holeRadius;

  HolePainter({
    required this.centerX,
    required this.centerY,
    required this.holeRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.65)
      ..style = PaintingStyle.fill;

    // Vẽ hình nền tối có đục một lỗ tròn tại vùng chọn
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addOval(Rect.fromCircle(center: Offset(centerX, centerY), radius: holeRadius))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);

    // Vẽ viền nét đứt/vòng tròn xanh ngọc bích để tăng thẩm mỹ
    final borderPaint = Paint()
      ..color = AppTheme.teal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawCircle(Offset(centerX, centerY), holeRadius + 2, borderPaint);
  }

  @override
  bool shouldRepaint(covariant HolePainter oldDelegate) {
    return oldDelegate.centerX != centerX ||
        oldDelegate.centerY != centerY ||
        oldDelegate.holeRadius != holeRadius;
  }
}
