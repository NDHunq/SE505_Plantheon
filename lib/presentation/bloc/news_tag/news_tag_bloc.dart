import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:se501_plantheon/domain/usecases/news/get_news_tags.dart';
import 'package:se501_plantheon/presentation/bloc/news_tag/news_tag_event.dart';
import 'package:se501_plantheon/presentation/bloc/news_tag/news_tag_state.dart';

class NewsTagBloc extends Bloc<NewsTagEvent, NewsTagState> {
  final GetNewsTags getNewsTags;

  NewsTagBloc({required this.getNewsTags}) : super(NewsTagInitial()) {
    on<FetchNewsTagsEvent>(_onFetchNewsTags);
  }

  Future<void> _onFetchNewsTags(
    FetchNewsTagsEvent event,
    Emitter<NewsTagState> emit,
  ) async {
    emit(NewsTagLoading());
    try {
      final tags = await getNewsTags();
      emit(NewsTagLoaded(tags: tags));
    } catch (e) {
      emit(NewsTagError(message: e.toString()));
    }
  }
}
