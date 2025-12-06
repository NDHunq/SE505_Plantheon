import '../entities/auth_entity.dart';
import '../repository/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase({required this.repository});

  Future<AuthEntity> call({
    required String email,
    required String username,
    required String fullName,
    required String password,
  }) {
    return repository.register(
      email: email,
      username: username,
      fullName: fullName,
      password: password,
    );
  }
}
