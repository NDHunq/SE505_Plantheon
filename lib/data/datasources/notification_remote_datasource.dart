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
      throw Exception('Token expired. Please login again.');
    } else {
      throw Exception('Failed to load notifications');
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
      throw Exception('Token expired. Please login again.');
    } else if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete notification');
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
      throw Exception('Token expired. Please login again.');
    } else if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to clear notifications');
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
      throw Exception('Token expired. Please login again.');
    } else if (response.statusCode != 200) {
      throw Exception('Failed to mark notification as seen');
    }
  }
}
