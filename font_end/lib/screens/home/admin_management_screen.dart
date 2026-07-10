import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../core/theme.dart';
import '../../core/services/api_service.dart';


class AdminManagementScreen extends StatefulWidget {
  const AdminManagementScreen({super.key});

  @override
  State<AdminManagementScreen> createState() => _AdminManagementScreenState();
}

class _AdminManagementScreenState extends State<AdminManagementScreen> {
  List<dynamic> _categories = [];
  List<dynamic> _users = [];
  List<dynamic> _origamiModels = [];
  bool _isLoading = true;
  final ImagePicker _picker = ImagePicker();


  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final cats = await ApiService.adminGetCategories();
    final users = await ApiService.adminGetUsers();
    final origami = await ApiService.adminGetOrigamiModels();
    setState(() {
      _categories = cats;
      _users = users;
      _origamiModels = origami;
      _isLoading = false;
    });
  }

  void _showCategoryDialog({dynamic category}) {
    final nameController = TextEditingController(text: category?['name'] ?? '');
    String? localImagePath;
    String? selectedPresetUrl = (category?['image_url'] != null && category['image_url'].toString().startsWith('http'))
        ? category['image_url'].toString()
        : null;

    // Các hình mẫu có sẵn
    final List<Map<String, String>> presets = [
      {
        'label': '🐰 Động vật',
        'url': 'https://images.unsplash.com/photo-1544816155-12df9643f363?q=80&w=200',
        'emoji': '🐰'
      },
      {
        'label': '🌸 Hoa cỏ',
        'url': 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?q=80&w=200',
        'emoji': '🌸'
      },
      {
        'label': '⛵ Đồ vật',
        'url': 'https://images.unsplash.com/photo-1457369804613-52c61a468e7d?q=80&w=200',
        'emoji': '⛵'
      },
      {
        'label': '🎨 Khác',
        'url': 'https://images.unsplash.com/photo-1490730141103-6cac27aaab94?q=80&w=200',
        'emoji': '🎨'
      },
    ];

    String? selectedEmoji = category?['emoji'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            category == null ? '➕ Thêm danh mục mới' : '✏️ Sửa danh mục',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.indigo),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Khung chọn ảnh từ thư viện
                GestureDetector(
                  onTap: () async {
                    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      setDialogState(() {
                        localImagePath = image.path;
                        selectedPresetUrl = null; // Huỷ preset nếu chọn ảnh thư viện
                      });
                    }
                  },
                  child: Container(
                    width: 110, height: 110,
                    decoration: BoxDecoration(
                      color: AppTheme.bg,
                      border: Border.all(color: AppTheme.border, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: localImagePath != null
                          ? Image.file(File(localImagePath!), fit: BoxFit.cover)
                          : (selectedPresetUrl != null && selectedPresetUrl!.isNotEmpty)
                              ? Image.network(
                                  selectedPresetUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => _placeholderPhoto(),
                                )
                              : _placeholderPhoto(),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Text('Nhấn khung ảnh để chọn từ Thư viện điện thoại', style: TextStyle(fontSize: 11, color: AppTheme.muted), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                
                // Chọn từ hình ảnh mẫu có sẵn
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Hoặc chọn hình mẫu có sẵn:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.indigo)),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: presets.map((preset) {
                    final isSelected = selectedPresetUrl == preset['url'];
                    return ChoiceChip(
                      label: Text(preset['label']!, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : AppTheme.text)),
                      selected: isSelected,
                      selectedColor: AppTheme.indigo,
                      backgroundColor: AppTheme.bg,
                      onSelected: (selected) {
                        if (selected) {
                          setDialogState(() {
                            selectedPresetUrl = preset['url'];
                            localImagePath = null;
                            selectedEmoji = preset['emoji'];
                            if (nameController.text.trim().isEmpty) {
                              nameController.text = preset['label']!.substring(2); // Tự điền tên ví dụ: Động vật
                            }
                          });
                        }
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Tên danh mục
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Tên danh mục *',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    prefixIcon: const Icon(Icons.category_outlined),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
            FilledButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) return;

                // Nếu chọn ảnh local, do backend lưu dạng URL nên ta sẽ gán link placeholder tương ứng,
                // hoặc sử dụng link của preset đã chọn.
                final String finalUrl = selectedPresetUrl ?? 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?q=80&w=200';
                final String emoji = selectedEmoji ?? '📁';

                bool success;
                if (category == null) {
                  success = await ApiService.adminAddCategory(name, emoji, imageUrl: finalUrl);
                } else {
                  success = await ApiService.adminUpdateCategory(
                    category['id'], name, emoji, imageUrl: finalUrl,
                  );
                }
                if (!mounted) return;
                if (success) {
                  Navigator.pop(context);
                  _loadData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(category == null ? '✅ Đã thêm danh mục!' : '✅ Đã cập nhật danh mục!'), backgroundColor: AppTheme.teal),
                  );
                }
              },
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }


  Widget _placeholderPhoto() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate_outlined, color: AppTheme.muted, size: 30),
        SizedBox(height: 4),
        Text('Chọn ảnh', style: TextStyle(fontSize: 11, color: AppTheme.muted)),
      ],
    );
  }

  void _showUserXpDialog(dynamic user) {
    final xpController = TextEditingController(text: user['xp'].toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Sửa XP: ${user['display_name']}'),
        content: TextField(
          controller: xpController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Điểm kinh nghiệm (XP)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            prefixIcon: const Icon(Icons.star),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          FilledButton(
            onPressed: () async {
              final newXp = int.tryParse(xpController.text) ?? 0;
              if (!mounted) return;
              if (await ApiService.adminUpdateUserXP(user['id'], newXp)) {
                Navigator.pop(context);
                _loadData();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ Đã cập nhật XP!'), backgroundColor: AppTheme.teal),
                );
              }
            },
            child: const Text('Cập nhật'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteOrigami(dynamic model) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('🗑️ Xóa mẫu Origami', style: TextStyle(color: AppTheme.red)),
        content: Text(
          'Bạn có chắc muốn xóa mẫu "${model['name']}"?\nHành động này không thể hoàn tác và sẽ xóa tất cả tiến trình của người dùng liên quan.',
          style: const TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final success = await ApiService.adminDeleteOrigami(model['id']);
      if (success && mounted) {
        _loadData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🗑️ Đã xóa mẫu Origami!'), backgroundColor: AppTheme.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppTheme.bg,
        appBar: AppBar(
          title: const Text('Quản lý hệ thống (Admin)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          backgroundColor: AppTheme.white,
          foregroundColor: AppTheme.indigo,
          elevation: 0,
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.category_outlined, size: 18), text: 'Danh mục'),
              Tab(icon: Icon(Icons.auto_awesome_outlined, size: 18), text: 'Mẫu gấp'),
              Tab(icon: Icon(Icons.people_outline, size: 18), text: 'Người dùng'),
            ],
            labelColor: AppTheme.indigo,
            indicatorColor: AppTheme.teal,
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.teal))
            : TabBarView(
                children: [
                  // ─── Tab 1: Danh mục ──────────────────────────────────────
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Danh mục hiện có', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.indigo)),
                            ElevatedButton.icon(
                              onPressed: () => _showCategoryDialog(),
                              icon: const Icon(Icons.add, size: 16),
                              label: const Text('Thêm mới'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.teal,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _categories.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final cat = _categories[index];
                            final hasImage = cat['image_url'] != null && cat['image_url'].toString().isNotEmpty && cat['image_url'].toString().startsWith('http');
                            return Container(
                              decoration: BoxDecoration(
                                color: AppTheme.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppTheme.border),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: hasImage
                                    ? Image.network(
                                        cat['image_url'],
                                        width: 44, height: 44, fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          width: 44, height: 44,
                                          color: AppTheme.bg,
                                          child: Center(child: Text(cat['emoji'] ?? '📁', style: const TextStyle(fontSize: 22))),
                                        ),
                                      )
                                    : Container(
                                        width: 44, height: 44,
                                        color: AppTheme.bg,
                                        child: Center(child: Text(cat['emoji'] ?? '📁', style: const TextStyle(fontSize: 22))),
                                      ),
                                ),
                                title: Text(cat['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text(hasImage ? 'Có hình ảnh' : 'Chưa có hình ảnh', style: const TextStyle(fontSize: 11, color: AppTheme.muted)),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined, color: AppTheme.amber, size: 20),
                                      onPressed: () => _showCategoryDialog(category: cat),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: AppTheme.red, size: 20),
                                      onPressed: () async {
                                        if (await ApiService.adminDeleteCategory(cat['id']) && mounted) {
                                          _loadData();
                                        }
                                      },
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

                  // ─── Tab 2: Mẫu Origami ───────────────────────────────────
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: Text('Danh sách mẫu gấp', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.indigo)),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.teal.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${_origamiModels.length} mẫu',
                                style: const TextStyle(color: AppTheme.teal, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (_origamiModels.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 40),
                              child: Text('Chưa có mẫu gấp nào', style: TextStyle(color: AppTheme.muted)),
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _origamiModels.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final model = _origamiModels[index];
                              final statusColor = model['status'] == 'approved' ? AppTheme.teal
                                  : model['status'] == 'rejected' ? AppTheme.red : AppTheme.amber;
                              final statusLabel = model['status'] == 'approved' ? 'Đã duyệt'
                                  : model['status'] == 'rejected' ? 'Từ chối' : 'Chờ duyệt';
                              return Container(
                                decoration: BoxDecoration(
                                  color: AppTheme.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppTheme.border),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                  leading: Container(
                                    width: 44, height: 44,
                                    decoration: BoxDecoration(color: AppTheme.bg, borderRadius: BorderRadius.circular(10)),
                                    child: Center(child: Text(model['emoji'] ?? '🎨', style: const TextStyle(fontSize: 22))),
                                  ),
                                  title: Text(model['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('${model['category_name'] ?? ''} • ${model['difficulty'] ?? ''}', style: const TextStyle(fontSize: 11, color: AppTheme.muted)),
                                      const SizedBox(height: 2),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: statusColor.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(statusLabel, style: TextStyle(fontSize: 10, color: statusColor, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete_outline, color: AppTheme.red, size: 22),
                                    onPressed: () => _confirmDeleteOrigami(model),
                                    tooltip: 'Xóa mẫu này',
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),

                  // ─── Tab 3: Người dùng ────────────────────────────────────
                  ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _users.length,
                    itemBuilder: (context, index) {
                      final u = _users[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.indigoLight,
                            child: Text((u['display_name'] ?? 'U')[0].toUpperCase(),
                              style: const TextStyle(color: AppTheme.indigo, fontWeight: FontWeight.bold)),
                          ),
                          title: Text(u['display_name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${u['email']} • ${u['xp'] ?? 0} XP', style: const TextStyle(fontSize: 11, color: AppTheme.muted)),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit_note, color: AppTheme.teal),
                            onPressed: () => _showUserXpDialog(u),
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
}
