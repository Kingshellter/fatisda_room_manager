import 'package:flutter/material.dart';
import 'component/input_field.dart';
import 'component/auth_button.dart';
import 'component/auth_header.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController confirmPasswordController = TextEditingController();

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
                const AuthHeader(title: 'Create\nNew Account'),
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
                        )
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
                            label: 'Sign Up',
                            onPressed: () {
                              print('Sign Up Pressed');
                              // TODO: Implement sign up logic
                            },
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
                    "Already have an account?",
                    style: TextStyle(color: Colors.black),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Go back to login screen
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Sign In',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                        color: Colors.black,
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