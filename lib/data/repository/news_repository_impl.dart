import 'package:se501_plantheon/data/datasources/news_remote_datasource.dart';
import 'package:se501_plantheon/domain/entities/news_entity.dart';
import 'package:se501_plantheon/domain/entities/news_tag_entity.dart';
import 'package:se501_plantheon/domain/repository/news_repository.dart';

class NewsRepositoryImpl implements NewsRepository {
  final NewsRemoteDataSource remoteDataSource;

  NewsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<NewsEntity>> getNews({int? size}) async {
    final newsModels = await remoteDataSource.getNews(size: size);
    return newsModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<NewsTagEntity>> getNewsTags() async {
    final tagModels = await remoteDataSource.getNewsTags();
    return tagModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<NewsEntity> getNewsDetail(String id) async {
    final model = await remoteDataSource.getNewsDetail(id);
    return model.toEntity();
  }
}
