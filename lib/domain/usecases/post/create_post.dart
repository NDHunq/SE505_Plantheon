import 'package:se501_plantheon/domain/repository/post_repository.dart';

class CreatePost {
  final PostRepository repository;

  CreatePost(this.repository);

  Future<void> call({
    required String content,
    required List<String> imageLink,
    required List<String> tags,
    String? diseaseLink,
  }) async {
    return await repository.createPost(
      content: content,
      imageLink: imageLink,
      tags: tags,
      diseaseLink: diseaseLink,
    );
  }
}
