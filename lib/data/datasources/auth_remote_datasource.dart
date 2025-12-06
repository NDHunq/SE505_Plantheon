import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:se501_plantheon/core/configs/constants/api_constants.dart';
import 'package:se501_plantheon/data/models/auth_model.dart';

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
}
