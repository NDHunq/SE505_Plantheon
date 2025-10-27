import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:se501_plantheon/data/models/scan_history.model.dart';

abstract class ScanHistoryRemoteDataSource {
  Future<List<ScanHistoryModel>> getAllScanHistory();
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
            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiNzViMmVkOTEtNzY5Ni00NzI4LTk4NTQtZGU4NmRkOGNjZTUzIiwiZW1haWwiOiJhZG1pbkBnbWFpbC5jb20iLCJyb2xlIjoiYWRtaW4iLCJleHAiOjE3NjE2NjYxMDF9.fv7OF7RHZ9XIryudhmwegp9KXWksZJloDmTFkj8RiC8',
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
}
