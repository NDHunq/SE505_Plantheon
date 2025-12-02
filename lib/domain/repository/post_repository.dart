import 'package:se501_plantheon/domain/entities/post_entity.dart';

abstract class PostRepository {
  Future<List<PostEntity>> getUserPosts(String userId);
  Future<void> likePost(String postId);
  Future<void> unlikePost(String postId);
  Future<PostEntity> getPostDetail(String postId);
  Future<void> createComment(String postId, String content);
  Future<void> createPost({
    required String content,
    required List<String> imageLink,
    required List<String> tags,
    String? diseaseLink,
  });
}
