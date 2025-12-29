import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:se501_plantheon/core/configs/constants/api_constants.dart';
import 'package:se501_plantheon/core/services/token_storage_service.dart';
import 'package:se501_plantheon/data/models/notification_model.dart';

class NotificationRemoteDataSource {
  final http.Client client;
  final TokenStorageService tokenStorage;

  NotificationRemoteDataSource({
    required this.client,
    required this.tokenStorage,
  });

  Future<List<NotificationModel>> getNotifications() async {
    final url =
        '${ApiConstants.baseUrl}/${ApiConstants.apiVersion}/notification';

    final token = await tokenStorage.getToken();
    if (token == null) {
      throw Exception('User not authenticated');
    }

    final response = await client.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final notificationResponse = NotificationResponseModel.fromJson(
        jsonResponse,
      );
      return notificationResponse.notifications;
    } else if (response.statusCode == 401) {
      throw Exception('Token hết hạn. Vui lòng đăng nhập lại');
    } else {
      try {
        final errorBody = json.decode(response.body);
        final errorMessage = errorBody['error'] ?? 'Không thể tải thông báo';
        throw Exception(errorMessage);
      } catch (e) {
        throw Exception('Không thể tải thông báo');
      }
    }
  }

  Future<void> deleteNotification(String id) async {
    final url =
        '${ApiConstants.baseUrl}/${ApiConstants.apiVersion}/notification/$id';

    final token = await tokenStorage.getToken();
    if (token == null) {
      throw Exception('User not authenticated');
    }

    final response = await client.delete(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 401) {
      throw Exception('Token hết hạn. Vui lòng đăng nhập lại');
    } else if (response.statusCode != 200 && response.statusCode != 204) {
      try {
        final errorBody = json.decode(response.body);
        final errorMessage = errorBody['error'] ?? 'Không thể xóa thông báo';
        throw Exception(errorMessage);
      } catch (e) {
        throw Exception('Không thể xóa thông báo');
      }
    }
  }

  Future<void> clearNotifications() async {
    final url =
        '${ApiConstants.baseUrl}/${ApiConstants.apiVersion}/notification';

    final token = await tokenStorage.getToken();
    if (token == null) {
      throw Exception('User not authenticated');
    }

    final response = await client.delete(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 401) {
      throw Exception('Token hết hạn. Vui lòng đăng nhập lại');
    } else if (response.statusCode != 200 && response.statusCode != 204) {
      try {
        final errorBody = json.decode(response.body);
        final errorMessage =
            errorBody['error'] ?? 'Không thể xóa tất cả thông báo';
        throw Exception(errorMessage);
      } catch (e) {
        throw Exception('Không thể xóa tất cả thông báo');
      }
    }
  }

  Future<void> markNotificationSeen(String id) async {
    final url =
        '${ApiConstants.baseUrl}/${ApiConstants.apiVersion}/notification/$id/seen';

    final token = await tokenStorage.getToken();
    if (token == null) {
      throw Exception('User not authenticated');
    }

    final response = await client.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 401) {
      throw Exception('Token hết hạn. Vui lòng đăng nhập lại');
    } else if (response.statusCode != 200) {
      try {
        final errorBody = json.decode(response.body);
        final errorMessage =
            errorBody['error'] ?? 'Không thể đánh dấu đã xem thông báo';
        throw Exception(errorMessage);
      } catch (e) {
        throw Exception('Không thể đánh dấu đã xem thông báo');
      }
    }
  }
}
