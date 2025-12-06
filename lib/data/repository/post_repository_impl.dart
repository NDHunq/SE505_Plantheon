import 'package:se501_plantheon/data/datasources/post_remote_datasource.dart';
import 'package:se501_plantheon/domain/entities/post_entity.dart';
import 'package:se501_plantheon/domain/repository/post_repository.dart';

class PostRepositoryImpl implements PostRepository {
  final PostRemoteDataSource remoteDataSource;

  PostRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<PostEntity>> getUserPosts(String userId) async {
    final postModels = await remoteDataSource.getUserPosts(userId);
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
  Future<PostEntity> getPostDetail(String postId) async {
    final postModel = await remoteDataSource.getPostDetail(postId);
    return postModel.toEntity();
  }

  @override
  Future<void> createComment(String postId, String content) async {
    await remoteDataSource.createComment(postId, content);
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
