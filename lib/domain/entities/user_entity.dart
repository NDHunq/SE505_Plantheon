class UserEntity {
  final String id;
  final String email;
  final String username;
  final String fullName;
  final String avatar;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserEntity({
    required this.id,
    required this.email,
    required this.username,
    required this.fullName,
    required this.avatar,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });
}
