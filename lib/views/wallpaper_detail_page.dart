import 'package:flutter/material.dart';
import '../viewmodels/wallpaper_detail_viewmodel.dart';
import '../models/wallpaper_model.dart';
import '../services/auth_service.dart';
import '../utils/platform_utils.dart';
import '../widgets/custom_title_bar.dart';

/// 壁纸详情页面
class WallpaperDetailPage extends StatefulWidget {
  final String wallpaperId;
  final String title;
  final String imageUrl;
  final Color color;
  final String? creatorName;
  final String? creatorAvatar;
  final bool isVip;
  final bool isSvip;

  const WallpaperDetailPage({
    super.key,
    required this.wallpaperId,
    required this.title,
    required this.imageUrl,
    required this.color,
    this.creatorName,
    this.creatorAvatar,
    this.isVip = false,
    this.isSvip = false,
  });

  @override
  State<WallpaperDetailPage> createState() => _WallpaperDetailPageState();
}

class _WallpaperDetailPageState extends State<WallpaperDetailPage> {
  late WallpaperDetailViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = WallpaperDetailViewModel(
      wallpaper: WallpaperModel(
        wallpaperId: widget.wallpaperId,
        title: widget.title,
        imageUrl: widget.imageUrl,
        color: widget.color,
        creatorName: widget.creatorName,
        creatorAvatar: widget.creatorAvatar,
        isVip: widget.isVip,
        isSvip: widget.isSvip,
      ),
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1a1a1a),
      body: Column(
        children: [
          CustomTitleBar(
            title: '壁纸APP',
            subtitle: widget.title,
            onBackPressed: () => Navigator.of(context).pop(),
          ),
          // 主内容区域
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildMainContent(context),
                  _buildRecommendationsSection(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 主内容区域
  Widget _buildMainContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 左侧：大图预览
          Expanded(
            flex: 3,
            child: _buildWallpaperPreview(),
          ),
          const SizedBox(width: 16),
          // 右侧：详情信息
          Expanded(
            flex: 1,
            child: _buildDetailSidebar(context),
          ),
        ],
      ),
    );
  }

  // 壁纸预览区域（视频播放器）
  Widget _buildWallpaperPreview() {
    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 预览提示
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xff2a2a2a),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(Icons.info_outline, color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '壁纸仅预览10秒,下载后应用完整视频。',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // 视频播放器
            Container(
              height: 600,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xff2a2a2a),
              ),
              child: Stack(
                children: [
                  // 视频内容（使用图片模拟）
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          widget.imageUrl,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    widget.color,
                                    widget.color.withOpacity(0.6),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            );
                          },
                        ),
                        // 播放状态覆盖层
                        if (!_viewModel.isPlaying)
                          Container(
                            color: Colors.black.withOpacity(0.3),
                            child: Center(
                              child: IconButton(
                                icon: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.play_arrow,
                                    color: Colors.white,
                                    size: 60,
                                  ),
                                ),
                                onPressed: _viewModel.togglePlayPause,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // SVIP标签
                  if (widget.isSvip)
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                  // 播放控制栏
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: _buildVideoControls(),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // 视频播放控制栏
  Widget _buildVideoControls() {
    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.8),
              ],
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
          ),
          child: Row(
            children: [
              // 播放/暂停按钮
              IconButton(
                icon: Icon(
                  _viewModel.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 24,
                ),
                onPressed: _viewModel.togglePlayPause,
              ),
              const SizedBox(width: 8),
              // 静音按钮
              IconButton(
                icon: Icon(
                  _viewModel.isMuted ? Icons.volume_off : Icons.volume_up,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: _viewModel.toggleMute,
              ),
              const SizedBox(width: 8),
              // 时间显示
              Text(
                '${_viewModel.formatDuration(_viewModel.currentPosition)} / ${_viewModel.formatDuration(_viewModel.totalDuration)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 12),
              // 进度条
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.blue,
                    inactiveTrackColor: Colors.white.withOpacity(0.3),
                    thumbColor: Colors.white,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    trackHeight: 4,
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                  ),
                  child: Slider(
                    value: _viewModel.progress.clamp(0.0, 1.0),
                    onChanged: (value) {
                      _viewModel.seekTo(value);
                    },
                    onChangeStart: (_) {
                      _viewModel.pause();
                    },
                    onChangeEnd: (_) {
                      if (_viewModel.currentPosition < _viewModel.totalDuration) {
                        _viewModel.play();
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // 全屏按钮
              IconButton(
                icon: Icon(
                  _viewModel.isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () {
                  _viewModel.toggleFullscreen();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_viewModel.isFullscreen ? '退出全屏' : '进入全屏'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // 详情侧边栏
  Widget _buildDetailSidebar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xff2a2a2a),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 创作者信息
          _buildCreatorInfo(context),
          const SizedBox(height: 24),
          
          // 分隔线
          Divider(color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 24),
          
          // 壁纸元数据
          _buildWallpaperMetadata(),
          const SizedBox(height: 24),
          
          // 标签
          _buildTags(context),
          const SizedBox(height: 24),
          
          // 操作按钮
          _buildActionButtons(context),
        ],
      ),
    );
  }

  // 创作者信息
  Widget _buildCreatorInfo(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.white.withOpacity(0.1),
          child: widget.creatorAvatar != null
              ? ClipOval(
                  child: Image.network(
                    widget.creatorAvatar!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.person, color: Colors.white70, size: 30);
                    },
                  ),
                )
              : const Icon(Icons.person, color: Colors.white70, size: 30),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.creatorName ?? 'Lodo',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '原创动态壁纸,...',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('关注功能开发中')),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text('关注', style: TextStyle(fontSize: 12)),
        ),
      ],
    );
  }

  // 壁纸元数据
  Widget _buildWallpaperMetadata() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '番号 ${widget.wallpaperId}',
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.blue.withOpacity(0.5)),
              ),
              child: const Text(
                '©版权声明',
                style: TextStyle(color: Colors.blue, fontSize: 10),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.green.withOpacity(0.5)),
              ),
              child: const Text(
                '视频',
                style: TextStyle(color: Colors.green, fontSize: 10),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildStatItem(Icons.star, '18'),
            const SizedBox(width: 16),
            _buildStatItem(Icons.download, '57'),
            const SizedBox(width: 16),
            _buildStatItem(Icons.storage, '43.74MB'),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Icon(Icons.aspect_ratio, color: Colors.white.withOpacity(0.6), size: 16),
            const SizedBox(width: 4),
            Text(
              '3840x2160',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.6), size: 16),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // 标签
  Widget _buildTags(BuildContext context) {
    final tags = ['鬼灭之刃', '猗窝座', '热门动漫', '4K高清'];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags.map((tag) => InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('点击了标签: $tag')),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          child: Text(
            tag,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        ),
      )).toList(),
    );
  }

  // 操作按钮
  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('收藏功能开发中')),
              );
            },
            icon: const Icon(Icons.favorite_border, size: 18),
            label: const Text('收藏'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.white.withOpacity(0.2)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('应用壁纸功能开发中')),
              );
            },
            icon: const Icon(Icons.send, size: 18),
            label: const Text('应用壁纸'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 推荐区域
  Widget _buildRecommendationsSection() {
    final recommendations = [
      RecommendationItem(
        title: '推荐壁纸1',
        imageUrl: 'https://picsum.photos/300/200?random=30',
        color: Colors.blue,
        isVip: false,
      ),
      RecommendationItem(
        title: '推荐壁纸2',
        imageUrl: 'https://picsum.photos/300/200?random=31',
        color: Colors.purple,
        isVip: true,
      ),
      RecommendationItem(
        title: '推荐壁纸3',
        imageUrl: 'https://picsum.photos/300/200?random=32',
        color: Colors.pink,
        isVip: true,
      ),
      RecommendationItem(
        title: '推荐壁纸4',
        imageUrl: 'https://picsum.photos/300/200?random=33',
        color: Colors.orange,
        isVip: false,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '壁纸推荐',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: recommendations.length,
              itemBuilder: (context, index) {
                final item = recommendations[index];
                return Container(
                  width: 300,
                  margin: const EdgeInsets.only(right: 16),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => WallpaperDetailPage(
                            wallpaperId: '2001919${100 + index}',
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
                            height: double.infinity,
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
                        if (item.isVip)
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(6),
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

