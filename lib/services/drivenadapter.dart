import 'package:flutter/foundation.dart';

/// 400 错误
class BadRequestException implements Exception {
  final String message;
  BadRequestException(this.message);
}

/// 401 错误
class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException(this.message);
}

/// 403 错误
class ForbiddenException implements Exception {
  final String message;
  ForbiddenException(this.message);
}

/// 404 错误
class NotFoundException implements Exception {
  final String message;
  NotFoundException(this.message);
}

// 500 错误
class InternalServerErrorException implements Exception {
  final String message;
  InternalServerErrorException(this.message);
}

enum AuthState {
  initial, // 初始状态
  loggedIn, // 已登录
  loggingIn, // 登录中
  loggedOut, // 已登出
}

/// 认证服务接口
abstract class DrivenAuthService {
  AuthState get loginState;
  String? get userName;
  String? get userAvatar;
  Future<void> login(String username, {String? avatar});
  Future<void> logout();
  ValueNotifier<AuthState> get loginStateNotifier;
}

/// 下载进度回调，progress 为 0.0 ~ 1.0
typedef DownloadProgressCallback = void Function(double progress);

/// 下载服务接口
abstract class DrivenDownloadService {
  /// 下载文件到指定路径
  /// [url] 下载地址
  /// [savePath] 保存路径
  /// [onProgress] 可选，下载进度回调，progress 为 0.0 ~ 1.0
  Future<void> download(String url, String savePath, {DownloadProgressCallback? onProgress});
}
