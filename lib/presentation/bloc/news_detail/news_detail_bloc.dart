import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:se501_plantheon/domain/usecases/news/get_news_detail.dart';
import 'package:se501_plantheon/presentation/bloc/news_detail/news_detail_event.dart';
import 'package:se501_plantheon/presentation/bloc/news_detail/news_detail_state.dart';

class NewsDetailBloc extends Bloc<NewsDetailEvent, NewsDetailState> {
  final GetNewsDetail getNewsDetail;

  NewsDetailBloc({required this.getNewsDetail}) : super(NewsDetailInitial()) {
    on<FetchNewsDetailEvent>(_onFetchNewsDetail);
  }

  Future<void> _onFetchNewsDetail(
    FetchNewsDetailEvent event,
    Emitter<NewsDetailState> emit,
  ) async {
    emit(NewsDetailLoading());
    try {
      final news = await getNewsDetail(event.id);
      emit(NewsDetailLoaded(news: news));
    } catch (e) {
      emit(NewsDetailError(message: e.toString()));
    }
  }
}
