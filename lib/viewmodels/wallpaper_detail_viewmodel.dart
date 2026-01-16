import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/wallpaper_model.dart';

/// 壁纸详情 ViewModel
class WallpaperDetailViewModel extends ChangeNotifier {
  final WallpaperModel wallpaper;
  
  bool _isPlaying = false;
  bool _isMuted = false;
  bool _isFullscreen = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = const Duration(seconds: 10); // 10秒预览限制
  Timer? _timer;

  bool get isPlaying => _isPlaying;
  bool get isMuted => _isMuted;
  bool get isFullscreen => _isFullscreen;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;
  double get progress => _currentPosition.inMilliseconds / _totalDuration.inMilliseconds;

  WallpaperDetailViewModel({required this.wallpaper}) {
    _startPreviewTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startPreviewTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_isPlaying && _currentPosition < _totalDuration) {
        _currentPosition = Duration(
          milliseconds: _currentPosition.inMilliseconds + 100,
        );
        notifyListeners();
      } else if (_currentPosition >= _totalDuration) {
        pause();
      }
    });
  }

  void play() {
    if (_currentPosition >= _totalDuration) {
      _currentPosition = Duration.zero;
    }
    _isPlaying = true;
    notifyListeners();
  }

  void pause() {
    _isPlaying = false;
    notifyListeners();
  }

  void togglePlayPause() {
    if (_isPlaying) {
      pause();
    } else {
      play();
    }
  }

  void toggleMute() {
    _isMuted = !_isMuted;
    notifyListeners();
  }

  void toggleFullscreen() {
    _isFullscreen = !_isFullscreen;
    notifyListeners();
  }

  void seekTo(double value) {
    _currentPosition = Duration(
      milliseconds: (value * _totalDuration.inMilliseconds).round(),
    );
    notifyListeners();
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}

