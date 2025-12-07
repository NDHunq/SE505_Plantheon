import 'package:se501_plantheon/domain/entities/news_tag_entity.dart';
import 'package:se501_plantheon/domain/repository/news_repository.dart';

class GetNewsTags {
  final NewsRepository repository;

  GetNewsTags({required this.repository});

  Future<List<NewsTagEntity>> call() {
    return repository.getNewsTags();
  }
}
