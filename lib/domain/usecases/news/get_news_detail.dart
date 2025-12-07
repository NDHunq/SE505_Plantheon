import 'package:se501_plantheon/domain/entities/news_entity.dart';
import 'package:se501_plantheon/domain/repository/news_repository.dart';

class GetNewsDetail {
  final NewsRepository repository;

  GetNewsDetail({required this.repository});

  Future<NewsEntity> call(String id) {
    return repository.getNewsDetail(id);
  }
}
