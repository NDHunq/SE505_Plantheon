import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:se501_plantheon/domain/usecases/guide_stage/get_guide_stage_detail.dart';
import 'package:se501_plantheon/presentation/bloc/guide_stage_detail/guide_stage_detail_event.dart';
import 'package:se501_plantheon/presentation/bloc/guide_stage_detail/guide_stage_detail_state.dart';

class GuideStageDetailBloc
    extends Bloc<GuideStageDetailEvent, GuideStageDetailState> {
  final GetGuideStageDetail getGuideStageDetail;

  GuideStageDetailBloc({required this.getGuideStageDetail})
    : super(GuideStageDetailInitial()) {
    on<FetchGuideStageDetailEvent>(_onFetchDetail);
  }

  Future<void> _onFetchDetail(
    FetchGuideStageDetailEvent event,
    Emitter<GuideStageDetailState> emit,
  ) async {
    emit(GuideStageDetailLoading());
    try {
      final detail = await getGuideStageDetail(event.guideStageId);
      emit(GuideStageDetailLoaded(detail: detail));
    } catch (e) {
      emit(
        GuideStageDetailError(
          message: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }
}
