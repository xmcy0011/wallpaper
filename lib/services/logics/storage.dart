import 'package:uuid/uuid.dart';
import 'dart:io';
import 'package:image/image.dart' as img;

import '../logics.dart';
import '../dbaccess.dart';
import '../drivenadapter.dart';

class StorageLogicImpl implements StorageLogic {
  late DBSystemSettings dbSystemSettings;
  late DrivenDownloadService downloadService;
  late DBWallpaperStorage wallpaperStorage;

  StorageLogicImpl(this.dbSystemSettings, this.downloadService, this.wallpaperStorage);

  /// 将图片URL转换为4K分辨率(3840x2160)，支持 picsum.photos 等格式
  String _build4KUrl(String url) {
    return url.replaceFirst(RegExp(r'/\d+/\d+'), '/3840/2160');
  }

  @override
  Future<String?> saveWallpaperFromURL(
    String url,
    String title,
    List<String> tags,
    String description,
    DBWallpaperType type, {
    DownloadProgressCallback? onProgress,
    String? wallpaperId,
  }) async {
    // 使用传入的 wallpaperId 或生成新的
    String id = wallpaperId ?? Uuid().v4();

    // 创建壁纸目录
    String wallpaperPath = '${dbSystemSettings.getWallpaperPath()}/$id';
    if (!await Directory(wallpaperPath).exists()) {
      await Directory(wallpaperPath).create(recursive: true);
    }

    // 使用4K分辨率URL下载壁纸
    String downloadUrl = _build4KUrl(url);

    // 下载壁纸
    String savePath = '$wallpaperPath/$id.png';
    await downloadService.download(downloadUrl, savePath, onProgress: onProgress);

    // 制作缩略图
    String thumbnailPath = '$wallpaperPath/preview.png';
    await createThumbnail(savePath, thumbnailPath, DBWallpaperType.image);

    // 保存壁纸
    DBWallpaper wallpaper = DBWallpaper(
      wallpaperId: id,
      title: title,
      tags: tags,
      description: description,
      file: '$id.png',
      preview: "preview.png",
      type: type,
    );
    await wallpaperStorage.addWallpaper(wallpaper);
    return id;
  }

  Future<void> createThumbnail(String filePath, String thumbnailPath, DBWallpaperType type) async {
    switch (type) {
      case DBWallpaperType.video:
        throw Exception('video type not supported');
      case DBWallpaperType.gif || DBWallpaperType.image:
        // 缩略图制作，缩放到 512x512
        final maxWidth = 512;
        final maxHeight = 512;
        final bytes = await File(filePath).readAsBytes();
        final image = img.decodeImage(bytes);
        if (image == null) throw Exception('无法解码图片');

        // 保持宽高比缩放
        final thumbnail = img.copyResize(image, width: maxWidth, height: maxHeight);
        await File(thumbnailPath).writeAsBytes(img.encodePng(thumbnail));
        return;
    }
  }
}
