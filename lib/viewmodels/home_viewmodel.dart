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

  // 推荐列表（左侧分类，点击切换右侧内容）
  final List<String> recommendationList = [
    '入冬啦',
    '一起去抓水母吧!',
    '美少女拯救世界',
    '随时间变化',
  ];

  int _selectedRecommendationIndex = 0;
  int get selectedRecommendationIndex => _selectedRecommendationIndex;

  /// 各分类对应的推荐内容
  final List<List<RecommendationItem>> _recommendationsByCategory = [
    // 入冬啦
    [
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
    ],
    // 一起去抓水母吧!
    [
      RecommendationItem(
        title: '海绵宝宝',
        imageUrl: 'https://picsum.photos/300/200?random=12',
        color: Colors.cyan,
        isVip: false,
      ),
      RecommendationItem(
        title: '派大星',
        imageUrl: 'https://picsum.photos/300/200?random=13',
        color: Colors.pink,
        isVip: true,
      ),
    ],
    // 美少女拯救世界
    [
      RecommendationItem(
        title: '魔法少女小圆',
        imageUrl: 'https://picsum.photos/300/200?random=14',
        color: Colors.pink,
        isVip: true,
      ),
      RecommendationItem(
        title: '小樱',
        imageUrl: 'https://picsum.photos/300/200?random=15',
        color: Colors.amber,
        isVip: false,
      ),
    ],
    // 随时间变化
    [
      RecommendationItem(
        title: '昼夜交替',
        imageUrl: 'https://picsum.photos/300/200?random=16',
        color: Colors.orange,
        isVip: false,
      ),
      RecommendationItem(
        title: '四季流转',
        imageUrl: 'https://picsum.photos/300/200?random=17',
        color: Colors.green,
        isVip: true,
      ),
    ],
  ];

  /// 当前选中分类的推荐内容
  List<RecommendationItem> get currentRecommendations =>
      _recommendationsByCategory[_selectedRecommendationIndex];

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

  void selectRecommendation(int index) {
    if (index >= 0 && index < recommendationList.length && index != _selectedRecommendationIndex) {
      _selectedRecommendationIndex = index;
      notifyListeners();
    }
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

