import 'package:se501_plantheon/domain/entities/news_entity.dart';

abstract class NewsDetailState {}

class NewsDetailInitial extends NewsDetailState {}

class NewsDetailLoading extends NewsDetailState {}

class NewsDetailLoaded extends NewsDetailState {
  final NewsEntity news;

  NewsDetailLoaded({required this.news});
}

class NewsDetailError extends NewsDetailState {
  final String message;

  NewsDetailError({required this.message});
}
