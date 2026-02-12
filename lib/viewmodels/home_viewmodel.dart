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

  int _selectedRecommendationIndex = 0;
  int get selectedRecommendationIndex => _selectedRecommendationIndex;

  /// 主内容区 Tab 名称（推荐 + 各分类名）
  List<String> get mainContentTabNames => [
    '推荐',
    ...recommendationList,
  ];

  /// 各分类对应的推荐内容
  /// 第1个「推荐」：8 个元素，前 6 个轮播图，后 2 个竖向框
  /// 其他分类：各 6 个元素，用于六宫格
  final List<List<RecommendationItem>> _recommendationsByCategory = [
    // 推荐：8 个元素（6 轮播 + 2 竖向）
    [
      RecommendationItem(
        title: '特色壁纸1',
        imageUrl: 'https://picsum.photos/800/450?random=1',
        color: Colors.blue,
        isVip: false,
      ),
      RecommendationItem(
        title: '特色壁纸2',
        imageUrl: 'https://picsum.photos/800/450?random=2',
        color: Colors.purple,
        isVip: true,
      ),
      RecommendationItem(
        title: '特色壁纸3',
        imageUrl: 'https://picsum.photos/800/450?random=3',
        color: Colors.pink,
        isVip: false,
      ),
      RecommendationItem(
        title: '特色壁纸4',
        imageUrl: 'https://picsum.photos/800/450?random=4',
        color: Colors.orange,
        isVip: true,
      ),
      RecommendationItem(
        title: '特色壁纸5',
        imageUrl: 'https://picsum.photos/800/450?random=5',
        color: Colors.teal,
        isVip: false,
      ),
      RecommendationItem(
        title: '特色壁纸6',
        imageUrl: 'https://picsum.photos/800/450?random=6',
        color: Colors.indigo,
        isVip: true,
      ),
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
    // 入冬啦：6 个元素（六宫格）
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
      RecommendationItem(
        title: '冬季森林',
        imageUrl: 'https://picsum.photos/300/200?random=18',
        color: Colors.cyan,
        isVip: false,
      ),
      RecommendationItem(
        title: '雪景小屋',
        imageUrl: 'https://picsum.photos/300/200?random=19',
        color: Colors.white,
        isVip: true,
      ),
      RecommendationItem(
        title: '冰晶世界',
        imageUrl: 'https://picsum.photos/300/200?random=20',
        color: Colors.lightBlue,
        isVip: false,
      ),
      RecommendationItem(
        title: '暖冬午后',
        imageUrl: 'https://picsum.photos/300/200?random=21',
        color: Colors.amber,
        isVip: false,
      ),
    ],
    // 一起去抓水母吧!：6 个元素
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
      RecommendationItem(
        title: '章鱼哥',
        imageUrl: 'https://picsum.photos/300/200?random=22',
        color: Colors.teal,
        isVip: false,
      ),
      RecommendationItem(
        title: '蟹老板',
        imageUrl: 'https://picsum.photos/300/200?random=23',
        color: Colors.red,
        isVip: true,
      ),
      RecommendationItem(
        title: '珊迪',
        imageUrl: 'https://picsum.photos/300/200?random=24',
        color: Colors.brown,
        isVip: false,
      ),
      RecommendationItem(
        title: '痞老板',
        imageUrl: 'https://picsum.photos/300/200?random=25',
        color: Colors.green,
        isVip: false,
      ),
    ],
    // 美少女拯救世界：6 个元素
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
      RecommendationItem(
        title: '美少女战士',
        imageUrl: 'https://picsum.photos/300/200?random=26',
        color: Colors.purple,
        isVip: true,
      ),
      RecommendationItem(
        title: '辉夜姬',
        imageUrl: 'https://picsum.photos/300/200?random=27',
        color: Colors.indigo,
        isVip: false,
      ),
      RecommendationItem(
        title: '千与千寻',
        imageUrl: 'https://picsum.photos/300/200?random=28',
        color: Colors.orange,
        isVip: true,
      ),
      RecommendationItem(
        title: '龙猫',
        imageUrl: 'https://picsum.photos/300/200?random=29',
        color: Colors.green,
        isVip: false,
      ),
    ],
    // 随时间变化：6 个元素
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
      RecommendationItem(
        title: '日出东方',
        imageUrl: 'https://picsum.photos/300/200?random=30',
        color: Colors.deepOrange,
        isVip: false,
      ),
      RecommendationItem(
        title: '星空璀璨',
        imageUrl: 'https://picsum.photos/300/200?random=31',
        color: Colors.indigo,
        isVip: true,
      ),
      RecommendationItem(
        title: '黄昏时分',
        imageUrl: 'https://picsum.photos/300/200?random=32',
        color: Colors.amber,
        isVip: false,
      ),
      RecommendationItem(
        title: '月夜静谧',
        imageUrl: 'https://picsum.photos/300/200?random=33',
        color: Colors.blueGrey,
        isVip: false,
      ),
    ],
  ];

  // 推荐列表（主内容 Tab 除「推荐」外的分类名）
  final List<String> recommendationList = [
    '入冬啦',
    '一起去抓水母吧!',
    '美少女拯救世界',
    '随时间变化',
  ];

  /// 当前选中分类的推荐内容（兼容旧逻辑，index 0 为推荐）
  List<RecommendationItem> get currentRecommendations =>
      _recommendationsByCategory[_selectedRecommendationIndex];

  /// 推荐 Tab：轮播图 6 张
  List<RecommendationItem> get recommendationCarouselItems =>
      _recommendationsByCategory[0].take(6).toList();

  /// 推荐 Tab：竖向框 2 张
  List<RecommendationItem> get recommendationSidebarItems =>
      _recommendationsByCategory[0].skip(6).take(2).toList();

  /// 指定分类的六宫格数据（6 个元素）
  List<RecommendationItem> getRecommendationGridItems(int categoryIndex) {
    if (categoryIndex <= 0 || categoryIndex >= _recommendationsByCategory.length) {
      return [];
    }
    return _recommendationsByCategory[categoryIndex].take(6).toList();
  }

  // 热门壁纸（分页加载）
  final List<HotWallpaperItem> _hotWallpapers = [];
  List<HotWallpaperItem> get hotWallpapers => List.unmodifiable(_hotWallpapers);
  int _hotWallpapersPage = 0;
  bool _hotWallpapersLoading = false;
  bool get hotWallpapersLoading => _hotWallpapersLoading;
  bool _hotWallpapersHasMore = true;
  bool get hotWallpapersHasMore => _hotWallpapersHasMore;

  /// 加载热门壁纸（mock API：刷新或首次加载）
  Future<void> loadHotWallpapers() async {
    if (_hotWallpapersLoading) return;
    _hotWallpapersLoading = true;
    _hotWallpapersPage = 0;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500)); // 模拟网络延迟
    _hotWallpapers.clear();
    _hotWallpapers.addAll(_mockHotWallpapersPage(0));
    _hotWallpapersLoading = false;
    _hotWallpapersHasMore = true;
    notifyListeners();
  }

  /// 加载更多热门壁纸（mock API：每次 8 行 = 24 张）
  Future<void> loadMoreHotWallpapers() async {
    if (_hotWallpapersLoading || !_hotWallpapersHasMore) return;
    _hotWallpapersLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500)); // 模拟网络延迟
    _hotWallpapersPage++;
    final newItems = _mockHotWallpapersPage(_hotWallpapersPage);
    _hotWallpapers.addAll(newItems);
    _hotWallpapersLoading = false;
    _hotWallpapersHasMore = newItems.length >= 24; // mock 一直有更多
    notifyListeners();
  }

  /// Mock 生成一页热门壁纸（24 张）
  List<HotWallpaperItem> _mockHotWallpapersPage(int page) {
    final colors = [
      Colors.indigo, Colors.red, Colors.deepPurple, Colors.blue,
      Colors.pink, Colors.orange, Colors.teal, Colors.green,
      Colors.amber, Colors.cyan, Colors.brown,
    ];
    return List.generate(24, (i) {
      final idx = page * 24 + i;
      return HotWallpaperItem(
        title: '热门壁纸${idx + 1}',
        imageUrl: 'https://picsum.photos/300/200?random=${100 + idx}',
        color: colors[idx % colors.length],
        isSvip: idx % 3 == 0,
      );
    });
  }

  HomeViewModel() {
    _authService.addListener(_onAuthStateChanged);
    _startCarouselAutoPlay();
    loadHotWallpapers(); // 首次加载热门壁纸
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
    const changeInterval = 5;
    // 定时器切换轮播图
    Future.delayed(const Duration(seconds: changeInterval), () {
      if (!_isDisposed && carouselController.hasClients) {
        final len = recommendationCarouselItems.length;
        if (_currentCarouselIndex < len - 1) {
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
    final len = recommendationCarouselItems.length;
    if (len == 0) return;
    if (_currentCarouselIndex > 0) {
      carouselController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // 首张时点击左箭头，循环到末张
      carouselController.animateToPage(
        len - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void nextCarouselPage() {
    final len = recommendationCarouselItems.length;
    if (len == 0) return;
    if (_currentCarouselIndex < len - 1) {
      carouselController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // 末张时点击右箭头，循环到首张
      carouselController.animateToPage(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
}

