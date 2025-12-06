import '../repository/auth_repository.dart';

class CheckAuthUseCase {
  final AuthRepository repository;

  CheckAuthUseCase({required this.repository});

  Future<bool> call() {
    return repository.isAuthenticated();
  }
}
