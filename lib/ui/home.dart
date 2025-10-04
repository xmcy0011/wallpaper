import 'package:flutter/material.dart';
import 'dart:developer';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // 九宫格的数据
  final List<GridItem> _gridItems = [
    GridItem(title: '自然风光', imageUrl: 'https://picsum.photos/700/390?random=1', color: Colors.green),
    GridItem(title: '城市夜景', imageUrl: 'https://picsum.photos/700/390?random=2', color: Colors.blue),
    GridItem(title: '山水画卷', imageUrl: 'https://picsum.photos/700/390?random=3', color: Colors.teal),
    GridItem(title: '海滩日落', imageUrl: 'https://picsum.photos/700/390?random=4', color: Colors.orange),
    GridItem(title: '森林秘境', imageUrl: 'https://picsum.photos/700/390?random=5', color: Colors.lightGreen),
    GridItem(title: '星空银河', imageUrl: 'https://picsum.photos/700/390?random=6', color: Colors.indigo),
    GridItem(title: '花海田园', imageUrl: 'https://picsum.photos/700/390?random=7', color: Colors.pink),
    GridItem(title: '雪山冰川', imageUrl: 'https://picsum.photos/700/390?random=8', color: Colors.cyan),
    GridItem(title: '极光奇观', imageUrl: 'https://picsum.photos/700/390?random=9', color: Colors.purple),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          // gridDelegate 定义网格的布局规则
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 700,     // 每个格子最大宽度700px
            crossAxisSpacing: 12,        // 横向间距
            mainAxisSpacing: 12,         // 纵向间距
            childAspectRatio: 700 / 390, // 宽高比 700:390 ≈ 1.795
          ),
          itemCount: _gridItems.length,  // 总共9个格子
          itemBuilder: (context, index) {
            final item = _gridItems[index];
            return _buildGridItem(item, index);
          },
        ),
      ),
    );
  }

  // 构建每个格子的内容
  Widget _buildGridItem(GridItem item, int index) {
    return GridItemWidget(item: item);
  }
}

// 单个格子组件 - 带悬停效果
class GridItemWidget extends StatefulWidget {
  final GridItem item;

  const GridItemWidget({super.key, required this.item});

  @override
  State<GridItemWidget> createState() => _GridItemWidgetState();
}

class _GridItemWidgetState extends State<GridItemWidget> {
  bool _isHovered = false;  // 是否悬停

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      // 鼠标进入
      onEnter: (_) {
        setState(() {
          _isHovered = true;
        });
      },
      // 鼠标离开
      onExit: (_) {
        setState(() {
          _isHovered = false;
        });
      },
      child: InkWell(
        // 点击效果
        onTap: () {
          // 点击时显示提示
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('你点击了 ${widget.item.title}')),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            // 悬停时添加阴影
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),  // 圆角
            child: Stack(
              fit: StackFit.expand,  // 填充整个空间
              children: [
                // 背景图片（带放大效果）
                AnimatedScale(
                  scale: _isHovered ? 1.1 : 1.0,  // 悬停时图片放大到110%
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  child: _buildBackgroundImage(widget.item),
                ),
                
                // 渐变遮罩层（悬停时加深）
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.center,
                      colors: [
                        Colors.black.withOpacity(_isHovered ? 0.7 : 0.6),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                
                // 悬停时的全屏遮罩
                if (_isHovered)
                  AnimatedOpacity(
                    opacity: _isHovered ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      color: Colors.black.withOpacity(0.3),
                    ),
                  ),
                
                // 标题文字（左上角）
                Positioned(
                  top: 12,
                  left: 12,
                  right: 12,
                  child: Text(
                    widget.item.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 1),
                          blurRadius: 4,
                          color: Colors.black45,
                        ),
                      ],
                    ),
                  ),
                ),
                
                // 播放按钮（中心，悬停时显示）
                if (_isHovered)
                  Center(
                    child: AnimatedScale(
                      scale: _isHovered ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutBack,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.play_arrow_rounded,
                          size: 50,
                          color: widget.item.color,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 构建背景图片
  Widget _buildBackgroundImage(GridItem item) {
    // 如果有图片URL，尝试加载网络图片
    if (item.imageUrl.isNotEmpty) {
      log("item.imageUrl: ${item.imageUrl}");

      return Image.network(
        item.imageUrl,
        fit: BoxFit.cover,
        // 加载失败时显示渐变背景
        errorBuilder: (context, error, stackTrace) {
          return _buildGradientBackground(item.color);
        },
        // 加载中显示渐变背景
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return _buildGradientBackground(item.color);
        },
      );
    } else {
      // 没有图片URL，使用渐变背景
      return _buildGradientBackground(item.color);
    }
  }

  // 构建渐变背景（占位）
  Widget _buildGradientBackground(Color color) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color,
            color.withOpacity(0.6),
          ],
        ),
      ),
    );
  }
}

// 定义格子数据模型
class GridItem {
  final String title;
  final String imageUrl;  // 图片URL（可选）
  final Color color;       // 备用颜色（加载失败时使用）

  GridItem({
    required this.title,
    required this.color,
    required this.imageUrl,
  });
}