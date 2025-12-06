import '../../domain/entities/auth_entity.dart';
import 'user_model.dart';

class AuthModel extends AuthEntity {
  AuthModel({required super.user, required super.token});

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      user: UserModel.fromJson(json['data']['user'] as Map<String, dynamic>),
      token: json['data']['token'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': {'user': (user as UserModel).toJson(), 'token': token},
    };
  }
}
