import '../../domain/entities/auth_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repository/auth_repository.dart';
import '../../core/services/token_storage_service.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final TokenStorageService tokenStorage;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.tokenStorage,
  });

  @override
  Future<AuthEntity> login(String email, String password) async {
    try {
      final authModel = await remoteDataSource.login(email, password);

      // Store token and user data
      await tokenStorage.saveToken(authModel.token);
      await tokenStorage.saveUser(authModel.user as UserModel);

      return authModel;
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  @override
  Future<AuthEntity> register({
    required String email,
    required String username,
    required String fullName,
    required String password,
  }) async {
    try {
      final authModel = await remoteDataSource.register(
        email: email,
        username: username,
        fullName: fullName,
        password: password,
      );

      // Don't store token on registration - user should login after registering
      return authModel;
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    await tokenStorage.clear();
  }

  @override
  Future<String?> getStoredToken() async {
    return await tokenStorage.getToken();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    return await tokenStorage.getUser();
  }

  @override
  Future<bool> isAuthenticated() async {
    return await tokenStorage.isTokenValid();
  }
}
