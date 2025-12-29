import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:se501_plantheon/core/configs/constants/api_constants.dart';
import 'package:se501_plantheon/core/services/token_storage_service.dart';
import 'package:se501_plantheon/data/models/user_model.dart';

abstract class UserRemoteDataSource {
  Future<UserModel> getProfile();
  Future<UserModel> updateProfile({String? fullName, String? avatar});
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
}
