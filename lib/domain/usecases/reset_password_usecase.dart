import '../repository/auth_repository.dart';

class ResetPasswordUseCase {
  final AuthRepository repository;

  ResetPasswordUseCase({required this.repository});

  Future<void> call(String email, String otp, String newPassword) {
    return repository.resetPassword(email, otp, newPassword);
  }
}
