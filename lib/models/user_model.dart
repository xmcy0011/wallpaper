/// 用户模型
class UserModel {
  final String userName;
  final String? userAvatar;
  final bool isLoggedIn;

  UserModel({
    required this.userName,
    this.userAvatar,
    this.isLoggedIn = false,
  });

  UserModel copyWith({
    String? userName,
    String? userAvatar,
    bool? isLoggedIn,
  }) {
    return UserModel(
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }
}

