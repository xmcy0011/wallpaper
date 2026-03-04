import 'drivenadapter.dart';
import 'dbaccess.dart';
import 'enginewrap.dart';
import 'logics.dart';

/// Services 服务实例管理
class Services {
  Services._internal();
  static final Services _instance = Services._internal();
  factory Services() => _instance;

  DBSystemSettings? dbSystemSettings;
  DBWallpaperStorage? dbWallpaperStorage;

  WallpaperEngineService? wallpaperEngineService;

  DrivenDownloadService? downloadService;
  DrivenAuthService? authService;

  StorageLogic? storageLogic;
  PlayerLogic? playerLogic;

  DBSystemSettings getSystemSettings() {
    return dbSystemSettings!;
  }

  void setSystemSettings(DBSystemSettings systemSettings) {
    dbSystemSettings = systemSettings;
  }

  DBWallpaperStorage getWallpaperStorage() {
    return dbWallpaperStorage!;
  }

  void setWallpaperStorage(DBWallpaperStorage wallpaperStorage) {
    dbWallpaperStorage = wallpaperStorage;
  }

  WallpaperEngineService getWallpaperEngineService() {
    return wallpaperEngineService!;
  }

  void setWallpaperEngineService(WallpaperEngineService wallpaperEngineService) {
    this.wallpaperEngineService = wallpaperEngineService;
  }

  DrivenDownloadService getDownloadService() {
    return downloadService!;
  }

  void setDownloadService(DrivenDownloadService downloadService) {
    this.downloadService = downloadService;
  }

  DrivenAuthService getAuthService() {
    return authService!;
  }

  void setAuthService(DrivenAuthService authService) {
    this.authService = authService;
  }

  StorageLogic getStorageLogic() {
    return storageLogic!;
  }

  void setStorageLogic(StorageLogic storageLogic) {
    this.storageLogic = storageLogic;
  }

  PlayerLogic getPlayerLogic() {
    return playerLogic!;
  }

  void setPlayerLogic(PlayerLogic playerLogic) {
    this.playerLogic = playerLogic;
  }
}
