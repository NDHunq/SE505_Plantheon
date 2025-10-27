import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:se501_plantheon/data/models/diseases.model.dart';
import 'package:se501_plantheon/domain/usecases/disease/get_disease.dart';
import 'package:se501_plantheon/presentation/bloc/disease/disease_event.dart';
import 'package:se501_plantheon/presentation/bloc/disease/disease_state.dart';

class DiseaseBloc extends Bloc<DiseaseEvent, DiseaseState> {
  final GetDisease getDisease;

  DiseaseBloc({required this.getDisease}) : super(DiseaseInitial()) {
    on<GetDiseaseEvent>(_onGetDisease);
  }

  Future<void> _onGetDisease(
    GetDiseaseEvent event,
    Emitter<DiseaseState> emit,
  ) async {
    print(
      '🔍 BLoC: Received GetDiseaseEvent with diseaseId: ${event.diseaseId}',
    );
    emit(DiseaseLoading());
    print('📡 BLoC: Emitted DiseaseLoading state');

    try {
      print('🌐 BLoC: Calling getDisease use case...');
      final diseaseEntity = await getDisease(event.diseaseId);
      print('✅ BLoC: Received disease entity: ${diseaseEntity.name}');

      // Convert entity to model for UI
      final diseaseModel = _mapEntityToModel(diseaseEntity);
      print('🔄 BLoC: Converted to model: ${diseaseModel.name}');

      emit(DiseaseSuccess(disease: diseaseModel));
      print('🎉 BLoC: Emitted DiseaseSuccess state');
    } catch (e) {
      print('❌ BLoC: Error occurred: $e');
      emit(DiseaseError(message: e.toString()));
      print('💥 BLoC: Emitted DiseaseError state');
    }
  }

  // Helper method to convert entity to model
  DiseaseModel _mapEntityToModel(diseaseEntity) {
    return DiseaseModel(
      id: diseaseEntity.id,
      name: diseaseEntity.name,
      type: diseaseEntity.type,
      description: diseaseEntity.description,
      imageLink: diseaseEntity.imageLink,
      createdAt: diseaseEntity.createdAt,
      updatedAt: diseaseEntity.updatedAt,
      className: diseaseEntity.className,
      plantName: diseaseEntity.plantName,
      solution: diseaseEntity.solution,
    );
  }
}
