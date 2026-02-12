/**
 * @file wallpaper_engine.cpp
 * @brief WebView2 壁纸引擎实现
 *
 * 需要安装 Microsoft.Web.WebView2 NuGet 包
 * 或通过 vcpkg: vcpkg install webview2
 */

#include "webview2_engine.h"
#include <Shlwapi.h>
#include <cstdio>
#include <pathcch.h>


#pragma comment(lib, "Shlwapi.lib")
#pragma comment(lib, "pathcch.lib")

#include <WebView2.h>
#include <wrl.h>


namespace engine {

using namespace Microsoft::WRL;

struct WebView2Engine::Impl {
  ComPtr<ICoreWebView2Controller> controller;
  ComPtr<ICoreWebView2> webview;
};

namespace {

std::wstring GetTempUserDataPath() {
  wchar_t path[MAX_PATH];
  if (SUCCEEDED(GetTempPathW(MAX_PATH, path))) {
    PathCchAppend(path, MAX_PATH, L"WebView2Engine");
    return path;
  }
  return L"";
}

std::wstring GetFileExtension(const std::wstring &path) {
  size_t pos = path.find_last_of(L'.');
  if (pos != std::wstring::npos) {
    std::wstring ext = path.substr(pos);
    for (auto &c : ext)
      c = towlower(c);
    return ext;
  }
  return L"";
}

// 获取主显示器区域（单屏或多屏时均使用主显示器）
static void GetPrimaryMonitorBounds(RECT *out) {
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

} // namespace

WebView2Engine::WebView2Engine() { userDataPath_ = GetTempUserDataPath(); }

WebView2Engine::~WebView2Engine() { Close(); }

MediaType WebView2Engine::DetectMediaType(const std::wstring &filePath) {
  auto ext = GetFileExtension(filePath);
  if (ext == L".gif")
    return MediaType::Gif;
  if (ext == L".mp4" || ext == L".webm" || ext == L".mov" || ext == L".mkv" ||
      ext == L".avi" || ext == L".wmv" || ext == L".m4v") {
    return MediaType::Video;
  }
  if (ext == L".jpg" || ext == L".jpeg" || ext == L".png" || ext == L".bmp" ||
      ext == L".webp") {
    return MediaType::Image;
  }
  return MediaType::Image; // 默认
}

std::wstring WebView2Engine::BuildHtmlForMedia(const std::wstring &filePath,
                                               MediaType type) {
  std::wstring fileName = filePath;
  size_t slash = fileName.find_last_of(L"\\/");
  if (slash != std::wstring::npos) {
    fileName = fileName.substr(slash + 1);
  }

  std::wstring html;
  html += L"<!DOCTYPE html><html><head><meta charset='utf-8'>";
  html +=
      L"<style>"
      L"*{margin:0;padding:0;}"
      L"html,body{width:100%;height:100%;min-height:100vh;overflow:hidden;background:#1a1a1a;}"
      L"#media{position:fixed;top:0;left:0;width:100vw;height:100vh;object-fit:cover;object-position:center;display:block;}"
      L"</style></head><body>";

  switch (type) {
  case MediaType::Video:
    html += L"<video id='media' autoplay loop muted playsinline src='" +
            fileName + L"'></video>";
    break;
  case MediaType::Gif:
  case MediaType::Image:
    html += L"<img id='media' src='" + fileName + L"' />";
    break;
  }
  html += L"</body></html>";
  return html;
}

// 创建临时 HTML 文件并返回 file:// URL
static std::wstring CreateTempHtmlAndGetUrl(const std::wstring &filePath,
                                            const std::wstring &htmlContent) {
  std::wstring dir = filePath;
  size_t slash = dir.find_last_of(L"\\/");
  if (slash != std::wstring::npos) {
    dir = dir.substr(0, slash);
  }

  std::wstring tempPath = dir + L"\\_wallpaper_temp.html";

  FILE *fp = nullptr;
  if (_wfopen_s(&fp, tempPath.c_str(), L"w, ccs=UTF-8") == 0 && fp) {
    fputwc(L'\xFEFF', fp); // UTF-8 BOM
    for (wchar_t c : htmlContent) {
      fputwc(c, fp);
    }
    fclose(fp);
  }

  // 转换为 file:// URL
  std::wstring url = L"file:///";
  for (wchar_t c : tempPath) {
    if (c == L'\\')
      url += L'/';
    else
      url += c;
  }
  return url;
}

HRESULT WebView2Engine::onCreateCoreWebView2ControllerCompleted(HRESULT hr, ICoreWebView2Controller *ctrl) {
    if (FAILED(hr) || !ctrl)
    return hr;

  impl_ = std::make_unique<Impl>();
  impl_->controller = ctrl;

  ComPtr<ICoreWebView2> webview;
  ctrl->get_CoreWebView2(webview.GetAddressOf());
  if (!webview)
    return E_FAIL;
  impl_->webview = webview;

  // 设置窗口不显示状态栏
  ComPtr<ICoreWebView2Settings> settings;
  impl_->webview->get_Settings(settings.GetAddressOf());
  if (settings) {
    settings->put_IsStatusBarEnabled(FALSE);
  }

  // 设置窗口边界
  RECT desktop;
  GetPrimaryMonitorBounds(&desktop);
  RECT bounds = {0, 0, desktop.right - desktop.left,
                 desktop.bottom - desktop.top};
  impl_->controller->put_Bounds(bounds);

  // 导航完成回调
  impl_->webview->add_NavigationCompleted(
      Callback<ICoreWebView2NavigationCompletedEventHandler>(
          [this](ICoreWebView2 *,
                 ICoreWebView2NavigationCompletedEventArgs *args) -> HRESULT {
            BOOL success;
            args->get_IsSuccess(&success);
            if (success) {
              loaded_ = true;
              if (onLoaded_)
                onLoaded_();
            }
            return S_OK;
          })
          .Get(),
      nullptr);

  is_webview2_created_ = true;

  if (!this->filePath_.empty()) {
    MediaType type = DetectMediaType(this->filePath_);
    std::wstring html = BuildHtmlForMedia(this->filePath_, type);
    std::wstring fileUrl = CreateTempHtmlAndGetUrl(this->filePath_, html);
    this->impl_->webview->Navigate(fileUrl.c_str());
  }

  return S_OK;
}

bool WebView2Engine::CreateWebView2Window() {
  const wchar_t kClassName[] = L"WebView2EngineWindow";
  WNDCLASSEXW wc = {};
  wc.cbSize = sizeof(wc);
  wc.style = CS_HREDRAW | CS_VREDRAW;
  wc.lpfnWndProc = WndProc;
  wc.hInstance = GetModuleHandle(nullptr);
  wc.lpszClassName = kClassName;

  // 类首次注册后 persist，再次 RegisterClassExW 会失败
  // (ERROR_CLASS_ALREADY_EXISTS) 卸载壁纸后重新选择时需跳过已注册的类
  if (!GetClassInfoExW(GetModuleHandle(nullptr), kClassName, &wc)) {
    if (!RegisterClassExW(&wc)) {
      return false;
    }
  }

  RECT desktop;
  GetPrimaryMonitorBounds(&desktop);
  int w = desktop.right - desktop.left;
  int h = desktop.bottom - desktop.top;

  hwnd_ = CreateWindowExW(WS_EX_TOOLWINDOW | WS_EX_NOACTIVATE, kClassName, L"",
                          WS_POPUP, desktop.left, desktop.top, w, h, nullptr,
                          nullptr, wc.hInstance, this);

  // 获取WebView2目录（可选，nullptr 使用系统默认）
  // wchar_t modulePath[MAX_PATH];
  // GetModuleFileNameW(nullptr, modulePath, MAX_PATH);
  // PathRemoveFileSpecW(modulePath);
  // std::wstring webview2Path = std::wstring(modulePath) + L"\\WebView2";

  // CreateCoreWebView2EnvironmentWithOptions 为异步，完成在 callback 中处理
  CreateCoreWebView2EnvironmentWithOptions(
      nullptr, // 使用系统安装的 WebView2 Runtime
      userDataPath_.c_str(), nullptr,
      Callback<ICoreWebView2CreateCoreWebView2EnvironmentCompletedHandler>(
          [this](HRESULT hr, ICoreWebView2Environment *env) -> HRESULT {
            if (FAILED(hr) || !env)
              return hr;

            env->CreateCoreWebView2Controller(
                hwnd_,
                Callback<
                    ICoreWebView2CreateCoreWebView2ControllerCompletedHandler>(
                    [this](HRESULT hr,
                           ICoreWebView2Controller *ctrl) -> HRESULT {
                      return onCreateCoreWebView2ControllerCompleted(hr, ctrl);
                    })
                    .Get());
            return S_OK;
          })
          .Get());

  return hwnd_ != nullptr;
}

LRESULT CALLBACK WebView2Engine::WndProc(HWND hwnd, UINT msg, WPARAM wp,
                                         LPARAM lp) {
  auto *self = reinterpret_cast<WebView2Engine *>(
      GetWindowLongPtrW(hwnd, GWLP_USERDATA));

  switch (msg) {
  case WM_CREATE: {
    auto *cs = reinterpret_cast<CREATESTRUCT *>(lp);
    self = reinterpret_cast<WebView2Engine *>(cs->lpCreateParams);
    SetWindowLongPtrW(hwnd, GWLP_USERDATA, reinterpret_cast<LONG_PTR>(self));
    break;
  }
  case WM_DESTROY:
    if (self)
      self->exited_ = true;
    if (self && self->onExited_)
      self->onExited_();
    break;
  }
  return DefWindowProcW(hwnd, msg, wp, lp);
}

bool WebView2Engine::Initialize() {
  if (!initialized_ && !CreateWebView2Window()) {
    initialized_ = false;
    return false;
  }
  initialized_ = true;
  return true;
}

bool WebView2Engine::LoadMedia(const std::wstring &filePath) {
  if (!hwnd_ || !PathFileExistsW(filePath.c_str())) {
    return false;
  }
  this->filePath_ = filePath;

  MediaType type = DetectMediaType(filePath);
  std::wstring html = BuildHtmlForMedia(filePath, type);
  std::wstring fileUrl = CreateTempHtmlAndGetUrl(filePath, html);

  if (is_webview2_created_) {
    this->impl_->webview->Navigate(fileUrl.c_str());
  }

  ShowWindow(hwnd_, SW_SHOWNOACTIVATE);
  return true;
}

void WebView2Engine::SetBounds(int x, int y, int width, int height) {
  if (hwnd_) {
    SetWindowPos(hwnd_, nullptr, x, y, width, height,
                 SWP_NOACTIVATE | SWP_NOZORDER);
  }
}

void WebView2Engine::Play() {
  // 通过 WebView2 ExecuteScript 执行 play
  // 简化实现：在 LoadMedia 中已设置 autoplay
}

void WebView2Engine::Pause() {
  // 通过 ExecuteScript: document.querySelector('video').pause()
}

void WebView2Engine::Close() {
  if (hwnd_) {
    DestroyWindow(hwnd_);
    hwnd_ = nullptr;
  }
  exited_ = true;
}

HWND WebView2Engine::GetWindowHandle() const { return hwnd_; }

} // namespace engine
