import 'package:flutter/material.dart';
import '../../core/theme.dart';

class CreatorStepData {
  final int stepNumber;
  String instruction;
  String tip;
  String emojiPlaceholder;

  CreatorStepData({
    required this.stepNumber,
    this.instruction = '',
    this.tip = '',
    this.emojiPlaceholder = '📄',
  });
}

class CreatorWorkshopScreen extends StatefulWidget {
  const CreatorWorkshopScreen({super.key});

  @override
  State<CreatorWorkshopScreen> createState() => _CreatorWorkshopScreenState();
}

class _CreatorWorkshopScreenState extends State<CreatorWorkshopScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _timeController = TextEditingController();
  final _paperSizeController = TextEditingController();
  final _paperTypeController = TextEditingController();

  String _difficulty = 'Dễ';
  String _category = 'Động vật';
  
  final List<CreatorStepData> _steps = [
    CreatorStepData(stepNumber: 1, emojiPlaceholder: '📐'),
    CreatorStepData(stepNumber: 2, emojiPlaceholder: '📄'),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _timeController.dispose();
    _paperSizeController.dispose();
    _paperTypeController.dispose();
    super.dispose();
  }

  void _addNewStep() {
    setState(() {
      _steps.add(
        CreatorStepData(
          stepNumber: _steps.length + 1,
          emojiPlaceholder: '📄',
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
        // Just keeping ordering correct
      }
    });
  }

  void _submitModel() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✨ Đã xuất bản mẫu "${_nameController.text}" thành công lên ứng dụng!'),
          backgroundColor: AppTheme.teal,
        ),
      );
      Navigator.pop(context);
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
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('💾 Đã lưu bản nháp mẫu gấp!'),
                  backgroundColor: AppTheme.indigoLight,
                ),
              );
              Navigator.pop(context);
            },
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
                    // Tên mẫu
                    TextFormField(
                      controller: _nameController,
                      validator: (value) => value == null || value.isEmpty ? 'Vui lòng nhập tên mẫu' : null,
                      decoration: const InputDecoration(
                        labelText: 'Tên mẫu Origami',
                        hintText: 'Ví dụ: Hạc tiên, Cá rồng...',
                        prefixIcon: Icon(Icons.title, color: AppTheme.muted),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Hàng 2 cột: Thể loại & Độ khó
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _category,
                            onChanged: (v) => setState(() => _category = v!),
                            decoration: const InputDecoration(labelText: 'Danh mục'),
                            items: const [
                              DropdownMenuItem(value: 'Động vật', child: Text('Động vật 🐰')),
                              DropdownMenuItem(value: 'Hoa cỏ', child: Text('Hoa cỏ 🌺')),
                              DropdownMenuItem(value: 'Đồ vật', child: Text('Đồ vật ✈️')),
                            ],
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
                              onTap: () {
                                setState(() {
                                  step.emojiPlaceholder = '📸';
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('📸 Đã mở thư viện và chọn ảnh thành công!'),
                                    backgroundColor: AppTheme.teal,
                                  ),
                                );
                              },
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: AppTheme.bg,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppTheme.border),
                                ),
                                child: Center(
                                  child: step.emojiPlaceholder == '📸'
                                      ? const Icon(Icons.check_circle, color: AppTheme.teal, size: 28)
                                      : Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(step.emojiPlaceholder, style: const TextStyle(fontSize: 22)),
                                            const SizedBox(height: 4),
                                            const Text('Chọn ảnh', style: TextStyle(fontSize: 9, color: AppTheme.muted)),
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
