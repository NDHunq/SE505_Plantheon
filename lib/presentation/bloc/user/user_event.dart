abstract class UserEvent {}

class FetchProfileEvent extends UserEvent {}

class UpdateProfileEvent extends UserEvent {
  final String? fullName;
  final String? avatar;

  UpdateProfileEvent({this.fullName, this.avatar});
}