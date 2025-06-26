class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
  };
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

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'password': password,
    'confirmation_password': confirmationPassword,
  };
}

class UserResponse {
  final String name;
  final String email;

  UserResponse({required this.name, required this.email});

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      name: json['name'],
      email: json['email'],
    );
  }
}
