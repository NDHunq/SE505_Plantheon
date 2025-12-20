import 'package:se501_plantheon/domain/entities/complaint_entity.dart';
import 'package:se501_plantheon/domain/entities/complaint_history_entity.dart';

abstract class ComplaintState {}

class ComplaintInitial extends ComplaintState {}

class ComplaintLoading extends ComplaintState {}

class ComplaintSuccess extends ComplaintState {
  final ComplaintEntity complaint;

  ComplaintSuccess({required this.complaint});
}

class ComplaintError extends ComplaintState {
  final String message;

  ComplaintError({required this.message});
}

class ComplaintSubmitting extends ComplaintState {}

class ComplaintSubmitted extends ComplaintState {}

class ComplaintsLoading extends ComplaintState {}

class ComplaintsLoaded extends ComplaintState {
  final List<ComplaintHistoryEntity> complaints;

  ComplaintsLoaded({required this.complaints});
}

class ComplaintsLoadError extends ComplaintState {
  final String message;

  ComplaintsLoadError({required this.message});
}
