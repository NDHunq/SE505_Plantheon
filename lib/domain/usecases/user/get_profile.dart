import 'package:se501_plantheon/domain/entities/user_entity.dart';
import 'package:se501_plantheon/domain/repository/user_repository.dart';

class GetProfile {
  final UserRepository repository;

  GetProfile({required this.repository});

  Future<UserEntity> call() {
    return repository.getProfile();
  }
}
