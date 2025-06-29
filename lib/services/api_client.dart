import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:developer' as developer;

class ApiClient {
  static const String baseUrl =
      'http://192.168.100.87:8000/api/v1'; // ganti denggan API pada computer dengan perintah ipconfig
  static const Duration defaultTimeout = Duration(seconds: 15);

  // Singleton instance
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  // Default headers
  Map<String, String> get _defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Headers with authentication
  Map<String, String> _getAuthHeaders(String token) => {
    ..._defaultHeaders,
    'Authorization': 'Bearer $token',
  };

  // Generic GET request
  Future<http.Response> get(
    String endpoint, {
    String? token,
    Duration? timeout,
    Map<String, String>? additionalHeaders,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final headers = token != null ? _getAuthHeaders(token) : _defaultHeaders;

      if (additionalHeaders != null) {
        headers.addAll(additionalHeaders);
      }

      developer.log('GET Request: $uri');
      developer.log('Headers: $headers');

      final response = await http
          .get(uri, headers: headers)
          .timeout(
            timeout ?? defaultTimeout,
            onTimeout: () => throw _timeoutException(),
          );

      developer.log('Response Status: ${response.statusCode}');
      developer.log('Response Body: ${response.body}');

      return response;
    } on SocketException catch (e) {
      developer.log('Socket error: $e');
      throw _socketException(e);
    } catch (e) {
      developer.log('GET error: $e');
      rethrow;
    }
  }

  // Generic POST request
  Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
    Duration? timeout,
    Map<String, String>? additionalHeaders,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final headers = token != null ? _getAuthHeaders(token) : _defaultHeaders;

      if (additionalHeaders != null) {
        headers.addAll(additionalHeaders);
      }

      final requestBody = body != null ? jsonEncode(body) : null;

      developer.log('POST Request: $uri');
      developer.log('Headers: $headers');
      developer.log('Body: $requestBody');

      final response = await http
          .post(uri, headers: headers, body: requestBody)
          .timeout(
            timeout ?? defaultTimeout,
            onTimeout: () => throw _timeoutException(),
          );

      developer.log('Response Status: ${response.statusCode}');
      developer.log('Response Body: ${response.body}');

      return response;
    } on SocketException catch (e) {
      developer.log('Socket error: $e');
      throw _socketException(e);
    } catch (e) {
      developer.log('POST error: $e');
      rethrow;
    }
  }

  // Generic PUT request
  Future<http.Response> put(
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
    Duration? timeout,
    Map<String, String>? additionalHeaders,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final headers = token != null ? _getAuthHeaders(token) : _defaultHeaders;

      if (additionalHeaders != null) {
        headers.addAll(additionalHeaders);
      }

      final requestBody = body != null ? jsonEncode(body) : null;

      developer.log('PUT Request: $uri');
      developer.log('Headers: $headers');
      developer.log('Body: $requestBody');

      final response = await http
          .put(uri, headers: headers, body: requestBody)
          .timeout(
            timeout ?? defaultTimeout,
            onTimeout: () => throw _timeoutException(),
          );

      developer.log('Response Status: ${response.statusCode}');
      developer.log('Response Body: ${response.body}');

      return response;
    } on SocketException catch (e) {
      developer.log('Socket error: $e');
      throw _socketException(e);
    } catch (e) {
      developer.log('PUT error: $e');
      rethrow;
    }
  }

  // Generic DELETE request
  Future<http.Response> delete(
    String endpoint, {
    String? token,
    Duration? timeout,
    Map<String, String>? additionalHeaders,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final headers = token != null ? _getAuthHeaders(token) : _defaultHeaders;

      if (additionalHeaders != null) {
        headers.addAll(additionalHeaders);
      }

      developer.log('DELETE Request: $uri');
      developer.log('Headers: $headers');

      final response = await http
          .delete(uri, headers: headers)
          .timeout(
            timeout ?? defaultTimeout,
            onTimeout: () => throw _timeoutException(),
          );

      developer.log('Response Status: ${response.statusCode}');
      developer.log('Response Body: ${response.body}');

      return response;
    } on SocketException catch (e) {
      developer.log('Socket error: $e');
      throw _socketException(e);
    } catch (e) {
      developer.log('DELETE error: $e');
      rethrow;
    }
  }

  // Response handler with common error handling
  T handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson, {
    Function()? onUnauthorized,
  }) {
    final statusCode = response.statusCode;

    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      switch (statusCode) {
        case 200:
        case 201:
          return fromJson(data);

        // case 401:
        //   if (onUnauthorized != null) {
        //     onUnauthorized();
        //   }
        //   throw Exception('Session expired. Please login again.');

        case 404:
          throw Exception('Resource not found');

        case 422:
          // Validation errors - preserve full response for detailed error handling
          throw Exception(response.body);

        case 500:
          throw Exception('Server error. Please try again later.');

        default:
          String errorMessage = 'Request failed';

          if (data['message'] != null) {
            errorMessage = data['message'];
          } else if (data['data'] != null) {
            errorMessage = data['data'].toString();
          }

          throw Exception(errorMessage);
      }
    } on FormatException {
      throw Exception('Invalid response format from server');
    }
  }

  // Simple response handler for basic success/failure
  bool handleSimpleResponse(
    http.Response response, {
    Function()? onUnauthorized,
  }) {
    final statusCode = response.statusCode;

    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      switch (statusCode) {
        case 200:
        case 201:
          return data['success'] == true;

        case 401:
          if (onUnauthorized != null) {
            onUnauthorized();
          }
          throw Exception('Session expired. Please login again.');

        case 404:
          throw Exception('Resource not found');

        default:
          String errorMessage = 'Request failed';

          if (data['message'] != null) {
            errorMessage = data['message'];
          }

          throw Exception(errorMessage);
      }
    } on FormatException {
      throw Exception('Invalid response format from server');
    }
  }

  // Helper methods for common exceptions
  Exception _timeoutException() {
    return Exception(
      'Connection timeout. Please check your internet connection and server status.',
    );
  }

  Exception _socketException(SocketException e) {
    developer.log('Socket error details:');
    developer.log('Address: ${e.address}');
    developer.log('Port: ${e.port}');
    developer.log('OS Error: ${e.osError}');

    return Exception(
      'Cannot connect to server. Please check your network connection and ensure the server is running.',
    );
  }

  // Utility method to check if response is successful
  static bool isSuccessResponse(int statusCode) {
    return statusCode >= 200 && statusCode < 300;
  }

  // Utility method to extract error message from response
  static String extractErrorMessage(String responseBody) {
    try {
      final data = jsonDecode(responseBody) as Map<String, dynamic>;

      if (data['message'] != null) {
        return data['message'];
      } else if (data['data'] != null) {
        return data['data'].toString();
      }

      return 'Unknown error occurred';
    } catch (e) {
      return 'Failed to parse error message';
    }
  }
}
