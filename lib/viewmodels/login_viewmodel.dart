import 'package:flutter/foundation.dart';
import '../services/drivenadapter.dart';
import '../services/services.dart';

/// 登录 ViewModel
class LoginViewModel extends ChangeNotifier{
  final DrivenAuthService _authService = Services().getAuthService();
  AuthState get loginState => _authService.loginState;
  String? get userAvatar => _authService.userAvatar;

  String _username = '';
  String? _errorMessage;

  String get userName => _username;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  ValueNotifier<AuthState> get loginStateNotifier => ValueNotifier<AuthState>(_authService.loginState);

  void setUsername(String value) {
    _username = value;
    _errorMessage = null;
  }

  Future<bool> login() async {
    if (_username.trim().isEmpty) {
      _errorMessage = '请输入用户名';
      notifyListeners();
      return false;
    }

    try {
      await _authService.login(_username.trim());
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = '登录失败: $e';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

