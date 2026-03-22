import 'package:flutter/foundation.dart';
import '../services/dbaccess.dart';
import '../services/logics.dart';
import '../services/services.dart';

/// 个人中心 ViewModel - 壁纸管理/个人内容中心
class PersonalCenterViewModel extends ChangeNotifier {
  final StorageLogic _storageLogic = Services().getStorageLogic();
  final PlayerLogic _playerLogic = Services().getPlayerLogic();

  PersonalCenterViewModel() {
    _playerLogic.playingWallpaperIdNotifier.addListener(_onPlayerPlaybackChanged);
  }

  void _onPlayerPlaybackChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    _playerLogic.playingWallpaperIdNotifier.removeListener(_onPlayerPlaybackChanged);
    super.dispose();
  }

  /// 当前正在作为桌面壁纸播放的 id（含自动切换），无则 null
  String? get currentPlayingWallpaperId => _playerLogic.getCurrentWallpaperId();

  /// 子 Tab 名称：本地壁纸、我的上传、我的收藏、我的购买
  final List<String> subTabs = ['本地壁纸', '我的上传', '我的收藏', '我的购买'];

  /// 类型筛选：全部/视频/互动/图片
  final List<String> typeFilters = ['全部', '视频', '互动', '图片'];

  int _selectedTypeFilter = 0;
  int get selectedTypeFilter => _selectedTypeFilter;

  List<DBWallpaper> _wallpaperItems = [];
  List<DBWallpaper> get wallpaperItems => List.unmodifiable(_wallpaperItems);

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  void setSelectedTypeFilter(int index) {
    if (index >= 0 && index < typeFilters.length && index != _selectedTypeFilter) {
      _selectedTypeFilter = index;
      notifyListeners();
    }
  }

  /// 加载本地壁纸列表
  Future<void> loadLocalWallpapers() async {
    _isLoading = true;
    notifyListeners();

    try {
      final list = await _storageLogic.getLocalWallpaperList();
      _wallpaperItems = list;
    } catch (e) {
      _wallpaperItems = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
