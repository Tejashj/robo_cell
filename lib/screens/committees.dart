import 'package:flutter/material.dart';

class CommitteesPage extends StatelessWidget {
  const CommitteesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("COMMITTEE HERITAGE")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _sectionHeader("CURRENT COMMITTEE (2026-27)"),
          _memberTile("Tejas H J", "President", "1BI23RI052"),
          _memberTile("Lasya N S", "Vice President", "1BI23RI028"),
          const Divider(height: 40, color: Colors.white10),
          _sectionHeader("PREVIOUS COMMITTEE (2025-26)"),
          _memberTile("Alumni Lead", "Ex-President", "1BI22RIxxx"),
        ],
      ),
    );
  }

  Widget _sectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(text, style: const TextStyle(color: Color(0xFF16A085), fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  Widget _memberTile(String name, String role, String usn) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(name),
      subtitle: Text("$role | $usn", style: const TextStyle(color: Colors.grey, fontSize: 12)),
    );
  }
}

// --- NEW ABOUT ROBOCELL PAGE ---
class AboutRoboCellPage extends StatelessWidget {
  const AboutRoboCellPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ABOUT ROBOCELL")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Image.asset('assets/rcell.jpg', height: 120)),
            const SizedBox(height: 30),
            const Text("OUR MISSION", style: TextStyle(color: Color(0xFF16A085), fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text(
              "RoboCell is the premier robotics and automation department of the Bangalore Institute of Technology. We are dedicated to fostering innovation, technical excellence, and hands-on engineering skills among students.",
              style: TextStyle(color: Colors.white70, height: 1.5),
            ),
            const SizedBox(height: 30),
            const Text("THE VISION", style: TextStyle(color: Color(0xFF16A085), fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text(
              "To bridge the gap between theoretical academia and industrial application through decentralized robotic ecosystems and community-driven projects.",
              style: TextStyle(color: Colors.white70, height: 1.5),
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(15)),
              child: const Column(
                children: [
                  Text("ESTABLISHED", style: TextStyle(color: Color(0xFFD8CFB4), fontSize: 10)),
                  Text("2014", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}