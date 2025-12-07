import 'package:se501_plantheon/domain/entities/news_tag_entity.dart';

abstract class NewsTagState {}

class NewsTagInitial extends NewsTagState {}

class NewsTagLoading extends NewsTagState {}

class NewsTagLoaded extends NewsTagState {
  final List<NewsTagEntity> tags;

  NewsTagLoaded({required this.tags});
}

class NewsTagError extends NewsTagState {
  final String message;

  NewsTagError({required this.message});
}
