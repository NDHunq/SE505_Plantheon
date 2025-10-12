import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:se501_plantheon/core/configs/constants/api_constants.dart';
import 'package:se501_plantheon/data/models/activities_models.dart';

abstract class ActivitiesRemoteDataSource {
  Future<MonthActivitiesModel> getActivitiesByMonth({
    required int year,
    required int month,
  });

  Future<DayActivitiesOfDayModel> getActivitiesByDay({
    required String dateIso, // format: YYYY-MM-DD
  });

  Future<CreateActivityResponseModel> createActivity({
    required CreateActivityRequestModel request,
  });

  Future<CreateActivityResponseModel> updateActivity({
    required String id,
    required CreateActivityRequestModel request,
  });
}

class ActivitiesRemoteDataSourceImpl implements ActivitiesRemoteDataSource {
  final http.Client client;
  final String baseUrl;
  final String apiVersion;

  ActivitiesRemoteDataSourceImpl({
    required this.client,
    String? baseUrl,
    String? apiVersion,
  }) : baseUrl = baseUrl ?? ApiConstants.baseUrl,
       apiVersion = apiVersion ?? ApiConstants.apiVersion;

  @override
  Future<MonthActivitiesModel> getActivitiesByMonth({
    required int year,
    required int month,
  }) async {
    final base = '$baseUrl/$apiVersion/activities/get-activites-by-month';
    final url = Uri.parse(base).replace(
      queryParameters: {'year': year.toString(), 'month': month.toString()},
    );
    print('[ActivitiesRemote] GET $url');
    http.Response response;
    try {
      response = await client.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print('[ActivitiesRemote][ERROR] Network error on $url: $e');
      rethrow;
    }

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      print(
        '[ActivitiesRemote] 200 OK (month), body length=${response.body.length}',
      );
      return MonthActivitiesModel.fromJson(jsonData);
    }
    print(
      '[ActivitiesRemote][ERROR] Month request failed: ${response.statusCode}, body=${response.body}',
    );
    throw Exception('Failed to fetch activities: ${response.statusCode}');
  }

  @override
  Future<DayActivitiesOfDayModel> getActivitiesByDay({
    required String dateIso,
  }) async {
    final base = '$baseUrl/$apiVersion/activities/by-day';
    final url = Uri.parse(base).replace(queryParameters: {'date': dateIso});
    print('[ActivitiesRemote] GET $url');
    http.Response response;
    try {
      response = await client.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print('[ActivitiesRemote][ERROR] Network error on $url: $e');
      rethrow;
    }

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      print(
        '[ActivitiesRemote] 200 OK (day), body length=${response.body.length}',
      );
      return DayActivitiesOfDayModel.fromJson(jsonData);
    } else {
      print(
        '[ActivitiesRemote][ERROR] Day request failed: ${response.statusCode}, body=${response.body}',
      );
      throw Exception('Failed to fetch day activities: ${response.statusCode}');
    }
  }

  @override
  Future<CreateActivityResponseModel> createActivity({
    required CreateActivityRequestModel request,
  }) async {
    final url = Uri.parse('$baseUrl/$apiVersion/activities');
    print('[ActivitiesRemote] POST $url');
    print('[ActivitiesRemote] Request body: ${json.encode(request.toJson())}');

    http.Response response;
    try {
      response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(request.toJson()),
      );
    } catch (e) {
      print('[ActivitiesRemote][ERROR] Network error on $url: $e');
      rethrow;
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      print(
        '[ActivitiesRemote] ${response.statusCode} OK (create), body length=${response.body.length}',
      );
      return CreateActivityResponseModel.fromJson(jsonData);
    } else {
      print(
        '[ActivitiesRemote][ERROR] Create activity failed: ${response.statusCode}, body=${response.body}',
      );
      throw Exception('Failed to create activity: ${response.statusCode}');
    }
  }

  @override
  Future<CreateActivityResponseModel> updateActivity({
    required String id,
    required CreateActivityRequestModel request,
  }) async {
    final url = Uri.parse('$baseUrl/$apiVersion/activities/$id');
    print('[ActivitiesRemote] PUT $url');
    print('[ActivitiesRemote] Request body: ${json.encode(request.toJson())}');

    http.Response response;
    try {
      response = await client.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(request.toJson()),
      );
    } catch (e) {
      print('[ActivitiesRemote][ERROR] Network error on $url: $e');
      rethrow;
    }

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      print(
        '[ActivitiesRemote] ${response.statusCode} OK (update), body length=${response.body.length}',
      );
      return CreateActivityResponseModel.fromJson(jsonData);
    } else {
      print(
        '[ActivitiesRemote][ERROR] Update activity failed: ${response.statusCode}, body=${response.body}',
      );
      throw Exception('Failed to update activity: ${response.statusCode}');
    }
  }
}
