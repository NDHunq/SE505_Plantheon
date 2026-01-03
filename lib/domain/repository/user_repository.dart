import 'package:se501_plantheon/domain/entities/user_entity.dart';

abstract class UserRepository {
  Future<UserEntity> getProfile();
  Future<UserEntity> updateProfile({String? fullName, String? avatar});
  Future<void> deleteAccount(String password);
}
