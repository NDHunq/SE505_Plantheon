import 'package:flutter/material.dart';
import 'package:se501_plantheon/common/widgets/button/sized_button.dart';
import 'package:se501_plantheon/presentation/screens/Navigator/navigator.dart';

import '../../../core/configs/assets/app_vectors.dart';
import '../../../core/configs/constants/app_info.dart';
import '../../../core/configs/theme/app_colors.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  String _otp = '';
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _phoneDialogController = TextEditingController();

  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscureText = true;
  bool isShowErrText = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: _bottomText(context),
        body: Padding(
          padding: const EdgeInsets.all(AppInfo.main_padding),
          child: SingleChildScrollView(
            reverse: true,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                _registerText(),
                const SizedBox(height: 20),
                _supportText(),
                const SizedBox(height: 25),
                _buildFormLogin(),
                const SizedBox(height: 40),
                _dividerWithText('hoặc'),
                const SizedBox(height: 40),
                _iconGroup(context),
              ],
            ),
          ),
        ));
  }

  Widget _buildFormLogin() {
    return Form(
        key: _formKey,
        child: Column(
          children: [
            _userNameField(context),
            const SizedBox(height: 15),
            _passField(context),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () async {
                    _showForgotPasswordBottomSheet(context);
                  },
                  child: const Text(
                    'Quên mật khẩu',
                    style: TextStyle(
                        color: AppColors.primary_main,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity, // Chiều rộng bằng chiều rộng màn hình
              child: Sizedbutton(
                  text: 'Đăng nhập',
                  onPressFun: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                Navigation()));
                  }),
            ),
          ],
        ));
  }

  Widget _dividerWithText(String text) {
    return Row(
      children: [
        Expanded(child: _fadingDivider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Text(text),
        ),
        Expanded(child: _fadingDivider2()),
      ],
    );
  }

  Widget _fadingDivider() {
    return Container(
      height: 1,
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
      height: 1,
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
    return const Text(
      'Đăng nhập',
      style: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _supportText() {
    return Center(
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: [
            const TextSpan(
              text: 'Nếu bạn cần hỗ trợ, vui lòng liên hệ  ',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            WidgetSpan(
              child: GestureDetector(
                onTap: () async {
                  const url = 'https://flutter.dev/';
                  // if (await canLaunch(url)) {
                  //   await launch(url);
                  // } else {
                  //   throw 'Could not launch $url';
                  // }
                },
                child: const Text(
                  'Tại đây',
                  style: TextStyle(
                      color: AppColors.primary_main,
                      fontWeight: FontWeight.w600),
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
      padding: const EdgeInsets.only(bottom: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Bạn chưa có tài khoản?'),
          TextButton(
              onPressed: () {
                // Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //         builder: (BuildContext context) => SignUpPage()));
              },
              child: const Text(
                'Đăng kí ngay',
                style: TextStyle(
                  color: AppColors.primary_main,
                ),
              )),
        ],
      ),
    );
  }

  Widget _userNameField(BuildContext context) {
    return TextFormField(
      controller: _email,
      decoration: const InputDecoration(
          labelText: 'Số điện thoại',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          )),
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return 'Vui lòng nhập số điện thoại';
        }
        bool emailValid = RegExp(r'^\+?[0-9]{10,15}$').hasMatch(value);
        if (!emailValid) {
          return 'Vui lòng nhập đúng định dạng';
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
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureText ? Icons.visibility_off : Icons.visibility,
              color: const Color.fromARGB(255, 63, 63, 63),
            ),
            onPressed: () {
              setState(() {
                _obscureText = !_obscureText;
              });
            },
          )),
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

  Widget _iconGroup(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // SvgPicture.asset(AppVectors.google, height: 35),
        const SizedBox(
          width: 50,
        ),
        // SvgPicture.asset(AppVectors.facebook, height: 35),
      ],
    );
  }

  void _showForgotPasswordBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Cho phép BottomSheet cuộn
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context)
                .viewInsets
                .bottom, // Lấy khoảng trống của bàn phím
            left: 25.0,
            right: 25.0,
            top: 25.0,
          ),
          child: SingleChildScrollView(
            // Bao bọc nội dung để cho phép cuộn
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 100,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Quên mật khẩu',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Vui lòng nhập số điện thoại của bạn để nhận OTP đặt lại mật khẩu.',
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _phoneDialogController,
                  decoration: const InputDecoration(
                    labelText: 'Số điện thoại',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Sizedbutton(
                  onPressFun: () {},
                  text: 'Gửi OTP',
                  width: double.infinity,
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  final bool _isOtpError = false;
  void _showOtpBottomSheet(BuildContext context) {
    final TextEditingController OTPController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Cho phép BottomSheet cuộn
      builder: (BuildContext context) {
        bool isOtpError = false;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context)
                    .viewInsets
                    .bottom, // Lấy khoảng trống của bàn phím
                left: 25.0,
                right: 25.0,
                top: 25.0,
              ),
              child: SingleChildScrollView(
                // Bao bọc nội dung để cho phép cuộn
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 100,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Nhập OTP',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Vui lòng nhập số mã OTP đã được gửi đến số điện thoại của bạn.',
                    ),
                    const SizedBox(height: 20),
                    // PinCodeTextField(
                    //   appContext: context,
                    //   controller: OTPController,
                    //   length: 6,
                    //   onChanged: (value) {
                    //     setState(() {
                    //       _otp = value;
                    //     });
                    //   },
                    //   pinTheme: PinTheme(
                    //     shape: PinCodeFieldShape.box,
                    //     borderRadius: BorderRadius.circular(5),
                    //     fieldHeight: 50,
                    //     fieldWidth: 40,
                    //     activeFillColor: Colors.white,
                    //     inactiveFillColor: Colors.white,
                    //     selectedFillColor: Colors.white,
                    //     activeColor: AppColors
                    //         .xanh_ngoc_nhat, // Màu viền khi ô nhập đang được chọn
                    //     inactiveColor:
                    //         Colors.grey, // Màu viền khi ô nhập không được chọn
                    //     selectedColor: AppColors.xanh_ngoc_nhat,
                    //   ),
                    // ),
                    const SizedBox(height: 10),
                    Visibility(
                      visible: isOtpError,
                      child: const Text(
                        "OTP không hợp lệ hoặc hết hạn",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Sizedbutton(
                      onPressFun: () {},
                      text: 'Tiếp tục',
                      width: double.infinity,
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showChangePasswordBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Cho phép BottomSheet cuộn
      builder: (BuildContext context) {
        bool obscureText = true;
        bool isOtpError = false;
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context)
                  .viewInsets
                  .bottom, // Lấy khoảng trống của bàn phím
              left: 25.0,
              right: 25.0,
              top: 25.0,
            ),
            child: SingleChildScrollView(
              // Bao bọc nội dung để cho phép cuộn
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 100,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Cập nhật mật khẩu',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Vui lòng nhập mật khẩu mới của bạn.',
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _newPasswordController,
                    decoration: InputDecoration(
                        labelText: 'Mật khẩu mới',
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureText
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: const Color.fromARGB(255, 63, 63, 63),
                          ),
                          onPressed: () {
                            setState(() {
                              obscureText = !obscureText;
                            });
                          },
                        )),
                    obscureText: obscureText,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập mật khẩu';
                      }
                      if (value.length < 6) {
                        return 'Mật khẩu phải có ít nhất 6 ký tự';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                        labelText: 'Xác nhận mật khẩu mới',
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureText
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: const Color.fromARGB(255, 63, 63, 63),
                          ),
                          onPressed: () {
                            setState(() {
                              obscureText = !obscureText;
                            });
                          },
                        )),
                    obscureText: obscureText,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập mật khẩu';
                      }
                      if (value.length < 6) {
                        return 'Mật khẩu phải có ít nhất 6 ký tự';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  Visibility(
                    visible: isOtpError,
                    child: const Text(
                      "Mật khẩu không khớp",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Sizedbutton(
                    onPressFun: () {
                      // Xử lý đổi mật khẩu ở đây
                      String newPassword = _newPasswordController.text;
                      String confirmPassword = _confirmPasswordController.text;
                      if (newPassword == confirmPassword) {
                        //Navigator.pop(context); // Đóng BottomSheet
                      } else {
                        setState(() {
                          isOtpError = true;
                        });
                      }
                    },
                    text: 'Cập nhật mật khẩu',
                    width: double.infinity,
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          );
        });
      },
    );
  }
}