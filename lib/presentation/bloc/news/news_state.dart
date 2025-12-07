import 'package:se501_plantheon/domain/entities/news_entity.dart';

abstract class NewsState {}

class NewsInitial extends NewsState {}

class NewsLoading extends NewsState {}

class NewsLoaded extends NewsState {
  final List<NewsEntity> news;

  NewsLoaded({required this.news});
}

class NewsError extends NewsState {
  final String message;

  NewsError({required this.message});
}
