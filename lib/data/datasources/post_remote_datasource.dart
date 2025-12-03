import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:se501_plantheon/core/configs/constants/api_constants.dart';
import 'package:se501_plantheon/data/models/post_model.dart';

class PostRemoteDataSource {
  final http.Client client;

  PostRemoteDataSource({required this.client});

  Future<List<PostModel>> getUserPosts(String userId) async {
    final url =
        '${ApiConstants.baseUrl}/${ApiConstants.apiVersion}/posts/user/$userId';

    // Hardcoded token as requested by user
    final token =
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiNDg0OWZlZmMtZmRmMi00NDFmLWJiNWUtODMxOGQzOTA0Yjk0IiwiZW1haWwiOiJhZG1pcWV3ZTFuQHdtYWlsLmNvbSIsInJvbGUiOiJhZG1pbiIsImV4cCI6MTc2NDgxMDI2OX0.uKWgpplZKzEKgi6cRbC8ugAOYW6PERczbeldooto3aM';

    final response = await client.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final postResponse = PostResponseModel.fromJson(jsonResponse);
      return postResponse.posts;
    } else {
      throw Exception('Failed to load posts');
    }
  }

  Future<void> likePost(String postId) async {
    final url =
        '${ApiConstants.baseUrl}/${ApiConstants.apiVersion}/posts/$postId/like';
    final token =
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiNDg0OWZlZmMtZmRmMi00NDFmLWJiNWUtODMxOGQzOTA0Yjk0IiwiZW1haWwiOiJhZG1pcWV3ZTFuQHdtYWlsLmNvbSIsInJvbGUiOiJhZG1pbiIsImV4cCI6MTc2NDgxMDI2OX0.uKWgpplZKzEKgi6cRbC8ugAOYW6PERczbeldooto3aM';
    final response = await client.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to like post');
    }
  }

  Future<void> unlikePost(String postId) async {
    final url =
        '${ApiConstants.baseUrl}/${ApiConstants.apiVersion}/posts/$postId/unlike';
    final token =
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiNDg0OWZlZmMtZmRmMi00NDFmLWJiNWUtODMxOGQzOTA0Yjk0IiwiZW1haWwiOiJhZG1pcWV3ZTFuQHdtYWlsLmNvbSIsInJvbGUiOiJhZG1pbiIsImV4cCI6MTc2NDgxMDI2OX0.uKWgpplZKzEKgi6cRbC8ugAOYW6PERczbeldooto3aM';

    final response = await client.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to unlike post');
    }
  }

  Future<PostModel> getPostDetail(String postId) async {
    final url =
        '${ApiConstants.baseUrl}/${ApiConstants.apiVersion}/posts/$postId';
    final token =
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiNDg0OWZlZmMtZmRmMi00NDFmLWJiNWUtODMxOGQzOTA0Yjk0IiwiZW1haWwiOiJhZG1pcWV3ZTFuQHdtYWlsLmNvbSIsInJvbGUiOiJhZG1pbiIsImV4cCI6MTc2NDgxMDI2OX0.uKWgpplZKzEKgi6cRbC8ugAOYW6PERczbeldooto3aM';

    final response = await client.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return PostModel.fromJson(jsonResponse['data']);
    } else {
      throw Exception('Failed to load post detail');
    }
  }

  Future<void> createComment(String postId, String content) async {
    final url =
        '${ApiConstants.baseUrl}/${ApiConstants.apiVersion}/posts/$postId/comments';
    final token =
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiNDg0OWZlZmMtZmRmMi00NDFmLWJiNWUtODMxOGQzOTA0Yjk0IiwiZW1haWwiOiJhZG1pcWV3ZTFuQHdtYWlsLmNvbSIsInJvbGUiOiJhZG1pbiIsImV4cCI6MTc2NDgxMDI2OX0.uKWgpplZKzEKgi6cRbC8ugAOYW6PERczbeldooto3aM';
    final response = await client.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'content': content}),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create comment');
    }
  }

  Future<void> createPost({
    required String content,
    required List<String> imageLink,
    required List<String> tags,
    String? diseaseLink,
  }) async {
    final url = '${ApiConstants.baseUrl}/${ApiConstants.apiVersion}/posts';
    final token =
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiNDg0OWZlZmMtZmRmMi00NDFmLWJiNWUtODMxOGQzOTA0Yjk0IiwiZW1haWwiOiJhZG1pcWV3ZTFuQHdtYWlsLmNvbSIsInJvbGUiOiJhZG1pbiIsImV4cCI6MTc2NDgxMDI2OX0.uKWgpplZKzEKgi6cRbC8ugAOYW6PERczbeldooto3aM';

    final Map<String, dynamic> body = {
      'content': content,
      'image_link': imageLink,
      'tags': tags,
    };

    if (diseaseLink != null) {
      body['disease_link'] = diseaseLink;
    }

    final response = await client.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(body),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      print(
        'PostRemoteDataSource: Failed to create post. Status code: ${response.statusCode}',
      );
      print('PostRemoteDataSource: Response body: ${response.body}');
      throw Exception(
        'Failed to create post: ${response.statusCode} - ${response.body}',
      );
    }
  }
}
