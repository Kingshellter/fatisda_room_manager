import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_model.dart';
import 'api_client.dart';
import 'dart:developer' as developer;

class AuthService {
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _userEmailKey = 'userEmail';
  static const String _tokenKey = 'auth_token';

  final ApiClient _apiClient = ApiClient();
  String? _token;

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

      final requestBody = LoginRequest(
        email: email,
        password: password,
      ).toJson();

      final response = await _apiClient.post('/login', body: requestBody);

      // Use ApiClient's response handler
      final data = _apiClient.handleResponse<Map<String, dynamic>>(
        response,
        (data) => data,
      );

      if (data['success'] == true &&
          data['data'] != null &&
          data['data']['token'] != null) {
        await saveToken(data['data']['token']);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_isLoggedInKey, true);
        await prefs.setString(_userEmailKey, email);
        return data;
      } else {
        throw Exception('Token not found in response');
      }
    } catch (e) {
      developer.log('Login error: $e');
      throw Exception('Login failed: $e');
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

      final requestBody = RegisterRequest(
        name: name,
        email: email,
        password: password,
        confirmationPassword: confirmationPassword,
      ).toJson();

      final response = await _apiClient.post('/register', body: requestBody);

      // Use ApiClient's response handler
      final data = _apiClient.handleResponse<Map<String, dynamic>>(
        response,
        (data) => data,
      );

      if (data['success'] == true &&
          data['data'] != null &&
          data['data']['token'] != null) {
        await saveToken(data['data']['token']);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_isLoggedInKey, true);
        await prefs.setString(_userEmailKey, email);
      }
      return data;
    } catch (e) {
      developer.log('Register error: $e');
      throw Exception('Registration failed: $e');
    }
  }

  Future<UserResponse> getCurrentUser() async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      developer.log(
        'Getting user profile with token: ${token.substring(0, 20)}...',
      );

      final response = await _apiClient.get('/me', token: token);

      return _apiClient.handleResponse<UserResponse>(
        response,
        (data) => UserResponse.fromJson(data),
        onUnauthorized: () async => await logout(),
      );
    } catch (e) {
      developer.log('Get profile error: $e');
      throw Exception('Error getting user profile: $e');
    }
  }

  Future<void> logout() async {
    try {
      final token = await getToken();
      if (token != null) {
        // Call logout API
        await _apiClient.post('/logout', token: token);
      }
    } catch (e) {
      developer.log('Logout API error: $e');
      // Continue with local logout even if API fails
    } finally {
      // Clear local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isLoggedInKey, false);
      await prefs.remove(_userEmailKey);
      await prefs.remove(_tokenKey);
      _token = null;
    }
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
    final token = prefs.getString(_tokenKey);

    // If logged in but no token, clear the logged in status
    if (isLoggedIn && token == null) {
      await prefs.setBool(_isLoggedInKey, false);
      return false;
    }

    return isLoggedIn;
  }

  Future<String?> getCurrentUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  // Helper method to check if token is valid
  Future<bool> isTokenValid() async {
    try {
      await getCurrentUser();
      return true;
    } catch (e) {
      return false;
    }
  }
}
