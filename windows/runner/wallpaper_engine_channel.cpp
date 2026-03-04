#include "wallpaper_engine_channel.h"

#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>

#include <memory>
#include <string>

#include "api.h"

namespace {

// UTF-8 转 std::wstring (Windows)
std::wstring Utf8ToWstring(const std::string& utf8) {
  if (utf8.empty()) return std::wstring();

  int size = MultiByteToWideChar(CP_UTF8, 0, utf8.c_str(), -1, nullptr, 0);
  if (size <= 0) return std::wstring();

  std::wstring result(size - 1, 0);
  MultiByteToWideChar(CP_UTF8, 0, utf8.c_str(), -1, &result[0], size);
  return result;
}

// 当前壁纸句柄（单例模式）
WallpaperHandle g_wallpaper_handle = nullptr;

// 保持 MethodChannel 存活，否则回调会失效
std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>> g_wallpaper_channel;

}  // namespace

void RegisterWallpaperEngineChannel(flutter::FlutterEngine* engine) {
  if (!engine) return;

  const static std::string channel_name("com.example.wallpaper/engine");
  g_wallpaper_channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          engine->messenger(), channel_name,
          &flutter::StandardMethodCodec::GetInstance());

  g_wallpaper_channel->SetMethodCallHandler(
      [](const flutter::MethodCall<flutter::EncodableValue>& call,
         std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        const std::string& method = call.method_name();

        if (method == "create") {
          if (g_wallpaper_handle) {
            wallpaper_release(g_wallpaper_handle);
            g_wallpaper_handle = nullptr;
          }
          g_wallpaper_handle = wallpaper_create();
          result->Success(flutter::EncodableValue(g_wallpaper_handle != nullptr));
          return;
        }

        if (method == "initialize") {
          if (!g_wallpaper_handle) {
            result->Success(flutter::EncodableValue(false));
            return;
          }
          bool ok = wallpaper_initialize(g_wallpaper_handle);
          result->Success(flutter::EncodableValue(ok));
          return;
        }

        if (method == "load") {
          if (!g_wallpaper_handle) {
            result->Success(flutter::EncodableValue(false));
            return;
          }
          const auto* args = std::get_if<flutter::EncodableMap>(call.arguments());
          if (!args) {
            result->Success(flutter::EncodableValue(false));
            return;
          }
          std::string file_path;
          auto it = args->find(flutter::EncodableValue("filePath"));
          if (it != args->end()) {
            const auto* s = std::get_if<std::string>(&it->second);
            if (s) file_path = *s;
          }
          if (file_path.empty()) {
            result->Success(flutter::EncodableValue(false));
            return;
          }
          std::wstring wpath = Utf8ToWstring(file_path);
          DisplayRect display_rect;
          const DisplayRect* display_ptr = nullptr;
          it = args->find(flutter::EncodableValue("displayRect"));
          if (it != args->end()) {
            const auto* rect_map = std::get_if<flutter::EncodableMap>(&it->second);
            if (rect_map) {
              int x = 0, y = 0, w = 0, h = 0;
              auto rx = rect_map->find(flutter::EncodableValue("x"));
              auto ry = rect_map->find(flutter::EncodableValue("y"));
              auto rw = rect_map->find(flutter::EncodableValue("width"));
              auto rh = rect_map->find(flutter::EncodableValue("height"));
              if (rx != rect_map->end()) {
                const auto* v = std::get_if<int32_t>(&rx->second);
                if (v) x = *v;
              }
              if (ry != rect_map->end()) {
                const auto* v = std::get_if<int32_t>(&ry->second);
                if (v) y = *v;
              }
              if (rw != rect_map->end()) {
                const auto* v = std::get_if<int32_t>(&rw->second);
                if (v) w = *v;
              }
              if (rh != rect_map->end()) {
                const auto* v = std::get_if<int32_t>(&rh->second);
                if (v) h = *v;
              }
              display_rect.x = x;
              display_rect.y = y;
              display_rect.width = w;
              display_rect.height = h;
              display_ptr = &display_rect;
            }
          }
          bool ok = wallpaper_load(g_wallpaper_handle, &wpath, display_ptr,
                                  nullptr, nullptr);
          result->Success(flutter::EncodableValue(ok));
          return;
        }

        if (method == "play") {
          if (g_wallpaper_handle) wallpaper_play(g_wallpaper_handle);
          result->Success();
          return;
        }

        if (method == "pause") {
          if (g_wallpaper_handle) wallpaper_pause(g_wallpaper_handle);
          result->Success();
          return;
        }

        if (method == "close") {
          if (g_wallpaper_handle) wallpaper_close(g_wallpaper_handle);
          result->Success();
          return;
        }

        if (method == "release") {
          if (g_wallpaper_handle) {
            wallpaper_release(g_wallpaper_handle);
            g_wallpaper_handle = nullptr;
          }
          result->Success();
          return;
        }

        if (method == "isLoaded") {
          bool loaded = g_wallpaper_handle && wallpaper_is_loaded(g_wallpaper_handle);
          result->Success(flutter::EncodableValue(loaded));
          return;
        }

        if (method == "isExited") {
          bool exited = g_wallpaper_handle && wallpaper_is_exited(g_wallpaper_handle);
          result->Success(flutter::EncodableValue(exited));
          return;
        }

        if (method == "getPrimaryMonitorRect") {
          DisplayRect rect;
          bool ok = desktop_get_primary_monitor(rect);
          if (!ok) {
            result->Success();
            return;
          }
          flutter::EncodableMap map;
          map[flutter::EncodableValue("x")] = flutter::EncodableValue(rect.x);
          map[flutter::EncodableValue("y")] = flutter::EncodableValue(rect.y);
          map[flutter::EncodableValue("width")] = flutter::EncodableValue(rect.width);
          map[flutter::EncodableValue("height")] = flutter::EncodableValue(rect.height);
          result->Success(flutter::EncodableValue(map));
          return;
        }

        result->NotImplemented();
      });
}
