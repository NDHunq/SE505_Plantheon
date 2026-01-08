import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:se501_plantheon/data/models/diseases.model.dart';
import 'package:se501_plantheon/data/models/diseases_list_model.dart';

abstract class DiseaseRemoteDataSource {
  Future<DiseaseModel> getDisease(String diseaseId);
  Future<DiseasesListModel> getAllDiseases({String? search});
}

class DiseaseRemoteDataSourceImpl implements DiseaseRemoteDataSource {
  final http.Client client;
  final String baseUrl;

  DiseaseRemoteDataSourceImpl({required this.client, required this.baseUrl});

  @override
  Future<DiseaseModel> getDisease(String diseaseId) async {
    print('🌐 DataSource: Making API call to $baseUrl/diseases/$diseaseId');
    try {
      final response = await client
          .get(
            Uri.parse('$baseUrl/diseases/$diseaseId'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      print('📡 DataSource: Response status: ${response.statusCode}');
      print('📄 DataSource: Response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> jsonData = json.decode(response.body);
          print('🔍 DataSource: Parsed JSON: $jsonData');
          final model = DiseaseModel.fromJson(jsonData);
          print('✅ DataSource: Created model: ${model.name}');
          return model;
        } catch (e) {
          print('❌ DataSource: Parsing error: $e');
          throw Exception('Không thể đọc dữ liệu bệnh');
        }
      } else {
        print('❌ DataSource: API error: ${response.statusCode}');
        try {
          final errorBody = json.decode(response.body);
          final errorMessage =
              errorBody['error'] ?? 'Không thể tải thông tin bệnh';
          throw Exception(errorMessage);
        } catch (e) {
          throw Exception('Không thể tải thông tin bệnh');
        }
      }
    } on TimeoutException catch (_) {
      print('❌ DataSource: Connection timed out');
      throw Exception('Kết nối hết thời gian. Vui lòng kiểm tra internet');
    } catch (e) {
      print('❌ DataSource: General error: $e');
      throw Exception('Không thể tải thông tin bệnh');
    }
  }

  @override
  Future<DiseasesListModel> getAllDiseases({String? search}) async {
    final uri = search != null && search.isNotEmpty
        ? Uri.parse('$baseUrl/diseases/all').replace(
            queryParameters: {'search': search},
          )
        : Uri.parse('$baseUrl/diseases/all');

    print('🌐 DataSource: Making API call to $uri');
    
    try {
      final response = await client
          .get(
            uri,
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      print('📡 DataSource: Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> jsonData = json.decode(response.body);
          final model = DiseasesListModel.fromJson(jsonData);
          print('✅ DataSource: Loaded ${model.count} diseases');
          return model;
        } catch (e) {
          print('❌ DataSource: Parsing error: $e');
          throw Exception('Không thể đọc danh sách bệnh');
        }
      } else {
        print('❌ DataSource: API error: ${response.statusCode}');
        throw Exception('Không thể tải danh sách bệnh');
      }
    } on TimeoutException catch (_) {
      print('❌ DataSource: Connection timed out');
      throw Exception('Kết nối hết thời gian. Vui lòng kiểm tra internet');
    } catch (e) {
      print('❌ DataSource: General error: $e');
      throw Exception('Không thể tải danh sách bệnh');
    }
  }
}
