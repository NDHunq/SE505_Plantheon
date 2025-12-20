import 'package:se501_plantheon/domain/entities/user_entity.dart';

abstract class UserState {}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserUpdating extends UserState {
  final UserEntity user;

  UserUpdating({required this.user});
}

class UserLoaded extends UserState {
  final UserEntity user;

  UserLoaded({required this.user});
}

class UserError extends UserState {
  final String message;

  UserError({required this.message});
}