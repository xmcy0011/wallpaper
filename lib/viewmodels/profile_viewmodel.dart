import 'package:flutter/foundation.dart';
import '../services/drivenadapter.dart';
import '../services/services.dart';

/// 个人中心 ViewModel
class ProfileViewModel extends ChangeNotifier {
  final DrivenAuthService _authService = Services().getAuthService();

  bool get isLoggedIn => _authService.loginState == AuthState.loggedIn;
  String? get userName => _authService.userName;
  String? get userAvatar => _authService.userAvatar;

  ProfileViewModel() {
    _authService.loginStateNotifier.addListener(_onAuthStateChanged);
  }

  @override
  void dispose() {
    _authService.loginStateNotifier.removeListener(_onAuthStateChanged);
    super.dispose();
  }

  void _onAuthStateChanged() {
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.logout();
  }
}

