import 'package:equatable/equatable.dart';

abstract class ForgotPasswordState extends Equatable {
  const ForgotPasswordState();

  @override
  List<Object?> get props => [];
}

class ForgotPasswordInitial extends ForgotPasswordState {
  const ForgotPasswordInitial();
}

class ForgotPasswordLoading extends ForgotPasswordState {
  const ForgotPasswordLoading();
}

class OtpSent extends ForgotPasswordState {
  final String message;
  final String email;

  const OtpSent({required this.message, required this.email});

  @override
  List<Object?> get props => [message, email];
}

class OtpVerified extends ForgotPasswordState {
  final String message;
  final String email;
  final String otp;

  const OtpVerified({
    required this.message,
    required this.email,
    required this.otp,
  });

  @override
  List<Object?> get props => [message, email, otp];
}

class OtpInvalid extends ForgotPasswordState {
  final String message;
  final int? attemptsRemaining;

  const OtpInvalid({required this.message, this.attemptsRemaining});

  @override
  List<Object?> get props => [message, attemptsRemaining];
}

class PasswordResetSuccess extends ForgotPasswordState {
  final String message;

  const PasswordResetSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class ForgotPasswordError extends ForgotPasswordState {
  final String message;

  const ForgotPasswordError({required this.message});

  @override
  List<Object?> get props => [message];
}
