import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:se501_plantheon/core/configs/constants/api_constants.dart';
import 'package:se501_plantheon/core/services/token_storage_service.dart';
import 'package:se501_plantheon/data/models/user_model.dart';

abstract class UserRemoteDataSource {
  Future<UserModel> getProfile();
  Future<UserModel> updateProfile({String? fullName, String? avatar});
  Future<void> deleteAccount(String password);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final http.Client client;
  final TokenStorageService tokenStorage;
  final String baseUrl;
  final String apiVersion;

  UserRemoteDataSourceImpl({
    required this.client,
    required this.tokenStorage,
    String? baseUrl,
    String? apiVersion,
  }) : baseUrl = baseUrl ?? ApiConstants.baseUrl,
       apiVersion = apiVersion ?? ApiConstants.apiVersion;

  @override
  Future<UserModel> getProfile() async {
    final uri = Uri.parse('$baseUrl/$apiVersion/users/profile');
    final token = await tokenStorage.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('User not authenticated');
    }

    final response = await client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      final data = jsonData['data'] as Map<String, dynamic>? ?? {};
      return UserModel.fromJson(data);
    }

    try {
      final errorBody = json.decode(response.body);
      final errorMessage =
          errorBody['error'] ?? 'Không thể tải thông tin cá nhân';
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Không thể tải thông tin cá nhân');
    }
  }

  @override
  Future<UserModel> updateProfile({String? fullName, String? avatar}) async {
    final uri = Uri.parse('$baseUrl/$apiVersion/users/profile');
    final token = await tokenStorage.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('User not authenticated');
    }

    final body = <String, dynamic>{};
    if (fullName != null) body['full_name'] = fullName;
    if (avatar != null) body['avatar'] = avatar;

    final response = await client.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      final data = jsonData['data'] as Map<String, dynamic>? ?? {};
      return UserModel.fromJson(data);
    }

    try {
      final errorBody = json.decode(response.body);
      final errorMessage =
          errorBody['error'] ?? 'Không thể cập nhật thông tin cá nhân';
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Không thể cập nhật thông tin cá nhân');
    }
  }

  @override
  Future<void> deleteAccount(String password) async {
    final uri = Uri.parse('$baseUrl/$apiVersion/users/account');
    final token = await tokenStorage.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Không có token xác thực');
    }

    final response = await client.delete(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'password': password}),
    );

    if (response.statusCode == 200) {
      return;
    }

    print('Delete account failed with status: ${response.statusCode}');
    print('Response body: ${response.body}');
    print('Request password: $password');
    print('Request token: $token');
    // Handle error responses
    String? errorMessage;
    try {
      final errorBody = json.decode(response.body);
      errorMessage = errorBody['error'];
    } catch (e) {
      // If JSON parsing fails, use default error messages based on status code
    }

    // If we got an error message from the response, throw it
    if (errorMessage != null && errorMessage.isNotEmpty) {
      throw Exception(errorMessage);
    }

    // Default error messages based on status code
    switch (response.statusCode) {
      case 400:
        throw Exception('Định dạng yêu cầu không hợp lệ');
      case 401:
        throw Exception('Mật khẩu không đúng');
      case 404:
        throw Exception('Không tìm thấy người dùng');
      case 500:
        throw Exception('Xóa tài khoản thất bại');
      default:
        throw Exception('Xóa tài khoản thất bại');
    }
  }
}
