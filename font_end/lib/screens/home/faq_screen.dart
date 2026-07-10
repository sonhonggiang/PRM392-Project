import 'package:flutter/material.dart';
import '../../core/theme.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> faqs = [
      {
        'q': 'Làm thế nào để bắt đầu học gấp giấy?',
        'a': 'Bạn hãy chuyển sang tab "Khám phá", chọn một danh mục hoặc tìm kiếm mẫu gấp bạn thích. Bấm vào mẫu gấp đó rồi nhấn nút "Bắt đầu Gấp" để hiển thị hướng dẫn chi tiết từng bước.'
      },
      {
        'q': 'Thời gian đếm ngược (Timer) hoạt động thế nào?',
        'a': 'Mỗi mẫu gấp có một khoảng thời gian gợi ý nhất định. Khi bạn bắt đầu học, đồng hồ đếm ngược sẽ chạy. Nếu hết thời gian mà bạn chưa hoàn thành, app sẽ hiển thị thông báo và đưa bạn trở lại màn hình Khám phá để luyện tập lại.'
      },
      {
        'q': 'Làm sao để nhận được huy hiệu (Badges)?',
        'a': 'Hệ thống sẽ tự động tặng huy hiệu cho bạn khi bạn đạt đủ chỉ tiêu học tập: hoàn thành mẫu đầu tiên (🌱 Người mới), hoàn thành 5 bài học Hạc giấy (🦢 Fan Hạc giấy), tích lũy chuỗi học liên tiếp 7 ngày (🔥 Chuỗi 7 ngày), hoặc hoàn thành 10 bài gấp (⭐ Người học chăm chỉ).'
      },
      {
        'q': 'Điểm kinh nghiệm (XP) dùng để làm gì?',
        'a': 'Điểm XP thể hiện mức độ tích lũy học tập của bạn và được sử dụng để xếp hạng trên Bảng xếp hạng. Ngoài ra, khi đạt trên 1000 XP, bạn sẽ được mở khóa quyền năng tạo mẫu gấp mới ở mục Workshop.'
      },
      {
        'q': 'Giấy gấp Washi là gì và có điểm gì đặc biệt?',
        'a': 'Washi là loại giấy thủ công truyền thống của Nhật Bản, có sợi xơ dài giúp giấy dai, mềm, dễ nếp gấp phức tạp và giữ phom dáng tác phẩm rất tốt so với các loại giấy thông thường.'
      },
      {
        'q': 'Tôi muốn báo lỗi ứng dụng hoặc đóng góp ý kiến thì gửi ở đâu?',
        'a': 'Bạn hãy vào mục "Liên hệ hỗ trợ" trong Trung tâm trợ giúp để chat trực tiếp với Admin. Chúng tôi luôn sẵn sàng lắng nghe mọi phản hồi của bạn!'
      },
    ];

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Câu hỏi thường gặp (FAQ)', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.indigo)),
        backgroundColor: AppTheme.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.indigo),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          final faq = faqs[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.border),
            ),
            child: ExpansionTile(
              title: Text(
                faq['q']!,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.indigo),
              ),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              expandedAlignment: Alignment.topLeft,
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              shape: const Border(), // Xóa viền đen mặc định của ExpansionTile khi mở rộng
              children: [
                const Divider(height: 1, color: AppTheme.border),
                const SizedBox(height: 12),
                Text(
                  faq['a']!,
                  style: const TextStyle(fontSize: 12, color: AppTheme.text, height: 1.5),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
