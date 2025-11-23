import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:se501_plantheon/core/configs/constants/api_constants.dart';
import 'package:se501_plantheon/data/models/keyword_activity_model.dart';

abstract class KeywordActivitiesRemoteDataSource {
  Future<KeywordActivitiesResponseModel> getKeywordActivitiesByDiseaseId({
    required String diseaseId,
  });
}

class KeywordActivitiesRemoteDataSourceImpl
    implements KeywordActivitiesRemoteDataSource {
  final http.Client client;
  final String baseUrl;
  final String apiVersion;

  KeywordActivitiesRemoteDataSourceImpl({
    required this.client,
    String? baseUrl,
    String? apiVersion,
  }) : baseUrl = baseUrl ?? ApiConstants.baseUrl,
       apiVersion = apiVersion ?? ApiConstants.apiVersion;

  @override
  Future<KeywordActivitiesResponseModel> getKeywordActivitiesByDiseaseId({
    required String diseaseId,
  }) async {
    final url = Uri.parse(
      '$baseUrl/$apiVersion/activity-keywords/disease/$diseaseId',
    );

    print('[KeywordActivitiesRemote] GET $url');

    http.Response response;
    try {
      response = await client.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print('[KeywordActivitiesRemote][ERROR] Network error: $e');
      rethrow;
    }

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      print('[KeywordActivitiesRemote] 200 OK');
      return KeywordActivitiesResponseModel.fromJson(jsonData);
    } else {
      print(
        '[KeywordActivitiesRemote][ERROR] ${response.statusCode}: ${response.body}',
      );
      throw Exception(
        'Failed to load keyword activities: ${response.statusCode}',
      );
    }
  }
}
