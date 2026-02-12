/**
 * @file desktop_embed.h
 * @brief 桌面背景嵌入实现 - Progman、WorkerW、SHELLDLL_DefView
 */

#pragma once

#include <windows.h>

namespace engine {

/** 桌面嵌入上下文 */
struct DesktopEmbedContext {
    HWND progman = nullptr;      // Program Manager
    HWND workerW = nullptr;      // WorkerW - 壁纸嵌入目标
    HWND shellDLL_DefView = nullptr;  // 桌面图标容器
    bool isRaisedDesktop = false;     // Windows 11 分层 ShellView 模式
};

/**
 * 初始化桌面层，获取 Progman、WorkerW、SHELLDLL_DefView
 */
bool InitDesktopLayer(DesktopEmbedContext& ctx);

/**
 * 将窗口嵌入到桌面作为壁纸
 */
bool AttachToDesktop(HWND hwnd, const DesktopEmbedContext& ctx, const RECT& rect);

/**
 * 从桌面分离窗口
 */
void DetachFromDesktop(HWND hwnd);

/**
 * 刷新桌面（清除壁纸残留）
 */
void RefreshDesktop(const DesktopEmbedContext& ctx);

}  // namespace engine
