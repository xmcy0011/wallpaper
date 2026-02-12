/**
 * @file api.cpp
 * @brief api.h 实现 - 封装 desktop_embed 和 wallpaper_engine
 */

#include "api.h"
#include "desktop_embed.h"
#include "webview2_engine.h"

namespace {

// 嵌入的窗口
std::unordered_map<HWND, DesktopCoreHandle> g_embed_windows = {};

// 获取主显示器区域
void GetPrimaryMonitorBounds(RECT *out) {
  MONITORINFO mi = {sizeof(mi)};
  HMONITOR hMon = MonitorFromWindow(nullptr, MONITOR_DEFAULTTOPRIMARY);
  if (GetMonitorInfoW(hMon, &mi)) {
    *out = mi.rcMonitor;
  } else {
    out->left = out->top = 0;
    out->right = GetSystemMetrics(SM_CXSCREEN);
    out->bottom = GetSystemMetrics(SM_CYSCREEN);
  }
}

// DisplayRect 转 RECT
RECT ToRect(const DisplayRect *r) {
  if (!r) {
    RECT rect;
    GetPrimaryMonitorBounds(&rect);
    return rect;
  }
  RECT rect = {r->x, r->y, r->x + r->width, r->y + r->height};
  return rect;
}

} // namespace

#ifdef __cplusplus
extern "C" {
#endif

/* ==================== WallpaperHandle 实现 ==================== */

WALLPAPER_API WallpaperHandle wallpaper_create(void) {
  return new engine::WebView2Engine();
}

WALLPAPER_API bool wallpaper_initialize(WallpaperHandle handle) {
  auto *engine = reinterpret_cast<engine::WebView2Engine *>(handle);
  return engine ? engine->Initialize() : false;
}

WALLPAPER_API HWND wallpaper_get_handle(WallpaperHandle wp) {
  auto *engine = reinterpret_cast<engine::WebView2Engine *>(wp);
  return engine ? engine->GetWindowHandle() : nullptr;
}

WALLPAPER_API bool wallpaper_load(WallpaperHandle handle,
                                  const std::wstring *file_path,
                                  const DisplayRect *display,
                                  WallpaperStateCallback state_cb,
                                  void *user_data) {

  if (file_path->empty())
    return false;

  auto *engine = reinterpret_cast<engine::WebView2Engine *>(handle);
  if (!engine->IsInitialized()) {
    return false;
  }

  if (state_cb) {
    engine->SetLoadedCallback(
        [state_cb, user_data]() { state_cb(user_data, true, false); });
    engine->SetExitedCallback(
        [state_cb, user_data]() { state_cb(user_data, false, true); });
  }

  if (!engine->LoadMedia(*file_path)) {
    return false;
  }
  return true;
}

WALLPAPER_API bool wallpaper_is_loaded(WallpaperHandle wp) {
  auto *engine = reinterpret_cast<engine::WebView2Engine *>(wp);
  return engine ? engine->IsLoaded() : false;
}

WALLPAPER_API bool wallpaper_is_exited(WallpaperHandle wp) {
  auto *engine = reinterpret_cast<engine::WebView2Engine *>(wp);
  return engine ? engine->IsExited() : false;
}

WALLPAPER_API WallpaperType wallpaper_get_type(WallpaperHandle wp) {
  (void)wp;
  return WALLPAPER_TYPE_VIDEO; // 内部未存储类型，可扩展
}

WALLPAPER_API void wallpaper_play(WallpaperHandle wp) {
  auto *engine = reinterpret_cast<engine::WebView2Engine *>(wp);
  if (engine)
    engine->Play();
}

WALLPAPER_API void wallpaper_pause(WallpaperHandle wp) {
  auto *engine = reinterpret_cast<engine::WebView2Engine *>(wp);
  if (engine)
    engine->Pause();
}

WALLPAPER_API void wallpaper_close(WallpaperHandle wp) {
  auto *engine = reinterpret_cast<engine::WebView2Engine *>(wp);
  if (engine)
    engine->Close();
}

WALLPAPER_API void wallpaper_terminate(WallpaperHandle wp) {
  wallpaper_close(wp); // 当前实现与 close 相同
}

WALLPAPER_API void wallpaper_release(WallpaperHandle wp) {
  auto *engine = reinterpret_cast<engine::WebView2Engine *>(wp);
  if (engine) {
    engine->Close();
    delete engine;
  }
}

/* ==================== DesktopCoreHandle 实现 ==================== */

WALLPAPER_API HWND desktop_core_get_worker_w(DesktopCoreHandle core) {
  auto *ctx = reinterpret_cast<engine::DesktopEmbedContext *>(core);
  return ctx ? ctx->workerW : nullptr;
}

WALLPAPER_API bool desktop_get_primary_monitor(DisplayRect &rect) {
  RECT tmp;
  GetPrimaryMonitorBounds(&tmp);
  rect.x = tmp.left;
  rect.y = tmp.top;
  rect.width = tmp.right - tmp.left;
  rect.height = tmp.bottom - tmp.top;
  return true;
}

WALLPAPER_API DesktopCoreHandle desktop_core_create(void) {
  engine::DesktopEmbedContext *ctx = new engine::DesktopEmbedContext();
  if (!engine::InitDesktopLayer(*ctx)) {
    delete ctx;
    return nullptr;
  }
  return ctx;
}

WALLPAPER_API void desktop_core_release(DesktopCoreHandle core) {
  if (core) {
    auto instance = reinterpret_cast<engine::DesktopEmbedContext *>(core);
    delete instance;
  }
}

WALLPAPER_API bool desktop_is_embed_window(HWND hwnd) {
  return g_embed_windows.find(hwnd) != g_embed_windows.end();
}

WALLPAPER_API bool desktop_embed_window(HWND hwnd, DesktopCoreHandle core,
                                        const DisplayRect *rect) {
  auto *ctx = reinterpret_cast<engine::DesktopEmbedContext *>(core);
  if (!ctx || !ctx->workerW || !IsWindow(hwnd)) {
    return false;
  }

  RECT r = ToRect(rect);
  bool result = engine::AttachToDesktop(hwnd, *ctx, r);
  if (result) {
    g_embed_windows[hwnd] = core;
  }
  return result;
}

WALLPAPER_API void desktop_detach_window(HWND hwnd) {
  engine::DetachFromDesktop(hwnd);
  g_embed_windows.erase(hwnd);
}

#ifdef __cplusplus
}
#endif
