import 'package:se501_plantheon/domain/entities/complaint_entity.dart';

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
