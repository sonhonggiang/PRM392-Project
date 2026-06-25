import 'package:flutter/material.dart';
import '../../core/theme.dart';

class AdminApprovalScreen extends StatefulWidget {
  const AdminApprovalScreen({super.key});

  @override
  State<AdminApprovalScreen> createState() => _AdminApprovalScreenState();
}

class _AdminApprovalScreenState extends State<AdminApprovalScreen> {
  final List<Map<String, dynamic>> _pendingModels = [
    {
      'id': 'p1',
      'name': 'Thiên Nga Trắng',
      'emoji': '🦢',
      'creator': 'Nguyễn Nam',
      'date': '24/06/2026',
      'difficulty': 'Dễ',
      'time': '12 phút',
      'stepsCount': 10,
      'description': 'Mẫu thiên nga trắng thanh lịch, sử dụng kỹ thuật gấp nếp giấy cơ bản rất thích hợp cho trẻ em.',
      'steps': [
        {'step': 1, 'instruction': 'Gấp đôi tờ giấy vuông để tạo nếp gấp đường chéo chính.'},
        {'step': 2, 'instruction': 'Gấp 2 mép giấy bên ngoài vào sát đường chéo chính.'},
        {'step': 3, 'instruction': 'Bẻ ngược phần nhọn lên trên để tạo thành cổ thiên nga.'},
      ]
    },
    {
      'id': 'p2',
      'name': 'Hổ Vàng Mãnh Lực',
      'emoji': '🐯',
      'creator': 'Lê Minh',
      'date': '22/06/2026',
      'difficulty': 'Khó',
      'time': '40 phút',
      'stepsCount': 28,
      'description': 'Mẫu hổ vàng oai dũng với nhiều bước gấp xếp lớp phức tạp, cần độ chuẩn xác và kiên nhẫn cao.',
      'steps': [
        {'step': 1, 'instruction': 'Tạo các nếp gấp cơ bản chia lưới 8x8 trên tờ giấy màu vàng.'},
        {'step': 2, 'instruction': 'Gấp xếp ly góc trên để tạo hình tai hổ.'},
        {'step': 3, 'instruction': 'Tạo nếp gấp lồi lõm xen kẽ để tạo chân hổ.'},
      ]
    },
    {
      'id': 'p3',
      'name': 'Hoa Tulip Đỏ',
      'emoji': '🌷',
      'creator': 'Thanh Hằng',
      'date': '21/06/2026',
      'difficulty': 'Trung bình',
      'time': '18 phút',
      'stepsCount': 12,
      'description': 'Mẫu hoa tulip nở rộ sắc nét, đi kèm hướng dẫn gấp cành và lá xanh lá cây.',
      'steps': [
        {'step': 1, 'instruction': 'Gấp chéo 4 góc của tờ giấy màu đỏ vào tâm giữa.'},
        {'step': 2, 'instruction': 'Mở rộng các cánh hoa ngoài bằng cách vuốt nhẹ ra sau.'},
      ]
    }
  ];

  void _approveModel(String id, String name) {
    setState(() {
      _pendingModels.removeWhere((m) => m['id'] == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ Đã duyệt và xuất bản mẫu "$name" thành công!'),
        backgroundColor: AppTheme.teal,
      ),
    );
  }

  void _rejectModel(String id, String name) {
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
              onPressed: () {
                Navigator.pop(ctx);
                setState(() {
                  _pendingModels.removeWhere((m) => m['id'] == id);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('❌ Đã từ chối mẫu "$name". Lý do: ${reasonCtrl.text}'),
                    backgroundColor: AppTheme.red,
                  ),
                );
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
      builder: (ctx) => Dialog(
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
                  Text(item['emoji'], style: const TextStyle(fontSize: 40)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.indigo)),
                        Text('Tạo bởi: ${item['creator']} | ${item['date']}', style: const TextStyle(fontSize: 11, color: AppTheme.muted)),
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
              Text(item['description'], style: const TextStyle(fontSize: 12, color: AppTheme.text, height: 1.4)),
              const SizedBox(height: 16),

              // Detail metadata
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Độ khó: ${item['difficulty']}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.amber)),
                  Text('Thời gian: ${item['time']}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.teal)),
                  Text('Số bước: ${item['stepsCount']}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.indigo)),
                ],
              ),
              const SizedBox(height: 16),

              // Steps List Preview
              const Text('Xem trước các bước gấp chính:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.indigo)),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: (item['steps'] as List).length,
                  itemBuilder: (context, i) {
                    final step = item['steps'][i];
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
                            child: Text('${step['step']}', style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              step['instruction'],
                              style: const TextStyle(fontSize: 11, color: AppTheme.text),
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
      ),
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
      body: _pendingModels.isEmpty
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
                            child: Center(child: Text(item['emoji'], style: const TextStyle(fontSize: 26))),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['name'],
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.text),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Tạo bởi: ${item['creator']} | ${item['date']}',
                                  style: const TextStyle(fontSize: 11, color: AppTheme.muted),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        item['description'],
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
                            child: Text('Độ khó: ${item['difficulty']}', style: const TextStyle(fontSize: 10, color: AppTheme.amber, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: AppTheme.teal.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                            child: Text('Thời gian: ${item['time']}', style: const TextStyle(fontSize: 10, color: AppTheme.teal, fontWeight: FontWeight.bold)),
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
                              onPressed: () => _rejectModel(item['id'], item['name']),
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
                              onPressed: () => _approveModel(item['id'], item['name']),
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
