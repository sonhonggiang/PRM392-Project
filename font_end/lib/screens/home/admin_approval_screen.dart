import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/services/api_service.dart';

class AdminApprovalScreen extends StatefulWidget {
  const AdminApprovalScreen({super.key});

  @override
  State<AdminApprovalScreen> createState() => _AdminApprovalScreenState();
}

class _AdminApprovalScreenState extends State<AdminApprovalScreen> {
  List<dynamic> _pendingModels = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPendingModels();
  }

  Future<void> _loadPendingModels() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final models = await ApiService.getPendingOrigami();
      if (mounted) {
        setState(() {
          _pendingModels = models;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Lỗi tải mẫu chờ duyệt: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _approveModel(int id, String name) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: AppTheme.indigo)),
    );

    try {
      final success = await ApiService.approveOrRejectOrigami(id, 'approved');
      if (mounted) {
        Navigator.pop(context); // Đóng indicator loading
      }

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Đã duyệt và xuất bản mẫu "$name" thành công!'),
              backgroundColor: AppTheme.teal,
            ),
          );
        }
        _loadPendingModels();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Lỗi khi duyệt mẫu!'),
              backgroundColor: AppTheme.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
      }
      print('Lỗi duyệt mẫu: $e');
    }
  }

  void _rejectModel(int id, String name) {
    showDialog(
      context: context,
      builder: (ctx) {
        final reasonCtrl = TextEditingController();
        return AlertDialog(
          title: Text('Từ chối mẫu "$name"'),
          content: TextField(
            controller: reasonCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Nhập lý do từ chối (ví dụ: Hình ảnh mờ, hướng dẫn không rõ ràng...)',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
            FilledButton(
              onPressed: () async {
                Navigator.pop(ctx);
                
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(child: CircularProgressIndicator(color: AppTheme.indigo)),
                );

                try {
                  final success = await ApiService.approveOrRejectOrigami(id, 'rejected', rejectionReason: reasonCtrl.text);
                  if (mounted) {
                    Navigator.pop(context); // Đóng indicator loading
                  }

                  if (success) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('❌ Đã từ chối mẫu "$name". Lý do: ${reasonCtrl.text}'),
                          backgroundColor: AppTheme.red,
                        ),
                      );
                    }
                    _loadPendingModels();
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('❌ Lỗi khi từ chối mẫu!'),
                          backgroundColor: AppTheme.red,
                        ),
                      );
                    }
                  }
                } catch (e) {
                  if (mounted) {
                    Navigator.pop(context);
                  }
                  print('Lỗi từ chối mẫu: $e');
                }
              },
              style: FilledButton.styleFrom(backgroundColor: AppTheme.red),
              child: const Text('Xác nhận từ chối'),
            ),
          ],
        );
      },
    );
  }

  void _showPreviewDialog(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (ctx) {
        return FutureBuilder<Map<String, dynamic>?>(
          future: ApiService.getOrigamiDetail(item['id']),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppTheme.indigo));
            }
            if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
              return AlertDialog(
                title: const Text('Lỗi'),
                content: const Text('Không thể lấy chi tiết mẫu gấp này.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Đóng'),
                  )
                ],
              );
            }

            final fullItem = snapshot.data!;
            final List steps = fullItem['steps'] ?? [];

            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Container(
                padding: const EdgeInsets.all(20),
                width: double.infinity,
                constraints: const BoxConstraints(maxHeight: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header preview
                    Row(
                      children: [
                        Text(fullItem['emoji'] ?? '📄', style: const TextStyle(fontSize: 40)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(fullItem['name'] ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.indigo)),
                              Text('Tạo bởi: ${item['creator_name'] ?? 'Ẩn danh'} | ${item['created_at'] != null ? item['created_at'].toString().split('T')[0] : ''}', style: const TextStyle(fontSize: 11, color: AppTheme.muted)),
                            ],
                          ),
                        ),
                        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Divider(),
                    const SizedBox(height: 8),

                    // Overview
                    const Text('Giới thiệu mẫu:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.indigo)),
                    const SizedBox(height: 4),
                    Text(
                      'Danh mục: ${fullItem['category_name'] ?? 'Chưa phân loại'}. Cỡ giấy khuyên dùng: ${fullItem['paper_size'] ?? '15x15 cm'}. Loại giấy: ${fullItem['paper_type'] ?? 'Washi'}.',
                      style: const TextStyle(fontSize: 12, color: AppTheme.text, height: 1.4),
                    ),
                    const SizedBox(height: 16),

                    // Detail metadata
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Độ khó: ${fullItem['difficulty'] ?? 'Dễ'}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.amber)),
                        Text('Thời gian: ${fullItem['estimated_time'] ?? 10} phút', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.teal)),
                        Text('Số bước: ${steps.length}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.indigo)),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Steps List Preview
                    const Text('Xem trước các bước gấp chính:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.indigo)),
                    const SizedBox(height: 8),
                    Expanded(
                      child: steps.isEmpty
                          ? const Center(child: Text('Không có bước gấp nào.', style: TextStyle(fontSize: 12, color: AppTheme.muted)))
                          : ListView.builder(
                              itemCount: steps.length,
                              itemBuilder: (context, i) {
                                final step = steps[i];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppTheme.bg,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        radius: 10,
                                        backgroundColor: AppTheme.indigo,
                                        child: Text('${step['step_number'] ?? (i + 1)}', style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold)),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              step['instruction'] ?? '',
                                              style: const TextStyle(fontSize: 11, color: AppTheme.text),
                                            ),
                                            if (step['tip'] != null && step['tip'].toString().trim().isNotEmpty) ...[
                                              const SizedBox(height: 4),
                                              Text(
                                                '💡 Mẹo: ${step['tip']}',
                                                style: const TextStyle(fontSize: 10, color: AppTheme.muted, fontStyle: FontStyle.italic),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 16),

                    // Actions inside preview
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              _rejectModel(item['id'], item['name']);
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.red,
                              side: const BorderSide(color: AppTheme.red),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Từ Chối'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              _approveModel(item['id'], item['name']);
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: AppTheme.teal,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Duyệt & Xuất Bản'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }
        );
      }
    );
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
          'Duyệt mẫu mới (Admin)',
          style: TextStyle(color: AppTheme.indigo, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.indigo))
          : _pendingModels.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text('🎉', style: TextStyle(fontSize: 56)),
                      SizedBox(height: 12),
                      Text('Hộp thư duyệt trống!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.indigo)),
                      SizedBox(height: 6),
                      Text('Không có mẫu nào đang chờ phê duyệt.', style: TextStyle(color: AppTheme.muted, fontSize: 13)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _pendingModels.length,
                  itemBuilder: (context, index) {
                    final item = _pendingModels[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.border),
                        boxShadow: const [
                          BoxShadow(color: Color(0x051A2F6E), blurRadius: 8, offset: Offset(0, 4))
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: AppTheme.bg,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(child: Text(item['emoji'] ?? '📄', style: const TextStyle(fontSize: 26))),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['name'] ?? '',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.text),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Tạo bởi: ${item['creator_name'] ?? 'Ẩn danh'} | ${item['created_at'] != null ? item['created_at'].toString().split('T')[0] : ''}',
                                      style: const TextStyle(fontSize: 11, color: AppTheme.muted),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Danh mục: ${item['category_name'] ?? 'Chưa phân loại'} | Giấy khuyên dùng: ${item['paper_size'] ?? '15x15 cm'} (${item['paper_type'] ?? 'Washi'})',
                            style: const TextStyle(fontSize: 12, color: AppTheme.text, height: 1.4),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: AppTheme.amber.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                child: Text('Độ khó: ${item['difficulty'] ?? 'Dễ'}', style: const TextStyle(fontSize: 10, color: AppTheme.amber, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: AppTheme.teal.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                child: Text('Thời gian: ${item['estimated_time'] ?? 10} phút', style: const TextStyle(fontSize: 10, color: AppTheme.teal, fontWeight: FontWeight.bold)),
                              ),
                              const Spacer(),
                              TextButton(
                                onPressed: () => _showPreviewDialog(item),
                                child: const Text('Xem chi tiết', style: TextStyle(color: AppTheme.indigo, fontWeight: FontWeight.bold, fontSize: 12)),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => _rejectModel(item['id'], item['name'] ?? ''),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppTheme.red,
                                    side: const BorderSide(color: AppTheme.red),
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  child: const Text('Từ Chối', style: TextStyle(fontSize: 13)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: FilledButton(
                                  onPressed: () => _approveModel(item['id'], item['name'] ?? ''),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppTheme.teal,
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  child: const Text('Phê Duyệt', style: TextStyle(fontSize: 13)),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
