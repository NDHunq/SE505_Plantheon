import 'package:se501_plantheon/domain/entities/news_entity.dart';

import 'package:se501_plantheon/domain/entities/news_tag_entity.dart';

abstract class NewsRepository {
  Future<List<NewsEntity>> getNews({int? size});
  Future<List<NewsTagEntity>> getNewsTags();
  Future<NewsEntity> getNewsDetail(String id);
}
