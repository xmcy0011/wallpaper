/**
 * @file main.cpp
 * @brief 动态壁纸 C++ Win32 演示 - 仅使用 api.h 接口
 *
 * 功能：加载选择视频/图片/GIF -> 自动播放动态壁纸 -> 关闭退出
 */

#ifdef _MSC_VER
#pragma execution_character_set("utf-8")
#endif

#include "../engine/api.h"
#include <commdlg.h>
#include <windows.h>

namespace {

const wchar_t kMainWindowClass[] = L"WallpaperDemoMain";
const wchar_t kMainWindowTitle[] = L"动态壁纸演示";

HWND g_hMainWnd = nullptr;
HWND g_hLoadBtn = nullptr;
HWND g_hCloseBtn = nullptr;
HWND g_hStatusLabel = nullptr;

DesktopCoreHandle g_core = nullptr;
WallpaperHandle g_wallpaper = nullptr;

void OnStateCallback(void *user_data, bool loaded, bool exited) {
  HWND label = reinterpret_cast<HWND>(user_data);
  if (!label || !IsWindow(label))
    return;
  if (loaded) {
    SetWindowTextW(label, L"壁纸已加载");
  } else if (exited) {
    SetWindowTextW(label, L"壁纸已关闭");
  }
}

void OnPlayWallpaper() {
  OPENFILENAMEW ofn = {};
  wchar_t path[MAX_PATH] = {};

  ofn.lStructSize = sizeof(ofn);
  ofn.hwndOwner = g_hMainWnd;
  ofn.lpstrFilter =
      L"媒体文件\0*.mp4;*.webm;*.gif;*.jpg;*.jpeg;*.png;*.bmp;*.webp\0"
      L"视频\0*.mp4;*.webm;*.mov;*.mkv;*.avi;*.wmv\0"
      L"图片\0*.gif;*.jpg;*.jpeg;*.png;*.bmp;*.webp\0"
      L"所有文件\0*.*\0";
  ofn.lpstrFile = path;
  ofn.nMaxFile = MAX_PATH;
  ofn.Flags = OFN_FILEMUSTEXIST | OFN_PATHMUSTEXIST;

  if (!GetOpenFileNameW(&ofn)) {
    return;
  }

  // 创建浏览器窗口
  if (!g_wallpaper) {
    g_wallpaper = wallpaper_create();
    if (!g_wallpaper) {
      SetWindowTextW(g_hStatusLabel, L"错误：无法创建壁纸");
      return;
    }
    if (!wallpaper_initialize(g_wallpaper)) {
      SetWindowTextW(g_hStatusLabel, L"错误：无法初始化壁纸");
      return;
    }
  }

  // 加载壁纸
  SetWindowTextW(g_hStatusLabel, L"正在加载...");
  std::wstring file_path = ofn.lpstrFile;
  if (!wallpaper_load(g_wallpaper, &file_path, nullptr, OnStateCallback,
                      g_hStatusLabel)) {
    SetWindowTextW(g_hStatusLabel, L"错误：加载失败");
  }

  // 如果壁纸未嵌入到桌面，则嵌入到桌面
  if (!desktop_is_embed_window(wallpaper_get_handle(g_wallpaper))) {
    DisplayRect rect;
    if (!desktop_get_primary_monitor(rect)) {
      SetWindowTextW(g_hStatusLabel, L"错误：无法获取主显示器区域");
      return;
    }
    if (!desktop_embed_window(wallpaper_get_handle(g_wallpaper), g_core,
                              &rect)) {
      SetWindowTextW(g_hStatusLabel, L"错误：无法嵌入壁纸");
    }
  }
}

void OnCloseWallpaper() {
  if (g_wallpaper) {
    wallpaper_close(g_wallpaper);
    g_wallpaper = nullptr;
    SetWindowTextW(g_hStatusLabel, L"壁纸已关闭");
  }
}

void OnCleanup() {
  if (g_core) {
    desktop_core_release(g_core);
    g_core = nullptr;
  }
}

LRESULT CALLBACK MainWndProc(HWND hwnd, UINT msg, WPARAM wp, LPARAM lp) {
  switch (msg) {
  case WM_CREATE: {
    g_hLoadBtn =
        CreateWindowW(L"BUTTON", L"播放", WS_CHILD | WS_VISIBLE | BS_PUSHBUTTON,
                      20, 20, 120, 32, hwnd, (HMENU)1, nullptr, nullptr);

    g_hCloseBtn = CreateWindowW(L"BUTTON", L"关闭壁纸",
                                WS_CHILD | WS_VISIBLE | BS_PUSHBUTTON, 160, 20,
                                120, 32, hwnd, (HMENU)2, nullptr, nullptr);

    g_hStatusLabel =
        CreateWindowW(L"STATIC", L"就绪", WS_CHILD | WS_VISIBLE | SS_LEFT, 20,
                      65, 360, 24, hwnd, nullptr, nullptr, nullptr);
    break;
  }
  case WM_COMMAND:
    if (LOWORD(wp) == 1)
      OnPlayWallpaper();
    else if (LOWORD(wp) == 2)
      OnCloseWallpaper();
    break;
  case WM_DESTROY:
    OnCleanup();
    PostQuitMessage(0);
    break;
  default:
    return DefWindowProcW(hwnd, msg, wp, lp);
  }
  return 0;
}

} // namespace

// 程序启动时立即设置 DPI 感知，避免 WebView2 加载后 DPI 切换导致 GetMonitorInfo
// 返回值不一致
static void SetDpiAwarenessEarly() {
#ifndef DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2
#define DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2 ((DPI_AWARENESS_CONTEXT) - 4)
#endif
  using SetProcessDpiAwarenessContextFn = BOOL(WINAPI *)(DPI_AWARENESS_CONTEXT);
  if (auto *fn =
          reinterpret_cast<SetProcessDpiAwarenessContextFn>(GetProcAddress(
              GetModuleHandleW(L"user32"), "SetProcessDpiAwarenessContext"))) {
    fn(DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2);
  }
}

int WINAPI wWinMain(HINSTANCE hInstance, HINSTANCE, PWSTR, int nCmdShow) {
  SetDpiAwarenessEarly();

  WNDCLASSEXW wc = {};
  wc.cbSize = sizeof(wc);
  wc.style = CS_HREDRAW | CS_VREDRAW;
  wc.lpfnWndProc = MainWndProc;
  wc.hInstance = hInstance;
  wc.hCursor = LoadCursor(nullptr, IDC_ARROW);
  wc.hbrBackground = (HBRUSH)(COLOR_WINDOW + 1);
  wc.lpszClassName = kMainWindowClass;

  if (!RegisterClassExW(&wc)) {
    return 1;
  }

  g_hMainWnd =
      CreateWindowExW(0, kMainWindowClass, kMainWindowTitle,
                      WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU, 100, 100, 420,
                      160, nullptr, nullptr, hInstance, nullptr);

  if (!g_hMainWnd) {
    return 1;
  }

  ShowWindow(g_hMainWnd, nCmdShow);

  g_core = desktop_core_create();
  if (!g_core) {
    SetWindowTextW(g_hStatusLabel, L"错误：无法初始化桌面核心");
    return 1;
  }

  SetWindowTextW(g_hStatusLabel, L"点击播放选择壁纸");

  MSG msg = {};
  while (GetMessage(&msg, nullptr, 0, 0)) {
    TranslateMessage(&msg);
    DispatchMessage(&msg);
  }

  return 0;
}
