import 'package:flutter/material.dart';
import 'wallpaper_detail_page.dart';

/// 资源区页面
/// 参考 upupoo 资源区布局：主分类、筛选、排序、壁纸网格、分页
class ResourceZonePage extends StatefulWidget {
  const ResourceZonePage({super.key});

  @override
  State<ResourceZonePage> createState() => _ResourceZonePageState();
}

class _ResourceZonePageState extends State<ResourceZonePage> {
  int _selectedPrimaryFilter = 0; // 全部
  int _selectedSecondaryFilter = 0; // 美女
  int _selectedSortIndex = 0;
  int _currentPage = 1;

  // 一级筛选
  final List<String> _primaryFilters = [
    '全部', '动漫', '游戏', '美景', '文字', '可爱', '趣味', '简约',
    '科幻', '分区', 'CP', '国漫', '明星', '热门图剧', '虚拟偶像', '车枪球',
  ];

  // 排序选项
  final List<String> _sortOptions = [
    '默认排序', '最新', '一周热门', '本月热门', '最热', '收藏量',
  ];

  // 壁纸列表数据
  final List<Map<String, dynamic>> _wallpapers = [
    {'title': '夕阳', 'url': 'https://picsum.photos/300/200?random=30', 'color': Colors.orange, 'isSvip': false},
    {'title': '花丛中的少女', 'url': 'https://picsum.photos/300/200?random=31', 'color': Colors.pink, 'isSvip': true},
    {'title': '冰雪奇缘2动态壁纸', 'url': 'https://picsum.photos/300/200?random=32', 'color': Colors.blue, 'isSvip': true},
    {'title': '飞行', 'url': 'https://picsum.photos/300/200?random=33', 'color': Colors.cyan, 'isSvip': false},
    {'title': '治愈女孩', 'url': 'https://picsum.photos/300/200?random=34', 'color': Colors.purple, 'isSvip': false},
    {'title': '星光少女', 'url': 'https://picsum.photos/300/200?random=35', 'color': Colors.indigo, 'isSvip': true},
    {'title': '秋季', 'url': 'https://picsum.photos/300/200?random=36', 'color': Colors.amber, 'isSvip': false},
    {'title': '刀客', 'url': 'https://picsum.photos/300/200?random=37', 'color': Colors.deepOrange, 'isSvip': false},
    {'title': '暴雨已至', 'url': 'https://picsum.photos/300/200?random=38', 'color': Colors.blueGrey, 'isSvip': false},
    {'title': '申锦 | 银装沧澜', 'url': 'https://picsum.photos/300/200?random=39', 'color': Colors.teal, 'isSvip': true},
    {'title': '蓝眼萌猫的可爱瞬间', 'url': 'https://picsum.photos/300/200?random=40', 'color': Colors.brown, 'isSvip': false},
    {'title': '纯欲魅惑 眼镜娘', 'url': 'https://picsum.photos/300/200?random=41', 'color': Colors.red, 'isSvip': false},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 筛选行：一级筛选铺满 + 二级筛选及排序靠右固定宽度
          _buildFiltersRow(),
          const SizedBox(height: 16),
          // 3. 壁纸网格
          _buildWallpaperGrid(),
          const SizedBox(height: 24),
          // 4. 分页
          _buildPagination(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildFiltersRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 一级筛选：铺满左侧
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_primaryFilters.length, (index) {
                final isSelected = index == _selectedPrimaryFilter;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: InkWell(
                    onTap: () => setState(() => _selectedPrimaryFilter = index),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _primaryFilters[index],
                          style: TextStyle(
                            color: isSelected ? Colors.blue : Colors.white70,
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                        if (isSelected)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            height: 2,
                            width: 20,
                            color: Colors.blue,
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // 二级筛选 + 排序：靠右固定宽度，内容过多时可横向滚动
        SizedBox(
          width: 246,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
              // 排序
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xff2a2a2a),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: PopupMenuButton<int>(
                  padding: EdgeInsets.zero,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_sortOptions[_selectedSortIndex], style: const TextStyle(color: Colors.white70, fontSize: 13)),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_drop_down, color: Colors.white70, size: 20),
                    ],
                  ),
                  onSelected: (i) => setState(() => _selectedSortIndex = i),
                  itemBuilder: (context) => List.generate(
                    _sortOptions.length,
                    (i) => PopupMenuItem(value: i, child: Text(_sortOptions[i])),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  side: BorderSide(color: Colors.white.withOpacity(0.3)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
                child: const Text('带鱼屏', style: TextStyle(fontSize: 13)),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  side: BorderSide(color: Colors.white.withOpacity(0.3)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
                child: const Text('4K超清', style: TextStyle(fontSize: 13)),
              ),
            ],
          ),
        ),
        ),
      ],
    );
  }

  Widget _buildWallpaperGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        // 图片 16:9 + 标题区域，childAspectRatio ≈ width/(width*9/16 + 36)
        childAspectRatio: 1.45,
      ),
      itemCount: _wallpapers.length,
      itemBuilder: (context, index) {
        final item = _wallpapers[index];
        return _buildWallpaperCard(
          title: item['title'] as String,
          imageUrl: item['url'] as String,
          color: item['color'] as Color,
          isSvip: item['isSvip'] as bool,
          index: index,
        );
      },
    );
  }

  Widget _buildWallpaperCard({
    required String title,
    required String imageUrl,
    required Color color,
    required bool isSvip,
    required int index,
  }) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => WallpaperDetailPage(
              wallpaperId: 'resource_${index}',
              title: title,
              imageUrl: imageUrl,
              color: color,
              isSvip: isSvip,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
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
                if (isSvip)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA500)]),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('S', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: _currentPage > 1 ? () => setState(() => _currentPage--) : null,
          icon: Icon(Icons.chevron_left, color: _currentPage > 1 ? Colors.white : Colors.white38),
        ),
        const SizedBox(width: 8),
        ...List.generate(7, (i) {
          final page = i + 1;
          final isSelected = page == _currentPage;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: () => setState(() => _currentPage = page),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '$page',
                  style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontSize: 14),
                ),
              ),
            ),
          );
        }),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text('...', style: TextStyle(color: Colors.white54, fontSize: 14)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: InkWell(
            onTap: () {},
            child: const Text('5869', style: TextStyle(color: Colors.white70, fontSize: 14)),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () => setState(() => _currentPage++),
          icon: const Icon(Icons.chevron_right, color: Colors.white),
        ),
        const SizedBox(width: 24),
        SizedBox(
          width: 50,
          child: TextField(
            controller: TextEditingController(text: '$_currentPage'),
            style: const TextStyle(color: Colors.white, fontSize: 14),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              filled: true,
              fillColor: const Color(0xff2a2a2a),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        TextButton(
          onPressed: () {},
          child: const Text('跳转', style: TextStyle(color: Colors.white70, fontSize: 13)),
        ),
      ],
    );
  }
}
