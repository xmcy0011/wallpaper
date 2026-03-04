import '../dbaccess.dart';

/// 系统设置服务 - 管理系统设置信息
class DBSystemSettingsImpl implements DBSystemSettings {
  // 获取壁纸保存路径
  @override
  String getWallpaperPath() {
    return 'data/wallpaper';
  }
}
