import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:se501_plantheon/core/configs/constants/api_constants.dart';
import 'package:se501_plantheon/core/services/token_storage_service.dart';
import 'package:se501_plantheon/data/models/news_model.dart';
import 'package:se501_plantheon/data/models/news_tag_model.dart';

abstract class NewsRemoteDataSource {
  Future<List<NewsModel>> getNews({int? size});
  Future<List<NewsTagModel>> getNewsTags();
  Future<NewsModel> getNewsDetail(String id);
}

class NewsRemoteDataSourceImpl implements NewsRemoteDataSource {
  final http.Client client;
  final String baseUrl;
  final String apiVersion;
  final TokenStorageService tokenStorage;

  NewsRemoteDataSourceImpl({
    required this.client,
    required this.tokenStorage,
    String? baseUrl,
    String? apiVersion,
  }) : baseUrl = baseUrl ?? ApiConstants.baseUrl,
       apiVersion = apiVersion ?? ApiConstants.apiVersion;

  @override
  Future<List<NewsModel>> getNews({int? size}) async {
    final uri = Uri.parse(
      '$baseUrl/$apiVersion/news',
    ).replace(queryParameters: size != null ? {'size': size.toString()} : null);
    try {
      final token = await tokenStorage.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('User not authenticated');
      }

      final response = await client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print(
        '📡 News RemoteDataSource: Received response with status code ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final responseModel = NewsResponseModel.fromJson(jsonData);
        return responseModel.news;
      }

      try {
        final errorBody = json.decode(response.body);
        final errorMessage = errorBody['error'] ?? 'Không thể tải tin tức';
        throw Exception(errorMessage);
      } catch (e) {
        throw Exception('Không thể tải tin tức');
      }
    } catch (e) {
      throw Exception('Không thể tải tin tức');
    }
  }

  @override
  Future<List<NewsTagModel>> getNewsTags() async {
    final uri = Uri.parse('$baseUrl/$apiVersion/news-tags');
    try {
      final token = await tokenStorage.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('User not authenticated');
      }

      final response = await client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final responseModel = NewsTagResponseModel.fromJson(jsonData);
        return responseModel.tags;
      }

      try {
        final errorBody = json.decode(response.body);
        final errorMessage = errorBody['error'] ?? 'Không thể tải thẻ tin tức';
        throw Exception(errorMessage);
      } catch (e) {
        throw Exception('Không thể tải thẻ tin tức');
      }
    } catch (e) {
      throw Exception('Không thể tải thẻ tin tức');
    }
  }

  @override
  Future<NewsModel> getNewsDetail(String id) async {
    final uri = Uri.parse('$baseUrl/$apiVersion/news/$id');
    try {
      final token = await tokenStorage.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('User not authenticated');
      }

      final response = await client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final data = jsonData['data'] as Map<String, dynamic>? ?? {};
        return NewsModel.fromJson(data);
      }

      try {
        final errorBody = json.decode(response.body);
        final errorMessage =
            errorBody['error'] ?? 'Không thể tải chi tiết tin tức';
        throw Exception(errorMessage);
      } catch (e) {
        throw Exception('Không thể tải chi tiết tin tức');
      }
    } catch (e) {
      throw Exception('Không thể tải chi tiết tin tức');
    }
  }
}
