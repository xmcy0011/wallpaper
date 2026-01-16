import 'package:flutter/material.dart';
import '../services/auth_service.dart';

/// 个人中心页面
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    
    return Scaffold(
      backgroundColor: const Color(0xff1a1a1a),
      appBar: AppBar(
        backgroundColor: const Color(0xff222222),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '个人中心',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: AnimatedBuilder(
        animation: authService,
        builder: (context, _) {
          return SingleChildScrollView(
            child: Column(
              children: [
                // 用户信息卡片
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xff333333),
                        const Color(0xff222222),
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      // 头像
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 3,
                          ),
                        ),
                        child: authService.userAvatar != null
                            ? ClipOval(
                                child: Image.network(
                                  authService.userAvatar!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Colors.white70,
                                    );
                                  },
                                ),
                              )
                            : const Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.white70,
                              ),
                      ),
                      const SizedBox(height: 16),
                      
                      // 用户名
                      Text(
                        authService.userName ?? '未登录',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // 用户状态
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: authService.isLoggedIn
                              ? Colors.green.withOpacity(0.2)
                              : Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: authService.isLoggedIn
                                ? Colors.green
                                : Colors.grey,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          authService.isLoggedIn ? '已登录' : '未登录',
                          style: TextStyle(
                            fontSize: 12,
                            color: authService.isLoggedIn
                                ? Colors.green
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // 功能列表
                _buildSection(
                  context,
                  '账户',
                  [
                    _buildMenuItem(
                      context,
                      icon: Icons.edit_rounded,
                      title: '编辑资料',
                      onTap: () {
                        _showEditProfileDialog(context);
                      },
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.security_rounded,
                      title: '账户安全',
                      onTap: () {
                        _showComingSoon(context);
                      },
                    ),
                  ],
                ),
                
                _buildSection(
                  context,
                  '内容',
                  [
                    _buildMenuItem(
                      context,
                      icon: Icons.collections_rounded,
                      title: '我的收藏',
                      trailing: Text(
                        '0',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                      onTap: () {
                        _showComingSoon(context);
                      },
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.download_rounded,
                      title: '下载记录',
                      trailing: Text(
                        '0',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                      onTap: () {
                        _showComingSoon(context);
                      },
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.history_rounded,
                      title: '浏览历史',
                      onTap: () {
                        _showComingSoon(context);
                      },
                    ),
                  ],
                ),
                
                _buildSection(
                  context,
                  '设置',
                  [
                    _buildMenuItem(
                      context,
                      icon: Icons.settings_rounded,
                      title: '应用设置',
                      onTap: () {
                        _showComingSoon(context);
                      },
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.help_outline_rounded,
                      title: '帮助与反馈',
                      onTap: () {
                        _showComingSoon(context);
                      },
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.info_outline_rounded,
                      title: '关于我们',
                      onTap: () {
                        _showAboutDialog(context);
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // 登出按钮
                if (authService.isLoggedIn)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: const Color(0xff2a2a2a),
                              title: const Text(
                                '确认登出',
                                style: TextStyle(color: Colors.white),
                              ),
                              content: const Text(
                                '确定要退出登录吗？',
                                style: TextStyle(color: Colors.white70),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('取消'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text(
                                    '确认',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                          
                          if (confirm == true) {
                            await authService.logout();
                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          '退出登录',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xff2a2a2a),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: children,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.white.withOpacity(0.8),
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
            if (trailing != null) trailing,
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: Colors.white.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xff2a2a2a),
        title: const Text(
          '编辑资料',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          '此功能开发中...',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('功能开发中，敬请期待'),
        backgroundColor: const Color(0xff2a2a2a),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: '壁纸APP',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(
        Icons.wallpaper_rounded,
        color: Colors.white,
      ),
      children: [
        const Text('一款精美的动态壁纸应用'),
      ],
    );
  }
}

