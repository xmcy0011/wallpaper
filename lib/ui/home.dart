import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_guide.dart';
import 'profile_page.dart';
import 'wallpaper_detail_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  final _authService = AuthService();
  final PageController _carouselController = PageController();
  int _currentCarouselIndex = 0;
  late TabController _tabController;
  bool _showLoginBanner = true;

  // 轮播图数据
  final List<CarouselItem> _carouselItems = [
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
  final List<RecommendationItem> _recommendations = [
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
  final List<String> _recommendationList = [
    '入冬啦',
    '一起去抓水母吧!',
    '美少女拯救世界',
    '随时间变化',
  ];

  // 热门壁纸
  final List<HotWallpaperItem> _hotWallpapers = [
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _authService.addListener(_onAuthStateChanged);
    // 自动轮播
    _startCarouselAutoPlay();
  }

  @override
  void dispose() {
    _carouselController.dispose();
    _tabController.dispose();
    _authService.removeListener(_onAuthStateChanged);
    super.dispose();
  }

  void _onAuthStateChanged() {
    setState(() {});
  }

  void _startCarouselAutoPlay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _carouselController.hasClients) {
        if (_currentCarouselIndex < _carouselItems.length - 1) {
          _currentCarouselIndex++;
        } else {
          _currentCarouselIndex = 0;
        }
        _carouselController.animateToPage(
          _currentCarouselIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        _startCarouselAutoPlay();
      }
    });
  }

  void _openLoginGuide() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const LoginGuidePage(),
      ),
    );
  }

  void _openProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ProfilePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1a1a1a),
      body: Column(
        children: [
          // 顶部导航栏
          _buildTopBar(),
          
          // 主内容区域
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // 主内容区（登录横幅 + 轮播图 + 推荐栏）
                  _buildMainContent(),
                  
                  // 热门壁纸区域
                  _buildHotWallpapersSection(),
                  
                  const SizedBox(height: 80), // 为底部播放器留空间
                ],
              ),
            ),
          ),
          
          // 底部媒体播放器控制栏
          _buildMediaPlayerBar(),
        ],
      ),
    );
  }

  // 顶部导航栏
  Widget _buildTopBar() {
    return Container(
      height: 60,
      color: const Color(0xff222222),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Logo和标题
          Row(
            children: [
              const Icon(
                Icons.wallpaper_rounded,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: 8),
              const Text(
                '壁纸APP',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '啊噗',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          
          const SizedBox(width: 32),
          
          // 导航标签
          Expanded(
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.white.withOpacity(0.6),
              indicatorColor: Colors.blue,
              tabs: const [
                Tab(text: '推荐'),
                Tab(text: '资源区'),
                Tab(text: 'SVIP'),
                Tab(text: '组件'),
              ],
            ),
          ),
          
          const SizedBox(width: 16),
          
          // 搜索栏
          Expanded(
            flex: 2,
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(18),
              ),
              child: TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: '蜡笔小新',
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.white.withOpacity(0.5),
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // 上传按钮
          Container(
            height: 36,
            decoration: BoxDecoration(
              color: Colors.pink,
              borderRadius: BorderRadius.circular(18),
            ),
            child: TextButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('上传功能开发中')),
                );
              },
              icon: const Icon(Icons.upload, size: 18, color: Colors.white),
              label: const Text(
                '上传',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // 手机APP图标
          IconButton(
            icon: Icon(Icons.phone_android, color: Colors.white.withOpacity(0.7)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('手机APP功能开发中')),
              );
            },
          ),
          
          // 设置图标
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white.withOpacity(0.7)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('设置功能开发中')),
              );
            },
          ),
          
          // 用户信息或登录按钮
          AnimatedBuilder(
            animation: _authService,
            builder: (context, _) {
              if (_authService.isLoggedIn) {
                return InkWell(
                  onTap: _openProfile,
                  child: Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: _authService.userAvatar != null
                              ? ClipOval(
                                  child: Image.network(
                                    _authService.userAvatar!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.person,
                                        size: 18,
                                        color: Colors.white70,
                                      );
                                    },
                                  ),
                                )
                              : const Icon(
                                  Icons.person,
                                  size: 18,
                                  color: Colors.white70,
                                ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _authService.userName ?? '用户',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return TextButton(
                  onPressed: _openLoginGuide,
                  child: const Text(
                    '登录',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // 主内容区域
  Widget _buildMainContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 左侧：登录横幅
          if (!_authService.isLoggedIn && _showLoginBanner)
            Container(
              width: 200,
              margin: const EdgeInsets.only(right: 16),
              child: _buildLoginBanner(),
            ),
          
          // 中间：轮播图
          Expanded(
            flex: 3,
            child: _buildCarousel(),
          ),
          
          const SizedBox(width: 16),
          
          // 右侧：推荐栏
          Expanded(
            flex: 1,
            child: _buildRecommendationSidebar(),
          ),
        ],
      ),
    );
  }

  // 登录横幅
  Widget _buildLoginBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.pink,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '登录立享',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '【限时低价会员】',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '~(o´`ο) Χ',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 18),
              onPressed: () {
                setState(() {
                  _showLoginBanner = false;
                });
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
        ],
      ),
    );
  }

  // 轮播图
  Widget _buildCarousel() {
    return Container(
      height: 450,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xff2a2a2a),
      ),
      child: Stack(
        children: [
          // 轮播内容
          PageView.builder(
            controller: _carouselController,
            onPageChanged: (index) {
              setState(() {
                _currentCarouselIndex = index;
              });
            },
            itemCount: _carouselItems.length,
            itemBuilder: (context, index) {
              final item = _carouselItems[index];
              return InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => WallpaperDetailPage(
                        wallpaperId: '2001919${100 + index}',
                        title: item.title,
                        imageUrl: item.imageUrl,
                        color: item.color,
                        creatorName: 'Creator ${index + 1}',
                        isSvip: true,
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        item.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  item.color,
                                  item.color.withOpacity(0.6),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    // SVIP标签
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.star, size: 14, color: Colors.white),
                            SizedBox(width: 4),
                            Text(
                              'SVIP',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              );
            },
          ),
          
          // 左右箭头
          Positioned(
            left: 16,
            top: 0,
            bottom: 0,
            child: Center(
              child: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.chevron_left, color: Colors.white),
                ),
                onPressed: () {
                  if (_currentCarouselIndex > 0) {
                    _carouselController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
              ),
            ),
          ),
          Positioned(
            right: 16,
            top: 0,
            bottom: 0,
            child: Center(
              child: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.chevron_right, color: Colors.white),
                ),
                onPressed: () {
                  if (_currentCarouselIndex < _carouselItems.length - 1) {
                    _carouselController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
              ),
            ),
          ),
          
          // 指示器
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _carouselItems.length,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentCarouselIndex == index
                        ? Colors.white
                        : Colors.white.withOpacity(0.3),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 推荐侧边栏
  Widget _buildRecommendationSidebar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 推荐图片预览
        ..._recommendations.map((item) => Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () {
                  final index = _recommendations.indexOf(item);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => WallpaperDetailPage(
                        wallpaperId: '2001919${200 + index}',
                        title: item.title,
                        imageUrl: item.imageUrl,
                        color: item.color,
                        creatorName: 'Creator ${index + 1}',
                        isVip: item.isVip,
                        isSvip: false,
                      ),
                    ),
                  );
                },
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item.imageUrl,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  item.color,
                                  item.color.withOpacity(0.6),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          );
                        },
                      ),
                    ),
                  if (item.isVip)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          shape: BoxShape.circle,
                        ),
                        child: const Text(
                          'V',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )),
        
        // 推荐列表
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xff2a2a2a),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '推荐',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ..._recommendationList.map((text) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('点击了: $text')),
                    );
                  },
                  child: Text(
                    text,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ),
              )),
            ],
          ),
        ),
      ],
    );
  }

  // 热门壁纸区域
  Widget _buildHotWallpapersSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '热门壁纸',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('查看更多功能开发中')),
                  );
                },
                child: Text(
                  '更多',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: _hotWallpapers.map((item) => Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: InkWell(
                  onTap: () {
                    final index = _hotWallpapers.indexOf(item);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => WallpaperDetailPage(
                          wallpaperId: '2001919${300 + index}',
                          title: item.title,
                          imageUrl: item.imageUrl,
                          color: item.color,
                          creatorName: 'Creator ${index + 1}',
                          isSvip: item.isSvip,
                        ),
                      ),
                    );
                  },
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item.imageUrl,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 200,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    item.color,
                                    item.color.withOpacity(0.6),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            );
                          },
                        ),
                      ),
                    if (item.isSvip)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Text(
                            'S',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  // 底部媒体播放器控制栏
  Widget _buildMediaPlayerBar() {
    return Container(
      height: 60,
      color: const Color(0xff222222),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // 左侧：标题
          Expanded(
            child: Text(
              '壁纸APP看板娘小优和小欧',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
          ),
          
          // 中间：播放控制
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.shuffle, color: Colors.white.withOpacity(0.7)),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.skip_previous, color: Colors.white.withOpacity(0.7)),
                onPressed: () {},
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.play_arrow, color: Colors.white),
                  onPressed: () {},
                ),
              ),
              IconButton(
                icon: Icon(Icons.skip_next, color: Colors.white.withOpacity(0.7)),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.volume_up, color: Colors.white.withOpacity(0.7)),
                onPressed: () {},
              ),
              Container(
                width: 100,
                margin: const EdgeInsets.only(left: 8),
                child: Slider(
                  value: 0.5,
                  onChanged: (value) {},
                  activeColor: Colors.blue,
                  inactiveColor: Colors.white.withOpacity(0.3),
                ),
              ),
              IconButton(
                icon: Icon(Icons.repeat, color: Colors.white.withOpacity(0.7)),
                onPressed: () {},
              ),
            ],
          ),
          
          // 右侧：其他功能
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.timer, color: Colors.white.withOpacity(0.7)),
                onPressed: () {},
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  '多屏显示',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// 数据模型
class CarouselItem {
  final String title;
  final String imageUrl;
  final Color color;

  CarouselItem({
    required this.title,
    required this.imageUrl,
    required this.color,
  });
}

class RecommendationItem {
  final String title;
  final String imageUrl;
  final Color color;
  final bool isVip;

  RecommendationItem({
    required this.title,
    required this.imageUrl,
    required this.color,
    this.isVip = false,
  });
}

class HotWallpaperItem {
  final String title;
  final String imageUrl;
  final Color color;
  final bool isSvip;

  HotWallpaperItem({
    required this.title,
    required this.imageUrl,
    required this.color,
    this.isSvip = false,
  });
}
