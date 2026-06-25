import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../core/providers/auth_provider.dart';
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

  // 2. Danh sách dữ liệu đầy đủ
  final List<Map<String, dynamic>> _origamiModels = const [
    {'name': 'Hoa Hồng', 'emoji': '🌺', 'rating': '⭐⭐⭐', 'likes': '1.2k', 'category': 'Hoa cỏ'},
    {'name': 'Hạc Giấy', 'emoji': '🦢', 'rating': '⭐⭐⭐⭐', 'likes': '2.5k', 'category': 'Động vật'},
    {'name': 'Rồng Lửa', 'emoji': '🐲', 'rating': '⭐⭐⭐⭐⭐', 'likes': '5.0k', 'category': 'Động vật'},
    {'name': 'Máy Bay', 'emoji': '✈️', 'rating': '⭐⭐', 'likes': '800', 'category': 'Đồ vật'},
    {'name': 'Con Ếch', 'emoji': '🐸', 'rating': '⭐⭐⭐', 'likes': '1.1k', 'category': 'Động vật'},
    {'name': 'Trái Tim', 'emoji': '❤️', 'rating': '⭐⭐', 'likes': '3.2k', 'category': 'Đồ vật'},
    {'name': 'Cá Vàng', 'emoji': '🐠', 'rating': '⭐⭐⭐⭐', 'likes': '1.8k', 'category': 'Động vật'},
    {'name': 'Khủng Long', 'emoji': '🦖', 'rating': '⭐⭐⭐⭐⭐', 'likes': '4.1k', 'category': 'Động vật'},
    {'name': 'Tháp Eiffel', 'emoji': '🗼', 'rating': '⭐⭐⭐⭐', 'likes': '900', 'category': 'Kiến trúc'},
    {'name': 'Cây Thông', 'emoji': '🌲', 'rating': '⭐⭐', 'likes': '1.5k', 'category': 'Hoa cỏ'},
  ];




  // 3. Logic lọc kép: Theo danh mục VÀ Theo từ khóa tìm kiếm
  List<Map<String, dynamic>> get _filteredModels {
    return _origamiModels.where((item) {
      final matchesCategory = _selectedCategory == 'Tất cả' || item['category'] == _selectedCategory;
      final matchesSearch = item['name'].toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _filteredModels;
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
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Tìm kiếm mẫu gấp giấy...',
              prefixIcon: const Icon(Icons.search, color: AppTheme.muted),
              suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      setState(() { _searchQuery = ''; });
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
                'Tất cả', 'Động vật', 'Hoa cỏ', 'Đồ vật', 'Kiến trúc'
              ].map((cat) => _buildFilterChip(cat, _selectedCategory == cat)).toList(),
            ),
          ),
        ),

        // Grid View với "Tiếp tục học" ở đầu
        Expanded(
          child: filteredList.isEmpty
            ? _buildEmptyState()
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // --- Tiếp tục học (chỉ hiện khi không search và đã đăng nhập) ---
                  if (_searchQuery.isEmpty && !isGuest) ...[
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
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final item = filteredList[index];
                      return _buildOrigamiCard(
                        context,
                        item['name'],
                        item['emoji'],
                        item['rating'],
                        item['likes'],
                      );
                    },
                  ),
                ],
              ),
        ),
      ],
    );
  }

  // ── Phần "Tiếp tục học" → navigate sang MyLearningScreen ───────────────
  Widget _buildContinueLearningSection(BuildContext context) {
    final inProgress = inProgressModels;
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MyLearningScreen()),
      ),
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
              width: 80,
              height: 50,
              child: Stack(
                children: [
                  ...inProgress.take(3).toList().asMap().entries.map((e) {
                    final idx = e.key;
                    final item = e.value;
                    return Positioned(
                      left: idx * 20.0,
                      child: Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
                        ),
                        child: Center(child: Text(item['emoji'], style: const TextStyle(fontSize: 20))),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tiếp tục học',
                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    '${inProgress.length} mẫu đang làm dở • ${completedModels.length} đã hoàn thành',
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
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
      onTap: () {
        setState(() {
          _selectedCategory = label;
        });
      },
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

  Widget _buildOrigamiCard(BuildContext context, String name, String emoji, String rating, String likes) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const OrigamiDetailScreen()),
        );
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
                      child: Text(rating, style: const TextStyle(fontSize: 10)),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.favorite, color: AppTheme.red, size: 12),
                      const SizedBox(width: 4),
                      Text(likes, style: const TextStyle(fontSize: 11, color: AppTheme.muted)),
                    ],
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
