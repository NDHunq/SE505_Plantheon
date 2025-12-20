import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:se501_plantheon/domain/usecases/keyword_activity/get_keyword_activities.dart';
import 'package:se501_plantheon/presentation/bloc/keyword_activities/keyword_activities_event.dart';
import 'package:se501_plantheon/presentation/bloc/keyword_activities/keyword_activities_state.dart';

class KeywordActivitiesBloc
    extends Bloc<KeywordActivitiesEvent, KeywordActivitiesState> {
  final GetKeywordActivities getKeywordActivities;

  KeywordActivitiesBloc({required this.getKeywordActivities})
    : super(KeywordActivitiesInitial()) {
    on<FetchKeywordActivities>(_onFetchKeywordActivities);
  }

  Future<void> _onFetchKeywordActivities(
    FetchKeywordActivities event,
    Emitter<KeywordActivitiesState> emit,
  ) async {
    emit(KeywordActivitiesLoading());
    try {
      print(
        '[KeywordActivitiesBloc] Fetching activities for disease: ${event.diseaseId}',
      );
      final activities = await getKeywordActivities(diseaseId: event.diseaseId);
      print('[KeywordActivitiesBloc] Loaded ${activities.length} activities');
      emit(KeywordActivitiesLoaded(activities: activities));
    } catch (e) {
      print('[KeywordActivitiesBloc] Error: $e');
      emit(KeywordActivitiesError(message: e.toString()));
    }
  }
}