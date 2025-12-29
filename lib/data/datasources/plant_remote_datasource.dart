import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:se501_plantheon/core/configs/constants/api_constants.dart';
import 'package:se501_plantheon/data/models/plant_model.dart';

abstract class PlantRemoteDataSource {
  Future<List<PlantModel>> getPlants();
}

class PlantRemoteDataSourceImpl implements PlantRemoteDataSource {
  final http.Client client;
  final String baseUrl;
  final String apiVersion;

  PlantRemoteDataSourceImpl({
    required this.client,
    String? baseUrl,
    String? apiVersion,
  }) : baseUrl = baseUrl ?? ApiConstants.baseUrl,
       apiVersion = apiVersion ?? ApiConstants.apiVersion;

  @override
  Future<List<PlantModel>> getPlants() async {
    final url = Uri.parse('$baseUrl/$apiVersion/plants');
    print('🌐 PlantRemoteDataSource: GET $url');

    try {
      final response = await client.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );
      print(
        '📡 PlantRemoteDataSource: status=${response.statusCode}, body=${response.body}',
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final responseModel = GetPlantsResponseModel.fromJson(jsonData);
        print(
          '✅ PlantRemoteDataSource: fetched ${responseModel.plants.length} plants',
        );
        return responseModel.plants;
      }

      try {
        final errorBody = json.decode(response.body);
        final errorMessage =
            errorBody['error'] ?? 'Không thể tải danh sách cây trồng';
        throw Exception(errorMessage);
      } catch (e) {
        throw Exception('Không thể tải danh sách cây trồng');
      }
    } catch (e) {
      print('❌ PlantRemoteDataSource: error $e');
      throw Exception('Không thể tải danh sách cây trồng');
    }
  }
}
