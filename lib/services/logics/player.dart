import '../logics.dart';
import '../dbaccess.dart';
import '../enginewrap.dart';
import 'dart:developer';
import 'dart:async';
import 'dart:math' show Random;
import 'package:flutter/foundation.dart';

class PlayerLogicImpl extends PlayerLogic {
  late WallpaperEngineService wallpaperEngineService;
  late DBWallpaperStorage wallpaperStorage;
  
  bool _isInitialized = false;
  AutoPlayOrder _autoPlayOrder = AutoPlayOrder.sequential;
  Duration _autoPlayInterval = const Duration(minutes: 1);
  bool _autoPlayActive = false;
  Timer? _autoPlayTimer;

  String? _currentWallpaperId;
  final ValueNotifier<String> _playingWallpaperIdNotifier = ValueNotifier<String>('');
  final List<String> _autoPlayWallpaperIds = [];
  final Random _random = Random();

  PlayerLogicImpl(this.wallpaperEngineService, this.wallpaperStorage);

  @override
  void add(String wallpaperId) {
    if (!_autoPlayWallpaperIds.contains(wallpaperId)) {
      _autoPlayWallpaperIds.add(wallpaperId);
    }
  }

  @override
  void setAutoPlayOrder(AutoPlayOrder order) {
    _autoPlayOrder = order;
  }

  @override
  void setAutoPlayInterval(Duration interval) {
    if (interval <= Duration.zero) return;
    _autoPlayInterval = interval;
    if (_autoPlayActive) {
      _scheduleNextAutoTick();
    }
  }

  @override
  Future<void> startAutoPlay() async {
    _autoPlayActive = true;
    if (_autoPlayWallpaperIds.isEmpty) return;
    if (_currentWallpaperId == null) {
      await play(_pickInitialWallpaperId());
    } else {
      _scheduleNextAutoTick();
    }
  }

  @override
  void stopAutoPlay() {
    _autoPlayActive = false;
    _autoPlayTimer?.cancel();
    _autoPlayTimer = null;
  }

  String _pickInitialWallpaperId() {
    if (_autoPlayOrder == AutoPlayOrder.random) {
      return _autoPlayWallpaperIds[_random.nextInt(_autoPlayWallpaperIds.length)];
    }
    return _autoPlayWallpaperIds.first;
  }

  String _pickNextAutoWallpaperId() {
    if (_autoPlayWallpaperIds.isEmpty) return '';
    if (_autoPlayWallpaperIds.length == 1) {
      return _autoPlayWallpaperIds.first;
    }
    if (_autoPlayOrder == AutoPlayOrder.random) {
      String next;
      do {
        next = _autoPlayWallpaperIds[_random.nextInt(_autoPlayWallpaperIds.length)];
      } while (next == _currentWallpaperId);
      return next;
    }
    final cur = _currentWallpaperId;
    final idx = cur == null ? -1 : _autoPlayWallpaperIds.indexOf(cur);
    if (idx < 0) {
      return _autoPlayWallpaperIds.first;
    }
    return _autoPlayWallpaperIds[(idx + 1) % _autoPlayWallpaperIds.length];
  }

  Future<void> _advanceAutoPlay() async {
    if (!_autoPlayActive || _autoPlayWallpaperIds.isEmpty) return;
    final nextId = _pickNextAutoWallpaperId();
    if (nextId.isEmpty) return;
    try {
      await _loadWallpaperInternal(nextId);
    } catch (e, st) {
      log('auto advance failed: $e', stackTrace: st);
    }
  }

  void _scheduleNextAutoTick() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = null;
    if (!_autoPlayActive) return;
    _autoPlayTimer = Timer(_autoPlayInterval, () {
      _advanceAutoPlay().then((_) {
        if (_autoPlayActive) {
          _scheduleNextAutoTick();
        }
      });
    });
  }

  Future<void> _ensureEngineInitialized() async {
    if (_isInitialized) return;
    await wallpaperEngineService.create();
    await wallpaperEngineService.initialize();
    _isInitialized = true;
  }

  Future<void> _loadWallpaperInternal(String wallpaperId) async {
    await _ensureEngineInitialized();

    _currentWallpaperId = wallpaperId;

    DBWallpaper? wallpaper = wallpaperStorage.getLocalWallpaper(wallpaperId);
    if (wallpaper == null) {
      throw Exception('壁纸不存在');
    }

    String fullPath = wallpaperStorage.getWallpaperFilePath(wallpaperId, wallpaper.file);
    bool ok = await wallpaperEngineService.load(fullPath);
    if (!ok) {
      throw Exception('加载壁纸失败');
    }
    log('load wallpaper: $fullPath, ok: $ok');

    await wallpaperEngineService.play();
    _playingWallpaperIdNotifier.value = wallpaperId;
  }

  @override
  Future<void> play(String wallpaperId) async {
    await _loadWallpaperInternal(wallpaperId);
    if (_autoPlayActive) {
      _scheduleNextAutoTick();
    }
  }

  @override
  Future<void> pause(String wallpaperId) async {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = null;
    _currentWallpaperId = null;
    wallpaperEngineService.pause();
    _playingWallpaperIdNotifier.value = '';
  }

  @override
  bool isPlaying(String wallpaperId) {
    return _currentWallpaperId == wallpaperId;
  }

  @override
  String? getCurrentWallpaperId() {
    return _currentWallpaperId;
  }

  @override
  ValueNotifier<String> get playingWallpaperIdNotifier => _playingWallpaperIdNotifier;
}
