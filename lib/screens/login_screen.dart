import 'package:flutter/material.dart';
import 'signup_screen.dart';
import 'forgotpassword_screen.dart';
import '../component/input_field.dart';
import '../component/auth_button.dart';
import '../component/auth_header.dart';
import '../component/custom_notification.dart'; // Add this import
import '../services/auth_service.dart';

import 'dart:developer' as developer;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    _handleLogin(); // Remove the isLoading check since button is now disabled
  }

  Future<void> _handleLogin() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      CustomNotification.show(
        context,
        message: 'Please fill in all fields',
        type: NotificationType.warning,
        subtitle: 'Email and password are required',
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final authService = AuthService();
      final response = await authService.login(
        emailController.text.trim(),
        passwordController.text,
      );

      if (response['success'] == true && response['data'] != null) {
        if (mounted) {
          CustomNotification.show(
            context,
            message: 'Welcome back!',
            type: NotificationType.success,
            subtitle: 'Hello, ${response['data']['user']['name']}',
          );

          // Wait a bit for the notification to show, then navigate
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) {
            Navigator.pop(context, true);
          }
        }
      } else {
        throw Exception('Login failed: Invalid response format');
      }
    } catch (e) {
      developer.log('Login error: $e');
      if (mounted) {
        CustomNotification.show(
          context,
          message: 'Login Failed',
          type: NotificationType.error,
          subtitle: e.toString().replaceAll('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
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
        child: SafeArea(
          child: Stack(
            children: [
              // Back Button
              Positioned(
                top: 0,
                left: 0,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              // Main Content
              Column(
                children: [
                  const AuthHeader(title: 'Hallo,\nMahasiswa Fatisda!'),
                  Expanded(
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 24),
                            InputField(
                              controller: emailController,
                              label: 'Email',
                              obscureText: false,
                            ),
                            const SizedBox(height: 16),
                            InputField(
                              controller: passwordController,
                              label: 'Password',
                              obscureText: true,
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const ForgotPasswordScreen(),
                                          ),
                                        );
                                      },
                                child: const Text(
                                  'Lupa Password?',
                                  style: TextStyle(color: Colors.black87),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            AuthButton(
                              label: isLoading ? 'Signing In...' : 'Sign In',
                              onPressed: isLoading ? null : _onLoginPressed,
                              isLoading: isLoading,
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Belum punya akun?",
                                  style: TextStyle(color: Colors.black87),
                                ),
                                TextButton(
                                  onPressed: isLoading
                                      ? null
                                      : () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const SignUpScreen(),
                                            ),
                                          );
                                        },
                                  child: const Text(
                                    'Sign Up',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF3A3A5A),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
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
