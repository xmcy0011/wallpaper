import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'utils/platform_utils.dart';
import 'views/home.dart';
import 'services/services.dart';
import 'services/drivenadapter/auth_service.dart';
import 'services/drivenadapter/download_service.dart';
import 'services/dbaccess/db_system_settings.dart';
import 'services/dbaccess/db_wallpaper_storage.dart';
import 'services/enginewrap/wallpaper_engine_service.dart';
import 'services/logics/storage.dart';
import 'services/logics/player.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  initServices();

  // 仅在桌面平台启用自定义标题栏
  if (isDesktopPlatform) {
    await windowManager.ensureInitialized();
    const windowOptions = WindowOptions(
      size: Size(1280, 800),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
    );
    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  runApp(const MyApp());
}

void initServices() {
  // dbaccess
  Services().setSystemSettings(DBSystemSettingsImpl());
  Services().setWallpaperStorage(DBWallpaperStorageImpl(Services().getSystemSettings()));
  // drivenadapter
  Services().setAuthService(DrivenAuthServiceImpl());
  Services().setDownloadService(DownloadServiceImpl());
  // enginewrap
  Services().setWallpaperEngineService(WallpaperEngineServiceImpl());
  // logics
  Services().setStorageLogic( 
    StorageLogicImpl(
      Services().getSystemSettings(),
      Services().getDownloadService(),
      Services().getWallpaperStorage(),
    ),
  );
  Services().setPlayerLogic(PlayerLogicImpl(
    Services().getWallpaperEngineService(),
    Services().getWallpaperStorage(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '壁纸APP',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xff222222)),
      ),
      home: const MyHomePage(title: '壁纸APP'),
    );
  }
}
