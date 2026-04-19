import 'package:flutter/material.dart';
import 'login.dart'; // 🔥 make sure path is correct

class ProfilePage extends StatelessWidget {
  final Map<String, dynamic> user;

  const ProfilePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final String name = user['name'] ?? '';
    final String usn = user['usn'] ?? '';
    final String role = user['role'] ?? '';
    final String photoUrl = user['photo_url'] ?? '';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("MEMBER PROFILE"),
        backgroundColor: Colors.black,
        foregroundColor: const Color(0xFFD8CFB4),
        actions: [
          // 🔥 LOGOUT BUTTON (UPDATED)
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
                    (route) => false,
              );
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // 🔥 Profile Photo
            CircleAvatar(
              radius: 60,
              backgroundColor: const Color(0xFF16A085),
              child: CircleAvatar(
                radius: 57,
                backgroundColor: Colors.black,
                backgroundImage:
                photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                child: photoUrl.isEmpty
                    ? const Icon(
                  Icons.person,
                  size: 50,
                  color: Color(0xFF16A085),
                )
                    : null,
              ),
            ),

            const SizedBox(height: 15),

            // 🔥 Name
            Text(
              name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFFD8CFB4),
              ),
            ),

            // 🔥 USN + ROLE
            Text(
              "$usn | ${role.toUpperCase()}",
              style: const TextStyle(
                color: Color(0xFF16A085),
                letterSpacing: 1.2,
              ),
            ),

            const SizedBox(height: 30),
            const Divider(color: Colors.white10, indent: 30, endIndent: 30),
            const SizedBox(height: 30),

            // 🔐 Change Password Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white10,
                  side: const BorderSide(color: Color(0xFFD8CFB4)),
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  // 🔥 Next step feature
                },
                child: const Text(
                  "CHANGE PASSWORD",
                  style: TextStyle(color: Color(0xFFD8CFB4)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}