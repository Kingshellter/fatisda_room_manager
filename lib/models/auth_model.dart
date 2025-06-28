class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }
}

class RegisterRequest {
  final String name;
  final String email;
  final String password;
  final String confirmationPassword;

  RegisterRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.confirmationPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': confirmationPassword,
    };
  }
}

class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final bool isAdmin;
  final String createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isAdmin,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      isAdmin: json['is_admin'] ?? false,
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'is_admin': isAdmin,
      'created_at': createdAt,
    };
  }
}

class UserResponse {
  final bool success;
  final String message;
  final User data;

  UserResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      success: json['success'],
      message: json['message'],
      data: User.fromJson(json['data']),
    );
  }
}

class AuthResponse {
  final bool success;
  final String message;
  final AuthData data;

  AuthResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'],
      message: json['message'],
      data: AuthData.fromJson(json['data']),
    );
  }
}

class AuthData {
  final User user;
  final String token;
  final String tokenType;

  AuthData({required this.user, required this.token, required this.tokenType});

  factory AuthData.fromJson(Map<String, dynamic> json) {
    return AuthData(
      user: User.fromJson(json['user']),
      token: json['token'],
      tokenType: json['token_type'],
    );
  }
}
