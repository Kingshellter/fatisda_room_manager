import 'package:flutter/material.dart';
import '../component/input_field.dart';
import '../component/auth_button.dart';
import '../component/auth_header.dart';
import '../component/custom_notification.dart';
import '../services/auth_service.dart';
import 'dart:convert';
import 'dart:developer' as developer;

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final AuthService authService = AuthService();
  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _onSignUpPressed() {
    _handleSignUp();
  }

  bool _validateInputs() {
    // Check if any field is empty
    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      CustomNotification.show(
        context,
        message: 'Please fill in all fields',
        type: NotificationType.warning,
        subtitle: 'All fields are required',
      );
      return false;
    }

    // Validate name length
    if (nameController.text.trim().length < 2) {
      CustomNotification.show(
        context,
        message: 'Invalid Name',
        type: NotificationType.warning,
        subtitle: 'Name must be at least 2 characters long',
      );
      return false;
    }

    // Validate email format
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(emailController.text.trim())) {
      CustomNotification.show(
        context,
        message: 'Invalid Email',
        type: NotificationType.warning,
        subtitle: 'Please enter a valid email address',
      );
      return false;
    }

    // Validate password length
    if (passwordController.text.length < 8) {
      CustomNotification.show(
        context,
        message: 'Password Too Short',
        type: NotificationType.warning,
        subtitle: 'Password must be at least 8 characters long',
      );
      return false;
    }

    // Check if passwords match
    if (passwordController.text != confirmPasswordController.text) {
      CustomNotification.show(
        context,
        message: 'Passwords Don\'t Match',
        type: NotificationType.warning,
        subtitle: 'Please make sure both passwords are the same',
      );
      return false;
    }

    return true;
  }

  Future<void> _handleSignUp() async {
    // Validate inputs first
    if (!_validateInputs()) return;

    setState(() {
      isLoading = true;
    });

    try {
      final response = await authService.register(
        nameController.text.trim(),
        emailController.text.trim(),
        passwordController.text,
        confirmPasswordController.text,
      );

      if (mounted) {
        if (response['success'] == true) {
          // Show success notification
          CustomNotification.show(
            context,
            message: 'Account Created Successfully!',
            type: NotificationType.success,
            subtitle: 'Login for your new account.',
          );

          // Wait a bit for the notification to show, then navigate back to login
          await Future.delayed(const Duration(milliseconds: 1000));
          if (mounted) {
            Navigator.pop(context);
          }
        } else {
          throw Exception('Registration failed: Invalid response format');
        }
      }
    } catch (e) {
      developer.log('Registration error: $e');
      if (mounted) {
        _handleRegistrationError(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _handleRegistrationError(String errorString) {
    String errorMessage = 'Registration Failed';
    String errorSubtitle = 'Please try again';

    try {
      // Try to parse the error string to get the actual response
      // The error string usually contains the full HTTP response
      if (errorString.contains('{') && errorString.contains('}')) {
        // Extract JSON from error string
        final jsonStart = errorString.indexOf('{');
        final jsonEnd = errorString.lastIndexOf('}') + 1;
        final jsonString = errorString.substring(jsonStart, jsonEnd);

        final errorData = Map<String, dynamic>.from(
          const JsonDecoder().convert(jsonString),
        );

        if (errorData['success'] == false && errorData['data'] != null) {
          final validationErrors = errorData['data'] as Map<String, dynamic>;
          final List<String> allErrors = [];

          // Extract all validation errors
          validationErrors.forEach((field, errors) {
            if (errors is List) {
              for (var error in errors) {
                allErrors.add(error.toString());
              }
            }
          });

          if (allErrors.isNotEmpty) {
            // Use the first error as the main message
            final firstError = allErrors.first;

            if (firstError.toLowerCase().contains('email')) {
              if (firstError.contains('already been taken')) {
                errorMessage = 'Email Already Registered';
                errorSubtitle =
                    'This email is already in use. Please try with a different email or sign in instead.';
              } else {
                errorMessage = 'Invalid Email';
                errorSubtitle = firstError;
              }
            } else if (firstError.toLowerCase().contains('password')) {
              if (firstError.contains('confirmation does not match')) {
                errorMessage = 'Passwords Don\'t Match';
                errorSubtitle =
                    'Please make sure both password fields are identical.';
              } else if (firstError.contains('at least')) {
                errorMessage = 'Password Too Short';
                errorSubtitle = firstError;
              } else {
                errorMessage = 'Password Error';
                errorSubtitle = firstError;
              }
            } else if (firstError.toLowerCase().contains('name')) {
              errorMessage = 'Invalid Name';
              errorSubtitle = firstError;
            } else {
              errorMessage = 'Validation Error';
              errorSubtitle = firstError;
            }

            // If there are multiple errors, add them to subtitle
            if (allErrors.length > 1) {
              errorSubtitle = allErrors.join(' ');
            }
          }
        } else if (errorData['message'] != null) {
          errorMessage = 'Registration Failed';
          errorSubtitle = errorData['message'].toString();
        }
      } else {
        // Handle non-JSON errors
        if (errorString.toLowerCase().contains('connection')) {
          errorMessage = 'Connection Error';
          errorSubtitle =
              'Please check your internet connection and try again.';
        } else if (errorString.toLowerCase().contains('timeout')) {
          errorMessage = 'Request Timeout';
          errorSubtitle =
              'The server is taking too long to respond. Please try again.';
        } else {
          errorMessage = 'Registration Failed';
          errorSubtitle = errorString
              .replaceAll('Exception: ', '')
              .replaceAll('Registration failed: ', '');
        }
      }
    } catch (parseError) {
      developer.log('Error parsing registration error: $parseError');
      // Fallback to simple error handling
      errorMessage = 'Registration Failed';
      errorSubtitle = errorString
          .replaceAll('Exception: ', '')
          .replaceAll('Registration failed: ', '');
    }

    CustomNotification.show(
      context,
      message: errorMessage,
      type: NotificationType.error,
      subtitle: errorSubtitle,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF4A4A6A), Color(0xFF3A3A5A), Color(0xFF2A2A4A)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Decorative circles
              Positioned(
                top: -50,
                right: -50,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
              ),
              Positioned(
                top: 100,
                left: -30,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),

              Column(
                children: [
                  // Header Section
                  Expanded(
                    flex: 2,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 40),
                          Text(
                            'Creat Your',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w300,
                              color: Colors.white.withValues(alpha: 0.9),
                              height: 1.2,
                            ),
                          ),
                          Text(
                            'Account',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Buat akunmu sekarang untuk mengakses semua fitur kami.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Form Section
                  Expanded(
                    flex: 4,
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(32),
                          topRight: Radius.circular(32),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 20,
                            offset: Offset(0, -8),
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(32),
                          topRight: Radius.circular(32),
                        ),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(32),
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Form indicator
                              Center(
                                child: Container(
                                  width: 40,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),

                              Text(
                                'Daftar Sekarang',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Lengkapi data berikut untuk membuat akun',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 32),

                              InputField(
                                label: 'Nama Lengkap',
                                controller: nameController,
                                obscureText: false,
                              ),
                              const SizedBox(height: 20),
                              InputField(
                                label: 'Email',
                                controller: emailController,
                                obscureText: false,
                              ),
                              const SizedBox(height: 20),
                              InputField(
                                label: 'Password',
                                controller: passwordController,
                                obscureText: true,
                              ),
                              const SizedBox(height: 20),
                              InputField(
                                label: 'Konfirmasi Password',
                                controller: confirmPasswordController,
                                obscureText: true,
                              ),
                              const SizedBox(height: 24),

                              // Password requirements
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.blue.shade200,
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          size: 16,
                                          color: Colors.blue.shade600,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Persyaratan Password:',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.blue.shade800,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '• Minimal 8 karakter\n• Pastikan password sama pada kedua field',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.blue.shade700,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 32),

                              AuthButton(
                                label: isLoading
                                    ? 'Creating Account...'
                                    : 'Buat Akun',
                                onPressed: isLoading ? null : _onSignUpPressed,
                                isLoading: isLoading,
                              ),
                              const SizedBox(height: 32),

                              // Sign in section
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Sudah punya akun? ",
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontSize: 14,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: isLoading
                                          ? null
                                          : () {
                                              Navigator.pop(context);
                                            },
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 0,
                                        ),
                                        minimumSize: Size.zero,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: Text(
                                        'Masuk Sekarang',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF3A3A5A),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
