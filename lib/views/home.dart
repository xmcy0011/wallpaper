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

  // 主内容区右侧 Tab 索引，0=推荐
  int _mainContentTabIndex = 0;

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

  // 主内容区域：右侧 Tab 标签，左侧根据选中 Tab 动态变化
  Widget _buildMainContent() {
    return SizedBox(
      height: 416,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 左侧：根据 List 选择页动态显示内容
                Expanded(
                  child: _mainContentTabIndex == 0
                      ? _buildRecommendationContent()
                      : _buildGridContent(),
                ),
                const SizedBox(width: 16),
                // 右侧：List 标签
                _buildMainContentListViews(),
              ],
            ),
            if (!_viewModel.isLoggedIn && _viewModel.showLoginBanner)
              Positioned(
                left: 0,
                top: 0,
                child: SizedBox(width: 200, child: _buildLoginBanner()),
              ),
          ],
        ),
      ),
    );
  }

  // 右侧 ListView 标签栏（ListView + 鼠标悬停切换）
  Widget _buildMainContentListViews() {
    final tabNames = _viewModel.mainContentTabNames;
    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xff2D2F31),
          borderRadius: BorderRadius.circular(8),
        ),
        child: SizedBox(
          width: 200,
          height: 388,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tabNames.length,
            itemBuilder: (context, index) {
              final isSelected = index == _mainContentTabIndex;
              return MouseRegion(
                onEnter: (_) => setState(() => _mainContentTabIndex = index),
                child: SizedBox(
                  height: 58,
                  child: InkWell(
                    onTap: () => setState(() => _mainContentTabIndex = index),
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Colors.white.withOpacity(0.02),
                                  Colors.white.withOpacity(0.12),
                                ],
                              )
                            : null,
                        color: isSelected ? null : Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      alignment: Alignment.centerRight,
                      child: Text(
                        tabNames[index],
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : Colors.white.withOpacity(0.75),
                          fontSize: isSelected ? 18 : 14,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // 推荐 Tab 内容：轮播图(6张) + 右侧竖排 2 张图片
  Widget _buildRecommendationContent() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildCarousel()),
        const SizedBox(width: 16),
        SizedBox(width: 325, child: _buildRecommendationSidebar()),
      ],
    );
  }

  // 其他 Tab 内容：六宫格 6 张 16:9 图片
  Widget _buildGridContent() {
    final items = _viewModel.getRecommendationGridItems(_mainContentTabIndex);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 16 / 9,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildGridCard(
          title: item.title,
          imageUrl: item.imageUrl,
          color: item.color,
          index: index,
          isVip: item.isVip,
        );
      },
    );
  }

  Widget _buildGridCard({
    required String title,
    required String imageUrl,
    required Color color,
    required int index,
    bool isVip = false,
  }) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => WallpaperDetailPage(
              wallpaperId: 'grid_$index',
              title: title,
              imageUrl: imageUrl,
              color: color,
              creatorName: 'Creator ${index + 1}',
              isVip: isVip,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        alignment: Alignment.bottomLeft,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withOpacity(0.6)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              },
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 40,
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
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isVip)
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
            itemCount: _viewModel.recommendationCarouselItems.length,
            itemBuilder: (context, index) {
              final item = _viewModel.recommendationCarouselItems[index];
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
                _viewModel.recommendationCarouselItems.length,
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

  // 推荐 Tab 右侧竖排 2 张固定图片
  Widget _buildRecommendationSidebar() {
    final items = _viewModel.recommendationSidebarItems;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: items.map((item) {
        final idx = items.indexOf(item);
        return Container(
          margin: idx == items.length - 1 ? null : const EdgeInsets.only(bottom: 16),
          child: InkWell(
          onTap: () {
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
                              colors: [item.color, item.color.withOpacity(0.6)],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        );
                      },
                    ),
                  ),
                ),
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
        );
      }).toList(),
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
