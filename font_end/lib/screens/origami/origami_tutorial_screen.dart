import 'package:flutter/material.dart';
import '../../core/theme.dart';

class OrigamiTutorialScreen extends StatefulWidget {
  const OrigamiTutorialScreen({super.key});

  @override
  State<OrigamiTutorialScreen> createState() => _OrigamiTutorialScreenState();
}

class _OrigamiTutorialScreenState extends State<OrigamiTutorialScreen> {
  int _currentStep = 1;
  final int _totalSteps = 18;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            // Show confirm dialog
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Thoát hướng dẫn?'),
                content: const Text('Tiến độ của bạn sẽ được lưu lại.'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tiếp tục học')),
                  FilledButton(
                    onPressed: () {
                      Navigator.pop(ctx); // Close dialog
                      Navigator.pop(context); // Close screen
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
            Text('Bước $_currentStep / $_totalSteps', style: const TextStyle(fontSize: 14, color: AppTheme.indigo, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            SizedBox(
              width: 150,
              child: LinearProgressIndicator(
                value: _currentStep / _totalSteps,
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
              color: AppTheme.teal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('⏱️ 08:24', style: TextStyle(color: AppTheme.teal, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Interactive Area
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
                child: const Center(
                  // Placeholder for 3D/Zoomable Image
                  child: Text('🦢', style: TextStyle(fontSize: 120)),
                ),
              ),
            ),
            
            // Text Instructions
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
                      'Gấp chéo góc trái lên trên',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.indigo,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Gấp góc dưới bên trái lên sao cho mép giấy trùng khít với mép trên. Nhấn chặt để tạo nếp gấp cơ bản chuẩn xác.',
                      style: TextStyle(color: AppTheme.text, height: 1.5),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.amber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.amber.withOpacity(0.3)),
                      ),
                      child: const Row(
                        children: [
                          Text('💡', style: TextStyle(fontSize: 16)),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Dùng móng tay miết mạnh để nếp gấp sắc, giúp các bước sau dễ dàng hơn.',
                              style: TextStyle(fontSize: 12, color: AppTheme.amber),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    
                    // Navigation
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _currentStep > 1 ? () {
                              setState(() {
                                _currentStep--;
                              });
                            } : null,
                            child: const Text('← Trước'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              if (_currentStep < _totalSteps) {
                                setState(() {
                                  _currentStep++;
                                });
                              } else {
                                // Navigate to Complete Screen S-18
                              }
                            },
                            child: Text(_currentStep < _totalSteps ? 'Tiếp →' : 'Hoàn thành 🏆'),
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
