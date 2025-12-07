import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:se501_plantheon/domain/usecases/news/get_news.dart';
import 'package:se501_plantheon/presentation/bloc/news/news_event.dart';
import 'package:se501_plantheon/presentation/bloc/news/news_state.dart';

class NewsBloc extends Bloc<NewsEvent, NewsState> {
  final GetNews getNews;

  NewsBloc({required this.getNews}) : super(NewsInitial()) {
    on<FetchNewsEvent>(_onFetchNews);
  }

  Future<void> _onFetchNews(
    FetchNewsEvent event,
    Emitter<NewsState> emit,
  ) async {
    emit(NewsLoading());
    try {
      final news = await getNews(size: event.size);
      emit(NewsLoaded(news: news));
    } catch (e) {
      emit(NewsError(message: e.toString()));
    }
  }
}
