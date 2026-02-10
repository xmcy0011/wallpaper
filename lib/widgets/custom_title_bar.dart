import 'package:flutter/material.dart';
import '../utils/platform_utils.dart';
import 'package:window_manager/window_manager.dart';

/// 自定义标题栏组件
/// 参考 upupoo 风格：白色背景、扁平化设计、自定义窗口控制按钮
class CustomTitleBar extends StatefulWidget {
  /// 标题栏高度
  final double height;

  /// 背景色
  final Color backgroundColor;

  /// 主标题
  final String title;

  /// 副标题（可选，显示在主标题右侧，灰色小字）
  final String? subtitle;

  /// 中间内容区域（如 TabBar、搜索框等）
  final Widget? child;

  /// 返回按钮回调（不为 null 时在左侧显示返回按钮）
  final VoidCallback? onBackPressed;

  const CustomTitleBar({
    super.key,
    this.height = 40,
    this.backgroundColor = Colors.white,
    this.title = '壁纸APP',
    this.subtitle,
    this.child,
    this.onBackPressed,
  });

  @override
  State<CustomTitleBar> createState() => _CustomTitleBarState();
}

class _WindowListenerImpl extends WindowListener {
  final _CustomTitleBarState _state;

  _WindowListenerImpl(this._state);

  @override
  void onWindowMaximize() => _state._checkMaximized();
  @override
  void onWindowUnmaximize() => _state._checkMaximized();
}

class _CustomTitleBarState extends State<CustomTitleBar> {
  bool _isMaximized = false;
  late final WindowListener _windowListener;

  @override
  void initState() {
    super.initState();
    _checkMaximized();
    _windowListener = _WindowListenerImpl(this);
    windowManager.addListener(_windowListener);
  }

  @override
  void dispose() {
    windowManager.removeListener(_windowListener);
    super.dispose();
  }

  Future<void> _checkMaximized() async {
    if (isDesktopPlatform) {
      final isMaximized = await windowManager.isMaximized();
      if (mounted) {
        setState(() => _isMaximized = isMaximized);
      }
    }
  }

  void _minimize() => windowManager.minimize();
  void _maximizeOrRestore() async {
    if (_isMaximized) {
      await windowManager.unmaximize();
    } else {
      await windowManager.maximize();
    }
    _checkMaximized();
  }

  void _close() => windowManager.close();

  @override
  Widget build(BuildContext context) {
    // 非桌面平台不显示自定义标题栏
    if (!isDesktopPlatform) {
      return const SizedBox.shrink();
    }

    return Container(
      height: widget.height,
      color: widget.backgroundColor,
      child: Row(
        children: [
          // 返回按钮（可选）
          if (widget.onBackPressed != null)
            _TitleBarIconButton(
              icon: Icons.arrow_back,
              tooltip: '返回首页',
              onPressed: widget.onBackPressed!,
            ),
          // 左侧：Logo + 标题（可拖拽区域）
          Expanded(
            child: DragToMoveArea(
              child: GestureDetector(
                onDoubleTap: _maximizeOrRestore,
                behavior: HitTestBehavior.opaque,
                child: Row(
                children: [
                  const SizedBox(width: 16),
                  // Logo
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2196F3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(
                      Icons.wallpaper_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  // 主标题
                  Text(
                    widget.title,
                    style: const TextStyle(
                      color: Color(0xFF333333),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.subtitle != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      widget.subtitle!,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
          // 中间：自定义内容
          if (widget.child != null) ...[
            Expanded(
              child: widget.child!,
            ),
          ],
          // 右侧：功能图标 + 分隔线 + 窗口控制按钮
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 刷新
              _TitleBarIconButton(
                icon: Icons.refresh,
                tooltip: '刷新',
                onPressed: () {},
              ),
              // 最小化
              _WindowControlButton(
                icon: Icons.remove,
                onPressed: _minimize,
              ),
              // 最大化/恢复（恢复时显示重叠方框图标）
              _WindowControlButton(
                icon: _isMaximized ? Icons.filter_none : Icons.crop_square,
                onPressed: _maximizeOrRestore,
              ),
              // 关闭
              _WindowControlButton(
                icon: Icons.close,
                onPressed: _close,
                isClose: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 标题栏功能图标按钮
class _TitleBarIconButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _TitleBarIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  State<_TitleBarIconButton> createState() => _TitleBarIconButtonState();
}

class _TitleBarIconButtonState extends State<_TitleBarIconButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onPressed,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 40,
            height: 40,
            color: _hovered ? Colors.grey[200] : Colors.transparent,
            child: Icon(
              widget.icon,
              size: 20,
              color: const Color(0xFF333333),
            ),
          ),
        ),
      ),
    );
  }
}

/// 窗口控制按钮（最小化、最大化、关闭）
class _WindowControlButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isClose;

  const _WindowControlButton({
    required this.icon,
    required this.onPressed,
    this.isClose = false,
  });

  @override
  State<_WindowControlButton> createState() => _WindowControlButtonState();
}

class _WindowControlButtonState extends State<_WindowControlButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final hoverColor = widget.isClose
        ? const Color(0xFFE81123) // 关闭按钮悬停红色
        : Colors.grey[300]!;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 46,
          height: 40,
          color: _hovered ? hoverColor : Colors.transparent,
          child: Icon(
            widget.icon,
            size: 14,
            color: const Color(0xFF333333),
          ),
        ),
      ),
    );
  }
}
