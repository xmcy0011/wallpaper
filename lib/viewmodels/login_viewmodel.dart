import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

/// 登录 ViewModel
class LoginViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  String _username = '';
  String? _errorMessage;

  String get username => _username;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  void setUsername(String value) {
    _username = value;
    _errorMessage = null;
    notifyListeners();
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

