import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:se501_plantheon/core/configs/constants/api_constants.dart';
import 'package:se501_plantheon/core/services/token_storage_service.dart';
import 'package:se501_plantheon/data/models/complaint_model.dart';
import 'package:se501_plantheon/data/models/complaint_history_model.dart';

class ComplaintRemoteDataSource {
  final http.Client client;
  final TokenStorageService tokenStorage;

  ComplaintRemoteDataSource({required this.client, required this.tokenStorage});

  Future<void> submitComplaint(ComplaintModel complaint) async {
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
