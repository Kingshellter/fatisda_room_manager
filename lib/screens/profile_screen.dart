import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/auth_model.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Mahasiswa'),
        backgroundColor: const Color(0xFF3A3A5A),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFF3A3A5A),
              child: Icon(
                Icons.person,
                size: 50,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            FutureBuilder<UserResponse>(
              future: authService.getCurrentUser(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Column(
                    children: [
                      Text(snapshot.data!.name),
                      Text(snapshot.data!.email),
                    ],
                  );
                }
                return CircularProgressIndicator();
              },
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () async {
                await authService.logout();
                if (context.mounted) {
                  Navigator.of(context).pop(); // Go back to main screen
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 