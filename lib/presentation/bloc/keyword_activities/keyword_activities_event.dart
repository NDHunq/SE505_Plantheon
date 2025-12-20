abstract class KeywordActivitiesEvent {}

class FetchKeywordActivities extends KeywordActivitiesEvent {
  final String diseaseId;

  FetchKeywordActivities({required this.diseaseId});
}