import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:se501_plantheon/domain/usecases/user/get_profile.dart';
import 'package:se501_plantheon/presentation/bloc/user/user_event.dart';
import 'package:se501_plantheon/presentation/bloc/user/user_state.dart';
import 'package:se501_plantheon/domain/usecases/user/update_profile.dart';
import 'package:se501_plantheon/domain/entities/user_entity.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final GetProfile getProfile;
  final UpdateProfile updateProfile;

  UserBloc({required this.getProfile, required this.updateProfile})
    : super(UserInitial()) {
    on<FetchProfileEvent>(_onFetchProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
  }

  Future<void> _onFetchProfile(
    FetchProfileEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    try {
      final user = await getProfile();
      emit(UserLoaded(user: user));
    } catch (e) {
      emit(UserError(message: e.toString()));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<UserState> emit,
  ) async {
    UserEntity? currentUser;
    if (state is UserLoaded) {
      currentUser = (state as UserLoaded).user;
      emit(UserUpdating(user: currentUser));
    } else if (state is UserUpdating) {
      currentUser = (state as UserUpdating).user;
    }

    try {
      final user = await updateProfile(
        fullName: event.fullName,
        avatar: event.avatar,
      );
      emit(UserLoaded(user: user));
    } catch (e) {
      emit(UserError(message: e.toString()));
      if (currentUser != null) {
        emit(UserLoaded(user: currentUser));
      }
    }
  }
}
