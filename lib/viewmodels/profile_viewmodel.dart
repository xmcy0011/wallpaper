import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

/// 个人中心 ViewModel
class ProfileViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool get isLoggedIn => _authService.isLoggedIn;
  String? get userName => _authService.userName;
  String? get userAvatar => _authService.userAvatar;

  ProfileViewModel() {
    _authService.addListener(_onAuthStateChanged);
  }

  @override
  void dispose() {
    _authService.removeListener(_onAuthStateChanged);
    super.dispose();
  }

  void _onAuthStateChanged() {
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.logout();
  }
}

