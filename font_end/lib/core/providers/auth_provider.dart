import 'package:flutter/foundation.dart';
import '../../models/user_model.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  
  // Mặc định trả về mockGuest nếu chưa đăng nhập
  UserModel get currentUser => _currentUser ?? UserModel.mockGuest;
  
  bool get isAuthenticated => _currentUser != null && _currentUser!.role != UserRole.guest;
  
  UserRole get currentRole => currentUser.role;

  // Đăng nhập thực tế qua API
  // Trả về null nếu thành công, trả về chuỗi lỗi nếu thất bại
  Future<String?> login(String email, String password) async {
    try {
      final data = await ApiService.login(email, password);
      if (data != null) {
        if (data.containsKey('error')) {
          return data['error'];
        }
        
        if (data['user'] != null) {
          final userJson = data['user'];
          UserRole parsedRole = UserRole.user;
          if (userJson['role'] == 'admin') {
            parsedRole = UserRole.admin;
          } else if (userJson['role'] == 'creator') {
            parsedRole = UserRole.creator;
          }

          _currentUser = UserModel(
            id: userJson['id'].toString(),
            email: userJson['email'],
            displayName: userJson['displayName'] ?? userJson['display_name'] ?? '',
            avatarUrl: userJson['avatarUrl'] ?? userJson['avatar_url'] ?? '',
            role: parsedRole,
            xp: userJson['xp'] ?? 0,
            streakCount: userJson['streakCount'] ?? userJson['streak_count'] ?? 0,
            dailyMedals: userJson['daily_medals'] ?? userJson['dailyMedals'] ?? 0,
            weeklyTrophies: userJson['weekly_trophies'] ?? userJson['weeklyTrophies'] ?? 0,
          );
          notifyListeners();
          return null; // Thành công
        }
      }
      return "Lỗi đăng nhập không xác định";
    } catch (e) {
      return "Không thể kết nối đến máy chủ. Kiểm tra IP: ${ApiService.baseUrl}";
    }
  }

  // Đăng ký thực tế qua API
  // Trả về null nếu thành công, trả về chuỗi lỗi nếu thất bại
  Future<String?> register(String email, String password, String displayName) async {
    final data = await ApiService.register(email, password, displayName);
    if (data != null && data.containsKey('error')) {
      return data['error'];
    }
    return data != null ? null : "Lỗi không xác định";
  }

  // Giả lập chuyển đổi vai trò nhanh để test UI (Admin/User/Guest)
  void loginAs(UserModel user) {
    _currentUser = user;
    if (user.role == UserRole.guest) {
      ApiService.token = null;
    } else {
      // Gán token giả lập để vượt qua kiểm tra API nếu cần
      ApiService.token = 'mock_token_${user.id}';
    }
    notifyListeners();
  }

  // Cập nhật thông tin cá nhân mới nhất từ server
  Future<void> refreshProfile() async {
    if (_currentUser == null || _currentUser!.role == UserRole.guest) return;
    
    final userJson = await ApiService.getUserProfile();
    if (userJson != null) {
      UserRole parsedRole = UserRole.user;
      if (userJson['role'] == 'admin') {
        parsedRole = UserRole.admin;
      } else if (userJson['role'] == 'creator') {
        parsedRole = UserRole.creator;
      }

      _currentUser = UserModel(
        id: userJson['id'].toString(),
        email: userJson['email'],
        displayName: userJson['display_name'] ?? userJson['displayName'] ?? '',
        avatarUrl: userJson['avatar_url'] ?? userJson['avatarUrl'] ?? '',
        role: parsedRole,
        xp: userJson['xp'] ?? 0,
        streakCount: userJson['streak_count'] ?? userJson['streakCount'] ?? 0,
        dailyMedals: userJson['daily_medals'] ?? userJson['dailyMedals'] ?? 0,
        weeklyTrophies: userJson['weekly_trophies'] ?? userJson['weeklyTrophies'] ?? 0,
      );
      notifyListeners();
    }
  }

  // Đăng xuất
  void logout() {
    _currentUser = null;
    ApiService.token = null;
    notifyListeners();
  }
}
