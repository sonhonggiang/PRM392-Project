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
    setState(() {
      _categories = cats;
      _users = users;
      _isLoading = false;
    });
  }

  void _showCategoryDialog({dynamic category}) {
    final nameController = TextEditingController(text: category?['name'] ?? '');
    final emojiController = TextEditingController(text: category?['emoji'] ?? '');
    String? localImagePath;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(category == null ? 'Thêm danh mục' : 'Sửa danh mục'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Tên danh mục')),
              TextField(controller: emojiController, decoration: const InputDecoration(labelText: 'Emoji biểu tượng')),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () async {
                  final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    setDialogState(() => localImagePath = image.path);
                  }
                },
                child: Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(color: AppTheme.bg, border: Border.all(color: AppTheme.border)),
                  child: localImagePath != null 
                    ? Image.file(File(localImagePath!), fit: BoxFit.cover)
                    : (category?['image_url'] != null && category['image_url'].isNotEmpty)
                      ? Image.network(category['image_url'])
                      : const Center(child: Text('Chọn ảnh', style: TextStyle(fontSize: 12))),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
            FilledButton(
              onPressed: () async {
                bool success;
                if (category == null) {
                  success = await ApiService.adminAddCategory(nameController.text, emojiController.text, imageUrl: localImagePath);
                } else {
                  success = await ApiService.adminUpdateCategory(category['id'], nameController.text, emojiController.text, imageUrl: localImagePath);
                }
                if (success) {
                  Navigator.pop(context);
                  _loadData();
                }
              },
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }

  void _showUserXpDialog(dynamic user) {
    final xpController = TextEditingController(text: user['xp'].toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sửa XP: ${user['display_name']}'),
        content: TextField(
          controller: xpController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Điểm kinh nghiệm (XP)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          FilledButton(
            onPressed: () async {
              final newXp = int.tryParse(xpController.text) ?? 0;
              if (await ApiService.adminUpdateUserXP(user['id'], newXp)) {
                Navigator.pop(context);
                _loadData();
              }
            },
            child: const Text('Cập nhật'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quản lý hệ thống (Admin)', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: AppTheme.white,
          foregroundColor: AppTheme.indigo,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Danh mục'),
              Tab(text: 'Người dùng'),
            ],
            labelColor: AppTheme.indigo,
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  // Tab 1: Danh mục
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Quản lý danh mục', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.indigo)),
                            IconButton(
                              onPressed: () => _showCategoryDialog(),
                              icon: const Icon(Icons.add_circle, color: AppTheme.teal),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _categories.length,
                          itemBuilder: (context, index) {
                            final cat = _categories[index];
                            return Card(
                              child: ListTile(
                                leading: cat['image_url'] != null && cat['image_url'].isNotEmpty
                                  ? Image.network(cat['image_url'], width: 40)
                                  : Text(cat['emoji'] ?? '', style: const TextStyle(fontSize: 24)),
                                title: Text(cat['name'] ?? ''),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(icon: const Icon(Icons.edit, color: AppTheme.amber), onPressed: () => _showCategoryDialog(category: cat)),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: AppTheme.red),
                                      onPressed: () async {
                                        if (await ApiService.adminDeleteCategory(cat['id'])) _loadData();
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
                  // Tab 2: Người dùng
                  ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _users.length,
                    itemBuilder: (context, index) {
                      final u = _users[index];
                      return Card(
                        child: ListTile(
                          leading: const CircleAvatar(child: Icon(Icons.person)),
                          title: Text(u['display_name']),
                          subtitle: Text('${u['email']} • ${u['xp']} XP'),
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
