import 'package:flutter/services.dart';
import '../enginewrap.dart';
import 'dart:developer';

/// 壁纸引擎服务实现 - 通过 MethodChannel 调用 Windows 原生 API
class WallpaperEngineServiceImpl implements WallpaperEngineService {
  static const MethodChannel _channel = MethodChannel('com.example.wallpaper/engine');

  @override
  Future<bool> create() async {
    try {
      final result = await _channel.invokeMethod<bool>('create');
      log('create wallpaper engine: $result');
      return result ?? false;
    } on PlatformException catch (_) {
      return false;
    }
  }

  @override
  Future<bool> initialize() async {
    try {
      final result = await _channel.invokeMethod<bool>('initialize');
      log('initialize wallpaper engine: $result');
      return result ?? false;
    } on PlatformException catch (_) {
      return false;
    }
  }

  @override
  Future<bool> load(String filePath, {Rect? displayRect}) async {
    try {
      final result = await _channel.invokeMethod<bool>('load', {
        'filePath': filePath,
        if (displayRect != null)
          'displayRect': {
            'x': displayRect.left.toInt(),
            'y': displayRect.top.toInt(),
            'width': displayRect.width.toInt(),
            'height': displayRect.height.toInt(),
          },
      });
      return result ?? false;
    } on PlatformException catch (_) {
      return false;
    }
  }

  @override
  Future<void> play() async {
    await _channel.invokeMethod('play');
  }

  @override
  Future<void> pause() async {
    await _channel.invokeMethod('pause');
  }

  @override
  Future<void> close() async {
    await _channel.invokeMethod('close');
  }

  @override
  Future<void> release() async {
    await _channel.invokeMethod('release');
  }

  @override
  Future<bool> isLoaded() async {
    try {
      final result = await _channel.invokeMethod<bool>('isLoaded');
      return result ?? false;
    } on PlatformException catch (_) {
      return false;
    }
  }

  @override
  Future<bool> isExited() async {
    try {
      final result = await _channel.invokeMethod<bool>('isExited');
      return result ?? false;
    } on PlatformException catch (_) {
      return false;
    }
  }

  @override
  Future<Rect?> getPrimaryMonitorRect() async {
    try {
      final result = await _channel.invokeMethod<Map<Object?, Object?>>('getPrimaryMonitorRect');
      if (result == null) return null;
      final x = (result['x'] as num?)?.toInt() ?? 0;
      final y = (result['y'] as num?)?.toInt() ?? 0;
      final width = (result['width'] as num?)?.toInt() ?? 0;
      final height = (result['height'] as num?)?.toInt() ?? 0;
      return Rect.fromLTWH(x.toDouble(), y.toDouble(), width.toDouble(), height.toDouble());
    } on PlatformException catch (_) {
      return null;
    }
  }
}
