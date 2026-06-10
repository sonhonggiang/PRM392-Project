import 'package:flutter/material.dart';
import '../../core/theme.dart';
import 'origami_tutorial_screen.dart'; // We'll create this next

class OrigamiDetailScreen extends StatelessWidget {
  const OrigamiDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.8),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppTheme.indigo),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.8),
              child: IconButton(
                icon: const Icon(Icons.favorite_border, color: AppTheme.red),
                onPressed: () {},
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.8),
              child: IconButton(
                icon: const Icon(Icons.share_outlined, color: AppTheme.indigo),
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100), // Space for bottom button
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Header (Mock placeholder)
                Container(
                  height: 300,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.indigoLight, AppTheme.indigoMid],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: const Center(
                    child: Text('🦢', style: TextStyle(fontSize: 120)),
                  ),
                ),
                
                // Content
                Transform.translate(
                  offset: const Offset(0, -24),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppTheme.bg,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title & Rating
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Expanded(
                                child: Text(
                                  'Hạc giấy Nhật Bản',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.indigo,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.amber.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.star, color: AppTheme.amber, size: 16),
                                    SizedBox(width: 4),
                                    Text(
                                      '4.7',
                                      style: TextStyle(
                                        color: AppTheme.amber,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Chips
                          Row(
                            children: [
                              _buildTagChip('🐦 Động vật', AppTheme.indigo),
                              const SizedBox(width: 8),
                              _buildTagChip('⭐⭐⭐ Trung cấp', AppTheme.amber),
                              const SizedBox(width: 8),
                              _buildTagChip('⏱️ 25 phút', AppTheme.teal),
                            ],
                          ),
                          const SizedBox(height: 24),
                          
                          // Description
                          const Text(
                            'Hạc giấy (Orizuru) là một trong những mẫu Origami cổ điển và phổ biến nhất, tượng trưng cho niềm hy vọng và sự an lành.',
                            style: TextStyle(color: AppTheme.muted, height: 1.5),
                          ),
                          const SizedBox(height: 24),
                          
                          // Info Cards
                          Row(
                            children: [
                              Expanded(child: _buildInfoCard('📐 Cỡ giấy', '20×20cm')),
                              const SizedBox(width: 12),
                              Expanded(child: _buildInfoCard('📄 Loại giấy', 'Washi')),
                              const SizedBox(width: 12),
                              Expanded(child: _buildInfoCard('🎨 Màu sắc', 'Đỏ/Trắng')),
                            ],
                          ),
                          const SizedBox(height: 32),
                          
                          // Steps Preview
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                '18 bước hướng dẫn',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.indigo,
                                ),
                              ),
                              TextButton(
                                onPressed: () {},
                                style: TextButton.styleFrom(foregroundColor: AppTheme.teal),
                                child: const Text('Xem tất cả'),
                              )
                            ],
                          ),
                          const SizedBox(height: 12),
                          
                          // Step horizontal list
                          SizedBox(
                            height: 120,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: 4,
                              itemBuilder: (context, index) {
                                return _buildStepPreview(index + 1);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Sticky Bottom Button
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.white,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.indigo.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  )
                ],
              ),
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const OrigamiTutorialScreen()),
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.teal,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('🎯 Bắt đầu Gấp', style: TextStyle(fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.muted)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.indigo)),
        ],
      ),
    );
  }

  Widget _buildStepPreview(int stepNum) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Bước $stepNum', style: const TextStyle(fontSize: 10, color: AppTheme.muted, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('🦢', style: TextStyle(fontSize: 32)),
        ],
      ),
    );
  }
}
