import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:se501_plantheon/data/models/activities_models.dart';
import 'package:se501_plantheon/domain/usecases/activity/get_activities_by_month.dart';
import 'package:se501_plantheon/domain/usecases/activity/get_activities_by_day.dart';
import 'package:se501_plantheon/domain/usecases/activity/create_activity.dart';
import 'package:se501_plantheon/domain/usecases/activity/update_activity.dart';
import 'package:se501_plantheon/domain/usecases/activity/delete_activity.dart';
import 'package:se501_plantheon/presentation/bloc/activities/activities_event.dart';
import 'package:se501_plantheon/presentation/bloc/activities/activities_state.dart';

class ActivitiesBloc extends Bloc<ActivitiesEvent, ActivitiesState> {
  final GetActivitiesByMonth getActivitiesByMonth;
  final GetActivitiesByDay getActivitiesByDay;
  final CreateActivity createActivity;
  final UpdateActivity updateActivity;
  final DeleteActivity deleteActivity;

  ActivitiesBloc({
    required this.getActivitiesByMonth,
    required this.getActivitiesByDay,
    required this.createActivity,
    required this.updateActivity,
    required this.deleteActivity,
  }) : super(ActivitiesInitial()) {
    on<FetchActivitiesByMonth>(_onFetchMonth);
    on<FetchActivitiesByDay>(_onFetchDay);
    on<CreateActivityEvent>(_onCreateActivity);
    on<UpdateActivityEvent>(_onUpdateActivity);
    on<DeleteActivityEvent>(_onDeleteActivity);
  }

  Future<void> _onFetchMonth(
    FetchActivitiesByMonth event,
    Emitter<ActivitiesState> emit,
  ) async {
    emit(ActivitiesLoading());
    try {
      print(
        '[ActivitiesBloc] Fetching month activities: year=${event.year}, month=${event.month}',
      );
      final entity = await getActivitiesByMonth(
        year: event.year,
        month: event.month,
      );
      print(
        '[ActivitiesBloc] Month entity: count=${entity.count}, days=${entity.days.length}',
      );
      if (entity.days.isNotEmpty) {
        final first = entity.days.first;
        print(
          '[ActivitiesBloc] First day: date=${first.date.toIso8601String()}, activities=${first.activities.length}',
        );
      }
      // map entity to model for UI reuse
      final model = MonthActivitiesModel(
        year: entity.year,
        month: entity.month,
        count: entity.count,
        days: entity.days
            .map(
              (d) => DayActivitiesModel(
                date: d.date,
                activities: d.activities
                    .map((a) => ActivityModel(title: a.title))
                    .toList(),
              ),
            )
            .toList(),
      );
      emit(ActivitiesLoaded(data: model));
    } catch (e) {
      emit(ActivitiesError(message: e.toString()));
    }
  }

  Future<void> _onFetchDay(
    FetchActivitiesByDay event,
    Emitter<ActivitiesState> emit,
  ) async {
    if (event.showLoading) {
      emit(DayActivitiesLoading());
    }
    try {
      print('[ActivitiesBloc] Fetching day activities: date=${event.dateIso}');
      final entity = await getActivitiesByDay(dateIso: event.dateIso);
      print(
        '[ActivitiesBloc] Day entity: date=${entity.date.toIso8601String()}, count=${entity.count}, activities=${entity.activities.length}',
      );
      if (entity.activities.isNotEmpty) {
        final a = entity.activities.first;
        print(
          '[ActivitiesBloc] First activity: id=${a.id}, title=${a.title}, type=${a.type}, start=${a.timeStart.toIso8601String()}, end=${a.timeEnd.toIso8601String()}',
        );
      }
      // Entity is already in the correct format, just pass it directly
      emit(DayActivitiesLoaded(data: entity));
    } catch (e) {
      if (event.showLoading) {
        emit(ActivitiesError(message: e.toString()));
      }
      // If silent refresh fails, just keep the current state
    }
  }

  Future<void> _onCreateActivity(
    CreateActivityEvent event,
    Emitter<ActivitiesState> emit,
  ) async {
    emit(CreateActivityLoading());
    try {
      print('[ActivitiesBloc] Creating activity: title=${event.request.title}');
      final response = await createActivity(request: event.request);
      print(
        '[ActivitiesBloc] Activity created successfully: id=${response.id}',
      );
      emit(CreateActivitySuccess(response: response));
    } catch (e) {
      print('[ActivitiesBloc] Error creating activity: $e');
      emit(CreateActivityError(message: e.toString()));
    }
  }

  Future<void> _onUpdateActivity(
    UpdateActivityEvent event,
    Emitter<ActivitiesState> emit,
  ) async {
    emit(UpdateActivityLoading());
    try {
      print(
        '[ActivitiesBloc] Updating activity: id=${event.id}, title=${event.request.title}',
      );
      final response = await updateActivity(
        id: event.id,
        request: event.request,
      );
      print(
        '[ActivitiesBloc] Activity updated successfully: id=${response.id}',
      );
      emit(UpdateActivitySuccess(response: response));
    } catch (e) {
      print('[ActivitiesBloc] Error updating activity: $e');
      emit(UpdateActivityError(message: e.toString()));
    }
  }

  Future<void> _onDeleteActivity(
    DeleteActivityEvent event,
    Emitter<ActivitiesState> emit,
  ) async {
    emit(DeleteActivityLoading());
    try {
      await deleteActivity(id: event.id);
      emit(DeleteActivitySuccess());
    } catch (e) {
      print('[ActivitiesBloc] Error deleting activity: $e');
      emit(DeleteActivityError(message: e.toString()));
    }
  }
}
