import '../services/dbaccess.dart';
import '../services/drivenadapter.dart';

/// 壁纸存储逻辑接口
abstract class StorageLogic {
  /// 从URL保存壁纸
  /// [url] 壁纸URL
  /// [title] 壁纸标题
  /// [tags] 壁纸标签
  /// [description] 壁纸描述
  /// [type] 壁纸类型
  /// [onProgress] 可选，下载进度回调，progress 为 0.0 ~ 1.0
  /// [wallpaperId] 可选，指定壁纸ID，不传则自动生成
  /// [return] 本地存储的壁纸ID，如果保存失败则返回null
  Future<String?> saveWallpaperFromURL(
    String url,
    String title,
    List<String> tags,
    String description,
    DBWallpaperType type, {
    DownloadProgressCallback? onProgress,
    String? wallpaperId,
  });

  /// 获取本地壁纸列表
  /// [return] 本地壁纸列表，如果本地没有壁纸列表，则返回空列表
  Future<List<DBWallpaper>> getLocalWallpaperList();
}

/// 播放器逻辑接口
abstract class PlayerLogic {
  /// 播放壁纸
  Future<void> play(String wallpaperId);
  /// 暂停壁纸
  Future<void> pause(String wallpaperId);
  /// 检查壁纸是否正在播放
  bool isPlaying(String wallpaperId);
  /// 获取当前播放的壁纸ID，如果当前没有播放的壁纸，则返回null
  String? getCurrentWallpaperId();
}