#ifndef RUNNER_WALLPAPER_ENGINE_CHANNEL_H_
#define RUNNER_WALLPAPER_ENGINE_CHANNEL_H_

#include <flutter/flutter_engine.h>

/// 注册壁纸引擎 MethodChannel，处理 Dart 端调用
void RegisterWallpaperEngineChannel(flutter::FlutterEngine* engine);

#endif  // RUNNER_WALLPAPER_ENGINE_CHANNEL_H_
