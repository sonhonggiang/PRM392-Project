import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme.dart';
import '../../core/services/api_service.dart';
import '../origami/origami_detail_screen.dart';

class CreatorProfileScreen extends StatefulWidget {
  final String creatorName;
  final int creatorId;

  const CreatorProfileScreen({
    super.key,
    required this.creatorName,
    required this.creatorId,
  });

  @override
  State<CreatorProfileScreen> createState() => _CreatorProfileScreenState();
}

class _CreatorProfileScreenState extends State<CreatorProfileScreen> {
  bool _isFollowing = false;
  int _followersCount = 1250; // Mẫu số lượng người theo dõi
  List<dynamic> _creatorModels = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCreatorData();
  }

  Future<void> _loadCreatorData() async {
    setState(() => _isLoading = true);
    try {
      // 1. Tải trạng thái theo dõi từ SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      _isFollowing = prefs.getBool('is_following_creator_${widget.creatorId}') ?? false;
      if (_isFollowing) {
        _followersCount++; // Tăng thêm 1 nếu đang follow
      }

      // 2. Lọc danh sách các mẫu của tác giả này từ API danh sách chung
      final allModels = await ApiService.getOrigamiList();
      _creatorModels = allModels.where((m) => 
        m['creator_id'] == widget.creatorId || 
        m['creatorId'] == widget.creatorId ||
        m['display_name'] == widget.creatorName
      ).toList();

    } catch (e) {
      print('Lỗi tải thông tin người sáng tạo: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleFollow() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isFollowing = !_isFollowing;
      if (_isFollowing) {
        _followersCount++;
      } else {
        _followersCount--;
      }
    });

    await prefs.setBool('is_following_creator_${widget.creatorId}', _isFollowing);

    if (_isFollowing && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🔔 Bạn đã theo dõi ${widget.creatorName}! Sẽ nhận được thông báo khi có mẫu mới.'),
          backgroundColor: AppTheme.teal,
        ),
      );

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Hồ sơ người sáng tạo', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.indigo)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppTheme.indigo,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.teal))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 1. Creator Avatar
                  Container(
                    width: 90, height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.indigo.withOpacity(0.1),
                      border: Border.all(color: AppTheme.indigoLight, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        widget.creatorName.isNotEmpty ? widget.creatorName[0].toUpperCase() : 'C',
                        style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: AppTheme.indigo),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 2. Creator Name
                  Text(
                    widget.creatorName,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.indigo),
                  ),
                  const SizedBox(height: 4),
                  
                  // Role Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.teal.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('🎨 CREATOR', style: TextStyle(color: AppTheme.teal, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 16),

                  // 3. Stats (Pinterest style)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatColumn('4.9 ★', 'Đánh giá'),
                      _buildStatDivider(),
                      _buildStatColumn('${_creatorModels.length} mẫu', 'Đăng tải'),
                      _buildStatDivider(),
                      _buildStatColumn('15.4k', 'Lượt xem'),
                      _buildStatDivider(),
                      _buildStatColumn('$_followersCount', 'Theo dõi'),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 4. Follow Button
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 160,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: _toggleFollow,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isFollowing ? AppTheme.white : AppTheme.indigo,
                        foregroundColor: _isFollowing ? AppTheme.indigo : Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                          side: BorderSide(color: AppTheme.indigo, width: _isFollowing ? 1.5 : 0),
                        ),
                      ),
                      child: Text(
                        _isFollowing ? 'Đang theo dõi' : 'Theo dõi',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 5. Portfolio Section (Pinterest Grid of Models)
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Tác phẩm đã đăng',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.indigo),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  _creatorModels.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Text('Người sáng tạo này chưa đăng mẫu nào 🎨', style: TextStyle(color: AppTheme.muted)),
                          ),
                        )
                      : GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.85,
                          ),
                          itemCount: _creatorModels.length,
                          itemBuilder: (context, index) {
                            final item = _creatorModels[index];
                            return GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => OrigamiDetailScreen(origamiId: item['id']),
                                ),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppTheme.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppTheme.border),
                                  boxShadow: const [
                                    BoxShadow(color: Color(0x0D1A2F6E), blurRadius: 12, offset: Offset(0, 4)),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        width: double.infinity,
                                        decoration: const BoxDecoration(
                                          color: AppTheme.bg,
                                          borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                                        ),
                                        child: Center(child: Text(item['emoji'] ?? '📄', style: const TextStyle(fontSize: 44))),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['name'] ?? '',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Text(item['difficulty'] ?? 'Dễ', style: const TextStyle(fontSize: 10, color: AppTheme.muted)),
                                              const Spacer(),
                                              const Icon(Icons.star, color: AppTheme.amber, size: 12),
                                              const SizedBox(width: 2),
                                              Text((item['rating'] ?? 5.0).toString(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                        ],
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

  Widget _buildStatColumn(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.indigo)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.muted)),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(width: 1, height: 24, color: AppTheme.border);
  }
}
