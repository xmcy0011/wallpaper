import 'package:flutter/material.dart';

/// 轮播图项模型
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

/// 推荐项模型
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

/// 热门壁纸项模型
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

/// 壁纸详情模型
class WallpaperModel {
  final String wallpaperId;
  final String title;
  final String imageUrl;
  final Color color;
  final String? creatorName;
  final String? creatorAvatar;
  final bool isVip;
  final bool isSvip;

  WallpaperModel({
    required this.wallpaperId,
    required this.title,
    required this.imageUrl,
    required this.color,
    this.creatorName,
    this.creatorAvatar,
    this.isVip = false,
    this.isSvip = false,
  });
}

