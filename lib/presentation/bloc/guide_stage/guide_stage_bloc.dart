import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:se501_plantheon/domain/usecases/guide_stage/get_guide_stages_by_plant.dart';
import 'package:se501_plantheon/presentation/bloc/guide_stage/guide_stage_event.dart';
import 'package:se501_plantheon/presentation/bloc/guide_stage/guide_stage_state.dart';

class GuideStageBloc extends Bloc<GuideStageEvent, GuideStageState> {
  final GetGuideStagesByPlant getGuideStagesByPlant;

  GuideStageBloc({required this.getGuideStagesByPlant})
    : super(GuideStageInitial()) {
    on<FetchGuideStagesEvent>(_onFetchGuideStages);
  }

  Future<void> _onFetchGuideStages(
    FetchGuideStagesEvent event,
    Emitter<GuideStageState> emit,
  ) async {
    emit(GuideStageLoading());
    try {
      final stages = await getGuideStagesByPlant(event.plantId);
      emit(GuideStageLoaded(stages: stages));
    } catch (e) {
      emit(GuideStageError(message: e.toString()));
    }
  }
}
