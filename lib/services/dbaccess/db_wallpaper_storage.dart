import '../dbaccess.dart';
import 'dart:convert';
import 'dart:io';

/// 壁纸存储服务实现
class DBWallpaperStorageImpl implements DBWallpaperStorage {
  late DBSystemSettings dbSystemSettings;
  DBWallpaperStorageImpl(this.dbSystemSettings);

  @override
  Future<List<DBWallpaper>> getWallpaperList() async {
    return [];
  }

  @override
  Future<void> addWallpaper(DBWallpaper wallpaper) async {
    String jsonString = jsonEncode(wallpaper.toJson());
    String projectFilePath = getWallpaperPath(wallpaper.wallpaperId);
    String dir = '${dbSystemSettings.getWallpaperPath()}/${wallpaper.wallpaperId}';
    await Directory(dir).create(recursive: true);
    await File(projectFilePath).writeAsString(jsonString);
  }

  String getWallpaperPath(String wallpaperId) {
    return '${dbSystemSettings.getWallpaperPath()}/$wallpaperId/project.json';
  }

  @override
  Future<void> deleteWallpaper(DBWallpaper wallpaper) async {}

  @override
  DBWallpaper? getLocalWallpaper(String wallpaperId) {
    // 解析 project.json 文件
    String projectFilePath = getWallpaperPath(wallpaperId);
    if (!File(projectFilePath).existsSync()) return null;
    String projectJson = File(projectFilePath).readAsStringSync();
    Map<String, dynamic> projectMap = jsonDecode(projectJson);
    return DBWallpaper(
      wallpaperId: wallpaperId,
      title: projectMap['title'] as String,
      tags: (projectMap['tags'] as List).map((e) => e.toString()).toList(),
      description: projectMap['description'] as String,
      file: projectMap['file'] as String,
      preview: projectMap['preview'] as String,
      type: DBWallpaperType.values.byName(projectMap['type'] as String),
    );
  }

  @override
  String getWallpaperFilePath(String wallpaperId, String relativeFile) {
    // 获取当前目录
    String currentDir = Directory.current.path;
    String dir = '$currentDir/${dbSystemSettings.getWallpaperPath()}/$wallpaperId';
    return '$dir/$relativeFile';
  }
}
