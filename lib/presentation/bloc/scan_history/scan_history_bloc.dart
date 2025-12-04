import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:se501_plantheon/domain/usecases/scan_history/get_all_scan_history.dart';
import 'package:se501_plantheon/domain/usecases/scan_history/get_scan_history_by_id.dart';
import 'package:se501_plantheon/domain/usecases/scan_history/create_scan_history.dart';
import 'package:se501_plantheon/domain/usecases/scan_history/delete_all_scan_history.dart';
import 'package:se501_plantheon/domain/usecases/scan_history/delete_scan_history_by_id.dart';
import 'package:se501_plantheon/presentation/bloc/scan_history/scan_history_event.dart';
import 'package:se501_plantheon/presentation/bloc/scan_history/scan_history_state.dart';
import 'package:se501_plantheon/core/services/supabase_service.dart';

class ScanHistoryBloc extends Bloc<ScanHistoryEvent, ScanHistoryState> {
  final GetAllScanHistory getAllScanHistory;
  final GetScanHistoryById getScanHistoryById;
  final CreateScanHistory createScanHistory;
  final DeleteAllScanHistory deleteAllScanHistory;
  final DeleteScanHistoryById deleteScanHistoryById;

  ScanHistoryBloc({
    required this.getAllScanHistory,
    required this.getScanHistoryById,
    required this.createScanHistory,
    required this.deleteAllScanHistory,
    required this.deleteScanHistoryById,
  }) : super(ScanHistoryInitial()) {
    on<GetAllScanHistoryEvent>(_onGetAllScanHistory);
    on<GetScanHistoryByIdEvent>(_onGetScanHistoryById);
    on<CreateScanHistoryEvent>(_onCreateScanHistory);
    on<DeleteAllScanHistoryEvent>(_onDeleteAllScanHistory);
    on<DeleteScanHistoryByIdEvent>(_onDeleteScanHistoryById);
  }

  Future<void> _onGetAllScanHistory(
    GetAllScanHistoryEvent event,
    Emitter<ScanHistoryState> emit,
  ) async {
    print('🔍 BLoC: Received GetAllScanHistoryEvent');
    emit(ScanHistoryLoading());
    print('📡 BLoC: Emitted ScanHistoryLoading state');

    try {
      print('🌐 BLoC: Calling getAllScanHistory use case${event.size != null ? ' with size=${event.size}' : ''}...');
      final scanHistories = await getAllScanHistory(size: event.size);
      print('✅ BLoC: Received ${scanHistories.length} scan history items');

      emit(ScanHistorySuccess(scanHistories: scanHistories));
      print('🎉 BLoC: Emitted ScanHistorySuccess state');
    } catch (e) {
      print('❌ BLoC: Error occurred: $e');
      emit(ScanHistoryError(message: e.toString()));
      print('💥 BLoC: Emitted ScanHistoryError state');
    }
  }

  Future<void> _onGetScanHistoryById(
    GetScanHistoryByIdEvent event,
    Emitter<ScanHistoryState> emit,
  ) async {
    print('🔍 BLoC: Received GetScanHistoryByIdEvent with id: ${event.id}');
    emit(ScanHistoryLoading());
    print('📡 BLoC: Emitted ScanHistoryLoading state');

    try {
      print('🌐 BLoC: Calling getScanHistoryById use case...');
      final scanHistory = await getScanHistoryById(event.id);
      print('✅ BLoC: Received scan history with id: ${scanHistory.id}');

      emit(GetScanHistoryByIdSuccess(scanHistory: scanHistory));
      print('🎉 BLoC: Emitted GetScanHistoryByIdSuccess state');
    } catch (e) {
      print('❌ BLoC: Error occurred: $e');
      emit(ScanHistoryError(message: e.toString()));
      print('💥 BLoC: Emitted ScanHistoryError state');
    }
  }

  Future<void> _onCreateScanHistory(
    CreateScanHistoryEvent event,
    Emitter<ScanHistoryState> emit,
  ) async {
    print(
      '🔍 BLoC: Received CreateScanHistoryEvent with diseaseId: ${event.diseaseId}',
    );
    emit(ScanHistoryLoading());
    print('📡 BLoC: Emitted ScanHistoryLoading state');

    try {
      String? imageUrl;

      // Upload image if available
      if (event.scanImage != null) {
        print('📸 BLoC: Uploading image to Supabase...');
        final bytes = await event.scanImage!.readAsBytes();
        final fileName = 'scan_${DateTime.now().millisecondsSinceEpoch}.jpg';

        imageUrl = await SupabaseService.uploadFileFromBytes(
          bucketName: 'uploads',
          fileBytes: bytes,
          fileName: fileName,
        );
        print('✅ BLoC: Image uploaded successfully: $imageUrl');
      }

      print('🌐 BLoC: Calling createScanHistory use case...');
      final scanHistory = await createScanHistory(
        event.diseaseId,
        scanImage: imageUrl,
      );
      print('✅ BLoC: Created scan history with id: ${scanHistory.id}');

      emit(CreateScanHistorySuccess(scanHistory: scanHistory));
      print('🎉 BLoC: Emitted CreateScanHistorySuccess state');
    } catch (e) {
      print('❌ BLoC: Error occurred: $e');
      emit(ScanHistoryError(message: e.toString()));
      print('💥 BLoC: Emitted ScanHistoryError state');
    }
  }

  Future<void> _onDeleteAllScanHistory(
    DeleteAllScanHistoryEvent event,
    Emitter<ScanHistoryState> emit,
  ) async {
    print('🔍 BLoC: Received DeleteAllScanHistoryEvent');
    emit(ScanHistoryLoading());
    print('📡 BLoC: Emitted ScanHistoryLoading state');

    try {
      print('🌐 BLoC: Calling deleteAllScanHistory use case...');
      await deleteAllScanHistory();
      print('✅ BLoC: Deleted all scan history');

      emit(DeleteAllScanHistorySuccess());
      print('🎉 BLoC: Emitted DeleteAllScanHistorySuccess state');
    } catch (e) {
      print('❌ BLoC: Error occurred: $e');
      emit(ScanHistoryError(message: e.toString()));
      print('💥 BLoC: Emitted ScanHistoryError state');
    }
  }

  Future<void> _onDeleteScanHistoryById(
    DeleteScanHistoryByIdEvent event,
    Emitter<ScanHistoryState> emit,
  ) async {
    print('🔍 BLoC: Received DeleteScanHistoryByIdEvent with id: ${event.id}');
    emit(ScanHistoryLoading());
    print('📡 BLoC: Emitted ScanHistoryLoading state');

    try {
      print('🌐 BLoC: Calling deleteScanHistoryById use case...');
      await deleteScanHistoryById(event.id);
      print('✅ BLoC: Deleted scan history with id: ${event.id}');

      emit(DeleteScanHistoryByIdSuccess());
      print('🎉 BLoC: Emitted DeleteScanHistoryByIdSuccess state');
    } catch (e) {
      print('❌ BLoC: Error occurred: $e');
      emit(ScanHistoryError(message: e.toString()));
      print('💥 BLoC: Emitted ScanHistoryError state');
    }
  }
}
