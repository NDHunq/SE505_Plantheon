import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:se501_plantheon/common/widgets/button/sized_button.dart';
import 'package:se501_plantheon/common/widgets/loading_indicator.dart';
import 'package:se501_plantheon/core/configs/assets/app_vectors.dart';
import 'package:se501_plantheon/presentation/bloc/auth/auth_bloc.dart';
import 'package:se501_plantheon/presentation/bloc/auth/auth_event.dart';
import 'package:se501_plantheon/presentation/bloc/auth/auth_state.dart';
import 'package:se501_plantheon/presentation/screens/navigator/navigator.dart';
import '../../../core/configs/constants/app_info.dart';
import '../../../core/configs/theme/app_colors.dart';
import '../../../core/configs/assets/app_text_styles.dart';
import 'signup.dart';
import 'package:toastification/toastification.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _phoneDialogController = TextEditingController();

  bool _obscureText = true;
  bool isShowErrText = false;
  bool _isLoadingDialogVisible = false;

  @override
  void initState() {
    super.initState();
    // Check if user is already authenticated when page loads
    context.read<AuthBloc>().add(const CheckAuthRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLoading) {
          _showLoadingDialog(context);
        } else {
          _hideLoadingDialog();
        }

        if (state is AuthAuthenticated) {
          // Navigate to main screen on successful authentication
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => const CustomNavigator(),
            ),
          );
        } else if (state is AuthError) {
          // Show error message
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
        // Keep the login UI visible and use a dialog for loading state
        return Scaffold(
          bottomNavigationBar: _bottomText(context),
          body: Padding(
            padding: EdgeInsets.all(AppInfo.main_padding.sp),
            child: SingleChildScrollView(
              reverse: true,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 150.sp),
                  _registerText(),
                  SizedBox(height: 20.sp),
                  _supportText(),
                  SizedBox(height: 25.sp),
                  _buildFormLogin(state),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFormLogin(AuthState state) {
    final isLoading = state is AuthLoading;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          _emailField(context),
          SizedBox(height: 15.sp),
          _passField(context),
          SizedBox(height: 15.sp),
          Padding(
            padding: EdgeInsets.only(left: 5.sp),
            child: Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () async {
                  _showForgotPasswordBottomSheet(context);
                },
                child: Text(
                  'Quên mật khẩu',
                  style: AppTextStyles.s14Medium(color: AppColors.primary_main),
                ),
              ),
            ),
          ),
          SizedBox(height: 15.sp),
          SizedBox(
            width: double.infinity, // Chiều rộng bằng chiều rộng màn hình
            child: Sizedbutton(
              text: isLoading ? 'Đang đăng nhập...' : 'Đăng nhập',
              onPressFun: isLoading
                  ? null
                  : () {
                      if (_formKey.currentState!.validate()) {
                        // Dispatch login event to BLoC
                        context.read<AuthBloc>().add(
                          LoginRequested(
                            email: _email.text.trim(),
                            password: _password.text,
                          ),
                        );
                      }
                    },
            ),
          ),
        ],
      ),
    );
  }

  Widget _registerText() {
    return Text('Đăng nhập', style: AppTextStyles.s24SemiBold());
  }

  Widget _supportText() {
    return Center(
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: [
            TextSpan(
              text: 'Nếu bạn cần hỗ trợ, vui lòng liên hệ  ',
              style: AppTextStyles.s14Regular(color: Colors.grey),
            ),
            WidgetSpan(
              child: GestureDetector(
                onTap: () async {},
                child: Text(
                  'Tại đây',
                  style: AppTextStyles.s14SemiBold(
                    color: AppColors.primary_main,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomText(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 30.sp),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Bạn chưa có tài khoản?', style: AppTextStyles.s14Regular()),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => const SignUpPage(),
                ),
              );
            },
            child: Text(
              'Đăng kí ngay',
              style: AppTextStyles.s14Medium(color: AppColors.primary_main),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emailField(BuildContext context) {
    return TextFormField(
      controller: _email,
      decoration: InputDecoration(
        labelText: 'Email',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.sp)),
        ),
      ),
      keyboardType: TextInputType.emailAddress,
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return 'Vui lòng nhập email';
        }
        bool emailValid = RegExp(
          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
        ).hasMatch(value);
        if (!emailValid) {
          return 'Vui lòng nhập đúng định dạng email';
        }
        return null;
      },
    );
  }

  Widget _passField(BuildContext context) {
    return TextFormField(
      controller: _password,
      decoration: InputDecoration(
        labelText: 'Mật khẩu',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.sp)),
        ),
        suffixIcon: IconButton(
          icon: SvgPicture.asset(
            _obscureText ? AppVectors.eyeOff : AppVectors.eye,
            width: 24.sp,
            height: 24.sp,
            color: AppColors.primary_600,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
      ),
      obscureText: _obscureText,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Vui lòng nhập mật khẩu';
        }
        if (value.length < 6) {
          return 'Mật khẩu phải có ít nhất 6 ký tự';
        }
        return null;
      },
    );
  }

  void _showForgotPasswordBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Cho phép BottomSheet cuộn
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(
              context,
            ).viewInsets.bottom, // Lấy khoảng trống của bàn phím
            left: 25.sp,
            right: 25.sp,
            top: 25.sp,
          ),
          child: SingleChildScrollView(
            // Bao bọc nội dung để cho phép cuộn
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 100.sp,
                    height: 5.sp,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10.sp),
                    ),
                  ),
                ),
                SizedBox(height: 30.sp),
                Text('Quên mật khẩu', style: AppTextStyles.s20Bold()),
                SizedBox(height: 20.sp),
                Text(
                  'Vui lòng nhập số điện thoại của bạn để nhận OTP đặt lại mật khẩu.',
                  style: AppTextStyles.s14Regular(),
                ),
                SizedBox(height: 20.sp),
                TextFormField(
                  controller: _phoneDialogController,
                  decoration: InputDecoration(
                    labelText: 'Số điện thoại',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12.sp)),
                    ),
                  ),
                ),
                SizedBox(height: 20.sp),
                Sizedbutton(
                  onPressFun: () {},
                  text: 'Gửi OTP',
                  width: double.infinity,
                ),
                SizedBox(height: 10.sp),
              ],
            ),
          ),
        );
      },
    );
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
          child: AlertDialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            content: Center(child: const LoadingIndicator()),
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
    _email.dispose();
    _password.dispose();
    _phoneDialogController.dispose();
    super.dispose();
  }
}
