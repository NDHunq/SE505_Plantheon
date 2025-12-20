import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:se501_plantheon/domain/usecases/complaint/submit_scan_complaint.dart';
import 'package:se501_plantheon/presentation/bloc/complaint/complaint_event.dart';
import 'package:se501_plantheon/presentation/bloc/complaint/complaint_state.dart';

class ComplaintBloc extends Bloc<ComplaintEvent, ComplaintState> {
  final SubmitScanComplaint submitScanComplaint;

  ComplaintBloc({
    required this.submitScanComplaint,
  }) : super(ComplaintInitial()) {
    on<SubmitScanComplaintEvent>(_onSubmitScanComplaint);
  }

  Future<void> _onSubmitScanComplaint(
    SubmitScanComplaintEvent event,
    Emitter<ComplaintState> emit,
  ) async {
    print(
      '🔍 BLoC: Received SubmitScanComplaintEvent for disease: ${event.predictedDiseaseId}',
    );
    emit(ComplaintLoading());
    print('📡 BLoC: Emitted ComplaintLoading state');

    try {
      print('🌐 BLoC: Calling submitScanComplaint use case...');
      final complaint = await submitScanComplaint(
        predictedDiseaseId: event.predictedDiseaseId,
        confidenceScore: event.confidenceScore,
        category: event.category,
        imageUrl: event.imageUrl,
        userSuggestedDiseaseId: event.userSuggestedDiseaseId,
        content: event.content,
      );
      print('✅ BLoC: Complaint submitted with id: ${complaint.id}');

      emit(ComplaintSuccess(complaint: complaint));
      print('🎉 BLoC: Emitted ComplaintSuccess state');
    } catch (e) {
      print('❌ BLoC: Error occurred: $e');
      emit(ComplaintError(message: e.toString()));
      print('💥 BLoC: Emitted ComplaintError state');
    }
  }
}
