import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/auth_model.dart';
import 'dart:io';

import 'dart:developer' as developer;

class AuthService {
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _userEmailKey = 'userEmail';
  static const String _tokenKey = 'auth_token';

  String? _token;
  final String baseUrl = 'http://(192.168.0.106):8000/api/v1';

  // Singleton instance
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    if (_token != null) return _token;
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
    return _token;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      developer.log('Attempting login with email: $email');
      developer.log('Connecting to: $baseUrl/login');

      final requestBody = LoginRequest(
        email: email,
        password: password,
      ).toJson();
      developer.log('Login request body: $requestBody');

      final response = await http
          .post(
            Uri.parse('$baseUrl/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(requestBody),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception(
                'Connection timeout. Please check your internet connection and server status.',
              );
            },
          );

      developer.log('Login response status: ${response.statusCode}');
      developer.log('Login response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data'] != null && data['data']['token'] != null) {
          await saveToken(data['data']['token']);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool(_isLoggedInKey, true);
          await prefs.setString(_userEmailKey, email);
          return data;
        } else {
          throw Exception('Token not found in response');
        }
      } else {
        throw Exception('Login failed: ${response.body}');
      }
    } catch (e) {
      developer.log('Login error details:');
      developer.log('Error type: ${e.runtimeType}');
      developer.log('Error message: $e');
      if (e is SocketException) {
        developer.log('Socket error details:');
        developer.log('Address: ${e.address}');
        developer.log('Port: ${e.port}');
        developer.log('OS Error: ${e.osError}');
      }
      throw Exception('Connection error: $e');
    }
  }

  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
    String confirmationPassword,
  ) async {
    try {
      developer.log('Attempting register with email: $email');
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(
          RegisterRequest(
            name: name,
            email: email,
            password: password,
            confirmationPassword: confirmationPassword,
          ).toJson(),
        ),
      );

      developer.log('Register response status: ${response.statusCode}');
      developer.log('Register response body: ${response.body}');

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Registration failed: ${response.body}');
      }
    } catch (e) {
      developer.log('Register error: $e');
      throw Exception('Error: $e');
    }
  }

  Future<UserResponse> getCurrentUser() async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      developer.log('Getting user profile with token: $token');
      final response = await http.get(
        Uri.parse('$baseUrl/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      developer.log('Profile response status: ${response.statusCode}');
      developer.log('Profile response body: ${response.body}');

      if (response.statusCode == 200) {
        return UserResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to get user data');
      }
    } catch (e) {
      developer.log('Get profile error: $e');
      throw Exception('Error: $e');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, false);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_tokenKey);
    _token = null;
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  Future<String?> getCurrentUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }
}
