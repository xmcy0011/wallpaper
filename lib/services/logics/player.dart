import '../logics.dart';
import '../dbaccess.dart';
import '../enginewrap.dart';
import 'dart:developer';

class PlayerLogicImpl implements PlayerLogic {
  late WallpaperEngineService wallpaperEngineService;
  late DBWallpaperStorage wallpaperStorage;

  PlayerLogicImpl(this.wallpaperEngineService, this.wallpaperStorage) {
    wallpaperEngineService.create();
    wallpaperEngineService.initialize();
  }

  String? _currentWallpaperId;

  @override
  Future<void> play(String wallpaperId) async {
    _currentWallpaperId = wallpaperId;

    // 读取本地壁纸信息
    DBWallpaper? wallpaper = wallpaperStorage.getLocalWallpaper(wallpaperId);
    if (wallpaper == null) {
      throw Exception('壁纸不存在');
    }

    // 加载壁纸（使用完整路径）
    String fullPath = wallpaperStorage.getWallpaperFilePath(wallpaperId, wallpaper.file);
    wallpaperEngineService.load(fullPath);
    log('load wallpaper: $fullPath');

    // 开始播放
    wallpaperEngineService.play();
  }

  @override
  Future<void> pause(String wallpaperId) async {
    _currentWallpaperId = null;
    // 暂停播放
    wallpaperEngineService.pause();
  }

  @override
  bool isPlaying(String wallpaperId) {
    return _currentWallpaperId == wallpaperId;
  }

  @override
  String? getCurrentWallpaperId() {
    return _currentWallpaperId;
  }
}