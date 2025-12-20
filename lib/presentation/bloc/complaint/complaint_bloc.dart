import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:se501_plantheon/domain/usecases/complaint/submit_scan_complaint.dart';
import 'package:se501_plantheon/domain/repository/complaint_repository.dart';
import 'package:se501_plantheon/domain/entities/complaint_entity.dart';
import 'package:se501_plantheon/presentation/bloc/complaint/complaint_event.dart';
import 'package:se501_plantheon/presentation/bloc/complaint/complaint_state.dart';

class ComplaintBloc extends Bloc<ComplaintEvent, ComplaintState> {
  final SubmitScanComplaint submitScanComplaint;
  final ComplaintRepository complaintRepository;

  ComplaintBloc({
    required this.submitScanComplaint,
    required this.complaintRepository,
  }) : super(ComplaintInitial()) {
    on<SubmitScanComplaintEvent>(_onSubmitScanComplaint);
    on<SubmitComplaintEvent>(_onSubmitComplaint);
    on<FetchComplaintsAboutMeEvent>(_onFetchComplaintsAboutMe);
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

  Future<void> _onSubmitComplaint(
    SubmitComplaintEvent event,
    Emitter<ComplaintState> emit,
  ) async {
    emit(ComplaintSubmitting());
    try {
      final complaint = ComplaintEntity(
        id: '',
        userId: '',
        targetId: event.targetId,
        targetType: event.targetType,
        category: event.category,
        content: event.content,
        imageUrl: '',
        status: '',
        predictedDiseaseId: '',
        confidenceScore: 0.0,
        isVerified: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await complaintRepository.submitComplaint(complaint);
      emit(ComplaintSubmitted());
    } catch (e) {
      emit(ComplaintError(message: e.toString()));
    }
  }

  Future<void> _onFetchComplaintsAboutMe(
    FetchComplaintsAboutMeEvent event,
    Emitter<ComplaintState> emit,
  ) async {
    emit(ComplaintsLoading());
    try {
      final complaints = await complaintRepository.getComplaintsAboutMe(
        page: event.page,
        limit: event.limit,
      );
      emit(ComplaintsLoaded(complaints: complaints));
    } catch (e) {
      emit(ComplaintsLoadError(message: e.toString()));
    }
  }
}
