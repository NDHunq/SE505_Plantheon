import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:se501_plantheon/data/models/scan_history.model.dart';

abstract class ScanHistoryRemoteDataSource {
  Future<List<ScanHistoryModel>> getAllScanHistory();
  Future<ScanHistoryModel> createScanHistory(String diseaseId);
}

class ScanHistoryRemoteDataSourceImpl implements ScanHistoryRemoteDataSource {
  final http.Client client;
  final String baseUrl;
  final String apiVersion;

  ScanHistoryRemoteDataSourceImpl({
    required this.client,
    required this.baseUrl,
    this.apiVersion = 'api/v1',
  });

  @override
  Future<List<ScanHistoryModel>> getAllScanHistory() async {
    print(
      '🌐 DataSource: Making API call to $baseUrl/$apiVersion/scan-history',
    );
    final response = await client.get(
      Uri.parse('$baseUrl/$apiVersion/scan-history'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiNDg0OWZlZmMtZmRmMi00NDFmLWJiNWUtODMxOGQzOTA0Yjk0IiwiZW1haWwiOiJhZG1pcWV3ZTFuQHdtYWlsLmNvbSIsInJvbGUiOiJhZG1pbiIsImV4cCI6MTc1ODQzNjg4MH0.AXf8UyN6ODcYV68n3XBP3EnD-8WzSDqzklsUnYqBfwE',
      },
    );

    print('📡 DataSource: Response status: ${response.statusCode}');
    print('📄 DataSource: Response body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      print('🔍 DataSource: Parsed JSON');

      final responseModel = GetAllScanHistoryResponseModel.fromJson(jsonData);
      print(
        '✅ DataSource: Created model with ${responseModel.scanHistories.length} items',
      );
      return responseModel.scanHistories;
    } else {
      print('❌ DataSource: API error: ${response.statusCode}');
      throw Exception('Failed to load scan history: ${response.statusCode}');
    }
  }

  @override
  Future<ScanHistoryModel> createScanHistory(String diseaseId) async {
    print(
      '🌐 DataSource: Making POST API call to $baseUrl/$apiVersion/scan-history',
    );
    print('📝 DataSource: Request body: {"disease_id": "$diseaseId"}');

    final response = await client.post(
      Uri.parse('$baseUrl/$apiVersion/scan-history'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiNzViMmVkOTEtNzY5Ni00NzI4LTk4NTQtZGU4NmRkOGNjZTUzIiwiZW1haWwiOiJhZG1pbkBnbWFpbC5jb20iLCJyb2xlIjoiYWRtaW4iLCJleHAiOjE3NjQ4NjUwMjZ9.6DuFHmrO3XXXQeVTgGP0PTy7A3IvYjWa9Zk7-fBKYHc',
      },
      body: json.encode(
        CreateScanHistoryRequestModel(diseaseId: diseaseId).toJson(),
      ),
    );

    print('📡 DataSource: Response status: ${response.statusCode}');
    print('📄 DataSource: Response body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      print('🔍 DataSource: Parsed JSON');

      final responseModel = CreateScanHistoryResponseModel.fromJson(jsonData);
      print(
        '✅ DataSource: Created scan history with id: ${responseModel.scanHistory.id}',
      );
      return responseModel.scanHistory;
    } else {
      print('❌ DataSource: API error: ${response.statusCode}');
      throw Exception('Failed to create scan history: ${response.statusCode}');
    }
  }
}
