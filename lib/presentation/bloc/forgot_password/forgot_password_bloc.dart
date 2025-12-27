import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:se501_plantheon/domain/usecases/request_password_reset_usecase.dart';
import 'package:se501_plantheon/domain/usecases/verify_otp_usecase.dart';
import 'package:se501_plantheon/domain/usecases/reset_password_usecase.dart';
import 'forgot_password_event.dart';
import 'forgot_password_state.dart';

class ForgotPasswordBloc
    extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  final RequestPasswordResetUseCase requestPasswordResetUseCase;
  final VerifyOtpUseCase verifyOtpUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;

  ForgotPasswordBloc({
    required this.requestPasswordResetUseCase,
    required this.verifyOtpUseCase,
    required this.resetPasswordUseCase,
  }) : super(const ForgotPasswordInitial()) {
    on<RequestOtpEvent>(_onRequestOtp);
    on<VerifyOtpEvent>(_onVerifyOtp);
    on<ResetPasswordEvent>(_onResetPassword);
  }

  Future<void> _onRequestOtp(
    RequestOtpEvent event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    emit(const ForgotPasswordLoading());
    try {
      final message = await requestPasswordResetUseCase(event.email);
      emit(OtpSent(message: message, email: event.email));
    } catch (e) {
      emit(ForgotPasswordError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onVerifyOtp(
    VerifyOtpEvent event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    emit(const ForgotPasswordLoading());
    try {
      final result = await verifyOtpUseCase(event.email, event.otp);
      final valid = result['valid'] as bool;
      final message = result['message'] as String;
      final attemptsRemaining = result['attemptsRemaining'] as int?;

      if (valid) {
        emit(OtpVerified(
          message: message,
          email: event.email,
          otp: event.otp,
        ));
      } else {
        emit(OtpInvalid(
          message: message,
          attemptsRemaining: attemptsRemaining,
        ));
      }
    } catch (e) {
      emit(ForgotPasswordError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onResetPassword(
    ResetPasswordEvent event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    emit(const ForgotPasswordLoading());
    try {
      await resetPasswordUseCase(event.email, event.otp, event.newPassword);
      emit(const PasswordResetSuccess(
        message: 'Đặt lại mật khẩu thành công',
      ));
    } catch (e) {
      emit(ForgotPasswordError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }
}
