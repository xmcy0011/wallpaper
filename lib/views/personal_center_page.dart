import 'package:flutter/material.dart';
import 'wallpaper_detail_page.dart';

/// 个人中心页面 - 壁纸管理/个人内容中心
/// 参考：本地壁纸、本地美化、我的上传、我的收藏、我的购买
class PersonalCenterPage extends StatefulWidget {
  const PersonalCenterPage({super.key});

  @override
  State<PersonalCenterPage> createState() => _PersonalCenterPageState();
}

class _PersonalCenterPageState extends State<PersonalCenterPage>
    with SingleTickerProviderStateMixin {
  late TabController _subTabController;
  int _selectedTypeFilter = 0; // 全部/视频/互动/图片

  final List<String> _subTabs = [
    '本地壁纸',
    '我的上传',
    '我的收藏',
    '我的购买',
  ];

  final List<String> _typeFilters = ['全部', '视频', '互动', '图片'];

  // 示例内容数据
  final List<Map<String, dynamic>> _wallpaperItems = [
    {
      'title': '清除壁纸效果',
      'subtitle': null,
      'author': null,
      'url': 'https://picsum.photos/300/200?random=50',
      'color': Colors.orange,
      'hasQuestion': false,
    },
    {
      'title': '啊噗啊噗看板娘小优和小欧',
      'subtitle': '无法应用?',
      'author': '官方阿噗君',
      'url': 'https://picsum.photos/300/200?random=51',
      'color': Colors.blue,
      'hasQuestion': true,
    },
    {
      'title': '治愈系森林',
      'subtitle': null,
      'author': '创作者123',
      'url': 'https://picsum.photos/300/200?random=52',
      'color': Colors.green,
      'hasQuestion': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _subTabController = TabController(length: _subTabs.length, vsync: this);
  }

  @override
  void dispose() {
    _subTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 顶部子导航：本地壁纸、本地美化、我的上传、我的收藏、我的购买 + 操作指南
        _buildSubNavBar(),
        // 内容区筛选/操作栏
        _buildFilterBar(),
        // 内容展示区域
        Expanded(
          child: TabBarView(
            controller: _subTabController,
            children: List.generate(
              _subTabs.length,
              (index) => _buildContentGrid(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubNavBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xff222222),
      ),
      child: Row(
        children: [
          Expanded(
            child: TabBar(
              controller: _subTabController,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.white.withOpacity(0.6),
              indicatorColor: Colors.blue,
              dividerColor: Colors.transparent,
              dividerHeight: 0,
              tabs: _subTabs.map((t) => Tab(text: t)).toList(),
            ),
          ),
          InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('操作指南'),
                  backgroundColor: Color(0xff2a2a2a),
                ),
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.help_outline,
                  size: 18,
                  color: Colors.white.withOpacity(0.7),
                ),
                const SizedBox(width: 4),
                Text(
                  '操作指南',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: const Color(0xff1a1a1a),
      child: Row(
        children: [
          // 左侧：全部壁纸(1)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.blue.withOpacity(0.5)),
            ),
            child: Text(
              '全部壁纸(${_wallpaperItems.length})',
              style: const TextStyle(
                color: Colors.blue,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // 分类筛选：全部 / 视频 / 互动 / 图片
          ...List.generate(_typeFilters.length, (index) {
            final isSelected = index == _selectedTypeFilter;
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: InkWell(
                onTap: () => setState(() => _selectedTypeFilter = index),
                child: Text(
                  _typeFilters[index],
                  style: TextStyle(
                    color: isSelected
                        ? Colors.blue
                        : Colors.white.withOpacity(0.7),
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('搜索功能开发中'),
                  backgroundColor: Color(0xff2a2a2a),
                ),
              );
            },
            icon: const Icon(Icons.search, size: 16, color: Colors.white70),
            label: const Text(
              '搜索',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
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
                Text(
                  '更多操作',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13,
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: Colors.white.withOpacity(0.8),
                  size: 20,
                ),
              ],
            ),
            onSelected: (value) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$value 功能开发中'),
                  backgroundColor: const Color(0xff2a2a2a),
                ),
              );
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
  }

  Widget _buildContentGrid() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.35,
        ),
        itemCount: _wallpaperItems.length,
        itemBuilder: (context, index) {
          final item = _wallpaperItems[index];
          return _buildWallpaperCard(
            title: item['title'] as String,
            subtitle: item['subtitle'] as String?,
            author: item['author'] as String?,
            imageUrl: item['url'] as String,
            color: item['color'] as Color,
            hasQuestion: item['hasQuestion'] as bool,
            index: index,
          );
        },
      ),
    );
  }

  Widget _buildWallpaperCard({
    required String title,
    required String? subtitle,
    required String? author,
    required String imageUrl,
    required Color color,
    required bool hasQuestion,
    required int index,
  }) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => WallpaperDetailPage(
              wallpaperId: 'personal_$index',
              title: title,
              imageUrl: imageUrl,
              color: color,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
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
                if (hasQuestion)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.help_outline,
                          size: 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            subtitle ?? '无法应用?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (author != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 12,
                  color: Colors.white.withOpacity(0.5),
                ),
                const SizedBox(width: 4),
                Text(
                  author,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
