import 'package:flutter/material.dart';
import 'signup_screen.dart';
import 'forgotpassword_screen.dart';
import '../component/input_field.dart';
import '../component/auth_button.dart';
import '../component/auth_header.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

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
            // Back Button
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 10,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            
            Column(
              children: [
                // Header yang dipisah
                const AuthHeader(title: 'Hallo,\nMahasiswa Fatisda!'),

                // Bagian bawah: form login
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
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                             onPressed: () {
                              Navigator.push(
                               context,
                               MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                               );
                              },
                              child: const Text(
                                'Lupa Password?',
                                style: TextStyle(color: Colors.black87),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Tombol SIGN IN dari komponen terpisah
                         AuthButton(
                          label: 'Sign In',
                          onPressed: () {
                           print('Sign In Pressed');
                            // TODO: tambahkan logika sign in
                            },
                          ),
                          const SizedBox(height: 60), // Spasi bawah
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Teks dan tombol Sign Up di kanan bawah
            Positioned(
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "belum punya akun?",
                    style: TextStyle(color: Colors.black),
                  ),
                  TextButton(
                    onPressed: () {
                      print('Sign Up Pressed');
                      // TODO: Navigate to Sign Up screen
                       Navigator.push(
                       context,
                      MaterialPageRoute(builder: (context) => const SignUpScreen()),
                       );
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Sign Up',
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