import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:se501_plantheon/common/widgets/appbar/basic_appbar.dart';
import 'package:se501_plantheon/common/widgets/button/sized_button.dart';
import 'package:se501_plantheon/common/widgets/loading_indicator.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/core/configs/assets/app_text_styles.dart';
import 'package:se501_plantheon/presentation/bloc/forgot_password/forgot_password_bloc.dart';
import 'package:se501_plantheon/presentation/bloc/forgot_password/forgot_password_event.dart';
import 'package:se501_plantheon/presentation/bloc/forgot_password/forgot_password_state.dart';
import 'package:se501_plantheon/presentation/screens/authentication/reset_password_screen.dart';
import 'package:toastification/toastification.dart';
import 'dart:async';

class VerifyOtpScreen extends StatefulWidget {
  final String email;

  const VerifyOtpScreen({super.key, required this.email});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoadingDialogVisible = false;

  // Timer for OTP expiration (5 minutes)
  Timer? _expirationTimer;
  int _remainingSeconds = 300; // 5 minutes

  // Timer for resend cooldown (1 minute)
  Timer? _resendTimer;
  int _resendCooldown = 60; // 1 minute
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startExpirationTimer();
    _startResendTimer();
  }

  void _startExpirationTimer() {
    _expirationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _startResendTimer() {
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCooldown > 0) {
        setState(() {
          _resendCooldown--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      }
    });
  }

  void _resetTimers() {
    setState(() {
      _remainingSeconds = 300;
      _resendCooldown = 60;
      _canResend = false;
    });
    _expirationTimer?.cancel();
    _resendTimer?.cancel();
    _startExpirationTimer();
    _startResendTimer();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ForgotPasswordBloc, ForgotPasswordState>(
      listener: (context, state) {
        if (state is ForgotPasswordLoading) {
          _showLoadingDialog(context);
        } else {
          _hideLoadingDialog();
        }

        if (state is OtpVerified) {
          // Navigate to reset password screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ResetPasswordScreen(email: widget.email, otp: state.otp),
            ),
          );
        } else if (state is OtpInvalid) {
          // Show error with attempts remaining
          String message = state.message;
          if (state.attemptsRemaining != null) {
            message += '. Còn ${state.attemptsRemaining} lần thử';
          }
          toastification.show(
            context: context,
            type: ToastificationType.error,
            style: ToastificationStyle.flat,
            title: Text(message),
            autoCloseDuration: const Duration(seconds: 3),
            alignment: Alignment.bottomCenter,
            showProgressBar: true,
          );
        } else if (state is ForgotPasswordError) {
          toastification.show(
            context: context,
            type: ToastificationType.error,
            style: ToastificationStyle.flat,
            title: Text(state.message),
            autoCloseDuration: const Duration(seconds: 3),
            alignment: Alignment.bottomCenter,
            showProgressBar: true,
          );
        } else if (state is OtpSent) {
          // OTP resent successfully
          _resetTimers();
          toastification.show(
            context: context,
            type: ToastificationType.success,
            style: ToastificationStyle.flat,
            title: const Text('OTP đã được gửi lại'),
            autoCloseDuration: const Duration(seconds: 2),
            alignment: Alignment.bottomCenter,
            showProgressBar: true,
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: BasicAppbar(
            title: 'Xác thực OTP',
            titleColor: AppColors.primary_main,
          ),
          body: Padding(
            padding: EdgeInsets.all(24.sp),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.sp),
                    Text('Nhập mã OTP', style: AppTextStyles.s24SemiBold()),
                    SizedBox(height: 12.sp),
                    Text(
                      'Mã OTP đã được gửi đến email ${widget.email}',
                      style: AppTextStyles.s14Regular(color: Colors.grey),
                    ),
                    SizedBox(height: 40.sp),

                    // OTP Input
                    PinCodeTextField(
                      appContext: context,
                      length: 6,
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      animationType: AnimationType.fade,
                      pinTheme: PinTheme(
                        shape: PinCodeFieldShape.box,
                        borderRadius: BorderRadius.circular(8.sp),
                        fieldHeight: 50.sp,
                        fieldWidth: 45.sp,
                        activeFillColor: Colors.white,
                        inactiveFillColor: Colors.white,
                        selectedFillColor: Colors.white,
                        activeColor: AppColors.primary_main,
                        inactiveColor: Colors.grey[300]!,
                        selectedColor: AppColors.primary_main,
                      ),
                      cursorColor: AppColors.primary_main,
                      animationDuration: const Duration(milliseconds: 300),
                      enableActiveFill: true,
                      onCompleted: (v) {
                        // Auto-submit when all 6 digits are entered
                        _verifyOtp();
                      },
                      onChanged: (value) {},
                      beforeTextPaste: (text) {
                        return true;
                      },
                    ),

                    SizedBox(height: 30.sp),

                    // Timer display
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'Mã OTP hết hạn sau:',
                            style: AppTextStyles.s14Regular(color: Colors.grey),
                          ),
                          SizedBox(height: 8.sp),
                          Text(
                            _formatTime(_remainingSeconds),
                            style: AppTextStyles.s20Bold(
                              color: _remainingSeconds < 60
                                  ? Colors.red
                                  : AppColors.primary_main,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 30.sp),

                    // Verify button
                    SizedBox(
                      width: double.infinity,
                      child: Sizedbutton(
                        text: 'Xác thực',
                        onPressFun: _verifyOtp,
                      ),
                    ),

                    SizedBox(height: 20.sp),

                    // Resend OTP button
                    Center(
                      child: TextButton(
                        onPressed: _canResend
                            ? () {
                                context.read<ForgotPasswordBloc>().add(
                                  RequestOtpEvent(email: widget.email),
                                );
                              }
                            : null,
                        child: Text(
                          _canResend
                              ? 'Gửi lại mã OTP'
                              : 'Gửi lại sau ${_formatTime(_resendCooldown)}',
                          style: AppTextStyles.s14Medium(
                            color: _canResend
                                ? AppColors.primary_main
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _verifyOtp() {
    if (_otpController.text.length == 6) {
      context.read<ForgotPasswordBloc>().add(
        VerifyOtpEvent(email: widget.email, otp: _otpController.text),
      );
    } else {
      toastification.show(
        context: context,
        type: ToastificationType.warning,
        style: ToastificationStyle.flat,
        title: const Text('Vui lòng nhập đầy đủ 6 chữ số'),
        autoCloseDuration: const Duration(seconds: 2),
        alignment: Alignment.bottomCenter,
        showProgressBar: true,
      );
    }
  }

  void _showLoadingDialog(BuildContext context) {
    if (_isLoadingDialogVisible) return;
    _isLoadingDialogVisible = true;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: const AlertDialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            content: Center(child: LoadingIndicator()),
          ),
        );
      },
    );
  }

  void _hideLoadingDialog() {
    if (!_isLoadingDialogVisible) return;
    _isLoadingDialogVisible = false;
    try {
      Navigator.of(context, rootNavigator: true).pop();
    } catch (_) {}
  }

  @override
  void dispose() {
    _hideLoadingDialog();
    _otpController.dispose();
    _expirationTimer?.cancel();
    _resendTimer?.cancel();
    super.dispose();
  }
}
