import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/wallpaper_model.dart';
import '../services/auth_service.dart';

/// 主页 ViewModel
class HomeViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final PageController carouselController = PageController();
  
  int _currentCarouselIndex = 0;
  bool _showLoginBanner = true;
  bool _isDisposed = false;

  int get currentCarouselIndex => _currentCarouselIndex;
  bool get showLoginBanner => _showLoginBanner;
  bool get isLoggedIn => _authService.isLoggedIn;

  // 轮播图数据
  final List<CarouselItem> carouselItems = [
    CarouselItem(
      title: '特色壁纸1',
      imageUrl: 'https://picsum.photos/800/450?random=1',
      color: Colors.blue,
    ),
    CarouselItem(
      title: '特色壁纸2',
      imageUrl: 'https://picsum.photos/800/450?random=2',
      color: Colors.purple,
    ),
    CarouselItem(
      title: '特色壁纸3',
      imageUrl: 'https://picsum.photos/800/450?random=3',
      color: Colors.pink,
    ),
    CarouselItem(
      title: '特色壁纸4',
      imageUrl: 'https://picsum.photos/800/450?random=4',
      color: Colors.orange,
    ),
    CarouselItem(
      title: '特色壁纸5',
      imageUrl: 'https://picsum.photos/800/450?random=5',
      color: Colors.teal,
    ),
  ];

  // 推荐侧边栏图片
  final List<RecommendationItem> recommendations = [
    RecommendationItem(
      title: '罗小黑-雪山旅者',
      imageUrl: 'https://picsum.photos/300/200?random=10',
      color: Colors.blue,
      isVip: false,
    ),
    RecommendationItem(
      title: '伊蕾娜',
      imageUrl: 'https://picsum.photos/300/200?random=11',
      color: Colors.purple,
      isVip: true,
    ),
  ];

  // 推荐列表
  final List<String> recommendationList = [
    '入冬啦',
    '一起去抓水母吧!',
    '美少女拯救世界',
    '随时间变化',
  ];

  // 热门壁纸
  final List<HotWallpaperItem> hotWallpapers = [
    HotWallpaperItem(
      title: '热门壁纸1',
      imageUrl: 'https://picsum.photos/300/200?random=20',
      color: Colors.indigo,
      isSvip: true,
    ),
    HotWallpaperItem(
      title: '热门壁纸2',
      imageUrl: 'https://picsum.photos/300/200?random=21',
      color: Colors.red,
      isSvip: true,
    ),
    HotWallpaperItem(
      title: '热门壁纸3',
      imageUrl: 'https://picsum.photos/300/200?random=22',
      color: Colors.deepPurple,
      isSvip: true,
    ),
  ];

  HomeViewModel() {
    _authService.addListener(_onAuthStateChanged);
    _startCarouselAutoPlay();
  }

  @override
  void dispose() {
    _isDisposed = true;
    carouselController.dispose();
    _authService.removeListener(_onAuthStateChanged);
    super.dispose();
  }

  void _onAuthStateChanged() {
    notifyListeners();
  }

  void updateCarouselIndex(int index) {
    _currentCarouselIndex = index;
    notifyListeners();
  }

  void hideLoginBanner() {
    _showLoginBanner = false;
    notifyListeners();
  }

  void _startCarouselAutoPlay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (!_isDisposed && carouselController.hasClients) {
        if (_currentCarouselIndex < carouselItems.length - 1) {
          _currentCarouselIndex++;
        } else {
          _currentCarouselIndex = 0;
        }
        carouselController.animateToPage(
          _currentCarouselIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        _startCarouselAutoPlay();
      }
    });
  }

  void previousCarouselPage() {
    if (_currentCarouselIndex > 0) {
      carouselController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void nextCarouselPage() {
    if (_currentCarouselIndex < carouselItems.length - 1) {
      carouselController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
}

