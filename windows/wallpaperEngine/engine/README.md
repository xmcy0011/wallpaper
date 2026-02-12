# 动态壁纸引擎 (C++)

从 Lively C# 实现迁移的 C++ 壁纸引擎核心，支持 video/gif/image 三种媒体类型。

## 依赖

- **WebView2 Runtime** - 运行时（Windows 10/11 通常已预装）
- **WebView2 SDK** - 开发时必需

### 安装 WebView2 SDK

**vcpkg:**

```bash
vcpkg install webview2
cmake .. -DCMAKE_TOOLCHAIN_FILE=[vcpkg]/scripts/buildsystems/vcpkg.cmake
```

**NuGet（CMake 构建时）:**

```bash
cd demo/build
nuget restore engine/packages.config -PackagesDirectory packages
cmake --build . --config Release
```

若出现 LNK2019: CreateCoreWebView2EnvironmentWithOptions，需确保已链接 WebView2LoaderStatic.lib（NuGet 包还原后会自动找到）

## 目录结构

```bash
engine/
├── api.h              # 对外 C API
├── desktop_embed.h/cpp # 桌面嵌入 (Progman/WorkerW/SHELLDLL_DefView)
├── wallpaper_engine.h/cpp  # WebView2 壁纸播放引擎
└── CMakeLists.txt
```

## 核心流程

1. `InitDesktopLayer()` - 获取 Progman、WorkerW、SHELLDLL_DefView
2. `WebView2Engine::LoadMedia()` - 创建 WebView2 窗口并加载媒体
3. `AttachToDesktop()` - 将壁纸窗口设为 WorkerW 子窗口
4. `RefreshDesktop()` - 关闭时刷新桌面
