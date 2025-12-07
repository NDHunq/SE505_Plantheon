import 'package:se501_plantheon/domain/entities/post_entity.dart';

abstract class PostRepository {
  Future<List<PostEntity>> getAllPosts();
  Future<List<PostEntity>> getMyPosts();
  Future<void> likePost(String postId);
  Future<void> unlikePost(String postId);
  Future<void> deletePost(String postId);
  Future<PostEntity> getPostDetail(String postId);
  Future<void> createComment(String postId, String content, {String? parentId});
  Future<void> likeComment(String commentId);
  Future<void> unlikeComment(String commentId);
  Future<void> createPost({
    required String content,
    required List<String> imageLink,
    required List<String> tags,
    String? diseaseLink,
    String? scanHistoryId,
  });
}
