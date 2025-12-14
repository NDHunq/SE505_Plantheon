import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import '../../data/models/disease_prediction_model.dart';
import '../configs/constants/api_constants.dart';

class DiseasePredictionService {
  static DiseasePredictionService? _instance;
  static DiseasePredictionService get instance =>
      _instance ??= DiseasePredictionService._();

  DiseasePredictionService._();

  /// Predict disease from image file
  Future<DiseasePredictionResponse> predictDisease(File imageFile) async {
    try {
      print('🔍 Gửi ảnh đến AI server...');
      print('📍 URL: ${ApiConstants.predictDiseaseUrl}');

      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConstants.predictDiseaseUrl),
      );

      // Add headers
      request.headers['accept'] = 'application/json';

      // Add file with proper content type
      var fileStream = http.ByteStream(imageFile.openRead());
      var fileLength = await imageFile.length();

      // Determine content type from file extension
      String contentType = 'image/jpeg';
      final extension = imageFile.path.toLowerCase().split('.').last;
      if (extension == 'png') {
        contentType = 'image/png';
      } else if (extension == 'jpg' || extension == 'jpeg') {
        contentType = 'image/jpeg';
      }

      var multipartFile = http.MultipartFile(
        'file',
        fileStream,
        fileLength,
        filename: 'image.$extension',
        contentType: MediaType.parse(contentType),
      );
      request.files.add(multipartFile);

      print('📤 Đang upload ảnh (${fileLength} bytes)...');
      print('📎 File: ${imageFile.path}');

      // Send request with timeout
      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout - Server không phản hồi sau 30s');
        },
      );

      print('📥 Đã nhận response, đang parse...');
      var response = await http.Response.fromStream(streamedResponse);

      print('📥 Status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print('✅ API response: ${response.body}');

        final result = DiseasePredictionResponse.fromJson(jsonData);
        print(
          '🎯 Top prediction: ${result.topPrediction?.label} (${result.topPrediction?.confidencePercent})',
        );

        return result;
      } else {
        throw Exception('API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Lỗi predict: $e');
      rethrow;
    }
  }

  /// Predict disease from image file using v2 API (with plant detection)
  Future<DiseasePredictionResponse> predictDiseaseV2(File imageFile) async {
    try {
      print('🔍 Gửi ảnh đến AI server (v2 - with plant detection)...');
      print('📍 URL: ${ApiConstants.predictDiseaseV2Url}');

      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConstants.predictDiseaseV2Url),
      );

      // Add headers
      request.headers['accept'] = 'application/json';

      // Add file with proper content type
      var fileStream = http.ByteStream(imageFile.openRead());
      var fileLength = await imageFile.length();

      // Determine content type from file extension
      String contentType = 'image/jpeg';
      final extension = imageFile.path.toLowerCase().split('.').last;
      if (extension == 'png') {
        contentType = 'image/png';
      } else if (extension == 'jpg' || extension == 'jpeg') {
        contentType = 'image/jpeg';
      }

      var multipartFile = http.MultipartFile(
        'file',
        fileStream,
        fileLength,
        filename: 'image.$extension',
        contentType: MediaType.parse(contentType),
      );
      request.files.add(multipartFile);

      print('📤 Đang upload ảnh (${fileLength} bytes)...');
      print('📎 File: ${imageFile.path}');

      // Send request with timeout (v2 needs more time for detection + classification)
      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw Exception('Request timeout - Server không phản hồi sau 60s');
        },
      );

      print('📥 Đã nhận response, đang parse...');
      var response = await http.Response.fromStream(streamedResponse);

      print('📥 Status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print('✅ API response: ${response.body}');

        final result = DiseasePredictionResponse.fromJson(jsonData);
        print(
          '🎯 Top prediction: ${result.topPrediction?.label} (${result.topPrediction?.confidencePercent})',
        );
        if (result.detection != null) {
          print(
            '🌿 Plant detected: ${result.detection!.plantDetected} (confidence: ${(result.detection!.plantConfidence * 100).toStringAsFixed(1)}%)',
          );
        }

        // Check confidence threshold (minimum 0.7 or 70%)
        const double confidenceThreshold = 0.7;
        if (result.topPrediction != null && 
            result.topPrediction!.probability < confidenceThreshold) {
          print(
            '⚠️ Low confidence prediction: ${result.topPrediction!.confidencePercent} < ${(confidenceThreshold * 100).toInt()}%',
          );
          throw LowConfidencePredictionException(
            'Độ tin cậy thấp: ${result.topPrediction!.confidencePercent}',
            result.topPrediction!.probability,
          );
        }

        return result;
      } else if (response.statusCode == 422) {
        // No plant detected
        final jsonData = json.decode(response.body);
        final errorDetail = jsonData['detail'] ?? 'No plant detected in the image';
        print('⚠️ No plant detected: $errorDetail');
        throw NoPlantDetectedException(errorDetail);
      } else {
        throw Exception('API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Lỗi predict v2: $e');
      rethrow;
    }
  }

  /// Check if server is available
  Future<bool> checkServerHealth() async {
    try {
      final response = await http
          .get(Uri.parse('${ApiConstants.aiPredictionBaseUrl}/health'))
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      print('⚠️ Server không phản hồi: $e');
      return false;
    }
  }
}

/// Custom exception for when no plant is detected in the image
class NoPlantDetectedException implements Exception {
  final String message;
  
  NoPlantDetectedException(this.message);
  
  @override
  String toString() => message;
}

/// Custom exception for when prediction confidence is below threshold
class LowConfidencePredictionException implements Exception {
  final String message;
  final double confidence;
  
  LowConfidencePredictionException(this.message, this.confidence);
  
  @override
  String toString() => message;
}
