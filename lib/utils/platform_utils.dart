// 平台检测工具，使用条件导入以支持 Web 编译
import 'platform_utils_stub.dart'
    if (dart.library.io) 'platform_utils_io.dart' as _impl;

bool get isDesktopPlatform => _impl.isDesktopPlatform;
