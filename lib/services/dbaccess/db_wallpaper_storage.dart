import '../dbaccess.dart';
import '../../utils/logger_ext.dart';
import 'dart:convert';
import 'dart:io';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;

/// 壁纸存储服务实现
class DBWallpaperStorageImpl implements DBWallpaperStorage {
  late DBSystemSettings dbSystemSettings;
  final logger = Logger('DBWallpaperStorageImpl');

  DBWallpaperStorageImpl(this.dbSystemSettings);

  @override
  Future<List<DBWallpaper>> getWallpaperList() async {
    String currentDir = Directory.current.path;
    String wallpaperPath = '$currentDir/${dbSystemSettings.getWallpaperPath()}';
    logger.i('getWallpaperList, wallpaperPath: $wallpaperPath');

    Directory wallpaperDir = Directory(wallpaperPath);
    if (!wallpaperDir.existsSync()) {
      logger.e('getWallpaperList, wallpaperPath not exists');
      return [];
    }

    List<DBWallpaper> wallpapers = [];
    for (var entry in wallpaperDir.listSync()) {
      // 先解析 project.json 文件
      String wallpaperId = path.basename(entry.path);
      String projectFilePath = '$wallpaperPath/$wallpaperId/project.json';
      if (!File(projectFilePath).existsSync()) {
        logger.e('getWallpaperList, project file not exists: $projectFilePath, wallpaperId: $wallpaperId');
        continue;
      }

      String json = File(projectFilePath).readAsStringSync();
      Map<String, dynamic> jsonMap = jsonDecode(json);
      DBWallpaper wallpaper = DBWallpaper(
        wallpaperId: jsonMap['wallpaperId'],
        title: jsonMap['title'],
        tags: (jsonMap['tags'] as List).map((e) => e.toString()).toList(),
        description: jsonMap['description'],
        file: jsonMap['file'] as String,
        preview: jsonMap['preview'] as String,
        type: DBWallpaperType.values.byName(jsonMap['type'] as String),
      );

      // 检查 preview 和 file 文件是否存在
      String previewPath = '${dbSystemSettings.getWallpaperPath()}/$wallpaperId/${wallpaper.preview}';
      String filePath = '${dbSystemSettings.getWallpaperPath()}/$wallpaperId/${wallpaper.file}';
      if (!File(previewPath).existsSync() || !File(filePath).existsSync()) continue;

      wallpapers.add(wallpaper);
    }

    logger.d('getWallpaperList, wallpapers: ${wallpapers.length}');
    return wallpapers;
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
