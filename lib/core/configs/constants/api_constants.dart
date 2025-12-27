class ApiConstants {
  static const String baseUrl = 'http://3.106.199.49:8080';
  static const String baseChatUrl = 'http://3.106.199.49:8080';
  static const String apiVersion = 'api/v1';

  // AI Prediction Server (separate server)
  // Dùng IP thật của máy để mobile có thể kết nối (cùng WiFi)
  static const String aiPredictionBaseUrl = 'http://3.106.207.247:8000';

  // Full API URLs
  static const String diseaseApiUrl = '$baseUrl/$apiVersion';
  static const String predictDiseaseUrl = '$aiPredictionBaseUrl/predict';
  static const String predictDiseaseV2Url = '$aiPredictionBaseUrl/predict/v2';
}
