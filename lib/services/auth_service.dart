import 'package:flutter/foundation.dart';

/// 认证服务 - 管理用户登录状态
class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  bool _isLoggedIn = false;
  String? _userName;
  String? _userAvatar;

  bool get isLoggedIn => _isLoggedIn;
  String? get userName => _userName;
  String? get userAvatar => _userAvatar;

  /// 登录
  Future<void> login(String username, {String? avatar}) async {
    _isLoggedIn = true;
    _userName = username;
    _userAvatar = avatar;
    notifyListeners();
  }

  /// 登出
  Future<void> logout() async {
    _isLoggedIn = false;
    _userName = null;
    _userAvatar = null;
    notifyListeners();
  }
}

