import 'package:se501_plantheon/data/datasources/post_remote_datasource.dart';
import 'package:se501_plantheon/domain/entities/post_entity.dart';
import 'package:se501_plantheon/domain/repository/post_repository.dart';

class PostRepositoryImpl implements PostRepository {
  final PostRemoteDataSource remoteDataSource;

  PostRepositoryImpl({required this.remoteDataSource});

  @override
  @override
  Future<List<PostEntity>> getAllPosts({int page = 1, int limit = 10}) async {
    final postModels = await remoteDataSource.getAllPosts(
      page: page,
      limit: limit,
    );
    return postModels.map((e) => e.toEntity()).toList();
  }

  @override
  Future<List<PostEntity>> searchPosts({
    required String keyword,
    int page = 1,
    int limit = 10,
  }) async {
    final postModels = await remoteDataSource.searchPosts(
      keyword: keyword,
      page: page,
      limit: limit,
    );
    return postModels.map((e) => e.toEntity()).toList();
  }

  @override
  Future<List<PostEntity>> getMyPosts() async {
    final postModels = await remoteDataSource.getMyPosts();
    return postModels.map((e) => e.toEntity()).toList();
  }

  @override
  Future<void> likePost(String postId) async {
    await remoteDataSource.likePost(postId);
  }

  @override
  Future<void> unlikePost(String postId) async {
    await remoteDataSource.unlikePost(postId);
  }

  @override
  Future<void> deletePost(String postId) async {
    await remoteDataSource.deletePost(postId);
  }

  @override
  Future<PostEntity> getPostDetail(String postId) async {
    final postModel = await remoteDataSource.getPostDetail(postId);
    return postModel.toEntity();
  }

  @override
  Future<void> createComment(
    String postId,
    String content, {
    String? parentId,
  }) async {
    await remoteDataSource.createComment(postId, content, parentId: parentId);
  }

  @override
  Future<void> likeComment(String commentId) async {
    await remoteDataSource.likeComment(commentId);
  }

  @override
  Future<void> unlikeComment(String commentId) async {
    await remoteDataSource.unlikeComment(commentId);
  }

  @override
  Future<void> createPost({
    required String content,
    required List<String> imageLink,
    required List<String> tags,
    String? diseaseLink,
    String? scanHistoryId,
  }) async {
    await remoteDataSource.createPost(
      content: content,
      imageLink: imageLink,
      tags: tags,
      diseaseLink: diseaseLink,
      scanHistoryId: scanHistoryId,
    );
  }
}
