import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../core/theme.dart';
import '../../core/services/api_service.dart';
import '../../core/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class CreatorStepData {
  int stepNumber;
  String instruction;
  String tip;
  String? imagePath;
  int estimatedDuration; // in minutes

  CreatorStepData({
    required this.stepNumber,
    this.instruction = '',
    this.tip = '',
    this.imagePath,
    this.estimatedDuration = 1,
  });
}

class CreatorWorkshopScreen extends StatefulWidget {
  const CreatorWorkshopScreen({super.key});

  @override
  State<CreatorWorkshopScreen> createState() => _CreatorWorkshopScreenState();
}

class _CreatorWorkshopScreenState extends State<CreatorWorkshopScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  
  final _nameController = TextEditingController();
  final _emojiController = TextEditingController(text: '🦆');
  final _timeController = TextEditingController();
  final _paperSizeController = TextEditingController();
  final _paperTypeController = TextEditingController();
  final _xpRewardController = TextEditingController(text: '50');

  String _difficulty = 'Dễ';
  int? _selectedCategoryId;
  List<dynamic> _categories = [];
  bool _isLoadingCategories = true;
  
  final List<CreatorStepData> _steps = [
    CreatorStepData(stepNumber: 1),
    CreatorStepData(stepNumber: 2),
  ];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await ApiService.adminGetCategories();
      setState(() {
        _categories = cats;
        if (cats.isNotEmpty) {
          _selectedCategoryId = cats[0]['id'];
        }
        _isLoadingCategories = false;
      });
    } catch (e) {
      setState(() => _isLoadingCategories = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emojiController.dispose();
    _timeController.dispose();
    _paperSizeController.dispose();
    _paperTypeController.dispose();
    _xpRewardController.dispose();
    super.dispose();
  }

  Future<void> _pickStepImage(int index) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _steps[index].imagePath = image.path;
      });
    }
  }

  void _showEmojiPicker() {
    final emojis = ['🦆', ' Swan ', '🦢', '🦅', '🦉', '🦋', '🐠', '🦖', '🐲', '❤️', '🌸', '✈️', '⛵', '🏠'];
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5),
          itemCount: emojis.length,
          itemBuilder: (context, i) => InkWell(
            onTap: () {
              setState(() => _emojiController.text = emojis[i]);
              Navigator.pop(context);
            },
            child: Center(child: Text(emojis[i], style: const TextStyle(fontSize: 32))),
          ),
        ),
      ),
    );
  }

  void _addNewStep() {
    setState(() {
      _steps.add(
        CreatorStepData(
          stepNumber: _steps.length + 1,
        ),
      );
    });
  }

  void _removeStep(int index) {
    if (_steps.length <= 1) return;
    setState(() {
      _steps.removeAt(index);
      // Re-index steps
      for (int i = 0; i < _steps.length; i++) {
        _steps[i].stepNumber = i + 1;
      }
    });
  }

  void _submitModel() {
    _saveOrPublish('approved');
  }

  void _saveOrPublish(String status) async {
    if (_formKey.currentState!.validate()) {
      final auth = context.read<AuthProvider>();
      int xpRewardLimit = 150; // Giới hạn mới
      
      // Giả định User Top 1 hoặc XP cao có giới hạn XP thưởng cao hơn
      if (auth.currentUser.xp >= 5000) {
        xpRewardLimit = 200;
      }
      
      int requestedXp = int.tryParse(_xpRewardController.text) ?? 50;
      if (requestedXp < 50 || requestedXp > xpRewardLimit) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ Điểm thưởng phải nằm trong khoảng 50 - $xpRewardLimit XP!'),
            backgroundColor: AppTheme.red,
          ),
        );
        return;
      }

      if (_selectedCategoryId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('⚠️ Vui lòng chọn danh mục!'), backgroundColor: AppTheme.red),
        );
        return;
      }

      // Validate that we have at least 1 step with instruction
      for (final step in _steps) {
        if (step.instruction.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('⚠️ Vui lòng nhập chỉ dẫn cho tất cả các bước!'),
              backgroundColor: AppTheme.red,
            ),
          );
          return;
        }
      }

      final payload = {
        'name': _nameController.text.trim(),
        'emoji': _emojiController.text.trim(),
        'difficulty': _difficulty,
        'estimatedTime': int.tryParse(_timeController.text.trim()) ?? 10,
        'paperSize': _paperSizeController.text.trim(),
        'paperType': _paperTypeController.text.trim(),
        'categoryId': _selectedCategoryId,
        'status': status,
        'xpReward': requestedXp,
        'steps': _steps.map((step) => {
          'stepNumber': step.stepNumber,
          'instruction': step.instruction.trim(),
          'tip': step.tip.trim(),
          'imageUrl': step.imagePath ?? '',
          'duration': step.estimatedDuration,
        }).toList(),
      };

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator(color: AppTheme.indigo)),
      );

      final success = await ApiService.createOrigami(payload);
      
      if (mounted) {
        Navigator.pop(context); // Close loading indicator
      }

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(status == 'approved' 
                ? '✨ Đã xuất bản mẫu "${_nameController.text}" thành công lên ứng dụng!'
                : '💾 Đã gửi mẫu "${_nameController.text}" để phê duyệt!'),
              backgroundColor: AppTheme.teal,
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Lỗi khi lưu mẫu Origami mới!'),
              backgroundColor: AppTheme.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'Đóng góp & Sáng tạo mẫu',
          style: TextStyle(color: AppTheme.indigo, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () => _saveOrPublish('pending'),
            child: const Text('Lưu nháp', style: TextStyle(color: AppTheme.muted, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── PHẦN 1: THÔNG TIN MẪU GẤP ────────────────────────────────
              const Text(
                'Thông tin cơ bản',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.indigo),
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  children: [
                    // Hàng 2 cột: Tên mẫu & Emoji biểu tượng
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: _nameController,
                            validator: (value) => value == null || value.isEmpty ? 'Vui lòng nhập tên mẫu' : null,
                            decoration: const InputDecoration(
                              labelText: 'Tên mẫu Origami',
                              hintText: 'Ví dụ: Hạc tiên, Cá rồng...',
                              prefixIcon: Icon(Icons.title, color: AppTheme.muted),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: _showEmojiPicker,
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppTheme.bg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.border),
                            ),
                            child: Center(
                              child: Text(_emojiController.text, style: const TextStyle(fontSize: 28)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Thêm trường XP thưởng
                    TextFormField(
                      controller: _xpRewardController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Điểm thưởng (XP)',
                        hintText: 'Mặc định: 50 XP',
                        prefixIcon: Icon(Icons.stars_rounded, color: AppTheme.amber),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _isLoadingCategories
                              ? const Center(child: CircularProgressIndicator())
                              : DropdownButtonFormField<int>(
                                  value: _selectedCategoryId,
                                  onChanged: (v) => setState(() => _selectedCategoryId = v!),
                                  decoration: const InputDecoration(labelText: 'Danh mục'),
                                  items: _categories.map((cat) => DropdownMenuItem<int>(
                                    value: cat['id'],
                                    child: Text('${cat['name']} ${cat['emoji'] ?? ''}'),
                                  )).toList(),
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _difficulty,
                            onChanged: (v) => setState(() => _difficulty = v!),
                            decoration: const InputDecoration(labelText: 'Độ khó'),
                            items: const [
                              DropdownMenuItem(value: 'Dễ', child: Text('Dễ ⭐')),
                              DropdownMenuItem(value: 'Trung bình', child: Text('Trung bình ⭐⭐')),
                              DropdownMenuItem(value: 'Khó', child: Text('Khó ⭐⭐⭐')),
                              DropdownMenuItem(value: 'Cực khó', child: Text('Cực khó 🔥')),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Hàng 2 cột: Thời gian & Kích thước giấy
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _timeController,
                            validator: (value) => value == null || value.isEmpty ? 'Nhập thời gian' : null,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Thời gian gấp (phút)',
                              hintText: 'Ví dụ: 15',
                              prefixIcon: Icon(Icons.timer_outlined, color: AppTheme.muted),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _paperSizeController,
                            validator: (value) => value == null || value.isEmpty ? 'Nhập cỡ giấy' : null,
                            decoration: const InputDecoration(
                              labelText: 'Cỡ giấy khuyên dùng',
                              hintText: 'Ví dụ: 15x15 cm',
                              prefixIcon: Icon(Icons.aspect_ratio_rounded, color: AppTheme.muted),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _paperTypeController,
                      validator: (value) => value == null || value.isEmpty ? 'Vui lòng nhập loại giấy' : null,
                      decoration: const InputDecoration(
                        labelText: 'Loại giấy khuyên dùng',
                        hintText: 'Ví dụ: Washi, Kami, Giấy xi măng...',
                        prefixIcon: Icon(Icons.layers_outlined, color: AppTheme.muted),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ─── PHẦN 2: XÂY DỰNG CÁC BƯỚC HƯỚNG DẪN ──────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Các bước hướng dẫn gấp',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.indigo),
                  ),
                  TextButton.icon(
                    onPressed: _addNewStep,
                    icon: const Icon(Icons.add_circle_outline_rounded, color: AppTheme.teal, size: 18),
                    label: const Text('Thêm bước', style: TextStyle(color: AppTheme.teal, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Danh sách các bước
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _steps.length,
                itemBuilder: (context, index) {
                  final step = _steps[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Bước ${index + 1}',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.indigo, fontSize: 14),
                            ),
                            if (_steps.length > 1)
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.red, size: 20),
                                onPressed: () => _removeStep(index),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Thumbnail picker simulation
                            GestureDetector(
                              onTap: () => _pickStepImage(index),
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: AppTheme.bg,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppTheme.border),
                                ),
                                child: Center(
                                  child: step.imagePath != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: Image.file(File(step.imagePath!), fit: BoxFit.cover, width: 80, height: 80),
                                        )
                                      : const Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.add_a_photo_outlined, color: AppTheme.muted, size: 22),
                                            SizedBox(height: 4),
                                            Text('Chọn ảnh', style: TextStyle(fontSize: 9, color: AppTheme.muted)),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),

                            // Fields for instructions and tips
                            Expanded(
                              child: Column(
                                children: [
                                  TextFormField(
                                    initialValue: step.instruction,
                                    onChanged: (val) => step.instruction = val,
                                    maxLines: 2,
                                    validator: (value) => value == null || value.isEmpty ? 'Hãy nhập chỉ dẫn cho bước này' : null,
                                    decoration: const InputDecoration(
                                      labelText: 'Chỉ dẫn gấp',
                                      hintText: 'Gấp chéo 2 mép giấy...',
                                      contentPadding: EdgeInsets.all(10),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  TextFormField(
                                    initialValue: step.estimatedDuration.toString(),
                                    onChanged: (val) => step.estimatedDuration = int.tryParse(val) ?? 1,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'Thời gian bước này (phút)',
                                      hintText: 'Ví dụ: 2',
                                      contentPadding: EdgeInsets.all(10),
                                      prefixIcon: Icon(Icons.timer_outlined, size: 16),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  TextFormField(
                                    initialValue: step.tip,
                                    onChanged: (val) => step.tip = val,
                                    decoration: const InputDecoration(
                                      labelText: 'Mẹo nhỏ (Không bắt buộc)',
                                      hintText: 'Miết mạnh tay để nếp gấp sắc hơn...',
                                      contentPadding: EdgeInsets.all(10),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // ─── NÚT XUẤT BẢN ──────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _submitModel,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.teal,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('🎯 Xuất Bản Mẫu Lên Ứng Dụng', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
