abstract class NewsDetailEvent {}

class FetchNewsDetailEvent extends NewsDetailEvent {
  final String id;

  FetchNewsDetailEvent({required this.id});
}
