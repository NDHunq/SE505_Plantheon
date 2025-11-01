import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:se501_plantheon/domain/usecases/scan_history/get_all_scan_history.dart';
import 'package:se501_plantheon/presentation/bloc/scan_history/scan_history_event.dart';
import 'package:se501_plantheon/presentation/bloc/scan_history/scan_history_state.dart';

class ScanHistoryBloc extends Bloc<ScanHistoryEvent, ScanHistoryState> {
  final GetAllScanHistory getAllScanHistory;

  ScanHistoryBloc({required this.getAllScanHistory})
    : super(ScanHistoryInitial()) {
    on<GetAllScanHistoryEvent>(_onGetAllScanHistory);
  }

  Future<void> _onGetAllScanHistory(
    GetAllScanHistoryEvent event,
    Emitter<ScanHistoryState> emit,
  ) async {
    print('🔍 BLoC: Received GetAllScanHistoryEvent');
    emit(ScanHistoryLoading());
    print('📡 BLoC: Emitted ScanHistoryLoading state');

    try {
      print('🌐 BLoC: Calling getAllScanHistory use case...');
      final scanHistories = await getAllScanHistory();
      print('✅ BLoC: Received ${scanHistories.length} scan history items');

      emit(ScanHistorySuccess(scanHistories: scanHistories));
      print('🎉 BLoC: Emitted ScanHistorySuccess state');
    } catch (e) {
      print('❌ BLoC: Error occurred: $e');
      emit(ScanHistoryError(message: e.toString()));
      print('💥 BLoC: Emitted ScanHistoryError state');
    }
  }
}
