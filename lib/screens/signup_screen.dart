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
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF3A3A5A), Colors.white],
          ),
        ),
        child: Stack(
          children: [
            Column(
              children: [
                const AuthHeader(title: 'Buat\nAkun Baru'),
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, -4),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),
                          InputField(
                            label: 'Full Name',
                            controller: nameController,
                            obscureText: false,
                          ),
                          const SizedBox(height: 16),
                          InputField(
                            label: 'Email',
                            controller: emailController,
                            obscureText: false,
                          ),
                          const SizedBox(height: 16),
                          InputField(
                            label: 'Password',
                            controller: passwordController,
                            obscureText: true,
                          ),
                          const SizedBox(height: 16),
                          InputField(
                            label: 'Confirm Password',
                            controller: confirmPasswordController,
                            obscureText: true,
                          ),
                          const SizedBox(height: 32),
                          AuthButton(
                            label: isLoading
                                ? 'Creating Account...'
                                : 'Sign Up',
                            onPressed: isLoading ? null : _onSignUpPressed,
                            isLoading: isLoading,
                          ),
                          const SizedBox(height: 60),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Back button and Sign In text at the bottom
            Positioned(
              left: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Sudah Punya Akun?",
                    style: TextStyle(color: Colors.black),
                  ),
                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            Navigator.pop(context); // Go back to login screen
                          },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Sign In',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                        color: isLoading ? Colors.grey : Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
