import 'package:se501_plantheon/domain/entities/news_entity.dart';
import 'package:se501_plantheon/domain/repository/news_repository.dart';

class GetNews {
  final NewsRepository repository;

  GetNews({required this.repository});

  Future<List<NewsEntity>> call({int? size}) {
    return repository.getNews(size: size);
  }
}
