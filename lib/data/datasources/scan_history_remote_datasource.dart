import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:se501_plantheon/data/models/scan_history.model.dart';

abstract class ScanHistoryRemoteDataSource {
  Future<List<ScanHistoryModel>> getAllScanHistory();
  Future<ScanHistoryModel> createScanHistory(
    String diseaseId, {
    String? scanImage,
  });
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
            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiNzViMmVkOTEtNzY5Ni00NzI4LTk4NTQtZGU4NmRkOGNjZTUzIiwiZW1haWwiOiJhZG1pbkBnbWFpbC5jb20iLCJyb2xlIjoiYWRtaW4iLCJleHAiOjE3NjQ5Mzk4NzB9.n-ndIUXMXX9_qzT3WWs5u0e84pp4UCBeST9aiDqelRY',
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
  Future<ScanHistoryModel> createScanHistory(
    String diseaseId, {
    String? scanImage,
  }) async {
    print(
      '🌐 DataSource: Making POST API call to $baseUrl/$apiVersion/scan-history',
    );
    print(
      '📝 DataSource: Request body: {"disease_id": "$diseaseId", "scan_image": "$scanImage"}',
    );

    final response = await client.post(
      Uri.parse('$baseUrl/$apiVersion/scan-history'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiNzViMmVkOTEtNzY5Ni00NzI4LTk4NTQtZGU4NmRkOGNjZTUzIiwiZW1haWwiOiJhZG1pbkBnbWFpbC5jb20iLCJyb2xlIjoiYWRtaW4iLCJleHAiOjE3NjQ5Mzk4NzB9.n-ndIUXMXX9_qzT3WWs5u0e84pp4UCBeST9aiDqelRY',
      },
      body: json.encode(
        CreateScanHistoryRequestModel(
          diseaseId: diseaseId,
          scanImage: scanImage,
        ).toJson(),
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
