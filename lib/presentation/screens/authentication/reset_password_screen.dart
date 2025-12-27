import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:se501_plantheon/common/widgets/appbar/basic_appbar.dart';
import 'package:se501_plantheon/common/widgets/button/sized_button.dart';
import 'package:se501_plantheon/common/widgets/loading_indicator.dart';
import 'package:se501_plantheon/core/configs/assets/app_vectors.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/core/configs/assets/app_text_styles.dart';
import 'package:se501_plantheon/presentation/bloc/forgot_password/forgot_password_bloc.dart';
import 'package:se501_plantheon/presentation/bloc/forgot_password/forgot_password_event.dart';
import 'package:se501_plantheon/presentation/bloc/forgot_password/forgot_password_state.dart';
import 'package:toastification/toastification.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String otp;

  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.otp,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoadingDialogVisible = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ForgotPasswordBloc, ForgotPasswordState>(
      listener: (context, state) {
        if (state is ForgotPasswordLoading) {
          _showLoadingDialog(context);
        } else {
          _hideLoadingDialog();
        }

        if (state is PasswordResetSuccess) {
          // Show success message and navigate back to signin
          toastification.show(
            context: context,
            type: ToastificationType.success,
            style: ToastificationStyle.flat,
            title: Text(state.message),
            autoCloseDuration: const Duration(seconds: 2),
            alignment: Alignment.bottomCenter,
            showProgressBar: true,
          );

          // Navigate back to signin screen (pop all forgot password screens)
          Future.delayed(const Duration(seconds: 2), () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          });
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
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: BasicAppbar(
            title: 'Đặt lại mật khẩu',
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
                    Text(
                      'Tạo mật khẩu mới',
                      style: AppTextStyles.s24SemiBold(),
                    ),
                    SizedBox(height: 12.sp),
                    Text(
                      'Mật khẩu mới của bạn phải khác với mật khẩu đã sử dụng trước đó',
                      style: AppTextStyles.s14Regular(color: Colors.grey),
                    ),
                    SizedBox(height: 40.sp),

                    // New password field
                    TextFormField(
                      controller: _newPasswordController,
                      decoration: InputDecoration(
                        labelText: 'Mật khẩu mới',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(12.sp),
                          ),
                        ),
                        suffixIcon: IconButton(
                          icon: SvgPicture.asset(
                            _obscureNewPassword
                                ? AppVectors.eyeOff
                                : AppVectors.eye,
                            width: 24.sp,
                            height: 24.sp,
                            color: AppColors.primary_600,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureNewPassword = !_obscureNewPassword;
                            });
                          },
                        ),
                      ),
                      obscureText: _obscureNewPassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập mật khẩu mới';
                        }
                        if (value.length < 6) {
                          return 'Mật khẩu phải có ít nhất 6 ký tự';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 20.sp),

                    // Confirm password field
                    TextFormField(
                      controller: _confirmPasswordController,
                      decoration: InputDecoration(
                        labelText: 'Xác nhận mật khẩu',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(12.sp),
                          ),
                        ),
                        suffixIcon: IconButton(
                          icon: SvgPicture.asset(
                            _obscureConfirmPassword
                                ? AppVectors.eyeOff
                                : AppVectors.eye,
                            width: 24.sp,
                            height: 24.sp,
                            color: AppColors.primary_600,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                      obscureText: _obscureConfirmPassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng xác nhận mật khẩu';
                        }
                        if (value != _newPasswordController.text) {
                          return 'Mật khẩu không khớp';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 12.sp),

                    // Password requirements
                    _buildPasswordRequirements(),

                    SizedBox(height: 40.sp),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      child: Sizedbutton(
                        text: 'Đặt lại mật khẩu',
                        onPressFun: _resetPassword,
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

  Widget _buildPasswordRequirements() {
    final password = _newPasswordController.text;
    final hasMinLength = password.length >= 6;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Yêu cầu mật khẩu:',
          style: AppTextStyles.s12Regular(color: Colors.grey),
        ),
        SizedBox(height: 8.sp),
        _buildRequirementItem('Ít nhất 6 ký tự', hasMinLength),
      ],
    );
  }

  Widget _buildRequirementItem(String text, bool isMet) {
    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle : Icons.circle_outlined,
          size: 16.sp,
          color: isMet ? Colors.green : Colors.grey,
        ),
        SizedBox(width: 8.sp),
        Text(
          text,
          style: AppTextStyles.s12Regular(
            color: isMet ? Colors.green : Colors.grey,
          ),
        ),
      ],
    );
  }

  void _resetPassword() {
    if (_formKey.currentState!.validate()) {
      context.read<ForgotPasswordBloc>().add(
        ResetPasswordEvent(
          email: widget.email,
          otp: widget.otp,
          newPassword: _newPasswordController.text,
        ),
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
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
