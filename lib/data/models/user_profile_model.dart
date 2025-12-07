import 'package:se501_plantheon/data/models/post_model.dart';

class PublicUserModel {
  final String id;
  final String email;
  final String username;
  final String fullName;
  final String avatar;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;

  PublicUserModel({
    required this.id,
    required this.email,
    required this.username,
    required this.fullName,
    required this.avatar,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PublicUserModel.fromJson(Map<String, dynamic> json) {
    return PublicUserModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      username: json['username'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      avatar: json['avatar'] as String? ?? '',
      role: json['role'] as String? ?? 'user',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }
}

class UserProfileResponseModel {
  final PublicUserModel user;
  final List<PostModel> posts;
  final int totalPosts;

  UserProfileResponseModel({
    required this.user,
    required this.posts,
    required this.totalPosts,
  });

  factory UserProfileResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final userJson = data['user'] as Map<String, dynamic>;
    final postsData = data['posts'] as Map<String, dynamic>;
    final postsList = postsData['posts'] as List<dynamic>? ?? [];

    return UserProfileResponseModel(
      user: PublicUserModel.fromJson(userJson),
      posts: postsList.map((e) => PostModel.fromJson(e)).toList(),
      totalPosts: postsData['total'] as int? ?? 0,
    );
  }
}
