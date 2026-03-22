import 'package:flutter/foundation.dart';

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

/// 自动播放列表的切换顺序
enum AutoPlayOrder {
  /// 按添加顺序循环
  sequential,
  /// 随机下一张（与当前不同，列表仅一张时不变）
  random,
}

/// 播放器逻辑接口
abstract class PlayerLogic {
  /// 添加自动播放壁纸（重复 id 不会重复加入）
  void add(String wallpaperId);

  /// 设置自动切换顺序，默认 [AutoPlayOrder.sequential]
  void setAutoPlayOrder(AutoPlayOrder order);

  /// 设置自动切换间隔，默认 1 分钟
  void setAutoPlayInterval(Duration interval);

  /// 开始自动按间隔切换壁纸；若当前未在播放则先播放首张（顺序模式为列表首项，随机模式为随机一项）
  Future<void> startAutoPlay();

  /// 停止自动切换（不影响当前已加载的壁纸播放状态，仅停止定时器）
  void stopAutoPlay();

  /// 立即切换到指定壁纸并插队：从此刻起重新计时下一自动切换
  Future<void> play(String wallpaperId);

  /// 暂停壁纸
  Future<void> pause(String wallpaperId);

  /// 检查壁纸是否正在播放
  bool isPlaying(String wallpaperId);

  /// 获取当前播放的壁纸ID，如果当前没有播放的壁纸，则返回null
  String? getCurrentWallpaperId();

  /// 当前播放的壁纸ID变化时会通知
  ValueNotifier<String> get playingWallpaperIdNotifier;
}