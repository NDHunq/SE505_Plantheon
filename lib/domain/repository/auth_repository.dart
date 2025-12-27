import '../entities/auth_entity.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<AuthEntity> login(String email, String password);
  Future<AuthEntity> register({
    required String email,
    required String username,
    required String fullName,
    required String password,
  });
  Future<void> logout();
  Future<String?> getStoredToken();
  Future<UserEntity?> getCurrentUser();
  Future<bool> isAuthenticated();
  
  // Forgot password methods
  Future<String> requestPasswordReset(String email);
  Future<Map<String, dynamic>> verifyOtp(String email, String otp);
  Future<void> resetPassword(String email, String otp, String newPassword);
}
