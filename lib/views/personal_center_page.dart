import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/dbaccess.dart';
import '../viewmodels/personal_center_viewmodel.dart';

/// 个人中心页面 - 壁纸管理/个人内容中心
/// 参考：本地壁纸、本地美化、我的上传、我的收藏、我的购买
class PersonalCenterPage extends StatefulWidget {
  const PersonalCenterPage({super.key});

  @override
  State<PersonalCenterPage> createState() => _PersonalCenterPageState();
}

class _PersonalCenterPageState extends State<PersonalCenterPage> with TickerProviderStateMixin {
  late TabController _subTabController;
  late PersonalCenterViewModel _viewModel;
  late AnimationController _playingPulseController;

  @override
  void initState() {
    super.initState();
    _viewModel = PersonalCenterViewModel();
    _subTabController = TabController(length: _viewModel.subTabs.length, vsync: this);
    _playingPulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1300));
    _viewModel.addListener(_syncPlaybackPulse);
    _viewModel.loadLocalWallpapers();
    _syncPlaybackPulse();
  }

  void _syncPlaybackPulse() {
    final playing = _viewModel.currentPlayingWallpaperId != null;
    if (playing) {
      if (!_playingPulseController.isAnimating) {
        _playingPulseController.repeat(reverse: true);
      }
    } else {
      _playingPulseController.stop();
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(_syncPlaybackPulse);
    _playingPulseController.dispose();
    _subTabController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 顶部子导航：本地壁纸、本地美化、我的上传、我的收藏、我的购买 + 操作指南
        _buildSubNavBar(),
        // 内容展示区域 - 每个 tab 对应不同界面
        Expanded(
          child: TabBarView(
            controller: _subTabController,
            children: List.generate(_viewModel.subTabs.length, (index) => _buildContentForTab(index)),
          ),
        ),
      ],
    );
  }

  Widget _buildSubNavBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: const Color(0xff222222)),
      child: Row(
        children: [
          Expanded(
            child: TabBar(
              controller: _subTabController,
              isScrollable: true,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.white.withOpacity(0.6),
              indicatorColor: Colors.blue,
              dividerColor: Colors.transparent,
              dividerHeight: 0,
              tabs: _viewModel.subTabs.map((t) => Tab(text: t)).toList(),
            ),
          ),
          InkWell(
            onTap: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('操作指南'), backgroundColor: Color(0xff2a2a2a)));
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.help_outline, size: 18, color: Colors.white.withOpacity(0.7)),
                const SizedBox(width: 4),
                Text('操作指南', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: const Color(0xff1a1a1a),
          child: Row(
            children: [
              // 左侧：全部壁纸(n)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.blue.withOpacity(0.5)),
                ),
                child: Text(
                  '全部壁纸(${_viewModel.wallpaperItems.length})',
                  style: const TextStyle(color: Colors.blue, fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(width: 16),
              // 分类筛选：全部 / 视频 / 互动 / 图片
              ...List.generate(_viewModel.typeFilters.length, (index) {
                final isSelected = index == _viewModel.selectedTypeFilter;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: InkWell(
                    onTap: () => _viewModel.setSelectedTypeFilter(index),
                    child: Text(
                      _viewModel.typeFilters[index],
                      style: TextStyle(
                        color: isSelected ? Colors.blue : Colors.white.withOpacity(0.7),
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }),
              const Spacer(),
              // 右侧：搜索、更多操作
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('搜索功能开发中'), backgroundColor: Color(0xff2a2a2a)));
                },
                icon: const Icon(Icons.search, size: 16, color: Colors.white70),
                label: const Text('搜索', style: TextStyle(color: Colors.white70, fontSize: 13)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.white.withOpacity(0.3)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('更多操作', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
                    Icon(Icons.arrow_drop_down, color: Colors.white.withOpacity(0.8), size: 20),
                  ],
                ),
                onSelected: (value) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('$value 功能开发中'), backgroundColor: const Color(0xff2a2a2a)));
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: '批量删除', child: Text('批量删除')),
                  const PopupMenuItem(value: '批量应用', child: Text('批量应用')),
                  const PopupMenuItem(value: '导出', child: Text('导出')),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// 根据 tab 索引构建对应界面内容
  Widget _buildContentForTab(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return AnimatedBuilder(
          animation: _viewModel,
          builder: (context, _) {
            if (_viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator(color: Colors.blue));
            }
            return _buildContentGrid(items: _viewModel.wallpaperItems);
          },
        );
      case 1:
        return _buildEmptyState('我的上传', '暂无上传内容，快去上传你的壁纸吧');
      case 2:
        return _buildEmptyState('我的收藏', '暂无收藏内容，快去收藏你喜欢的壁纸吧');
      case 3:
        return _buildEmptyState('我的购买', '暂无购买记录，快去购买你喜欢的壁纸吧');
      default:
        return _buildEmptyState('功能开发中', '暂无内容，敬请期待');
    }
  }

  Widget _buildEmptyState(String title, String hint) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.white.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(title, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 16)),
          const SizedBox(height: 8),
          Text(hint, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildContentGrid({required List<DBWallpaper> items}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 内容区筛选/操作栏
          _buildFilterBar(),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.35,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return _buildWallpaperCard(wallpaper: item);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWallpaperCard({required DBWallpaper wallpaper}) {
    final isPlaying = _viewModel.currentPlayingWallpaperId == wallpaper.wallpaperId;
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: isPlaying ? _buildPlayingWallpaperThumb(wallpaper) : _buildStaticWallpaperThumb(wallpaper),
          ),
          const SizedBox(height: 8),
          Text(
            wallpaper.title,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          )
        ],
      ),
    );
  }

  Widget _buildStaticWallpaperThumb(DBWallpaper wallpaper) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.file(
        File(wallpaper.preview),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.blue, Colors.blue.withOpacity(0.6)]),
              borderRadius: BorderRadius.circular(8),
            ),
          );
        },
      ),
    );
  }

  /// 正在播放：呼吸描边 + 角落波形动画
  Widget _buildPlayingWallpaperThumb(DBWallpaper wallpaper) {
    return AnimatedBuilder(
      animation: _playingPulseController,
      builder: (context, _) {
        final pulse = _playingPulseController.value;
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              width: 2,
              color: Color.lerp(Colors.blue.withOpacity(0.45), Colors.cyanAccent, pulse)!,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.12 + 0.22 * pulse),
                blurRadius: 6 + 10 * pulse,
                spreadRadius: 0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.file(
                  File(wallpaper.preview),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [Colors.blue, Colors.blue.withOpacity(0.6)]),
                      ),
                    );
                  },
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: _PlayingWaveBadge(animation: _playingPulseController),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// 角落波形指示（模拟「正在播放」）
class _PlayingWaveBadge extends StatelessWidget {
  const _PlayingWaveBadge({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final v = animation.value;
        return DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.cyanAccent.withOpacity(0.6)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(3, (i) {
                final h = 4.0 + 9.0 * (0.5 + 0.5 * math.sin(v * 2 * math.pi + i * 1.1));
                return Padding(
                  padding: EdgeInsets.only(left: i == 0 ? 0 : 3),
                  child: Container(
                    width: 3,
                    height: h,
                    decoration: BoxDecoration(
                      color: Colors.cyanAccent,
                      borderRadius: BorderRadius.circular(1.5),
                    ),
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }
}
