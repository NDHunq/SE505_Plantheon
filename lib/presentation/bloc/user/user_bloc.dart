import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:se501_plantheon/domain/usecases/user/get_profile.dart';
import 'package:se501_plantheon/presentation/bloc/user/user_event.dart';
import 'package:se501_plantheon/presentation/bloc/user/user_state.dart';
import 'package:se501_plantheon/domain/usecases/user/update_profile.dart';
import 'package:se501_plantheon/domain/usecases/user/delete_account.dart';
import 'package:se501_plantheon/domain/entities/user_entity.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final GetProfile getProfile;
  final UpdateProfile updateProfile;
  final DeleteAccount deleteAccount;

  UserBloc({
    required this.getProfile,
    required this.updateProfile,
    required this.deleteAccount,
  }) : super(UserInitial()) {
    on<FetchProfileEvent>(_onFetchProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<DeleteAccountEvent>(_onDeleteAccount);
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
      emit(UserError(message: e.toString().replaceAll('Exception: ', '')));
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
      emit(UserError(message: e.toString().replaceAll('Exception: ', '')));
      if (currentUser != null) {
        emit(UserLoaded(user: currentUser));
      }
    }
  }

  Future<void> _onDeleteAccount(
    DeleteAccountEvent event,
    Emitter<UserState> emit,
  ) async {
    // Save current user before deleting
    UserEntity? currentUser;
    if (state is UserLoaded) {
      currentUser = (state as UserLoaded).user;
    }

    emit(UserDeleting());
    try {
      await deleteAccount(event.password);
      emit(UserDeleted());
    } catch (e) {
      emit(UserError(message: e.toString().replaceAll('Exception: ', '')));
      // Restore user data after showing error
      if (currentUser != null) {
        emit(UserLoaded(user: currentUser));
      }
    }
  }
}
