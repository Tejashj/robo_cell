import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("MEMBER PROFILE"),
        backgroundColor: Colors.black,
        foregroundColor: const Color(0xFFD8CFB4),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // --- Profile Photo & Header ---
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: const Color(0xFF16A085),
                    child: CircleAvatar(
                      radius: 57,
                      backgroundImage: AssetImage('assets/rcell.jpg'), // Placeholder
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: const Color(0xFF16A085),
                      radius: 18,
                      child: Icon(Icons.edit, size: 18, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            const Text("Tejas H J", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFD8CFB4))),
            const Text("1BI23RI052 | PRESIDENT", style: TextStyle(color: Color(0xFF16A085), letterSpacing: 1.2)),
            
            const SizedBox(height: 30),
            
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatColumn("75%", "Attendance"),
                _buildStatColumn("12", "Meetings"),
                _buildStatColumn("3", "Projects"),
              ],
            ),

            const SizedBox(height: 30),
            const Divider(color: Colors.white10, indent: 30, endIndent: 30),

            // --- Details List ---
            _buildProfileTile(Icons.email_outlined, "Email", "tejas@bit.edu"),
            _buildProfileTile(Icons.link, "LinkedIn", "linkedin.com/in/tejas"),
            _buildProfileTile(Icons.history, "Committee History", "View Legacy"),
            
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white10,
                  side: const BorderSide(color: Color(0xFFD8CFB4)),
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {},
                child: const Text("CHANGE PASSWORD", style: TextStyle(color: Color(0xFFD8CFB4))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String val, String label) {
    return Column(
      children: [
        Text(val, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildProfileTile(IconData icon, String title, String value) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF16A085)),
      title: Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),
      subtitle: Text(value, style: const TextStyle(color: Colors.white, fontSize: 16)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white24),
    );
  }
}