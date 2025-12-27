import '../repository/auth_repository.dart';

class RequestPasswordResetUseCase {
  final AuthRepository repository;

  RequestPasswordResetUseCase({required this.repository});

  Future<String> call(String email) {
    return repository.requestPasswordReset(email);
  }
}
