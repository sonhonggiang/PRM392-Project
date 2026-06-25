import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../home/tabs/profile_tab.dart'; // To reuse BadgeData and allBadges list

class AnalyticsBadgesScreen extends StatelessWidget {
  const AnalyticsBadgesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Separate earned and locked badges
    final earned = allBadges.where((b) => b.earned).toList();
    final locked = allBadges.where((b) => !b.earned).toList();

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
          'Thống kê & Huy hiệu',
          style: TextStyle(color: AppTheme.indigo, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Phần Thống kê ──────────────────────────────────────────────
            const Text(
              'Thống kê học tập',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.indigo),
            ),
            const SizedBox(height: 12),

            // Card Biểu đồ học tập
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.border),
                boxShadow: const [
                  BoxShadow(color: Color(0x0A1A2F6E), blurRadius: 10, offset: Offset(0, 4))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Thời gian luyện tập tuần này (phút)',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.text),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tổng cộng: 120 phút (Đạt mục tiêu 🔥)',
                    style: TextStyle(fontSize: 12, color: AppTheme.muted),
                  ),
                  const SizedBox(height: 24),
                  
                  // Custom Bar Chart
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildBar(day: 'T2', heightFactor: 0.15, minutes: '5m', isToday: false),
                      _buildBar(day: 'T3', heightFactor: 0.50, minutes: '25m', isToday: false),
                      _buildBar(day: 'T4', heightFactor: 0.30, minutes: '15m', isToday: false),
                      _buildBar(day: 'T5', heightFactor: 0.85, minutes: '45m', isToday: true),
                      _buildBar(day: 'T6', heightFactor: 0.00, minutes: '0m', isToday: false),
                      _buildBar(day: 'T7', heightFactor: 0.60, minutes: '30m', isToday: false),
                      _buildBar(day: 'CN', heightFactor: 0.00, minutes: '0m', isToday: false),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Card phân chia Danh mục
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.border),
                boxShadow: const [
                  BoxShadow(color: Color(0x0A1A2F6E), blurRadius: 10, offset: Offset(0, 4))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tỷ lệ thể loại Origami đã học',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.text),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      // Circular chart simulation using Stack
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: CircularProgressIndicator(
                                value: 1.0,
                                strokeWidth: 10,
                                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.indigo.withOpacity(0.1)),
                              ),
                            ),
                            Positioned.fill(
                              child: CircularProgressIndicator(
                                value: 0.8,
                                strokeWidth: 10,
                                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.teal),
                              ),
                            ),
                            Positioned.fill(
                              child: CircularProgressIndicator(
                                value: 0.5,
                                strokeWidth: 10,
                                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.amber),
                              ),
                            ),
                            Positioned.fill(
                              child: CircularProgressIndicator(
                                value: 0.2,
                                strokeWidth: 10,
                                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.red),
                              ),
                            ),
                            const Center(
                              child: Text(
                                '3 Nhóm',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.indigo),
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      // Legend items
                      Expanded(
                        child: Column(
                          children: [
                            _buildLegendItem(label: 'Động vật (50%)', color: AppTheme.teal, count: '6 mẫu'),
                            const SizedBox(height: 8),
                            _buildLegendItem(label: 'Đồ vật (30%)', color: AppTheme.amber, count: '4 mẫu'),
                            const SizedBox(height: 8),
                            _buildLegendItem(label: 'Hoa cỏ (20%)', color: AppTheme.red, count: '2 mẫu'),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ─── Phần Huy hiệu ──────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Bộ sưu tập Huy hiệu',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.indigo),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.amber.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Đã đạt: ${earned.length}/${allBadges.length}',
                    style: const TextStyle(color: AppTheme.amber, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Grid view of all badges
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: allBadges.length,
              itemBuilder: (context, i) {
                final badge = allBadges[i];
                return GestureDetector(
                  onTap: () => _showBadgeDetail(context, badge),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: badge.earned ? badge.color.withOpacity(0.4) : AppTheme.border,
                        width: badge.earned ? 2 : 1,
                      ),
                      boxShadow: const [
                        BoxShadow(color: Color(0x051A2F6E), blurRadius: 6, offset: Offset(0, 2))
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        badge.earned
                            ? Text(badge.emoji, style: const TextStyle(fontSize: 34))
                            : const Icon(Icons.lock_outline_rounded, color: AppTheme.muted, size: 30),
                        const SizedBox(height: 8),
                        Text(
                          badge.name,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: badge.earned ? AppTheme.text : AppTheme.muted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          badge.earned ? 'Đã nhận' : 'Khóa',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: badge.earned ? AppTheme.teal : AppTheme.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBar({required String day, required double heightFactor, required String minutes, required bool isToday}) {
    return Column(
      children: [
        Text(minutes, style: TextStyle(fontSize: 9, color: isToday ? AppTheme.teal : AppTheme.muted)),
        const SizedBox(height: 6),
        Container(
          width: 14,
          height: 100,
          decoration: BoxDecoration(
            color: AppTheme.gray,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FractionallySizedBox(
                heightFactor: heightFactor,
                child: Container(
                  width: 14,
                  decoration: BoxDecoration(
                    color: isToday ? AppTheme.teal : AppTheme.indigoLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          day,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            color: isToday ? AppTheme.teal : AppTheme.text,
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem({required String label, required Color color, required String count}) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.text),
          ),
        ),
        Text(
          count,
          style: const TextStyle(fontSize: 11, color: AppTheme.muted),
        ),
      ],
    );
  }

  void _showBadgeDetail(BuildContext context, BadgeData b) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              b.earned
                  ? Text(b.emoji, style: const TextStyle(fontSize: 56))
                  : const Icon(Icons.lock_rounded, size: 56, color: AppTheme.muted),
              const SizedBox(height: 16),
              Text(b.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.indigo)),
              const SizedBox(height: 8),
              Text(b.description, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.muted, fontSize: 13, height: 1.4)),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: b.earned ? AppTheme.teal.withOpacity(0.1) : AppTheme.gray,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  b.earned ? '✅ Đã hoàn thành' : '🔒 Chưa đạt điều kiện',
                  style: TextStyle(
                    color: b.earned ? AppTheme.teal : AppTheme.muted,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Đóng'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
