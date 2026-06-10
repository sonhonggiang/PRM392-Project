import 'package:flutter/foundation.dart';
import '../../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  
  // Default to guest if no user is logged in
  UserModel get currentUser => _currentUser ?? UserModel.mockGuest;
  
  bool get isAuthenticated => _currentUser != null && _currentUser!.role != UserRole.guest;
  
  UserRole get currentRole => currentUser.role;

  // Mock login method
  void loginAs(UserModel user) {
    _currentUser = user;
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
