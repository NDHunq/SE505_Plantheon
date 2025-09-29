import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:se501_plantheon/data/models/diseases.model.dart';

abstract class DiseaseRemoteDataSource {
  Future<DiseaseModel> getDisease(String diseaseId);
}

class DiseaseRemoteDataSourceImpl implements DiseaseRemoteDataSource {
  final http.Client client;
  final String baseUrl;

  DiseaseRemoteDataSourceImpl({required this.client, required this.baseUrl});

  @override
  Future<DiseaseModel> getDisease(String diseaseId) async {
    print('🌐 DataSource: Making API call to $baseUrl/diseases/$diseaseId');
    final response = await client.get(
      Uri.parse('$baseUrl/diseases/$diseaseId'),
      headers: {'Content-Type': 'application/json'},
    );

    print('📡 DataSource: Response status: ${response.statusCode}');
    print('📄 DataSource: Response body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      print('🔍 DataSource: Parsed JSON: $jsonData');
      final model = DiseaseModel.fromJson(jsonData);
      print('✅ DataSource: Created model: ${model.name}');
      return model;
    } else {
      print('❌ DataSource: API error: ${response.statusCode}');
      throw Exception('Failed to load disease: ${response.statusCode}');
    }
  }
}
