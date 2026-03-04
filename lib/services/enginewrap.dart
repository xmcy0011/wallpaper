import 'package:flutter/material.dart';

/// 壁纸引擎服务接口 - 封装 wallpaperEngine 原生 API
abstract class WallpaperEngineService {
  /// 创建壁纸实例
  Future<bool> create();

  /// 初始化壁纸引擎
  Future<bool> initialize();

  /// 加载壁纸
  /// [filePath] 文件路径（支持 .mp4/.webm/.gif/.jpg/.png 等）
  /// [displayRect] 可选，显示区域，传 null 使用主屏默认
  Future<bool> load(String filePath, {Rect? displayRect});

  /// 开始播放
  Future<void> play();

  /// 暂停播放
  Future<void> pause();

  /// 关闭壁纸
  Future<void> close();

  /// 释放壁纸资源
  Future<void> release();

  /// 检查壁纸是否已加载完成
  Future<bool> isLoaded();

  /// 检查壁纸是否已退出
  Future<bool> isExited();

  /// 获取主显示器区域（用于桌面嵌入）
  Future<Rect?> getPrimaryMonitorRect();
}
