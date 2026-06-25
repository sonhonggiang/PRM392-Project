import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/services/api_service.dart';

class AnalyticsBadgesScreen extends StatefulWidget {
  const AnalyticsBadgesScreen({super.key});

  @override
  State<AnalyticsBadgesScreen> createState() => _AnalyticsBadgesScreenState();
}

class _AnalyticsBadgesScreenState extends State<AnalyticsBadgesScreen> {
  List<dynamic> _weeklyChart = [];
  List<dynamic> _categoryStats = [];
  List<dynamic> _allBadges = [];
  bool _isLoading = true;
  int _totalDuration = 0;

  @override
  void initState() {
    super.initState();
    _loadAnalyticsData();
  }

  // Tải dữ liệu thống kê học tập và huy hiệu từ API
  Future<void> _loadAnalyticsData() async {
    setState(() => _isLoading = true);
    try {
      // 1. Tải thống kê biểu đồ cột tuần và biểu đồ tròn thể loại
      final analytics = await ApiService.getUserAnalytics();
      if (analytics != null) {
        _weeklyChart = analytics['weeklyChart'] ?? [];
        _categoryStats = analytics['categoryStats'] ?? [];
        
        // Tính tổng số phút học trong tuần
        _totalDuration = _weeklyChart.fold<int>(0, (sum, item) => sum + (item['duration'] as int));
      }

      // 2. Tải danh sách huy hiệu
      final badges = await ApiService.getUserBadges();
      _allBadges = badges;
    } catch (e) {
      print('Lỗi tải dữ liệu Analytics: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Hàm phụ trợ chuyển đổi từ định dạng ngày sang tên Thứ trong tiếng Việt
  String _getDayName(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      switch (date.weekday) {
        case DateTime.monday: return 'T2';
        case DateTime.tuesday: return 'T3';
        case DateTime.wednesday: return 'T4';
        case DateTime.thursday: return 'T5';
        case DateTime.friday: return 'T6';
        case DateTime.saturday: return 'T7';
        case DateTime.sunday: return 'CN';
        default: return '';
      }
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final earned = _allBadges.where((b) => b['earned'] == true).toList();

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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.teal))
          : RefreshIndicator(
              onRefresh: _loadAnalyticsData,
              color: AppTheme.teal,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
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

                    // Card Biểu đồ học tập tuần
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
                          Text(
                            'Tổng cộng: $_totalDuration phút ${_totalDuration >= 60 ? "(Đạt mục tiêu 🔥)" : ""}',
                            style: const TextStyle(fontSize: 12, color: AppTheme.muted),
                          ),
                          const SizedBox(height: 24),
                          
                          // Vẽ biểu đồ cột động dựa trên dữ liệu thật
                          _buildBarChart(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Card phân chia Danh mục (Pie Chart)
                    _buildCategorySection(),
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
                            'Đã đạt: ${earned.length}/${_allBadges.length}',
                            style: const TextStyle(color: AppTheme.amber, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Lưới hiển thị danh sách huy hiệu
                    _buildBadgesGrid(),
                  ],
                ),
              ),
            ),
    );
  }

  // Tự động tính toán tỷ lệ chiều cao của các cột biểu đồ
  Widget _buildBarChart() {
    if (_weeklyChart.isEmpty) {
      return const Center(child: Text('Chưa có dữ liệu học tập nào trong tuần', style: TextStyle(color: AppTheme.muted)));
    }

    // Tìm giá trị lớn nhất trong tuần để làm mốc tỷ lệ chiều cao
    int maxDuration = 0;
    for (var item in _weeklyChart) {
      final dur = item['duration'] as int;
      if (dur > maxDuration) maxDuration = dur;
    }

    final todayStr = DateTime.now().toISOString().split('T')[0];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: _weeklyChart.map<Widget>((item) {
        final date = item['date'].toString();
        final dayName = _getDayName(date);
        final duration = item['duration'] as int;
        
        final heightFactor = maxDuration == 0 ? 0.0 : duration / maxDuration;
        final isToday = date == todayStr;

        return _buildBar(
          day: dayName,
          heightFactor: heightFactor,
          minutes: '${duration}m',
          isToday: isToday,
        );
      }).toList(),
    );
  }

  Widget _buildBar({required String day, required double heightFactor, required String minutes, required bool isToday}) {
    // Giới hạn chiều cao biểu đồ tối thiểu 5% để vẫn vẽ được cột nhỏ nếu duration > 0
    final double displayHeightFactor = heightFactor == 0.0 ? 0.0 : (heightFactor < 0.05 ? 0.05 : heightFactor);
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
                heightFactor: displayHeightFactor,
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

  // Khối thông tin tỷ lệ thể loại gấp giấy
  Widget _buildCategorySection() {
    if (_categoryStats.isEmpty) {
      return const SizedBox.shrink();
    }

    final totalCompleted = _categoryStats.fold<int>(0, (sum, item) => sum + (item['count'] as int));

    // Colors mapping list
    final colors = [AppTheme.teal, AppTheme.amber, AppTheme.red, AppTheme.indigo];

    return Container(
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
              // Mô phỏng biểu đồ tròn bằng Stack indicator
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
                    // Vẽ các vành tròn đè lên nhau biểu thị tỷ lệ
                    ..._categoryStats.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final item = entry.value;
                      final count = item['count'] as int;
                      final ratio = totalCompleted == 0 ? 0.0 : count / totalCompleted;
                      final color = colors[idx % colors.length];

                      return Positioned.fill(
                        child: CircularProgressIndicator(
                          value: ratio,
                          strokeWidth: 10,
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                        ),
                      );
                    }).toList(),
                    Center(
                      child: Text(
                        '${_categoryStats.length} nhóm',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.indigo),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // Chú thích danh mục bên phải
              Expanded(
                child: Column(
                  children: _categoryStats.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final item = entry.value;
                    final category = item['category'] ?? 'Khác';
                    final count = item['count'] as int;
                    final percent = totalCompleted == 0 ? 0 : ((count / totalCompleted) * 100).round();
                    final color = colors[idx % colors.length];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: _buildLegendItem(
                        label: '$category ($percent%)',
                        color: color,
                        count: '$count mẫu',
                      ),
                    );
                  }).toList(),
                ),
              )
            ],
          ),
        ],
      ),
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

  // Danh sách lưới bộ sưu tập Huy hiệu
  Widget _buildBadgesGrid() {
    if (_allBadges.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Text('Không tìm thấy thông tin huy hiệu!', style: TextStyle(color: AppTheme.muted)),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: _allBadges.length,
      itemBuilder: (context, i) {
        final badge = _allBadges[i];
        final isEarned = badge['earned'] == true;
        final emoji = badge['emoji'] ?? '🏆';
        final name = badge['name'] ?? '';

        return GestureDetector(
          onTap: () => _showBadgeDetail(context, badge, isEarned),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isEarned ? AppTheme.teal.withOpacity(0.4) : AppTheme.border,
                width: isEarned ? 2 : 1,
              ),
              boxShadow: const [
                BoxShadow(color: Color(0x051A2F6E), blurRadius: 6, offset: Offset(0, 2))
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                isEarned
                    ? Text(emoji, style: const TextStyle(fontSize: 34))
                    : const Icon(Icons.lock_outline_rounded, color: AppTheme.muted, size: 30),
                const SizedBox(height: 8),
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isEarned ? AppTheme.text : AppTheme.muted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  isEarned ? 'Đã nhận' : 'Khóa',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: isEarned ? AppTheme.teal : AppTheme.muted,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showBadgeDetail(BuildContext context, dynamic b, bool isEarned) {
    final emoji = b['emoji'] ?? '🏆';
    final name = b['name'] ?? '';
    final description = b['description'] ?? '';

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              isEarned
                  ? Text(emoji, style: const TextStyle(fontSize: 56))
                  : const Icon(Icons.lock_rounded, size: 56, color: AppTheme.muted),
              const SizedBox(height: 16),
              Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.indigo)),
              const SizedBox(height: 8),
              Text(description, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.muted, fontSize: 13, height: 1.4)),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: isEarned ? AppTheme.teal.withOpacity(0.1) : AppTheme.gray,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isEarned ? '✅ Đã hoàn thành' : '🔒 Chưa đạt điều kiện',
                  style: TextStyle(
                    color: isEarned ? AppTheme.teal : AppTheme.muted,
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

// Hàm extension để lấy nhanh chuỗi yyyy-mm-dd
extension DateFormatting on DateTime {
  String toISOString() {
    return this.toIso8601String();
  }
}
