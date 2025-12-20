import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:se501_plantheon/domain/entities/complaint_entity.dart';
import 'package:se501_plantheon/domain/entities/complaint_history_entity.dart';
import 'package:se501_plantheon/domain/repository/complaint_repository.dart';

// Events
abstract class ComplaintEvent {}

class SubmitComplaintEvent extends ComplaintEvent {
  final String targetId;
  final String targetType;
  final String category;
  final String content;

  SubmitComplaintEvent({
    required this.targetId,
    required this.targetType,
    required this.category,
    required this.content,
  });
}

class FetchComplaintsAboutMe extends ComplaintEvent {
  final int page;
  final int limit;

  FetchComplaintsAboutMe({this.page = 1, this.limit = 10});
}

// States
abstract class ComplaintState {}

class ComplaintInitial extends ComplaintState {}

class ComplaintSubmitting extends ComplaintState {}

class ComplaintSubmitted extends ComplaintState {}

class ComplaintError extends ComplaintState {
  final String message;
  ComplaintError(this.message);
}

// States for loading complaints about me
class ComplaintsLoading extends ComplaintState {}

class ComplaintsLoaded extends ComplaintState {
  final List<ComplaintHistoryEntity> complaints;
  ComplaintsLoaded(this.complaints);
}

class ComplaintsLoadError extends ComplaintState {
  final String message;
  ComplaintsLoadError(this.message);
}

// BLoC
class ComplaintBloc extends Bloc<ComplaintEvent, ComplaintState> {
  final ComplaintRepository complaintRepository;

  ComplaintBloc({required this.complaintRepository})
    : super(ComplaintInitial()) {
    on<SubmitComplaintEvent>(_onSubmitComplaint);
    on<FetchComplaintsAboutMe>(_onFetchComplaintsAboutMe);
  }

  Future<void> _onSubmitComplaint(
    SubmitComplaintEvent event,
    Emitter<ComplaintState> emit,
  ) async {
    emit(ComplaintSubmitting());
    try {
      final complaint = ComplaintEntity(
        targetId: event.targetId,
        targetType: event.targetType,
        category: event.category,
        content: event.content,
      );

      await complaintRepository.submitComplaint(complaint);
      emit(ComplaintSubmitted());
    } catch (e) {
      emit(ComplaintError(e.toString()));
    }
  }

  Future<void> _onFetchComplaintsAboutMe(
    FetchComplaintsAboutMe event,
    Emitter<ComplaintState> emit,
  ) async {
    emit(ComplaintsLoading());
    try {
      final complaints = await complaintRepository.getComplaintsAboutMe(
        page: event.page,
        limit: event.limit,
      );
      emit(ComplaintsLoaded(complaints));
    } catch (e) {
      emit(ComplaintsLoadError(e.toString()));
    }
  }
}
