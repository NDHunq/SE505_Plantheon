import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:se501_plantheon/core/configs/constants/api_constants.dart';
import 'package:se501_plantheon/core/services/token_storage_service.dart';
import 'package:se501_plantheon/data/models/complaint_model.dart';
import 'package:se501_plantheon/data/models/complaint_history_model.dart';

abstract class ComplaintRemoteDataSource {
  Future<ScanComplaintModel> submitScanComplaint({
    required String predictedDiseaseId,
    required double confidenceScore,
    required String category,
    required String imageUrl,
    String? userSuggestedDiseaseId,
    String? content,
  });

  Future<void> submitComplaint(ScanComplaintModel complaint);

  Future<List<ComplaintHistoryModel>> getComplaintsAboutMe({
    int page = 1,
    int limit = 10,
  });
}

class ComplaintRemoteDataSourceImpl implements ComplaintRemoteDataSource {
  final http.Client client;
  final String baseUrl;
  final String apiVersion;
  final TokenStorageService tokenStorage;

  ComplaintRemoteDataSourceImpl({
    required this.client,
    required this.baseUrl,
    required this.tokenStorage,
    this.apiVersion = 'api/v1',
  });

  @override
  Future<ScanComplaintModel> submitScanComplaint({
    required String predictedDiseaseId,
    required double confidenceScore,
    required String category,
    required String imageUrl,
    String? userSuggestedDiseaseId,
    String? content,
  }) async {
    print('🌐 DataSource: Making POST API call to $baseUrl/complaints/scan');

    final token = await tokenStorage.getToken();
    if (token == null) {
      throw Exception('User not authenticated');
    }

    final requestBody = SubmitScanComplaintRequestModel(
      predictedDiseaseId: predictedDiseaseId,
      confidenceScore: confidenceScore,
      category: category,
      imageUrl: imageUrl,
      userSuggestedDiseaseId: userSuggestedDiseaseId,
      content: content,
    );

    print('📝 DataSource: Request body: ${json.encode(requestBody.toJson())}');

    final response = await client.post(
      Uri.parse('$baseUrl/complaints/scan'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(requestBody.toJson()),
    );

    print('📡 DataSource: Response status: ${response.statusCode}');
    print('📄 DataSource: Response body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      print('🔍 DataSource: Parsed JSON');

      final responseModel = SubmitScanComplaintResponseModel.fromJson(jsonData);
      print(
        '✅ DataSource: Submitted complaint with id: ${responseModel.data.id}',
      );
      return responseModel.data;
    } else {
      print('❌ DataSource: API error: ${response.statusCode}');

      // Try to parse error message from response
      try {
        final errorData = json.decode(response.body);
        final errorMessage =
            errorData['error'] ?? errorData['detail'] ?? 'Unknown error';
        throw Exception('Failed to submit complaint: $errorMessage');
      } catch (e) {
        throw Exception('Failed to submit complaint: ${response.statusCode}');
      }
    }
  }

  @override
  Future<void> submitComplaint(ScanComplaintModel complaint) async {
    final url = '${ApiConstants.baseUrl}/${ApiConstants.apiVersion}/complaints';

    print('ComplaintRemoteDataSource: Submitting complaint');
    print('ComplaintRemoteDataSource: POST $url');

    final token = await tokenStorage.getToken();
    if (token == null) {
      throw Exception('User not authenticated');
    }

    final response = await client.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(complaint.toJson()),
    );

    print('ComplaintRemoteDataSource: Response status: ${response.statusCode}');
    print('ComplaintRemoteDataSource: Response body: ${response.body}');

    if (response.statusCode == 401) {
      throw Exception('Token expired. Please login again.');
    } else if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to submit complaint: ${response.body}');
    }

    print('ComplaintRemoteDataSource: Complaint submitted successfully');
  }

  @override
  Future<List<ComplaintHistoryModel>> getComplaintsAboutMe({
    int page = 1,
    int limit = 10,
  }) async {
    final url =
        '${ApiConstants.baseUrl}/${ApiConstants.apiVersion}/complaints/about-me?page=$page&limit=$limit';

    print('ComplaintRemoteDataSource: Fetching complaints about me');
    print('ComplaintRemoteDataSource: GET $url');

    final token = await tokenStorage.getToken();
    if (token == null) {
      throw Exception('User not authenticated');
    }

    final response = await client.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('ComplaintRemoteDataSource: Response status: ${response.statusCode}');
    print('ComplaintRemoteDataSource: Response body: ${response.body}');

    if (response.statusCode == 401) {
      throw Exception('Token expired. Please login again.');
    } else if (response.statusCode != 200) {
      throw Exception('Failed to fetch complaints: ${response.body}');
    }

    final jsonData = json.decode(response.body) as Map<String, dynamic>;
    final complaintsResponse = ComplaintsAboutMeResponse.fromJson(jsonData);

    print(
      'ComplaintRemoteDataSource: Loaded ${complaintsResponse.complaints.length} complaints',
    );
    return complaintsResponse.complaints;
  }
}
