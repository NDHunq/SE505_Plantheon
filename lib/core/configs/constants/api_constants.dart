class ApiConstants {
  static const String baseUrl = 'http://localhost:8080';
  static const String baseChatUrl = 'http://localhost:8081';
  static const String apiVersion = 'api/v1';

  // AI Prediction Server (separate server)
  // Dùng IP thật của máy để mobile có thể kết nối (cùng WiFi)
  static const String aiPredictionBaseUrl = 'http://192.168.1.213:8000';

  // Full API URLs
  static const String diseaseApiUrl = '$baseUrl/$apiVersion';
  static const String predictDiseaseUrl = '$aiPredictionBaseUrl/predict';
}
