import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../utils/constants.dart';
import '../../utils/strings.dart';

class ApiHandler {
  Future<Map<String, String>> _getHeaders() async {
    return {'Content-Type': 'application/json', 'Accept': 'application/json'};
  }

  Future<ApiResponse> get(String endpoint) async {
    try {
      final response = await http
          .get(
            Uri.parse('${AppConstants.baseUrl}$endpoint'),
            headers: await _getHeaders(),
          )
          .timeout(const Duration(seconds: AppConstants.connectionTimeout));

      return _handleResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: AppStrings.somethingWentWrong,
        error: e.toString(),
      );
    }
  }

  Future<ApiResponse> post(String endpoint, Map<String, dynamic> data) async {
    final url = '${AppConstants.baseUrl}$endpoint';
    final headers = await _getHeaders();

    try {
      print("\n===================== API REQUEST =====================");
      print("POST: $url");
      print("HEADERS: $headers");
      print("BODY: $data");
      print("=======================================================\n");

      final response = await http
          .post(Uri.parse(url), headers: headers, body: jsonEncode(data))
          .timeout(const Duration(seconds: AppConstants.connectionTimeout));

      print("\n==================== API RESPONSE =====================");
      print("STATUS CODE: ${response.statusCode}");
      print("BODY: ${response.body}");
      print("=======================================================\n");

      return _handleResponse(response);
    } catch (e) {
      print("\n==================== API ERROR ========================");
      print("ERROR: $e");
      print("=======================================================\n");

      return ApiResponse(
        success: false,
        message: AppStrings.somethingWentWrong,
        error: e.toString(),
      );
    }
  }

  ApiResponse _handleResponse(http.Response response) {
    final dynamic data = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ApiResponse(
        success: true,
        data: data,
        statusCode: response.statusCode,
      );
    } else {
      return ApiResponse(
        success: false,
        message: data['message'] ?? AppStrings.somethingWentWrong,
        statusCode: response.statusCode,
        data: data,
      );
    }
  }
}

class ApiResponse {
  final bool success;
  final dynamic data;
  final String? message;
  final String? error;
  final int? statusCode;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.error,
    this.statusCode,
  });
}
