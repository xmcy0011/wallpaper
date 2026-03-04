import 'package:flutter/foundation.dart';
import '../drivenadapter.dart';

/// 认证服务 - 管理用户登录状态
class DrivenAuthServiceImpl implements DrivenAuthService {
  AuthState _loginState = AuthState.initial;
  String? _userName;
  String? _userAvatar;
  final _loginStateNotifier = ValueNotifier<AuthState>(AuthState.initial);

  @override
  AuthState get loginState => _loginState;
  @override
  String? get userName => _userName;
  @override
  String? get userAvatar => _userAvatar;
  @override
  ValueNotifier<AuthState> get loginStateNotifier => _loginStateNotifier;

  /// 登录
  @override
  Future<void> login(String username, {String? avatar}) async {
    _userName = username;
    _userAvatar = avatar;
    _loginState = AuthState.loggedIn;
  }

  /// 登出
  @override
  Future<void> logout() async {
    _loginState = AuthState.loggedOut;
    _userName = null;
    _userAvatar = null;
  }
}
