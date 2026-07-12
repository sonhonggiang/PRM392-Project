import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme.dart';
import '../../core/services/api_service.dart';
import '../../core/providers/auth_provider.dart';
import '../../models/user_model.dart';
import 'origami_tutorial_screen.dart';
import '../home/creator_profile_screen.dart';

class OrigamiDetailScreen extends StatefulWidget {
  final int origamiId;
  final bool isDailyChallenge;
  const OrigamiDetailScreen({
    super.key,
    required this.origamiId,
    this.isDailyChallenge = false,
  });

  @override
  State<OrigamiDetailScreen> createState() => _OrigamiDetailScreenState();
}

class _OrigamiDetailScreenState extends State<OrigamiDetailScreen> {
  Map<String, dynamic>? _detailData;
  bool _isLoading = true;
  bool _isFavorite = false;
  bool _isDownloaded = false;
  List<Map<String, dynamic>> _localReviews = [];
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadModelDetail();
  }

  // Tải chi tiết mẫu Origami và kiểm tra trạng thái yêu thích
  Future<void> _loadModelDetail() async {
    setState(() => _isLoading = true);
    try {
      // 1. Tải chi tiết mẫu và các bước
      final detail = await ApiService.getOrigamiDetail(widget.origamiId);
      
      // 2. Kiểm tra xem mẫu này đã được yêu thích chưa
      final auth = context.read<AuthProvider>();
      bool isFav = false;
      if (auth.currentUser.role != UserRole.guest) {
        final favoritesList = await ApiService.getFavorites();
        isFav = favoritesList.any((item) => item['id'] == widget.origamiId);
      }

      setState(() {
        _detailData = detail;
        _isFavorite = isFav;
      });

      // 3. Kiểm tra trạng thái tải offline và danh sách đánh giá
      await _checkOfflineStatus();
      await _loadReviews();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Lỗi tải chi tiết Origami: $e');
      // Nếu mất mạng, thử tải dữ liệu offline từ cache
      try {
        final prefs = await SharedPreferences.getInstance();
        final jsonStr = prefs.getString('offline_model_detail_${widget.origamiId}');
        if (jsonStr != null) {
          setState(() {
            _detailData = jsonDecode(jsonStr);
            _isDownloaded = true;
          });
          await _loadReviews();
        }
      } catch (_) {}
      
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _checkOfflineStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final offlineIds = prefs.getStringList('offline_models_ids') ?? [];
    setState(() {
      _isDownloaded = offlineIds.contains(widget.origamiId.toString());
    });
  }

  Future<void> _downloadModelOffline() async {
    if (_detailData == null) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(color: AppTheme.teal),
            SizedBox(width: 20),
            Text('Đang tải mẫu về offline...', style: TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );

    await Future.delayed(const Duration(milliseconds: 1200));
    
    final prefs = await SharedPreferences.getInstance();
    final offlineIds = prefs.getStringList('offline_models_ids') ?? [];
    if (!offlineIds.contains(widget.origamiId.toString())) {
      offlineIds.add(widget.origamiId.toString());
      await prefs.setStringList('offline_models_ids', offlineIds);
    }
    await prefs.setString('offline_model_detail_${widget.origamiId}', jsonEncode(_detailData));

    if (mounted) {
      Navigator.pop(context); // Đóng progress dialog
      setState(() {
        _isDownloaded = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📥 Đã lưu ngoại tuyến! Bạn có thể học khi mất mạng.'),
          backgroundColor: AppTheme.teal,
        ),
      );
    }
  }

  Future<void> _loadReviews() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('reviews_for_model_${widget.origamiId}');
    if (jsonStr != null) {
      final List<dynamic> decoded = jsonDecode(jsonStr);
      setState(() {
        _localReviews = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      });
    } else {
      final defaults = [
        {
          'displayName': 'Nam Nguyễn',
          'rating': 5,
          'comment': 'Mẫu gấp rất đẹp và các bước xếp cực kỳ dễ làm theo!',
          'date': 'Hôm qua',
          'imageUrl': null,
        },
        {
          'displayName': 'Thùy Chi',
          'rating': 5,
          'comment': 'Mình gấp thành công rồi nhé! Đẹp cực kỳ luôn.',
          'date': '3 ngày trước',
          'imageUrl': null,
        }
      ];
      setState(() {
        _localReviews = defaults;
      });
    }
  }

  void _showAddReviewDialog() {
    final auth = context.read<AuthProvider>();
    if (auth.currentUser.role == UserRole.guest) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập để viết đánh giá!'), backgroundColor: AppTheme.amber),
      );
      return;
    }

    int selectedStars = 5;
    final commentController = TextEditingController();
    String? localImagePath;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('✍️ Viết đánh giá', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.indigo, fontSize: 16)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Chọn sao
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final isFilled = index < selectedStars;
                    return IconButton(
                      icon: Icon(
                        isFilled ? Icons.star_rounded : Icons.star_border_rounded,
                        color: AppTheme.amber,
                        size: 32,
                      ),
                      onPressed: () {
                        setDialogState(() {
                          selectedStars = index + 1;
                        });
                      },
                    );
                  }),
                ),
                const SizedBox(height: 12),
                
                // Nhận xét
                TextField(
                  controller: commentController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Nhập bình luận của bạn...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),

                // Đính kèm ảnh
                GestureDetector(
                  onTap: () async {
                    final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      setDialogState(() {
                        localImagePath = image.path;
                      });
                    }
                  },
                  child: Container(
                    height: 110,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppTheme.bg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.border, width: 1.5),
                    ),
                    child: localImagePath != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(11),
                            child: Image.file(File(localImagePath!), fit: BoxFit.cover),
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo_outlined, color: AppTheme.muted, size: 28),
                              SizedBox(height: 6),
                              Text('Đính kèm ảnh thực tế', style: TextStyle(fontSize: 11, color: AppTheme.muted)),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
            FilledButton(
              onPressed: () async {
                final comment = commentController.text.trim();
                if (comment.isEmpty) return;

                // Thêm review mới vào danh sách SharedPreferences
                final newReview = {
                  'displayName': auth.currentUser.displayName,
                  'rating': selectedStars,
                  'comment': comment,
                  'date': 'Hôm nay',
                  'imageUrl': localImagePath,
                };

                _localReviews.insert(0, newReview);
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('reviews_for_model_${widget.origamiId}', jsonEncode(_localReviews));

                // Cập nhật lên backend API
                await ApiService.rateOrigami(widget.origamiId, selectedStars);

                if (mounted) {
                  Navigator.pop(context);
                  _loadModelDetail(); // Tải lại chi tiết
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✅ Đã đăng đánh giá thành công!'), backgroundColor: AppTheme.teal),
                  );
                }
              },
              child: const Text('Gửi'),
            ),
          ],
        ),
      ),
    );
  }

  // Toggle favorite qua API
  Future<void> _handleFavoriteToggle() async {
    final auth = context.read<AuthProvider>();
    if (auth.currentUser.role == UserRole.guest) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đăng nhập để lưu vào danh sách yêu thích!'),
          backgroundColor: AppTheme.amber,
        ),
      );
      return;
    }

    try {
      final success = await ApiService.toggleFavorite(widget.origamiId);
      setState(() {
        _isFavorite = success;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Đã thêm vào yêu thích! ❤️' : 'Đã xóa khỏi yêu thích.'),
            backgroundColor: success ? AppTheme.teal : AppTheme.indigoMid,
          ),
        );
      }
    } catch (e) {
      print('Lỗi toggle yêu thích: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.bg,
        body: Center(child: CircularProgressIndicator(color: AppTheme.teal)),
      );
    }

    if (_detailData == null) {
      return Scaffold(
        appBar: AppBar(backgroundColor: AppTheme.white, elevation: 0),
        body: const Center(child: Text('Không tìm thấy thông tin mẫu Origami này!', style: TextStyle(color: AppTheme.muted))),
      );
    }

    final name = _detailData!['name'] ?? '';
    final emoji = _detailData!['emoji'] ?? '🦢';
    final difficulty = _detailData!['difficulty'] ?? 'Dễ';
    final time = '${_detailData!['estimated_time'] ?? _detailData!['estimatedTime'] ?? 10} phút';
    final paperSize = _detailData!['paper_size'] ?? _detailData!['paperSize'] ?? '15x15 cm';
    final paperType = _detailData!['paper_type'] ?? _detailData!['paperType'] ?? 'Washi';
    final rating = (_detailData!['rating'] ?? 0.0).toString();
    final category = _detailData!['category_name'] ?? 'Mẫu gấp';
    final steps = _detailData!['steps'] as List<dynamic>? ?? [];

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
          // Nút Tải về ngoại tuyến
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.8),
              child: IconButton(
                icon: Icon(
                  _isDownloaded ? Icons.offline_pin : Icons.download_for_offline,
                  color: _isDownloaded ? AppTheme.teal : AppTheme.indigoMid,
                ),
                onPressed: _isDownloaded 
                    ? () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Mẫu gấp đã được tải về để học ngoại tuyến!'))
                      )
                    : _downloadModelOffline,
                tooltip: 'Tải về ngoại tuyến',
              ),
            ),
          ),
          const SizedBox(width: 4),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.8),
              child: IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: AppTheme.red,
                ),
                onPressed: _handleFavoriteToggle,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100), // Khoảng trống cho nút bắt đầu gấp cố định ở đáy
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Header Gradient
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
                  child: Center(
                    child: Text(emoji, style: const TextStyle(fontSize: 120)),
                  ),
                ),
                
                // Nửa dưới chứa Content
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
                              Expanded(
                                child: Text(
                                  name,
                                  style: const TextStyle(
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
                                child: Row(
                                  children: [
                                    const Icon(Icons.star, color: AppTheme.amber, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      rating,
                                      style: const TextStyle(
                                        color: AppTheme.amber,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Text('Người tạo: ', style: TextStyle(fontSize: 12, color: AppTheme.muted)),
                              GestureDetector(
                                onTap: () {
                                  final creatorName = _detailData!['creator_name'] ?? _detailData!['creatorName'] ?? 'Quản trị viên';
                                  final creatorId = _detailData!['creator_id'] ?? _detailData!['creatorId'] ?? 1;
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CreatorProfileScreen(
                                        creatorName: creatorName,
                                        creatorId: creatorId,
                                      ),
                                    ),
                                  );
                                },
                                child: Text(
                                  _detailData!['creator_name'] ?? _detailData!['creatorName'] ?? 'Quản trị viên',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.indigo,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Chips Tags
                          Row(
                            children: [
                              _buildTagChip('📁 $category', AppTheme.indigo),
                              const SizedBox(width: 8),
                              _buildTagChip('⭐️ $difficulty', AppTheme.amber),
                              const SizedBox(width: 8),
                              _buildTagChip('⏱️ $time', AppTheme.teal),
                            ],
                          ),
                          const SizedBox(height: 24),
                          
                          // Mô tả
                          Text(
                            'Mẫu gấp Origami "$name" thuộc thể loại $category với độ khó cấp độ $difficulty. Hãy làm theo hướng dẫn từng bước chi tiết của chúng tôi để tự hoàn thiện tác phẩm bằng giấy tuyệt đẹp của riêng bạn!',
                            style: const TextStyle(color: AppTheme.muted, height: 1.5),
                          ),
                          const SizedBox(height: 24),
                          
                          // Info Cards thông số giấy
                          Row(
                            children: [
                              Expanded(child: _buildInfoCard('📐 Cỡ giấy', paperSize)),
                              const SizedBox(width: 12),
                              Expanded(child: _buildInfoCard('📄 Loại giấy', paperType)),
                              const SizedBox(width: 12),
                              Expanded(child: _buildInfoCard('🎨 Màu sắc', 'Tự do')),
                            ],
                          ),
                          const SizedBox(height: 32),
                          
                          // Sơ lược các bước
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${steps.length} bước hướng dẫn',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.indigo,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          
                          // Danh sách ngang xem trước các bước
                          steps.isEmpty
                              ? const Text('Chưa có danh sách bước gấp cụ thể.', style: TextStyle(color: AppTheme.muted))
                              : SizedBox(
                                  height: 120,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: steps.length,
                                    itemBuilder: (context, index) {
                                      final st = steps[index];
                                      final imgPath = st['image_url'] ?? st['imageUrl'] ?? '';
                                      return _buildStepPreview(index + 1, imgPath, emoji);
                                    },
                                  ),
                                ),
                          
                          const SizedBox(height: 32),

                          // ── ĐÁNH GIÁ CỦA CỘNG ĐỒNG (Photo Reviews) ─────────
                          _buildReviewsSection(),
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
                    MaterialPageRoute(
                      builder: (_) => OrigamiTutorialScreen(
                        origamiId: widget.origamiId,
                        steps: steps,
                        isDailyChallenge: widget.isDailyChallenge,
                        estimatedTimeMinutes: _detailData!['estimated_time'] ?? _detailData!['estimatedTime'] ?? 10,
                      ),
                    ),
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
          Text(
            value, 
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.indigo),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStepPreview(int stepNum, String imagePath, String modelEmoji) {
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
          const SizedBox(height: 6),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: imagePath.isEmpty
                  ? Center(child: Text(modelEmoji, style: const TextStyle(fontSize: 32)))
                  : imagePath.startsWith('http')
                      ? Image.network(
                          imagePath,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Center(child: Text(modelEmoji, style: const TextStyle(fontSize: 32))),
                        )
                      : Image.file(
                          File(imagePath),
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Center(child: Text(modelEmoji, style: const TextStyle(fontSize: 32))),
                        ),
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Đánh giá & Nhận xét (${_localReviews.length})',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.indigo),
            ),
            TextButton.icon(
              onPressed: _showAddReviewDialog,
              icon: const Icon(Icons.rate_review_outlined, size: 16, color: AppTheme.teal),
              label: const Text('Viết đánh giá', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.teal)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_localReviews.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Text('Chưa có đánh giá nào. Hãy là người đầu tiên xếp xong và đánh giá nhé!', style: TextStyle(color: AppTheme.muted, fontSize: 12)),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _localReviews.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final rev = _localReviews[index];
              final stars = rev['rating'] as int? ?? 5;
              final hasImage = rev['imageUrl'] != null && rev['imageUrl'].toString().isNotEmpty;

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: User & Rating
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          rev['displayName'] ?? 'Ẩn danh',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.indigo),
                        ),
                        Row(
                          children: List.generate(5, (starIdx) {
                            return Icon(
                              starIdx < stars ? Icons.star_rounded : Icons.star_border_rounded,
                              color: AppTheme.amber,
                              size: 14,
                            );
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Comment
                    Text(
                      rev['comment'] ?? '',
                      style: const TextStyle(fontSize: 12, color: AppTheme.text, height: 1.4),
                    ),

                    // Image Review (Nếu có)
                    if (hasImage) ...[
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          // Xem ảnh review chế độ full-screen
                          showDialog(
                            context: context,
                            builder: (context) => Dialog(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: rev['imageUrl'].toString().startsWith('http')
                                    ? Image.network(rev['imageUrl'])
                                    : Image.file(File(rev['imageUrl'])),
                              ),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: rev['imageUrl'].toString().startsWith('http')
                              ? Image.network(rev['imageUrl'], width: 120, height: 90, fit: BoxFit.cover)
                              : Image.file(File(rev['imageUrl']), width: 120, height: 90, fit: BoxFit.cover),
                        ),
                      ),
                    ],

                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        rev['date'] ?? 'Hôm nay',
                        style: const TextStyle(fontSize: 10, color: AppTheme.muted),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}
