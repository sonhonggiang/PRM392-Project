import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/api_service.dart';
import '../../../models/user_model.dart';
import '../../origami/origami_detail_screen.dart';
import '../my_learning_screen.dart';

class ExploreTab extends StatefulWidget {
  const ExploreTab({super.key});

  @override
  State<ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends State<ExploreTab> {
  // 1. Quản lý trạng thái lọc và tìm kiếm
  String _selectedCategory = 'Tất cả';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Dữ liệu tải động từ API
  List<dynamic> _origamiModels = [];
  int _inProgressCount = 0;
  int _completedCount = 0;
  List<dynamic> _inProgressList = [];
  List<String> _downloadedIds = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Tải dữ liệu ban đầu
  Future<void> _loadInitialData() async {
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;
    final isGuest = user.role == UserRole.guest;

    setState(() => _isLoading = true);

    try {
      // Tải danh sách ID đã tải ngoại tuyến từ SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      _downloadedIds = prefs.getStringList('offline_models_ids') ?? [];

      // 1. Tải danh sách mẫu Origami theo bộ lọc hiện tại
      await _loadModels();

      // 2. Tải tiến trình tiếp tục học
      if (!isGuest) {
        final progressList = await ApiService.getProgress();
        final inProgList = [];
        int completed = 0;

        for (var prog in progressList) {
          if (prog['is_completed'] == 1 || prog['isCompleted'] == true) {
            completed++;
          } else {
            inProgList.add(prog);
          }
        }

        setState(() {
          _inProgressList = inProgList;
          _inProgressCount = inProgList.length;
          _completedCount = completed;
        });
      }
    } catch (e) {
      print('Lỗi tải dữ liệu ExploreTab: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Tải danh sách mẫu khi bộ lọc danh mục hoặc từ khóa thay đổi
  Future<void> _loadModels() async {
    final prefs = await SharedPreferences.getInstance();
    _downloadedIds = prefs.getStringList('offline_models_ids') ?? [];

    if (_selectedCategory == 'Đã tải về 📥') {
      final List<dynamic> offlineModels = [];
      for (var idStr in _downloadedIds) {
        final jsonStr = prefs.getString('offline_model_detail_$idStr');
        if (jsonStr != null) {
          try {
            offlineModels.add(jsonDecode(jsonStr));
          } catch (_) {}
        }
      }
      if (mounted) {
        setState(() {
          _origamiModels = offlineModels;
        });
      }
      return;
    }

    final categoryFilter = _selectedCategory == 'Tất cả' ? null : _selectedCategory;
    final list = await ApiService.getOrigamiList(
      category: categoryFilter,
      search: _searchQuery.trim().isEmpty ? null : _searchQuery,
    );
    if (mounted) {
      setState(() {
        _origamiModels = list;
      });
    }
  }

  // Xử lý khi click thay đổi danh mục
  Future<void> _onCategoryChanged(String categoryName) async {
    setState(() {
      _selectedCategory = categoryName;
      _isLoading = true;
    });
    await _loadModels();
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  // Xử lý khi nhập từ khóa tìm kiếm
  Future<void> _onSearchChanged(String query) async {
    setState(() {
      _searchQuery = query;
    });
    await _loadModels();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isGuest = auth.currentUser.role == UserRole.guest;

    return Column(
      children: [
        // Search Bar Section
        Container(
          color: AppTheme.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Tìm kiếm mẫu gấp giấy...',
              prefixIcon: const Icon(Icons.search, color: AppTheme.muted),
              suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      _onSearchChanged('');
                    })
                : null,
              filled: true,
              fillColor: AppTheme.bg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ),

        // Category Filters
        Container(
          color: AppTheme.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                'Tất cả', 'Động vật', 'Hoa cỏ', 'Đồ vật', 'Đã tải về 📥'
              ].map((cat) => _buildFilterChip(cat, _selectedCategory == cat)).toList(),
            ),
          ),
        ),

        // Grid View
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppTheme.teal))
              : _origamiModels.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _loadInitialData,
                      color: AppTheme.teal,
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          // --- Tiếp tục học (chỉ hiện khi không search và đã đăng nhập) ---
                          if (_searchQuery.isEmpty && !isGuest && _inProgressList.isNotEmpty) ...[
                            _buildContinueLearningSection(context),
                            const SizedBox(height: 20),
                          ],

                          // --- Grid tất cả mẫu ---
                          Text(
                            _searchQuery.isEmpty ? 'Tất cả mẫu gấp' : 'Kết quả tìm kiếm',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.indigo),
                          ),
                          const SizedBox(height: 12),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.82,
                            ),
                            itemCount: _origamiModels.length,
                            itemBuilder: (context, index) {
                              final item = _origamiModels[index];
                              return _buildOrigamiCard(
                                context,
                                item['id'],
                                item['name'] ?? '',
                                item['emoji'] ?? '📄',
                                item['difficulty'] ?? 'Dễ',
                                (item['rating'] ?? 0.0).toString(),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
        ),
      ],
    );
  }

  // ── Phần "Tiếp tục học" → navigate sang MyLearningScreen ───────────────
  Widget _buildContinueLearningSection(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MyLearningScreen()),
      ).then((_) => _loadInitialData()),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.indigo, AppTheme.indigoMid],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: AppTheme.indigo.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            // Stack emoji của các mẫu đang học
            SizedBox(
              width: 60,
              height: 40,
              child: Stack(
                children: [
                  ..._inProgressList.take(3).toList().asMap().entries.map((e) {
                    final idx = e.key;
                    final item = e.value;
                    return Positioned(
                      left: idx * 15.0,
                      child: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
                        ),
                        child: Center(child: Text(item['emoji'] ?? '📄', style: const TextStyle(fontSize: 16))),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tiếp tục học',
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(
                    '$_inProgressCount mẫu đang làm dở • $_completedCount đã hoàn thành',
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🔍', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            'Không tìm thấy mẫu nào cho "$_searchQuery"',
            style: const TextStyle(color: AppTheme.muted),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () => _onCategoryChanged(label),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.indigo : AppTheme.bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppTheme.indigo : AppTheme.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.text,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildOrigamiCard(BuildContext context, int id, String name, String emoji, String rating, String difficulty) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => OrigamiDetailScreen(origamiId: id)),
        ).then((_) => _loadInitialData());
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
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
                child: Stack(
                  children: [
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: AppTheme.amber, size: 10),
                          const SizedBox(width: 2),
                          Text(rating, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.amber)),
                        ],
                      ),
                    ),
                    Center(
                      child: Text(emoji, style: const TextStyle(fontSize: 48)),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Độ khó: $difficulty',
                    style: const TextStyle(fontSize: 10, color: AppTheme.muted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
