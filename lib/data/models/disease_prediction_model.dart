class DiseasePredictionResponse {
  final List<PredictionItem> topPredictions;
  final double inferenceTimeMs;

  DiseasePredictionResponse({
    required this.topPredictions,
    required this.inferenceTimeMs,
  });

  factory DiseasePredictionResponse.fromJson(Map<String, dynamic> json) {
    return DiseasePredictionResponse(
      topPredictions: (json['top_predictions'] as List)
          .map((item) => PredictionItem.fromJson(item))
          .toList(),
      inferenceTimeMs: (json['inference_time_ms'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'top_predictions': topPredictions.map((item) => item.toJson()).toList(),
    'inference_time_ms': inferenceTimeMs,
  };

  // Get top prediction
  PredictionItem? get topPrediction =>
      topPredictions.isNotEmpty ? topPredictions.first : null;
}

class PredictionItem {
  final String label;
  final double probability;

  PredictionItem({required this.label, required this.probability});

  factory PredictionItem.fromJson(Map<String, dynamic> json) {
    return PredictionItem(
      label: json['label'] as String,
      probability: (json['probability'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {'label': label, 'probability': probability};

  // Format label to Vietnamese
  String get labelVi {
    // Replace underscores with spaces and capitalize
    return label.replaceAll('_', ' ');
  }

  // Get plant type from label
  String get plantType {
    final parts = label.split('_');
    return parts.isNotEmpty ? parts[0] : 'Unknown';
  }

  // Check if healthy
  bool get isHealthy => label.toLowerCase().contains('healthy');

  // Get disease name (without plant type)
  String get diseaseName {
    final parts = label.split('_');
    if (parts.length > 1) {
      return parts.skip(1).join(' ');
    }
    return label;
  }

  // Get confidence percentage
  String get confidencePercent => '${(probability * 100).toStringAsFixed(1)}%';
}
