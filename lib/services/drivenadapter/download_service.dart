import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;

import '../drivenadapter.dart';

/// 下载服务实现
class DownloadServiceImpl implements DrivenDownloadService {
  final Dio _dio = Dio();

  @override
  Future<void> download(
    String url,
    String savePath, {
    DownloadProgressCallback? onProgress,
  }) async {
    final dir = path.dirname(savePath);
    final dirFile = Directory(dir);
    if (!await dirFile.exists()) {
      await dirFile.create(recursive: true);
    }

    await _dio.download(
      url,
      savePath,
      onReceiveProgress: (received, total) {
        if (total != -1 && onProgress != null) {
          onProgress(received / total);
        }
      },
      options: Options(
        followRedirects: true,
        validateStatus: (status) => status != null && status < 400,
      ),
    );
  }
}