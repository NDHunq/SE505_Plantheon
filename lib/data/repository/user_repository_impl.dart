import 'package:se501_plantheon/data/datasources/user_remote_datasource.dart';
import 'package:se501_plantheon/domain/entities/user_entity.dart';
import 'package:se501_plantheon/domain/repository/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;

  UserRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserEntity> getProfile() {
    return remoteDataSource.getProfile();
  }

  @override
  Future<UserEntity> updateProfile({String? fullName, String? avatar}) {
    return remoteDataSource.updateProfile(fullName: fullName, avatar: avatar);
  }

  @override
  Future<void> deleteAccount(String password) {
    return remoteDataSource.deleteAccount(password);
  }
}
