import 'package:logging/logging.dart';

/// Logger 扩展：带调用位置（文件:行号）的日志方法
/// 使用 i/w/e/d 避免与 Logger 原有方法冲突
extension LoggerExt on Logger {
  void i(Object? message) => log(Level.INFO, message, null, StackTrace.current);
  void w(Object? message) => log(Level.WARNING, message, null, StackTrace.current);
  void e(Object? message) => log(Level.SEVERE, message, null, StackTrace.current);
  void d(Object? message) => log(Level.FINE, message, null, StackTrace.current);
}
