class DiseasePredictionResponse {
  final List<PredictionItem> topPredictions;
  final double inferenceTimeMs;
  final DetectionInfo? detection; // Optional for v2 API
  final double? classificationTimeMs; // Optional for v2 API
  final double? totalTimeMs; // Optional for v2 API

  DiseasePredictionResponse({
    required this.topPredictions,
    required this.inferenceTimeMs,
    this.detection,
    this.classificationTimeMs,
    this.totalTimeMs,
  });

  factory DiseasePredictionResponse.fromJson(Map<String, dynamic> json) {
    // Check if this is v2 API response (has 'detection' field)
    final bool isV2 = json.containsKey('detection');
    
    return DiseasePredictionResponse(
      topPredictions: (json['top_predictions'] as List)
          .map((item) => PredictionItem.fromJson(item))
          .toList(),
      inferenceTimeMs: isV2 
          ? (json['classification_time_ms'] as num).toDouble()
          : (json['inference_time_ms'] as num).toDouble(),
      detection: isV2 && json['detection'] != null
          ? DetectionInfo.fromJson(json['detection'])
          : null,
      classificationTimeMs: isV2 
          ? (json['classification_time_ms'] as num?)?.toDouble()
          : null,
      totalTimeMs: isV2 
          ? (json['total_time_ms'] as num?)?.toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'top_predictions': topPredictions.map((item) => item.toJson()).toList(),
    'inference_time_ms': inferenceTimeMs,
    if (detection != null) 'detection': detection!.toJson(),
    if (classificationTimeMs != null) 'classification_time_ms': classificationTimeMs,
    if (totalTimeMs != null) 'total_time_ms': totalTimeMs,
  };

  // Get top prediction
  PredictionItem? get topPrediction =>
      topPredictions.isNotEmpty ? topPredictions.first : null;
}

class DetectionInfo {
  final bool plantDetected;
  final double plantConfidence;
  final BoundingBox plantBbox;
  final double detectionTimeMs;

  DetectionInfo({
    required this.plantDetected,
    required this.plantConfidence,
    required this.plantBbox,
    required this.detectionTimeMs,
  });

  factory DetectionInfo.fromJson(Map<String, dynamic> json) {
    return DetectionInfo(
      plantDetected: json['plant_detected'] as bool,
      plantConfidence: (json['plant_confidence'] as num).toDouble(),
      plantBbox: BoundingBox.fromJson(json['plant_bbox']),
      detectionTimeMs: (json['detection_time_ms'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'plant_detected': plantDetected,
    'plant_confidence': plantConfidence,
    'plant_bbox': plantBbox.toJson(),
    'detection_time_ms': detectionTimeMs,
  };
}

class BoundingBox {
  final int x;
  final int y;
  final int width;
  final int height;

  BoundingBox({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  factory BoundingBox.fromJson(Map<String, dynamic> json) {
    return BoundingBox(
      x: json['x'] as int,
      y: json['y'] as int,
      width: json['width'] as int,
      height: json['height'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'x': x,
    'y': y,
    'width': width,
    'height': height,
  };
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
