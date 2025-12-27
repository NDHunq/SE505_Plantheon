import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/token_storage_service.dart';
import '../../../data/datasources/auth_remote_datasource.dart';
import '../../../data/repository/auth_repository_impl.dart';
import '../../../domain/usecases/check_auth_usecase.dart';
import '../../../domain/usecases/login_usecase.dart';
import '../../../domain/usecases/logout_usecase.dart';
import '../../../domain/usecases/register_usecase.dart';
import '../../../domain/usecases/request_password_reset_usecase.dart';
import '../../../domain/usecases/verify_otp_usecase.dart';
import '../../../domain/usecases/reset_password_usecase.dart';
import 'auth_bloc.dart';
import '../forgot_password/forgot_password_bloc.dart';

class AuthProvider extends StatelessWidget {
  final Widget child;

  const AuthProvider({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        final prefs = snapshot.data!;
        final tokenStorage = TokenStorageService(prefs: prefs);
        final remoteDataSource = AuthRemoteDataSource(client: http.Client());
        final repository = AuthRepositoryImpl(
          remoteDataSource: remoteDataSource,
          tokenStorage: tokenStorage,
        );

        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => AuthBloc(
                loginUseCase: LoginUseCase(repository: repository),
                registerUseCase: RegisterUseCase(repository: repository),
                logoutUseCase: LogoutUseCase(repository: repository),
                checkAuthUseCase: CheckAuthUseCase(repository: repository),
                authRepository: repository,
              ),
            ),
            BlocProvider(
              create: (context) => ForgotPasswordBloc(
                requestPasswordResetUseCase:
                    RequestPasswordResetUseCase(repository: repository),
                verifyOtpUseCase: VerifyOtpUseCase(repository: repository),
                resetPasswordUseCase:
                    ResetPasswordUseCase(repository: repository),
              ),
            ),
          ],
          child: child,
        );
      },
    );
  }
}