import 'dart:io' show Platform;

bool get isDesktopPlatform =>
    Platform.isWindows || Platform.isMacOS || Platform.isLinux;
