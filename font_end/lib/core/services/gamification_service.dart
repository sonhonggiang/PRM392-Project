import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class GamificationService {
  static const String _questsKey = 'admin_quests_list';
  static const String _campaignsKey = 'admin_campaigns_list';

  // 1. Quests CRUD
  static Future<List<Map<String, dynamic>>> getQuests() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_questsKey);
    if (jsonStr == null) {
      final defaults = [
        {'id': '1', 'title': 'Đăng nhập ứng dụng học tập', 'xp': '+40 XP', 'key': 'login'},
        {'id': '2', 'title': 'Hoàn thành gấp 1 mẫu bất kỳ', 'xp': '+50 XP', 'key': 'fold'},
        {'id': '3', 'title': 'Bắt đầu học hoặc gấp dở 2 mẫu', 'xp': '+30 XP', 'key': 'fav'},
      ];
      await prefs.setString(_questsKey, jsonEncode(defaults));
      return defaults;
    }
    return List<Map<String, dynamic>>.from(jsonDecode(jsonStr).map((e) => Map<String, dynamic>.from(e)));
  }

  static Future<void> saveQuests(List<Map<String, dynamic>> quests) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_questsKey, jsonEncode(quests));
  }

  // 2. Campaigns CRUD
  static Future<List<Map<String, dynamic>>> getCampaigns() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_campaignsKey);
    if (jsonStr == null) {
      final defaults = [
        {
          'id': '1',
          'title': 'Chiến dịch: Khởi đầu huyền thoại',
          'desc': 'Hoàn thành gấp 2 mẫu cơ bản nhất của nghệ thuật xếp giấy: Trái Tim & Hạc Giấy.',
          'total': 2,
          'emoji': '🔥',
          'reward': 'Huy hiệu "Cặp đôi huyền thoại" & +150 XP',
        },
        {
          'id': '2',
          'title': 'Chiến dịch: Nghệ nhân tập sự',
          'desc': 'Gấp thành công ít nhất 3 mẫu Origami bất kỳ để nhận chứng nhận Nghệ nhân tập sự.',
          'total': 3,
          'emoji': '⚡',
          'reward': 'Huy hiệu "Nghệ nhân tập sự" & +200 XP',
        }
      ];
      await prefs.setString(_campaignsKey, jsonEncode(defaults));
      return defaults;
    }
    return List<Map<String, dynamic>>.from(jsonDecode(jsonStr).map((e) => Map<String, dynamic>.from(e)));
  }

  static Future<void> saveCampaigns(List<Map<String, dynamic>> campaigns) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_campaignsKey, jsonEncode(campaigns));
  }
}
