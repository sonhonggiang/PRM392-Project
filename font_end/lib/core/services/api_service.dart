import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // Tự động phát hiện URL backend phù hợp theo nền tảng chạy app
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000/api';
    } else {
      // 10.0.2.2 là địa chỉ IP của Localhost của máy chủ từ góc nhìn của máy ảo Android
      return 'http://10.0.2.2:3000/api';
    }
  }

  // Token JWT lưu trữ trong bộ nhớ
  static String? token;

  // Header chuẩn cho các truy vấn
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

  // ─── 1. Module Xác thực (Authentication) ───────────────────────────────

  static Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: getHeaders(),
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        token = data['token']; // Lưu token
        return data;
      }
      return null;
    } catch (e) {
      print('Lỗi gọi API Đăng nhập: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> register(String email, String password, String displayName) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: getHeaders(),
        body: jsonEncode({'email': email, 'password': password, 'displayName': displayName}),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Lỗi gọi API Đăng ký: $e');
      return null;
    }
  }

  static Future<bool> sendOTP(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/otp/send'),
        headers: getHeaders(),
        body: jsonEncode({'email': email}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Lỗi gửi OTP: $e');
      return false;
    }
  }

  static Future<bool> verifyOTP(String email, String otpCode) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/otp/verify'),
        headers: getHeaders(),
        body: jsonEncode({'email': email, 'otpCode': otpCode}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Lỗi xác thực OTP: $e');
      return false;
    }
  }

  static Future<bool> resetPassword(String email, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/forgot-password'),
        headers: getHeaders(),
        body: jsonEncode({'email': email, 'newPassword': newPassword}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Lỗi đặt lại mật khẩu: $e');
      return false;
    }
  }

  // ─── 2. Module Mẫu Origami (Origami Models) ──────────────────────────

  static Future<List<dynamic>> getOrigamiList({String? search, String? category, String? sortBy}) async {
    try {
      final queryParams = <String, String>{};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (category != null && category.isNotEmpty) queryParams['category'] = category;
      if (sortBy != null && sortBy.isNotEmpty) queryParams['sortBy'] = sortBy;

      final uri = Uri.parse('$baseUrl/origami').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: getHeaders());

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print('Lỗi lấy danh sách Origami: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> getOrigamiDetail(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/origami/$id'), headers: getHeaders());
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Lỗi lấy chi tiết mẫu Origami: $e');
      return null;
    }
  }

  static Future<List<dynamic>> getPendingOrigami() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/origami/pending'), headers: getHeaders());
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print('Lỗi lấy danh sách mẫu chờ duyệt: $e');
      return [];
    }
  }

  static Future<bool> createOrigami(Map<String, dynamic> payload) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/origami'),
        headers: getHeaders(),
        body: jsonEncode(payload),
      );
      return response.statusCode == 201;
    } catch (e) {
      print('Lỗi gửi mẫu Origami mới: $e');
      return false;
    }
  }

  static Future<bool> approveOrRejectOrigami(int id, String status, {String? rejectionReason}) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/origami/$id/approval'),
        headers: getHeaders(),
        body: jsonEncode({'status': status, 'rejectionReason': rejectionReason}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Lỗi duyệt mẫu Origami: $e');
      return false;
    }
  }

  // ─── 3. Module Tiến trình & Yêu thích (Favorites & Progress) ──────────

  static Future<List<dynamic>> getFavorites() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users/favorites'), headers: getHeaders());
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print('Lỗi lấy danh sách yêu thích: $e');
      return [];
    }
  }

  static Future<bool> toggleFavorite(int origamiId) async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/users/favorites/$origamiId'), headers: getHeaders());
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['isFavorite'] ?? false;
      }
      return false;
    } catch (e) {
      print('Lỗi toggle yêu thích: $e');
      return false;
    }
  }

  static Future<List<dynamic>> getProgress() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users/progress'), headers: getHeaders());
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print('Lỗi lấy tiến trình học: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> updateProgress(int origamiId, int currentStep, bool isCompleted) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/users/progress/$origamiId'),
        headers: getHeaders(),
        body: jsonEncode({'currentStep': currentStep, 'isCompleted': isCompleted}),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Lỗi cập nhật tiến trình học: $e');
      return null;
    }
  }

  // ─── 4. Module Thống kê & Hoạt động (Analytics, Leaderboard & Badges) ──

  static Future<List<dynamic>> getLeaderboard() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/leaderboard'), headers: getHeaders());
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print('Lỗi lấy bảng xếp hạng: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> getUserAnalytics() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/analytics'), headers: getHeaders());
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Lỗi lấy thống kê người dùng: $e');
      return null;
    }
  }

  static Future<List<dynamic>> getUserBadges() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/badges'), headers: getHeaders());
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print('Lỗi lấy danh sách huy hiệu: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> getDailyChallenge() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/daily-challenge'), headers: getHeaders());
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Lỗi lấy thử thách ngày: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> completeDailyChallenge() async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/daily-challenge/complete'), headers: getHeaders());
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Lỗi hoàn thành thử thách ngày: $e');
      return null;
    }
  }
}
