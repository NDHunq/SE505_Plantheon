import 'package:se501_plantheon/domain/entities/user_entity.dart';
import 'package:se501_plantheon/domain/repository/user_repository.dart';

class UpdateProfile {
  final UserRepository repository;

  UpdateProfile({required this.repository});

  Future<UserEntity> call({String? fullName, String? avatar}) {
    return repository.updateProfile(fullName: fullName, avatar: avatar);
  }
}
