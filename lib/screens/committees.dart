import 'package:flutter/material.dart';

class CommitteesPage extends StatelessWidget {
  const CommitteesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("COMMITTEE HERITAGE"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionHeader("CURRENT COMMITTEE (2026-27)"),
          _memberCard("Tejas H J", "President", "1BI23RI052", 'assets/tejas.jpg'),
          _memberCard("Lasya N S", "Vice President", "1BI23RI028", 'assets/lasya.jpg'),
          const SizedBox(height: 20),
          const Divider(height: 40, color: Colors.white24),
          _sectionHeader("PREVIOUS COMMITTEE (2025-26)"),
          _memberCard("Alumni Lead", "Ex-President", "1BI22RIxxx", 'assets/alumni.jpg'),
        ],
      ),
    );
  }

  Widget _sectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 16),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF16A085),
          fontWeight: FontWeight.bold, 
          letterSpacing: 1.2,
          fontSize: 13
        ),
      ),
    );
  }

  Widget _memberCard(String name, String role, String usn, String imagePath) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: const Color(0xFF1E1E1E), // Slightly lighter than background
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Profile Picture Circle
            CircleAvatar(
              radius: 35,
              backgroundColor: const Color(0xFF16A085),
              // Use BackgroundImage for local assets:
              // backgroundImage: AssetImage(imagePath), 
              child: const Icon(Icons.person, color: Colors.white, size: 30), // Placeholder icon
            ),
            const SizedBox(width: 20),
            // Text Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    role,
                    style: const TextStyle(
                      color: Color(0xFF16A085),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "USN: $usn",
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
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