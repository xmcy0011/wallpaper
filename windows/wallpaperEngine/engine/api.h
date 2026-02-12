/**
 * @file api.h
 * @brief 动态壁纸引擎对外 API - 从 C# IWallpaper 和 IDesktopCore 迁移
 *
 * 简化版接口，保留核心功能：加载显示、循环播放、关闭退出
 */

#pragma once

#ifndef WALLPAPER_ENGINE_API_H
#define WALLPAPER_ENGINE_API_H

#if defined(WALLPAPER_ENGINE_STATIC)
#define WALLPAPER_API
#elif defined(WALLPAPER_ENGINE_EXPORTS)
#define WALLPAPER_API __declspec(dllexport)
#else
#define WALLPAPER_API __declspec(dllimport)
#endif

#include <stdbool.h>
#include <stdint.h>
#include <string>
#include <windows.h>


#ifdef __cplusplus
extern "C" {
#endif

/* ==================== 类型定义 ==================== */

/** 壁纸类型 */
typedef enum {
  WALLPAPER_TYPE_VIDEO = 0,
  WALLPAPER_TYPE_GIF,
  WALLPAPER_TYPE_IMAGE
} WallpaperType;

/** 显示区域信息 */
typedef struct {
  int x;
  int y;
  int width;
  int height;
} DisplayRect;

/** 壁纸状态回调 */
typedef void (*WallpaperStateCallback)(void *user_data, bool loaded,
                                       bool exited);

/* ==================== IWallpaper 接口抽象 ==================== */

/**
 * 壁纸句柄（不透明）
 */
typedef void *WallpaperHandle;

/**
 * 创建桌面壁纸句柄实例
 * @return 壁纸句柄实例，失败返回 NULL
 */
WALLPAPER_API WallpaperHandle wallpaper_create(void);

/**
 * 初始化壁纸引擎
 * @param handle 壁纸句柄实例
 * @return 是否成功
 */
WALLPAPER_API bool wallpaper_initialize(WallpaperHandle handle);

/**
 * 设置壁纸
 * @param handle 壁纸句柄实例
 * @param file_path 文件路径（支持 .mp4/.webm/.gif/.jpg/.png 等）
 * @param display 显示区域（主屏可传 NULL 使用默认）
 * @param state_cb 可选状态回调（loaded/exited），传 NULL 表示不需要
 * @param user_data 回调的 user_data
 * @return 壁纸句柄，失败返回 NULL
 */
WALLPAPER_API bool wallpaper_load(WallpaperHandle handle,
                                  const std::wstring *file_path,
                                  const DisplayRect *display,
                                  WallpaperStateCallback state_cb,
                                  void *user_data);

/**
 * 获取壁纸窗口句柄
 * @param wp 壁纸句柄
 * @return 窗口 HWND，失败返回 NULL
 */
WALLPAPER_API HWND wallpaper_get_handle(WallpaperHandle wp);

/**
 * 检查壁纸是否已加载完成
 */
WALLPAPER_API bool wallpaper_is_loaded(WallpaperHandle wp);

/**
 * 检查壁纸是否已退出
 */
WALLPAPER_API bool wallpaper_is_exited(WallpaperHandle wp);

/**
 * 获取壁纸类型
 */
WALLPAPER_API WallpaperType wallpaper_get_type(WallpaperHandle wp);

/**
 * 开始播放壁纸
 */
WALLPAPER_API void wallpaper_play(WallpaperHandle wp);

/**
 * 暂停壁纸播放
 */
WALLPAPER_API void wallpaper_pause(WallpaperHandle wp);

/**
 * 关闭壁纸
 */
WALLPAPER_API void wallpaper_close(WallpaperHandle wp);

/**
 * 强制终止壁纸
 */
WALLPAPER_API void wallpaper_terminate(WallpaperHandle wp);

/**
 * 释放壁纸资源
 */
WALLPAPER_API void wallpaper_release(WallpaperHandle wp);

/* ==================== 桌面嵌入相关 ==================== */

/**
 * 桌面核心句柄（不透明）
 */
typedef void *DesktopCoreHandle;

/**
 * 创建桌面核心
 * @return 桌面核心句柄，失败返回 NULL
 */
WALLPAPER_API DesktopCoreHandle desktop_core_create(void);

/**
 * 释放桌面核心
 */
WALLPAPER_API void desktop_core_release(DesktopCoreHandle core);

/**
 * 获取 WorkerW 窗口句柄（用于桌面嵌入）
 */
WALLPAPER_API HWND desktop_core_get_worker_w(DesktopCoreHandle core);

/**
 * 获取主显示器区域
 * @param rect 主显示器区域
 * @return 是否成功
 */
WALLPAPER_API bool desktop_get_primary_monitor(DisplayRect &rect);

/**
 * 检查窗口是否已嵌入到桌面
 * @param hwnd 窗口句柄
 * @return 是否已嵌入到桌面
 */
WALLPAPER_API bool desktop_is_embed_window(HWND hwnd);

/**
 * 将窗口嵌入到桌面背景（WorkerW）
 * @param hwnd 要嵌入的窗口句柄
 * @param core 桌面核心句柄
 * @param rect 窗口在 WorkerW 中的位置和大小
 * @return 成功返回 true
 */
WALLPAPER_API bool desktop_embed_window(HWND hwnd, DesktopCoreHandle core,
                                        const DisplayRect *rect);

/**
 * 从桌面分离窗口
 */
WALLPAPER_API void desktop_detach_window(HWND hwnd);

#ifdef __cplusplus
}
#endif

#endif /* WALLPAPER_ENGINE_API_H */
