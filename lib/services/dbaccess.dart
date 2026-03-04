/// 系统设置服务接口
abstract class DBSystemSettings {
  String getWallpaperPath();
}

/// 壁纸类型
enum DBWallpaperType {
  video, // 视频
  gif, // gif
  image, // 图片
}

/// 壁纸模型
class DBWallpaper {
  final String wallpaperId;    // 壁纸ID
  final String title;          // 壁纸标题
  final List<String> tags;     // 标签
  final String description;    // 描述
  final String file;      // 壁纸文件名
  final String preview;   // 缩略图路径
  final DBWallpaperType type;  // 壁纸类型

  DBWallpaper({
    required this.wallpaperId,
    required this.title,
    required this.tags,
    required this.description,
    required this.file,
    required this.preview,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
        'wallpaperId': wallpaperId,
        'title': title,
        'tags': tags,
        'description': description,
        'file': file,
        'preview': preview,
        'type': type.name,
      };
}

/// 壁纸管理服务接口
abstract class DBWallpaperStorage {
  /// 获取壁纸列表
  Future<List<DBWallpaper>> getWallpaperList();

  /// 添加壁纸
  Future<void> addWallpaper(DBWallpaper wallpaper);

  /// 删除壁纸
  Future<void> deleteWallpaper(DBWallpaper wallpaper);

  /// 获取本地壁纸信息
  /// [wallpaperId] 壁纸ID
  /// [return] 本地壁纸信息，如果本地没有壁纸信息，则返回null
  DBWallpaper? getLocalWallpaper(String wallpaperId);

  /// 获取壁纸文件的完整路径
  /// [wallpaperId] 壁纸ID
  /// [relativeFile] 相对文件名（如 wallpaperId.png）
  String getWallpaperFilePath(String wallpaperId, String relativeFile);
}
