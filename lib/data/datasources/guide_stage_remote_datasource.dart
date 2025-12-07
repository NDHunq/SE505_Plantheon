import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:se501_plantheon/core/configs/constants/api_constants.dart';
import 'package:se501_plantheon/data/models/guide_stage_model.dart';

abstract class GuideStageRemoteDataSource {
  Future<List<GuideStageModel>> getGuideStagesByPlant(String plantId);
  Future<GuideStageDetailModel> getGuideStageDetail(String guideStageId);
}

class GuideStageRemoteDataSourceImpl implements GuideStageRemoteDataSource {
  final http.Client client;
  final String baseUrl;
  final String apiVersion;

  GuideStageRemoteDataSourceImpl({
    required this.client,
    String? baseUrl,
    String? apiVersion,
  }) : baseUrl = baseUrl ?? ApiConstants.baseUrl,
       apiVersion = apiVersion ?? ApiConstants.apiVersion;

  @override
  Future<List<GuideStageModel>> getGuideStagesByPlant(String plantId) async {
    final url = Uri.parse('$baseUrl/$apiVersion/guide-stages/plant/$plantId');
    print('🌐 GuideStageRemoteDataSource: GET $url');

    try {
      final response = await client.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );
      print(
        '📡 GuideStageRemoteDataSource: '
        'status=${response.statusCode}, body=${response.body}',
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final responseModel = GetGuideStagesResponseModel.fromJson(jsonData);
        print(
          '✅ GuideStageRemoteDataSource: fetched '
          '${responseModel.guideStages.length} guide stages',
        );
        return responseModel.guideStages;
      }

      throw Exception('Failed to fetch guide stages: ${response.statusCode}');
    } catch (e) {
      print('❌ GuideStageRemoteDataSource: error $e');
      throw Exception('Failed to fetch guide stages: $e');
    }
  }

  @override
  Future<GuideStageDetailModel> getGuideStageDetail(String guideStageId) async {
    final url = Uri.parse('$baseUrl/$apiVersion/guide-stages/$guideStageId');
    print('🌐 GuideStageRemoteDataSource: GET $url');

    try {
      final response = await client.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );
      print(
        '📡 GuideStageRemoteDataSource (detail): '
        'status=${response.statusCode}, body=${response.body}',
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final model = GuideStageDetailModel.fromJson(jsonData);
        print(
          '✅ GuideStageRemoteDataSource: fetched detail with '
          '${model.subGuideStages.length} sub stages',
        );
        return model;
      }

      throw Exception(
        'Failed to fetch guide stage detail: ${response.statusCode}',
      );
    } catch (e) {
      print('❌ GuideStageRemoteDataSource (detail): error $e');
      throw Exception('Failed to fetch guide stage detail: $e');
    }
  }
}
