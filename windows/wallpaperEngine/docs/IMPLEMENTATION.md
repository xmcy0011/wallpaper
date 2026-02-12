# 动态壁纸 C++ 引擎 - 关键技术实现文档

## 1. 概述

本文档描述将 Lively 动态壁纸核心从 C# 迁移到 C++ 的实现细节，重点说明**桌面背景嵌入**的实现原理，涉及 Progman、WorkerW、SHELLDLL_DefView 等 Windows Shell 核心对象。

## 2. 桌面背景嵌入核心原理

### 2.1 Windows 桌面窗口层级结构

Windows 桌面由 explorer.exe 管理的多个窗口组成，典型层级如下：

```bash
GetDesktopWindow() (桌面根窗口)
├── WorkerW (0x00010190)          ← 包含桌面图标的 WorkerW
│   └── SHELLDLL_DefView
│       └── SysListView32        ← 桌面图标列表
├── WorkerW (0x00100B8A)          ← 空 WorkerW，壁纸嵌入目标！
└── Progman (0x000100EC)          ← Program Manager
```

**关键对象说明：**

| 对象 | 类名 | 说明 |
|------|------|------|
| **Progman** | `Progman` | 程序管理器，桌面 shell 的根窗口 |
| **WorkerW** | `WorkerW` | 工作线程窗口，通常有多个实例 |
| **SHELLDLL_DefView** | `SHELLDLL_DefView` | 默认 Shell 视图，容纳桌面图标 |

### 2.2 创建 WorkerW 的未文档化方法

系统默认不创建用于壁纸的空白 WorkerW。需要向 Progman 发送特定消息：

```cpp
// 发送 0x052C 到 Progman，让系统在桌面图标后面创建 WorkerW
constexpr UINT WM_SPAWN_WORKER = 0x052C;
SendMessageTimeoutW(progman, WM_SPAWN_WORKER, 0xD, 0x1, SMTO_NORMAL, 1000, nullptr);
```

- **消息 ID**: `0x052C`（未文档化，可能随 Windows 版本变化）
- **wParam**: `0xD`
- **lParam**: `0x1`
- 发送后，若不存在则创建新的 WorkerW，位于 SHELLDLL_DefView 之下

### 2.3 查找目标 WorkerW 的算法

```cpp
// 1. 获取 Progman
HWND progman = FindWindowW(L"Progman", nullptr);

// 2. 枚举顶层窗口，找到包含 SHELLDLL_DefView 的窗口
EnumWindows([](HWND top, LPARAM param) -> BOOL {
    HWND defView = FindWindowExW(top, nullptr, L"SHELLDLL_DefView", nullptr);
    if (defView) {
        // top = 包含图标的 WorkerW
        // 目标 WorkerW = top 的兄弟（下一个 WorkerW）
        workerW = FindWindowExW(GetDesktopWindow(), top, L"WorkerW", nullptr);
        return FALSE;  // 停止枚举
    }
    return TRUE;
}, 0);
```

**Spy++ 输出示意**（传统模式）：

```bash
0x00010190 "" WorkerW
  ...
  0x000100EE "" SHELLDLL_DefView
    0x000100F0 "FolderView" SysListView32
0x00100B8A "" WorkerW       <-- 目标：壁纸嵌入此窗口
0x000100EC "Program Manager" Progman
```

### 2.4 Windows 11 分层 ShellView 模式

从 Windows 11 起，微软引入了**分层桌面**（Raised Desktop）：

- Progman 带 `WS_EX_NOREDIRECTIONBITMAP`，无 GDI 内容
- SHELLDLL_DefView 为 `WS_EX_LAYERED` 子窗口
- WorkerW 为 Progman 的**直接子窗口**（而非桌面根的子窗口）

```bash
Progman (WS_EX_NOREDIRECTIONBITMAP)
├── SHELLDLL_DefView (WS_EX_LAYERED)
│   └── SysListView32
└── WorkerW             <-- 壁纸嵌入目标
```

**检测与处理**：

```cpp
if (GetWindowLongW(progman, GWL_EXSTYLE) & WS_EX_NOREDIRECTIONBITMAP) {
    isRaisedDesktop = true;
    workerW = FindWindowExW(progman, nullptr, L"WorkerW", nullptr);
}
```

### 2.5 将窗口嵌入为壁纸

```cpp
// 1. 设置父窗口为 WorkerW
SetParent(wallpaperHwnd, workerW);

// 2. 定位并调整大小
SetWindowPos(wallpaperHwnd, HWND_TOP, 0, 0, width, height, SWP_NOACTIVATE | SWP_NOZORDER);
```

**分层模式**下的额外步骤：

```cpp
// 1. 添加 WS_CHILD
SetWindowLongW(hwnd, GWL_STYLE, style | WS_CHILD);

// 2. 设置分层透明
SetWindowLongW(hwnd, GWL_EXSTYLE, exStyle | WS_EX_LAYERED);
SetLayeredWindowAttributes(hwnd, 0, 255, LWA_ALPHA);

// 3. 父窗口设为 Progman（而非 WorkerW）
SetParent(hwnd, progman);

// 4. Z-order: 壁纸在 SHELLDLL_DefView 之下
SetWindowPos(hwnd, shellDLL_DefView, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE | SWP_NOACTIVATE);
```

### 2.6 多显示器适配

- **单屏**：WorkerW 覆盖整个虚拟屏幕
- **多屏**：需对每个显示器单独设置壁纸，或使用 `MapWindowPoints` 转换坐标

```cpp
// 将壁纸窗口定位到目标显示器
RECT rect = displayBounds;
SetWindowPos(handle, HWND_TOP, rect.left, rect.top, rect.right - rect.left, rect.bottom - rect.top, SWP_NOACTIVATE);
MapWindowPoints(handle, workerW, (POINT*)&rect, 2);
SetParent(handle, workerW);
SetWindowPos(handle, HWND_TOP, rect.left, rect.top, rect.right - rect.left, rect.bottom - rect.top, SWP_NOACTIVATE);
```

### 2.7 从任务栏隐藏

壁纸窗口需避免出现在任务栏和 Alt+Tab：

```cpp
// 创建时添加扩展样式
CreateWindowExW(WS_EX_TOOLWINDOW | WS_EX_NOACTIVATE, ...);
```

### 2.8 刷新桌面

当壁纸关闭后，需刷新桌面以清除残留：

```cpp
// 传统模式：修改系统壁纸触发刷新
SystemParametersInfoW(SPI_SETDESKWALLPAPER, 0, nullptr, SPIF_UPDATEINIFILE | SPIF_SENDWININICHANGE);

// 分层模式：不刷新，否则会销毁 WorkerW
```

## 3. 壁纸引擎架构

### 3.1 API 设计

`api.h` 从 C# 迁移的简化接口：

```c
// IWallpaper 核心
WallpaperHandle wallpaper_create(const wchar_t* path);
HWND wallpaper_get_handle(WallpaperHandle wp);
void wallpaper_play/pause/close(WallpaperHandle wp);

// IDesktopCore 核心
DesktopCoreHandle desktop_core_create(void);
WallpaperHandle desktop_core_set_wallpaper(DesktopCoreHandle core, const wchar_t* path, ...);
HWND desktop_core_get_worker_w(DesktopCoreHandle core);
```

### 3.2 WebView2 媒体播放

支持 gif、图片、视频：

- **视频**：`<video autoplay loop muted playsinline src="...">`
- **GIF/图片**：`<img src="...">`

使用 `SetVirtualHostNameToFolderMapping` 将本地目录映射为虚拟主机，避免 `file://` 安全限制：

```cpp
webview->SetVirtualHostNameToFolderMapping(
    L"wallpaper.localhost",  // 虚拟主机
    fileDirectory.c_str(),   // 映射到文件所在目录
    COREWEBVIEW2_HOST_RESOURCE_ACCESS_KIND_ALLOW);
// 使用 https://wallpaper.localhost/filename 加载
```

## 4. 构建说明

### 4.1 依赖

- **WebView2 Runtime**：系统需安装（Win10/11 多数已预装）
- **WebView2 SDK**：开发需安装
  - **vcpkg**: `vcpkg install webview2`
  - **NuGet**: `Microsoft.Web.WebView2`

### 4.2 CMake 构建

```bash
mkdir build && cd build
cmake .. -DCMAKE_TOOLCHAIN_FILE=[vcpkg]/scripts/buildsystems/vcpkg.cmake
cmake --build . --config Release
```

### 4.3 Visual Studio

1. 新建 C++ 桌面应用项目
2. 右键项目 → 管理 NuGet 包 → 安装 `Microsoft.Web.WebView2`
3. 添加 `engine` 和 `demo` 源文件

## 5. 参考

- [Lively Wallpaper 源码](https://github.com/rocksdanister/lively)
- [WebView2 官方文档](https://learn.microsoft.com/en-us/microsoft-edge/webview2/)
- [Microsoft: 桌面背景渲染变更说明](https://learn.microsoft.com/en-us/windows/win32/winmsg/windows)
