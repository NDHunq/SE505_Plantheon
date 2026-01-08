import 'package:se501_plantheon/data/models/diseases.model.dart';

class DiseasesListModel {
  final List<DiseaseModel> diseases;
  final int total;
  final int count;

  DiseasesListModel({
    required this.diseases,
    required this.total,
    required this.count,
  });

  factory DiseasesListModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    
    return DiseasesListModel(
      diseases: (data['diseases'] as List?)
              ?.map((e) => DiseaseModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      total: data['total'] as int? ?? 0,
      count: data['count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'diseases': diseases.map((e) => e.toJson()).toList(),
      'total': total,
      'count': count,
    };
  }
}
