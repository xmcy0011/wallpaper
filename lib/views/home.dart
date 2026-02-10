import 'package:flutter/material.dart';
import '../viewmodels/home_viewmodel.dart';
import '../services/auth_service.dart';
import '../widgets/custom_title_bar.dart';
import 'login_guide.dart';
import 'profile_page.dart';
import 'wallpaper_detail_page.dart';
import 'resource_zone_page.dart';
import 'personal_center_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late HomeViewModel _viewModel;
  late TabController _tabController;
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _viewModel = HomeViewModel();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  void _openLoginGuide() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const LoginGuidePage()));
  }

  void _openProfile() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const ProfilePage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1a1a1a),
      body: AnimatedBuilder(
        animation: _viewModel,
        builder: (context, _) {
          return Column(
            children: [
              // 自定义标题栏（桌面端：含窗口控制按钮）
              const CustomTitleBar(title: '壁纸APP', subtitle: '小标题'),
              // 顶部导航栏
              _buildTopBar(),

              // 主内容区域（TabBarView 切换）
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // 推荐
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildMainContent(),
                          _buildHotWallpapersSection(),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                    // 资源区
                    const ResourceZonePage(),
                    // 个人中心
                    const PersonalCenterPage(),
                  ],
                ),
              ),

              // 底部媒体播放器控制栏
              _buildMediaPlayerBar(),
            ],
          );
        },
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
          // 导航标签（靠左，固定宽度）
          SizedBox(
            width: 280,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.white.withOpacity(0.6),
              indicatorColor: Colors.blue,
              dividerColor: Colors.transparent,
              dividerHeight: 0,
              tabs: const [
                Tab(text: '推荐'),
                Tab(text: '资源区'),
                Tab(text: '个人中心'),
              ],
            ),
          ),

          // 中间留空
          const Spacer(),

          // 搜索栏、上传、登录（靠右）
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 搜索栏
              SizedBox(
                width: 200,
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
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
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
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('上传功能开发中')));
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

              // 用户信息或登录按钮
              AnimatedBuilder(
                animation: _authService,
                builder: (context, _) {
                  if (_authService.isLoggedIn) {
                    return InkWell(
                      onTap: _openProfile,
                      child: Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
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
                                        errorBuilder:
                                            (context, error, stackTrace) {
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
        ],
      ),
    );
  }

  // 主内容区域
  Widget _buildMainContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 主体：轮播图 + 推荐栏（登录横幅不再占位）
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 5, child: _buildCarousel()),
              const SizedBox(width: 16),
              Expanded(flex: 3, child: _buildRecommendationSidebar()),
            ],
          ),
          // 左侧：登录横幅（悬浮，不挤占轮播图空间）
          if (!_viewModel.isLoggedIn && _viewModel.showLoginBanner)
            Positioned(
              left: 0,
              top: 0,
              child: SizedBox(width: 200, child: _buildLoginBanner()),
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
                _viewModel.hideLoginBanner();
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
        ],
      ),
    );
  }

  // 轮播图（按 16:9 宽高比缩放，随窗口变化保持比例）
  Widget _buildCarousel() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xff2a2a2a),
        ),
        child: Stack(
        children: [
          // 轮播内容
          PageView.builder(
            controller: _viewModel.carouselController,
            onPageChanged: (index) {
              _viewModel.updateCarouselIndex(index);
            },
            itemCount: _viewModel.carouselItems.length,
            itemBuilder: (context, index) {
              final item = _viewModel.carouselItems[index];
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
                onPressed: _viewModel.previousCarouselPage,
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
                onPressed: _viewModel.nextCarouselPage,
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
                _viewModel.carouselItems.length,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _viewModel.currentCarouselIndex == index
                        ? Colors.white
                        : Colors.white.withOpacity(0.3),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }

  // 推荐侧边栏（左侧分类列表 + 右侧推荐内容，联动）
  Widget _buildRecommendationSidebar() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 右侧：当前分类的推荐内容
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _viewModel.currentRecommendations
                  .map(
                    (item) => Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: InkWell(
                        onTap: () {
                          final list = _viewModel.currentRecommendations;
                          final idx = list.indexOf(item);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => WallpaperDetailPage(
                                wallpaperId: '2001919${200 + idx}',
                                title: item.title,
                                imageUrl: item.imageUrl,
                                color: item.color,
                                creatorName: 'Creator ${idx + 1}',
                                isVip: item.isVip,
                                isSvip: false,
                              ),
                            ),
                          );
                        },
                        child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Stack(
                              alignment: Alignment.bottomLeft,
                              children: [
                                Positioned.fill(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      item.imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
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
                                ),
                            // 底部渐变遮罩，使文字更清晰
                                Positioned(
                                  left: 0,
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    height: 48,
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.vertical(
                                        bottom: Radius.circular(8),
                                      ),
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withOpacity(0.7),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 12,
                                  right: 12,
                                  bottom: 12,
                                  child: Text(
                                    item.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
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
                        ),
                      ),
                    )
                  .toList(),
            ),
          ),
        ),
      const SizedBox(width: 12),
      // 左侧：推荐分类列表
      Container(
        width: 140,
        padding: const EdgeInsets.all(12),
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
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...List.generate(_viewModel.recommendationList.length, (index) {
              final text = _viewModel.recommendationList[index];
              final isSelected =
                  index == _viewModel.selectedRecommendationIndex;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  onTap: () => _viewModel.selectRecommendation(index),
                  child: Text(
                    text,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.blue
                          : Colors.white.withOpacity(0.8),
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }),
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
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('查看更多功能开发中')));
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
            children: _viewModel.hotWallpapers
                .map(
                  (item) => Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      child: InkWell(
                        onTap: () {
                          final index = _viewModel.hotWallpapers.indexOf(item);
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
                                      colors: [
                                        Color(0xFFFFD700),
                                        Color(0xFFFFA500),
                                      ],
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
                  ),
                )
                .toList(),
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
                icon: Icon(
                  Icons.skip_previous,
                  color: Colors.white.withOpacity(0.7),
                ),
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
                icon: Icon(
                  Icons.skip_next,
                  color: Colors.white.withOpacity(0.7),
                ),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(
                  Icons.volume_up,
                  color: Colors.white.withOpacity(0.7),
                ),
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
