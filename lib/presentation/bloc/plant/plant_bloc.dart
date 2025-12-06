import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:se501_plantheon/domain/usecases/plant/get_plants.dart';
import 'package:se501_plantheon/presentation/bloc/plant/plant_event.dart';
import 'package:se501_plantheon/presentation/bloc/plant/plant_state.dart';

class PlantBloc extends Bloc<PlantEvent, PlantState> {
  final GetPlants getPlants;

  PlantBloc({required this.getPlants}) : super(PlantInitial()) {
    on<FetchPlantsEvent>(_onFetchPlants);
  }

  Future<void> _onFetchPlants(
    FetchPlantsEvent event,
    Emitter<PlantState> emit,
  ) async {
    emit(PlantLoading());
    try {
      final plants = await getPlants();
      emit(PlantLoaded(plants: plants));
    } catch (e) {
      emit(PlantError(message: e.toString()));
    }
  }
}
