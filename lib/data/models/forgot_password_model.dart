// Response model for POST /api/v1/auth/forgot-password
class ForgotPasswordResponseModel {
  final String message;
  final String expiresIn;

  ForgotPasswordResponseModel({
    required this.message,
    required this.expiresIn,
  });

  factory ForgotPasswordResponseModel.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordResponseModel(
      message: json['message'] as String,
      expiresIn: json['expires_in'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'expires_in': expiresIn,
    };
  }
}

// Response model for POST /api/v1/auth/verify-otp
class VerifyOtpResponseModel {
  final bool valid;
  final String message;
  final int? attemptsRemaining;

  VerifyOtpResponseModel({
    required this.valid,
    required this.message,
    this.attemptsRemaining,
  });

  factory VerifyOtpResponseModel.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponseModel(
      valid: json['valid'] as bool,
      message: json['message'] as String,
      attemptsRemaining: json['attempts_remaining'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'valid': valid,
      'message': message,
      if (attemptsRemaining != null) 'attempts_remaining': attemptsRemaining,
    };
  }
}

// Response model for POST /api/v1/auth/reset-password
class ResetPasswordResponseModel {
  final String message;

  ResetPasswordResponseModel({
    required this.message,
  });

  factory ResetPasswordResponseModel.fromJson(Map<String, dynamic> json) {
    return ResetPasswordResponseModel(
      message: json['message'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
    };
  }
}
