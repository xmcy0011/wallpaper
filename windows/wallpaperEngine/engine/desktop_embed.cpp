/**
 * @file desktop_embed.cpp
 * @brief 桌面背景嵌入实现 - WorkerW、Progman、SHELLDLL_DefView 关键逻辑
 * 兼容 Windows 10 与 Windows 11
 */

#include "desktop_embed.h"

#ifndef WM_SPAWN_WORKER
#define WM_SPAWN_WORKER 0x052C
#endif
#ifndef WS_EX_NOREDIRECTIONBITMAP
#define WS_EX_NOREDIRECTIONBITMAP 0x00200000L
#endif

#include <thread>
#include <chrono>

namespace engine {

// RtlGetVersion 所需结构体（未文档化 API）
typedef struct _RTL_OSVERSIONINFOW {
    ULONG dwOSVersionInfoSize;
    ULONG dwMajorVersion;
    ULONG dwMinorVersion;
    ULONG dwBuildNumber;
    ULONG dwPlatformId;
    WCHAR szCSDVersion[128];
} RTL_OSVERSIONINFOW, *PRTL_OSVERSIONINFOW;

// 检查是否为 Windows 11 及以上（build 22000+）
static bool IsWindows11OrGreater() {
    typedef LONG(WINAPI* RtlGetVersionPtr)(PRTL_OSVERSIONINFOW);
    HMODULE hNtdll = GetModuleHandleW(L"ntdll.dll");
    if (!hNtdll) return false;
    auto RtlGetVersion = (RtlGetVersionPtr)GetProcAddress(hNtdll, "RtlGetVersion");
    if (!RtlGetVersion) return false;
    RTL_OSVERSIONINFOW osvi = {sizeof(osvi)};
    if (RtlGetVersion(&osvi) != 0) return false;
    return osvi.dwMajorVersion > 10 ||
           (osvi.dwMajorVersion == 10 && osvi.dwBuildNumber >= 22000);
}

// 在指定父窗口下，找到 SHELLDLL_DefView 所属 WorkerW 后面的那个 WorkerW（壁纸目标）
// 因存在多个 WorkerW，必须取 DefView 容器之后的那个，否则会找错
static HWND FindEmptyWorkerWAfterDefView(HWND parent) {
    if (!parent || !IsWindow(parent)) return nullptr;
    HWND workerW = nullptr;
    while ((workerW = FindWindowExW(parent, workerW, L"WorkerW", nullptr)) != nullptr) {
        if (FindWindowExW(workerW, nullptr, L"SHELLDLL_DefView", nullptr)) {
            // 找到 DefView 所属 WorkerW，返回其后的下一个 WorkerW
            return FindWindowExW(parent, workerW, L"WorkerW", nullptr);
        }
    }
    return nullptr;
}

// 查找壁纸目标 WorkerW，兼容 Desktop 与 Progman 两种父窗口结构
static HWND FindEmptyWorkerWByEnum(HWND progman) {
    HWND result = FindEmptyWorkerWAfterDefView(GetDesktopWindow());
    if (!result && progman) {
        result = FindEmptyWorkerWAfterDefView(progman);
    }
    return result;
}

bool initWin11DesktopLayer(DesktopEmbedContext& ctx) {
    ctx.progman = FindWindowW(L"Progman", nullptr);
    if (!ctx.progman) {
        return false;
    }

    // 检测 Windows 11 分层 ShellView 模式
    LONG exStyle = GetWindowLongW(ctx.progman, GWL_EXSTYLE);
    ctx.isRaisedDesktop = (exStyle & (LONG)WS_EX_NOREDIRECTIONBITMAP) != 0;

    // 发送 0x052C 到 Progman，让系统创建 WorkerW（在桌面图标后面）
    // 如果已存在则无操作
    SendMessageTimeoutW(ctx.progman, WM_SPAWN_WORKER, 0xD, 0x1,
                        SMTO_NORMAL, 1000, nullptr);

    // 查找 WorkerW 窗口
    // 窗口层级：Progman -> WorkerW(含SHELLDLL_DefView) -> WorkerW(空的，我们需要的)
    // 或：Progman -> SHELLDLL_DefView, WorkerW (Win11 分层模式)
    ctx.workerW = nullptr;
    ctx.shellDLL_DefView = nullptr;

    EnumWindows([](HWND top, LPARAM param) -> BOOL {
        auto* ctx = reinterpret_cast<DesktopEmbedContext*>(param);
        HWND defView = FindWindowExW(top, nullptr, L"SHELLDLL_DefView", nullptr);
        if (defView) {
            ctx->shellDLL_DefView = defView;
            if (ctx->isRaisedDesktop) {
                // Win11: WorkerW 是 Progman 的子窗口
                ctx->workerW = FindWindowExW(ctx->progman, nullptr, L"WorkerW", nullptr);
            } else {
                // 传统: WorkerW 是 DefView 所在 WorkerW 的兄弟
                ctx->workerW = FindWindowExW(GetDesktopWindow(), top, L"WorkerW", nullptr);
            }
            return FALSE;  // 停止枚举
        }
        return TRUE;
    }, reinterpret_cast<LPARAM>(&ctx));

    return ctx.workerW != nullptr;
}

bool initWin10DesktopLayer(DesktopEmbedContext& ctx) {
    // 发送 0x052C 到 Progman，让系统创建 WorkerW（在桌面图标后面），如果已存在，无效果
    SendMessageTimeoutW(ctx.progman, WM_SPAWN_WORKER, 0xD, 0x1,
                        SMTO_NORMAL, 1000, nullptr);

    // Win10: WorkerW 可能延迟创建，重试几次
    const int maxRetries = 5;
    const int retryMs = 50;

    ctx.workerW = nullptr;
    ctx.shellDLL_DefView = nullptr;

    for (int retry = 0; retry < maxRetries && !ctx.workerW; ++retry) {
        if (retry > 0) {
            std::this_thread::sleep_for(std::chrono::milliseconds(retryMs));
        }

        // Win10 传统模式：优先用枚举法找空 WorkerW（Desktop 与 Progman 双路径）
        ctx.workerW = FindEmptyWorkerWByEnum(ctx.progman);
        if (!ctx.workerW) {
            EnumWindows([](HWND top, LPARAM param) -> BOOL {
                auto* c = reinterpret_cast<DesktopEmbedContext*>(param);
                HWND defView = FindWindowExW(top, nullptr, L"SHELLDLL_DefView", nullptr);
                if (defView) {
                    c->shellDLL_DefView = defView;
                    // DefView 所在窗口(top)的父窗口下查找兄弟 WorkerW
                    HWND parent = GetParent(top);
                    if (parent) {
                        c->workerW = FindWindowExW(parent, top, L"WorkerW", nullptr);
                    }
                    if (!c->workerW) {
                        c->workerW = FindWindowExW(GetDesktopWindow(), top, L"WorkerW", nullptr);
                    }
                    if (!c->workerW && c->progman) {
                        c->workerW = FindWindowExW(c->progman, top, L"WorkerW", nullptr);
                    }
                    return FALSE;
                }
                return TRUE;
            }, reinterpret_cast<LPARAM>(&ctx));
        }
    }

    return ctx.workerW != nullptr;
}

bool InitDesktopLayer(DesktopEmbedContext& ctx) {
    bool isWin11 = IsWindows11OrGreater();
    if (isWin11) {
        return initWin11DesktopLayer(ctx);
    }
    return initWin10DesktopLayer(ctx);
}

bool AttachToDesktop(HWND hwnd, const DesktopEmbedContext& ctx, const RECT& rect) {
    if (!ctx.workerW || !IsWindow(hwnd)) {
        return false;
    }

    HWND parent = ctx.workerW;

    if (ctx.isRaisedDesktop && ctx.shellDLL_DefView) {
        // Win11 分层模式：需要特殊处理
        // 1. 添加 WS_CHILD
        LONG style = (LONG)GetWindowLongW(hwnd, GWL_STYLE);
        SetWindowLongW(hwnd, GWL_STYLE, style | WS_CHILD);

        // 2. 设置分层透明
        LONG exStyle = (LONG)GetWindowLongW(hwnd, GWL_EXSTYLE);
        SetWindowLongW(hwnd, GWL_EXSTYLE, exStyle | WS_EX_LAYERED);
        SetLayeredWindowAttributes(hwnd, 0, 255, 0x2 /* LWA_ALPHA */);

        // 3. 父窗口设为 Progman
        parent = ctx.progman;
    }

    if (!SetParent(hwnd, parent)) {
        return false;
    }

    // 设置窗口位置和大小
    SetWindowPos(hwnd, HWND_TOP, rect.left, rect.top,
                 rect.right - rect.left, rect.bottom - rect.top,
                 SWP_NOACTIVATE | SWP_NOZORDER);

    if (ctx.isRaisedDesktop && ctx.shellDLL_DefView) {
        // Z-order: 壁纸在 SHELLDLL_DefView 之下
        SetWindowPos(hwnd, ctx.shellDLL_DefView, 0, 0, 0, 0,
                     SWP_NOMOVE | SWP_NOSIZE | SWP_NOACTIVATE);
    }

    return true;
}

void DetachFromDesktop(HWND hwnd) {
    SetParent(hwnd, nullptr);
}

void RefreshDesktop(const DesktopEmbedContext& ctx) {
    if (ctx.isRaisedDesktop) {
        return;  // 分层模式不刷新，否则会销毁 WorkerW
    }
    SystemParametersInfoW(0x0014 /* SPI_SETDESKWALLPAPER */, 0, nullptr,
                          0x01 | 0x02 /* SPIF_UPDATEINIFILE | SPIF_SENDWININICHANGE */);
}

}  // namespace engine
