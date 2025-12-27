import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:se501_plantheon/core/configs/constants/api_constants.dart';
import 'package:se501_plantheon/data/models/auth_model.dart';
import 'package:se501_plantheon/data/models/forgot_password_model.dart';

class AuthRemoteDataSource {
  final http.Client client;

  AuthRemoteDataSource({required this.client});

  Future<AuthModel> login(String email, String password) async {
    final url = '${ApiConstants.baseUrl}/${ApiConstants.apiVersion}/auth/login';

    final response = await client.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return AuthModel.fromJson(jsonResponse);
    } else {
      final errorBody = json.decode(response.body);
      final errorMessage = errorBody['message'] ?? 'Login failed';
      throw Exception(errorMessage);
    }
  }

  Future<AuthModel> register({
    required String email,
    required String username,
    required String fullName,
    required String password,
  }) async {
    final url =
        '${ApiConstants.baseUrl}/${ApiConstants.apiVersion}/auth/register';

    final response = await client.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'username': username,
        'full_name': fullName,
        'password': password,
        'role': 'user',
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonResponse = json.decode(response.body);
      return AuthModel.fromJson(jsonResponse);
    } else {
      final errorBody = json.decode(response.body);
      final errorMessage = errorBody['message'] ?? 'Registration failed';
      throw Exception(errorMessage);
    }
  }

  // POST /api/v1/auth/forgot-password
  Future<ForgotPasswordResponseModel> requestPasswordReset(String email) async {
    final url =
        '${ApiConstants.baseUrl}/${ApiConstants.apiVersion}/auth/forgot-password';

    print('🔍 DEBUG: Sending forgot password request to: $url');
    print('🔍 DEBUG: Email: $email');

    final response = await client.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email}),
    );

    print('🔍 DEBUG: Response status code: ${response.statusCode}');
    print('🔍 DEBUG: Response body: ${response.body}');

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return ForgotPasswordResponseModel.fromJson(jsonResponse);
    } else {
      // Backend trả về error trong field 'error'
      try {
        final errorBody = json.decode(response.body);
        final errorMessage = errorBody['error'] ?? 'Không thể gửi OTP, vui lòng thử lại';
        throw Exception(errorMessage);
      } catch (e) {
        // Nếu không parse được JSON, dùng response body trực tiếp
        throw Exception(response.body);
      }
    }
  }

  // POST /api/v1/auth/verify-otp
  Future<VerifyOtpResponseModel> verifyOtp(String email, String otp) async {
    final url =
        '${ApiConstants.baseUrl}/${ApiConstants.apiVersion}/auth/verify-otp';

    final response = await client.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'otp': otp}),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return VerifyOtpResponseModel.fromJson(jsonResponse);
    } else {
      // Backend trả về error trong field 'error'
      try {
        final errorBody = json.decode(response.body);
        final errorMessage = errorBody['error'] ?? 'Không thể xác thực OTP, vui lòng thử lại';
        throw Exception(errorMessage);
      } catch (e) {
        throw Exception(response.body);
      }
    }
  }

  // POST /api/v1/auth/reset-password
  Future<ResetPasswordResponseModel> resetPassword(
    String email,
    String otp,
    String newPassword,
  ) async {
    final url =
        '${ApiConstants.baseUrl}/${ApiConstants.apiVersion}/auth/reset-password';

    final response = await client.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'otp': otp,
        'new_password': newPassword,
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return ResetPasswordResponseModel.fromJson(jsonResponse);
    } else {
      // Backend trả về error trong field 'error'
      try {
        final errorBody = json.decode(response.body);
        final errorMessage = errorBody['error'] ?? 'Đặt lại mật khẩu thất bại, vui lòng thử lại';
        throw Exception(errorMessage);
      } catch (e) {
        throw Exception(response.body);
      }
    }
  }
}
