import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:se501_plantheon/common/widgets/button/sized_button.dart';
import 'package:se501_plantheon/presentation/bloc/auth/auth_bloc.dart';
import 'package:se501_plantheon/presentation/bloc/auth/auth_event.dart';
import 'package:se501_plantheon/presentation/bloc/auth/auth_state.dart';
import '../../../core/configs/constants/app_info.dart';
import '../../../core/configs/theme/app_colors.dart';
import '../../../core/configs/assets/app_text_styles.dart';
import 'package:toastification/toastification.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _fullName = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _email.dispose();
    _username.dispose();
    _fullName.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthRegistered) {
          // Navigate back to login page on successful registration
          toastification.show(
            context: context,
            type: ToastificationType.success,
            style: ToastificationStyle.flat,
            title: const Text('Đăng ký thành công! Vui lòng đăng nhập.'),
            autoCloseDuration: const Duration(seconds: 3),
            alignment: Alignment.bottomCenter,
            showProgressBar: true,
            icon: const Icon(Icons.check_circle_outline, color: Colors.green),
          );
          Navigator.pop(context);
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
        return Scaffold(
          bottomNavigationBar: _bottomText(context),
          body: Padding(
            padding: EdgeInsets.all(AppInfo.main_padding),
            child: SingleChildScrollView(
              reverse: true,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 50.sp),
                  _registerText(),
                  SizedBox(height: 20.sp),
                  _supportText(),
                  SizedBox(height: 25.sp),
                  _buildFormRegister(state),
                  SizedBox(height: 40.sp),
                  _dividerWithText('hoặc'),
                  SizedBox(height: 40.sp),
                  _iconGroup(context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFormRegister(AuthState state) {
    final isLoading = state is AuthLoading;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          _emailField(context),
          SizedBox(height: 15.sp),
          _usernameField(context),
          SizedBox(height: 15.sp),
          _fullNameField(context),
          SizedBox(height: 15.sp),
          _passField(context),
          SizedBox(height: 15.sp),
          _confirmPassField(context),
          SizedBox(height: 15.sp),
          SizedBox(
            width: double.infinity,
            child: Sizedbutton(
              text: isLoading ? 'Đang đăng ký...' : 'Đăng ký',
              onPressFun: isLoading
                  ? null
                  : () {
                      if (_formKey.currentState!.validate()) {
                        // Check if passwords match
                        if (_password.text != _confirmPassword.text) {
                          toastification.show(
                            context: context,
                            type: ToastificationType.error,
                            style: ToastificationStyle.flat,
                            title: Text('Mật khẩu không khớp'),
                            autoCloseDuration: const Duration(seconds: 3),
                            alignment: Alignment.bottomCenter,
                            showProgressBar: true,
                          );
                          return;
                        }

                        // Dispatch register event to BLoC
                        context.read<AuthBloc>().add(
                          RegisterRequested(
                            email: _email.text.trim(),
                            username: _username.text.trim(),
                            fullName: _fullName.text.trim(),
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

  Widget _dividerWithText(String text) {
    return Row(
      children: [
        Expanded(child: _fadingDivider()),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.sp),
          child: Text(text, style: AppTextStyles.s14Regular()),
        ),
        Expanded(child: _fadingDivider2()),
      ],
    );
  }

  Widget _fadingDivider() {
    return Container(
      height: 1.sp,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey, Colors.transparent],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
    );
  }

  Widget _fadingDivider2() {
    return Container(
      height: 1.sp,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.transparent, Colors.grey],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
    );
  }

  Widget _registerText() {
    return Text('Đăng ký', style: AppTextStyles.s32SemiBold());
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
          Text('Bạn đã có tài khoản?', style: AppTextStyles.s14Regular()),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Đăng nhập ngay',
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

  Widget _usernameField(BuildContext context) {
    return TextFormField(
      controller: _username,
      decoration: InputDecoration(
        labelText: 'Tên đăng nhập',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.sp)),
        ),
      ),
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return 'Vui lòng nhập tên đăng nhập';
        }
        if (value.length < 3) {
          return 'Tên đăng nhập phải có ít nhất 3 ký tự';
        }
        return null;
      },
    );
  }

  Widget _fullNameField(BuildContext context) {
    return TextFormField(
      controller: _fullName,
      decoration: InputDecoration(
        labelText: 'Họ và tên',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.sp)),
        ),
      ),
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return 'Vui lòng nhập họ và tên';
        }
        if (value.length < 2) {
          return 'Họ và tên phải có ít nhất 2 ký tự';
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
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: const Color.fromARGB(255, 63, 63, 63),
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
      ),
      obscureText: _obscurePassword,
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

  Widget _confirmPassField(BuildContext context) {
    return TextFormField(
      controller: _confirmPassword,
      decoration: InputDecoration(
        labelText: 'Xác nhận mật khẩu',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.sp)),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
            color: const Color.fromARGB(255, 63, 63, 63),
          ),
          onPressed: () {
            setState(() {
              _obscureConfirmPassword = !_obscureConfirmPassword;
            });
          },
        ),
      ),
      obscureText: _obscureConfirmPassword,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Vui lòng xác nhận mật khẩu';
        }
        if (value.length < 6) {
          return 'Mật khẩu phải có ít nhất 6 ký tự';
        }
        return null;
      },
    );
  }

  Widget _iconGroup(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // SvgPicture.asset(AppVectors.google, height: 35.sp),
        SizedBox(width: 50.sp),
        // SvgPicture.asset(AppVectors.facebook, height: 35.sp),
      ],
    );
  }
}
