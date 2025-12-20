import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:se501_plantheon/core/configs/constants/api_constants.dart';
import 'package:se501_plantheon/core/services/token_storage_service.dart';
import 'package:se501_plantheon/data/models/post_model.dart';
import 'package:se501_plantheon/data/models/user_profile_model.dart';

class PostRemoteDataSource {
  final http.Client client;
  final TokenStorageService tokenStorage;

  PostRemoteDataSource({required this.client, required this.tokenStorage});

  Future<List<PostModel>> getAllPosts({int page = 1, int limit = 10}) async {
    final url =
        '${ApiConstants.baseUrl}/${ApiConstants.apiVersion}/posts?page=$page&limit=$limit';

    print(
      'PostRemoteDataSource: Fetching all posts (page: $page, limit: $limit)',
    );
    print('PostRemoteDataSource: GET $url');

    final token = await tokenStorage.getToken();
    if (token == null) {
      throw Exception('User not authenticated');
    }

    final response = await client.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('PostRemoteDataSource: Response status: ${response.statusCode}');
    // print('PostRemoteDataSource: Response body: ${response.body}');

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final postResponse = PostResponseModel.fromJson(jsonResponse);
      print('PostRemoteDataSource: Loaded ${postResponse.posts.length} posts');
      return postResponse.posts;
    } else if (response.statusCode == 401) {
      throw Exception('Token expired. Please login again.');
    } else {
      throw Exception('Failed to load posts');
    }
  }

  Future<List<PostModel>> searchPosts({
    required String keyword,
    int page = 1,
    int limit = 5,
  }) async {
    final url =
        '${ApiConstants.baseUrl}/${ApiConstants.apiVersion}/posts/search?keyword=$keyword&page=$page&limit=$limit';

    print(
      'PostRemoteDataSource: Searching posts (keyword: $keyword, page: $page, limit: $limit)',
    );
    print('PostRemoteDataSource: GET $url');

    final token = await tokenStorage.getToken();
    if (token == null) {
      throw Exception('User not authenticated');
    }

    final response = await client.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('PostRemoteDataSource: Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final postResponse = PostResponseModel.fromJson(jsonResponse);
      print(
        'PostRemoteDataSource: Found ${postResponse.posts.length} posts for keyword "$keyword"',
      );
      return postResponse.posts;
    } else if (response.statusCode == 401) {
      throw Exception('Token expired. Please login again.');
    } else {
      throw Exception('Failed to search posts');
    }
  }

  Future<List<PostModel>> getMyPosts() async {
    final url = '${ApiConstants.baseUrl}/${ApiConstants.apiVersion}/posts/my';

    print('PostRemoteDataSource: Fetching my posts');
    print('PostRemoteDataSource: GET $url');

    final token = await tokenStorage.getToken();
    if (token == null) {
      throw Exception('User not authenticated');
    }

    final response = await client.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('PostRemoteDataSource: Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final postResponse = PostResponseModel.fromJson(jsonResponse);
      print(
        'PostRemoteDataSource: Loaded ${postResponse.posts.length} my posts',
      );
      return postResponse.posts;
    } else if (response.statusCode == 401) {
      throw Exception('Token expired. Please login again.');
    } else {
      throw Exception('Failed to load my posts');
    }
  }

  Future<void> likePost(String postId) async {
    final url =
        '${ApiConstants.baseUrl}/${ApiConstants.apiVersion}/posts/$postId/like';

    final token = await tokenStorage.getToken();
    if (token == null) throw Exception('User not authenticated');

    final response = await client.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 401) {
      throw Exception('Token expired. Please login again.');
    } else if (response.statusCode != 200) {
      throw Exception('Failed to like post');
    }
  }

  Future<void> unlikePost(String postId) async {
    final url =
        '${ApiConstants.baseUrl}/${ApiConstants.apiVersion}/posts/$postId/unlike';

    final token = await tokenStorage.getToken();
    if (token == null) throw Exception('User not authenticated');

    final response = await client.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 401) {
      throw Exception('Token expired. Please login again.');
    } else if (response.statusCode != 200) {
      throw Exception('Failed to unlike post');
    }
  }

  Future<void> deletePost(String postId) async {
    final url =
        '${ApiConstants.baseUrl}/${ApiConstants.apiVersion}/posts/$postId';

    print('PostRemoteDataSource: Deleting post $postId');

    final token = await tokenStorage.getToken();
    if (token == null) throw Exception('User not authenticated');

    final response = await client.delete(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print(
      'PostRemoteDataSource: Delete response status: ${response.statusCode}',
    );

    if (response.statusCode == 401) {
      throw Exception('Token expired. Please login again.');
    } else if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete post');
    }
    print('PostRemoteDataSource: Post deleted successfully');
  }

  Future<PostModel> getPostDetail(String postId) async {
    final url =
        '${ApiConstants.baseUrl}/${ApiConstants.apiVersion}/posts/$postId';

    final token = await tokenStorage.getToken();
    if (token == null) throw Exception('User not authenticated');

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
    } else if (response.statusCode == 401) {
      throw Exception('Token expired. Please login again.');
    } else {
      throw Exception('Failed to load post detail');
    }
  }

  Future<void> createComment(
    String postId,
    String content, {
    String? parentId,
  }) async {
    final url =
        '${ApiConstants.baseUrl}/${ApiConstants.apiVersion}/posts/$postId/comments';

    final token = await tokenStorage.getToken();
    if (token == null) throw Exception('User not authenticated');

    // Build request body
    final Map<String, dynamic> body = {'content': content};
    if (parentId != null && parentId.isNotEmpty) {
      body['parent_id'] = parentId;
    }

    final response = await client.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(body),
    );

    if (response.statusCode == 401) {
      throw Exception('Token expired. Please login again.');
    } else if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create comment');
    }
  }

  Future<void> likeComment(String commentId) async {
    final url =
        '${ApiConstants.baseUrl}/${ApiConstants.apiVersion}/posts/comments/$commentId/like';

    final token = await tokenStorage.getToken();
    if (token == null) throw Exception('User not authenticated');

    final response = await client.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 401) {
      throw Exception('Token expired. Please login again.');
    } else if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to like comment');
    }
  }

  Future<void> unlikeComment(String commentId) async {
    final url =
        '${ApiConstants.baseUrl}/${ApiConstants.apiVersion}/posts/comments/$commentId/unlike';

    final token = await tokenStorage.getToken();
    if (token == null) throw Exception('User not authenticated');

    final response = await client.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 401) {
      throw Exception('Token expired. Please login again.');
    } else if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to unlike comment');
    }
  }

  Future<void> createPost({
    required String content,
    required List<String> imageLink,
    required List<String> tags,
    String? diseaseLink,
    String? scanHistoryId,
  }) async {
    final url = '${ApiConstants.baseUrl}/${ApiConstants.apiVersion}/posts';

    final token = await tokenStorage.getToken();
    if (token == null) throw Exception('User not authenticated');

    final Map<String, dynamic> body = {
      'content': content,
      'image_link': imageLink,
      'tags': tags,
    };

    if (diseaseLink != null) {
      body['disease_link'] = diseaseLink;
    }

    if (scanHistoryId != null) {
      body['scan_history_id'] = scanHistoryId;
    }

    print('PostRemoteDataSource: Creating post with body: $body');
    print('PostRemoteDataSource: Token: ${token.substring(0, 20)}...');

    final response = await client.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(body),
    );

    if (response.statusCode == 401) {
      print('PostRemoteDataSource: 401 Response body: ${response.body}');
      throw Exception('Token expired. Please login again.');
    } else if (response.statusCode != 200 && response.statusCode != 201) {
      print(
        'PostRemoteDataSource: Failed to create post. Status code: ${response.statusCode}',
      );
      print('PostRemoteDataSource: Response body: ${response.body}');
      throw Exception(
        'Failed to create post: ${response.statusCode} - ${response.body}',
      );
    }
    print('PostRemoteDataSource: Post created successfully!');
  }

  Future<UserProfileResponseModel> getUserProfile(String userId) async {
    final url =
        '${ApiConstants.baseUrl}/${ApiConstants.apiVersion}/public/users/$userId';

    print('PostRemoteDataSource: Fetching user profile for $userId');
    print('PostRemoteDataSource: GET $url');

    final token = await tokenStorage.getToken();
    if (token == null) {
      throw Exception('User not authenticated');
    }

    final response = await client.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('PostRemoteDataSource: Response status code: ${response.statusCode}');

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return UserProfileResponseModel.fromJson(jsonData);
    } else if (response.statusCode == 401) {
      throw Exception('Token expired. Please login again.');
    } else {
      throw Exception('Failed to load user profile');
    }
  }
}
