abstract class NewsEvent {}

class FetchNewsEvent extends NewsEvent {
  final int? size;

  FetchNewsEvent({this.size});
}
