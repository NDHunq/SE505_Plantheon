import '../repository/auth_repository.dart';

class VerifyOtpUseCase {
  final AuthRepository repository;

  VerifyOtpUseCase({required this.repository});

  Future<Map<String, dynamic>> call(String email, String otp) {
    return repository.verifyOtp(email, otp);
  }
}
