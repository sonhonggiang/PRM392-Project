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
  Future<bool> login(String email, String password) async {
    final data = await ApiService.login(email, password);
    if (data != null && data['user'] != null) {
      final userJson = data['user'];
      
      // Chuyển đổi chuỗi role thành UserRole enum
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
      );


      notifyListeners();
      return true;
    }
    return false;
  }

  // Đăng ký thực tế qua API
  Future<bool> register(String email, String password, String displayName) async {
    final data = await ApiService.register(email, password, displayName);
    return data != null;
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

  // Đăng xuất
  void logout() {
    _currentUser = null;
    ApiService.token = null;
    notifyListeners();
  }
}
