/**
 * @file wallpaper_engine.h
 * @brief WebView2 壁纸引擎 - 支持 video/gif/image
 */

#pragma once

#include "desktop_embed.h"
#include "wallpaper_engine.h"

#include <string>
#include <memory>
#include <functional>

struct ICoreWebView2;
struct ICoreWebView2Controller;
struct ICoreWebView2Environment;

namespace engine {

enum class MediaType { Video, Gif, Image };

class WebView2Engine: public IWallpaperEngine {
public:
    WebView2Engine();
    ~WebView2Engine();

    bool Initialize() override;
    bool IsInitialized() const override { return initialized_; }

    bool LoadMedia(const std::wstring& filePath) override;
    void SetBounds(int x, int y, int width, int height) override;
    void Play() override;
    void Pause() override;
    void Close() override;

    HWND GetWindowHandle() const override;
    bool IsLoaded() const override { return loaded_; }
    bool IsExited() const override { return exited_; }

    void SetLoadedCallback(LoadedCallback cb) override { onLoaded_ = std::move(cb); }
    void SetExitedCallback(ExitedCallback cb) override { onExited_ = std::move(cb); }

private:
    bool CreateWebView2Window();
    std::wstring BuildHtmlForMedia(const std::wstring& filePath, MediaType type);
    MediaType DetectMediaType(const std::wstring& filePath);
    static LRESULT CALLBACK WndProc(HWND hwnd, UINT msg, WPARAM wp, LPARAM lp);
    HRESULT onCreateCoreWebView2ControllerCompleted(HRESULT hr, ICoreWebView2Controller *ctrl);

    HWND hwnd_ = nullptr;
    std::wstring userDataPath_;
    std::wstring filePath_;
    bool initialized_ = false;
    bool loaded_ = false;
    bool exited_ = false;

    LoadedCallback onLoaded_;
    ExitedCallback onExited_;

    // WebView2 COM 接口 - 需保持引用防止释放
    struct Impl;
    std::unique_ptr<Impl> impl_;
    bool is_webview2_created_ = false;
};

}  // namespace engine
