import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("ROBOCELL CHANNELS"),
        backgroundColor: Colors.black,
        foregroundColor: const Color(0xFFD8CFB4),
      ),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          _buildChannelTile(Icons.public, "General Announcements", "Tejas: Meeting tomorrow at 4!", true),
          _buildChannelTile(Icons.security, "Core Committee", "Lasya: Budget approved.", false),
          _buildChannelTile(Icons.brush, "Media & Design", "Riya: New poster is ready.", false),
          _buildChannelTile(Icons.build, "Technical Team", "Havyas: ESP32 code updated.", true),
        ],
      ),
    );
  }

  Widget _buildChannelTile(IconData icon, String name, String lastMsg, bool hasUnread) {
    return Card(
      color: Colors.white.withOpacity(0.05),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF16A085).withOpacity(0.2),
          child: Icon(icon, color: const Color(0xFF16A085)),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD8CFB4))),
        subtitle: Text(lastMsg, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
        trailing: hasUnread 
          ? const CircleAvatar(radius: 5, backgroundColor: Color(0xFF16A085)) 
          : const Icon(Icons.chevron_right, color: Colors.white24),
        onTap: () {
          // Navigate to the actual chat conversation
        },
      ),
    );
  }
}