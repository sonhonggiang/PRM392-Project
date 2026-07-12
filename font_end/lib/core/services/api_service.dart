import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // IP HIỆN TẠI CỦA MÁY TÍNH: 192.168.1.7
  static String get baseUrl => 'http://192.168.1.7:3000/api';
  static String? token;

  static Map<String, String> getHeaders() {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/profile'),
        headers: getHeaders(),
      );
      return response.statusCode == 200 ? jsonDecode(response.body) : null;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> updateProfile(String displayName, String avatarUrl, {String? email, String? password}) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/users/profile'),
        headers: getHeaders(),
        body: jsonEncode({
          'displayName': displayName,
          'avatarUrl': avatarUrl,
          if (email != null) 'email': email,
          if (password != null) 'password': password,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: getHeaders(),
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 10));
      
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        token = data['token'];
        return data;
      } else {
        return {'error': data['message'] ?? 'Email hoặc mật khẩu không đúng'};
      }
    } catch (e) {
      return {'error': 'Lỗi kết nối Server: $e'};
    }
  }

  static Future<Map<String, dynamic>?> register(String email, String password, String displayName) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: getHeaders(),
        body: jsonEncode({'email': email, 'password': password, 'displayName': displayName}),
      ).timeout(const Duration(seconds: 10));
      
      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        return data;
      } else {
        // Trả về dữ liệu lỗi để UI có thể hiển thị message từ server
        return {'error': data['message'] ?? 'Đã có lỗi xảy ra'};
      }
    } catch (e) {
      return {'error': 'Không thể kết nối tới server. Vui lòng kiểm tra mạng hoặc địa chỉ IP.'};
    }
  }

  static Future<bool> sendOTP(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/send-otp'), 
        headers: getHeaders(), 
        body: jsonEncode({'email': email})
      ).timeout(const Duration(seconds: 10));
      return response.statusCode == 200;
    } catch (e) { return false; }
  }

  static Future<bool> verifyOTP(String email, String otp) async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/auth/verify-otp'), headers: getHeaders(), body: jsonEncode({'email': email, 'otp': otp}));
      return response.statusCode == 200;
    } catch (e) { return false; }
  }

  static Future<bool> resetPassword(String email, String newPassword) async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/auth/reset-password'), headers: getHeaders(), body: jsonEncode({'email': email, 'newPassword': newPassword}));
      return response.statusCode == 200;
    } catch (e) { return false; }
  }

  static Future<List<dynamic>> getOrigamiList({String? search, String? sortBy, String? category}) async {
    try {
      String url = '$baseUrl/origami?';
      if (search != null) url += 'search=$search&';
      if (sortBy != null) url += 'sortBy=$sortBy&';
      if (category != null) url += 'category=$category&';
      final response = await http.get(Uri.parse(url), headers: getHeaders());
      return response.statusCode == 200 ? jsonDecode(response.body) : [];
    } catch (e) { return []; }
  }

  static Future<Map<String, dynamic>?> getOrigamiDetail(dynamic id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/origami/$id'), headers: getHeaders());
      return response.statusCode == 200 ? jsonDecode(response.body) : null;
    } catch (e) { return null; }
  }

  static Future<bool> createOrigami(Map<String, dynamic> data) async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/origami'), headers: getHeaders(), body: jsonEncode(data));
      return response.statusCode == 201;
    } catch (e) { return false; }
  }

  static Future<List<dynamic>> getProgress() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users/progress'), headers: getHeaders());
      // Log để debug dữ liệu trả về
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) { return []; }
  }

  static Future<Map<String, dynamic>?> updateProgress(dynamic origamiId, int step, bool isComplete, {int duration = 0}) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/users/progress/$origamiId'), 
        headers: getHeaders(), 
        body: jsonEncode({
          'currentStep': step, 
          'isCompleted': isComplete,
          'duration': duration
        })
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) { 
      print('Lỗi gọi API updateProgress: $e');
      return null; 
    }
  }

  static Future<List<dynamic>> getFavorites() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users/favorites'), headers: getHeaders());
      return response.statusCode == 200 ? jsonDecode(response.body) : [];
    } catch (e) { return []; }
  }

  static Future<bool> toggleFavorite(dynamic origamiId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/favorites/$origamiId'), 
        headers: getHeaders()
      );
      return response.statusCode == 200;
    } catch (e) { return false; }
  }

  static Future<List<dynamic>> getUserBadges() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users/badges'), headers: getHeaders());
      return response.statusCode == 200 ? jsonDecode(response.body) : [];
    } catch (e) { return []; }
  }

  static Future<Map<String, dynamic>?> getUserAnalytics() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users/analytics'), headers: getHeaders());
      return response.statusCode == 200 ? jsonDecode(response.body) : null;
    } catch (e) { return null; }
  }

  static Future<List<dynamic>> getNotifications() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users/notifications'), headers: getHeaders());
      return response.statusCode == 200 ? jsonDecode(response.body) : [];
    } catch (e) { return []; }
  }

  static Future<bool> markNotificationRead(dynamic id) async {
    try {
      final response = await http.put(Uri.parse('$baseUrl/users/notifications/$id/read'), headers: getHeaders());
      return response.statusCode == 200;
    } catch (e) { return false; }
  }

  static Future<List<dynamic>> getLeaderboard({String? type}) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/leaderboard?type=${type ?? "alltime"}'), headers: getHeaders());
      return response.statusCode == 200 ? jsonDecode(response.body) : [];
    } catch (e) { return []; }
  }


  static Future<Map<String, dynamic>?> getDailyChallenge() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/daily-challenge'), headers: getHeaders());
      return response.statusCode == 200 ? jsonDecode(response.body) : null;
    } catch (e) { return null; }
  }

  static Future<Map<String, dynamic>?> completeDailyChallenge() async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/daily-challenge/complete'), headers: getHeaders());
      return response.statusCode == 200 ? jsonDecode(response.body) : null;
    } catch (e) { return null; }
  }

  static Future<List<dynamic>> getDailyChallengeHistory() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/daily-challenge/history'), headers: getHeaders());
      return response.statusCode == 200 ? jsonDecode(response.body) : [];
    } catch (e) { return []; }
  }


  static Future<List<dynamic>> getPendingOrigami() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/origami/pending'), headers: getHeaders());
      return response.statusCode == 200 ? jsonDecode(response.body) : [];
    } catch (e) { return []; }
  }

  static Future<bool> approveOrRejectOrigami(dynamic id, String status, {String? rejectionReason}) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/origami/$id/approval'), 
        headers: getHeaders(), 
        body: jsonEncode({'status': status, 'rejectionReason': rejectionReason})
      );
      return response.statusCode == 200;
    } catch (e) { return false; }
  }

  static Future<bool> rateOrigami(dynamic origamiId, int rating) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/origami/$origamiId/rate'),
        headers: getHeaders(),
        body: jsonEncode({'rating': rating}),
      );
      return response.statusCode == 200;
    } catch (e) { return false; }
  }

  // --- ADMIN MANAGEMENT API ---
  static Future<List<dynamic>> adminGetCategories() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/admin-manage/categories'), headers: getHeaders());
      return response.statusCode == 200 ? jsonDecode(response.body) : [];
    } catch (e) { return []; }
  }

  static Future<bool> adminAddCategory(String name, String emoji, {String? imageUrl}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin-manage/categories'),
        headers: getHeaders(),
        body: jsonEncode({'name': name, 'emoji': emoji, 'imageUrl': imageUrl ?? ''}),
      );
      return response.statusCode == 201;
    } catch (e) { return false; }
  }

  static Future<bool> adminUpdateCategory(dynamic id, String name, String emoji, {String? imageUrl}) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/admin-manage/categories/$id'),
        headers: getHeaders(),
        body: jsonEncode({'name': name, 'emoji': emoji, 'imageUrl': imageUrl ?? ''}),
      );
      return response.statusCode == 200;
    } catch (e) { return false; }
  }

  static Future<bool> adminDeleteCategory(dynamic id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/admin-manage/categories/$id'), headers: getHeaders());
      return response.statusCode == 200;
    } catch (e) { return false; }
  }

  static Future<bool> adminUpdateModel(dynamic id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/admin-manage/origami/$id'),
        headers: getHeaders(),
        body: jsonEncode(data),
      );
      return response.statusCode == 200;
    } catch (e) { return false; }
  }

  static Future<bool> adminDeleteOrigami(dynamic id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/admin-manage/origami/$id'),
        headers: getHeaders(),
      );
      return response.statusCode == 200;
    } catch (e) { return false; }
  }

  static Future<List<dynamic>> adminGetOrigamiModels() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/admin-manage/origami'), headers: getHeaders());
      return response.statusCode == 200 ? jsonDecode(response.body) : [];
    } catch (e) { return []; }
  }

  static Future<List<dynamic>> adminGetUsers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/admin-manage/users'), headers: getHeaders());
      return response.statusCode == 200 ? jsonDecode(response.body) : [];
    } catch (e) { return []; }
  }

  static Future<bool> adminUpdateUserXP(dynamic userId, int xp) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/admin-manage/users/$userId/xp'),
        headers: getHeaders(),
        body: jsonEncode({'xp': xp}),
      );
      return response.statusCode == 200;
    } catch (e) { return false; }
  }

  // --- SUPPORT CHAT REAL-TIME API ---

  // User: Lấy tin nhắn với Admin
  static Future<List<dynamic>> getUserMessages() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/support/messages'), headers: getHeaders());
      return response.statusCode == 200 ? jsonDecode(response.body) : [];
    } catch (e) { return []; }
  }

  // User: Gửi tin nhắn đến Admin
  static Future<bool> sendSupportMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/support/messages'),
        headers: getHeaders(),
        body: jsonEncode({'message': message}),
      );
      return response.statusCode == 201;
    } catch (e) { return false; }
  }

  // Admin: Lấy danh sách cuộc hội thoại
  static Future<List<dynamic>> adminGetConversations() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/support/conversations'), headers: getHeaders());
      return response.statusCode == 200 ? jsonDecode(response.body) : [];
    } catch (e) { return []; }
  }

  // Admin: Lấy chi tiết cuộc hội thoại của User X
  static Future<List<dynamic>> adminGetConversationDetail(dynamic userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/support/conversations/$userId'), headers: getHeaders());
      return response.statusCode == 200 ? jsonDecode(response.body) : [];
    } catch (e) { return []; }
  }

  // Admin: Gửi phản hồi cho User X
  static Future<bool> adminReplyToUser(dynamic userId, String message) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/support/conversations/$userId'),
        headers: getHeaders(),
        body: jsonEncode({'message': message}),
      );
      return response.statusCode == 201;
    } catch (e) { return false; }
  }
}

