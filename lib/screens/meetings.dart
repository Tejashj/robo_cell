import 'package:flutter/material.dart';

class MeetingsHistoryPage extends StatelessWidget {
  const MeetingsHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("MEETINGS & ATTENDANCE"),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- MOVE ATTENDANCE HERE ---
          _buildAttendanceCard(context),
          
          const SizedBox(height: 30),
          
          const Text("PAST SESSIONS", 
            style: TextStyle(color: Color(0xFF16A085), fontWeight: FontWeight.bold, letterSpacing: 1.5)
          ),
          const SizedBox(height: 15),
          
          // Meeting History List
          ..._pastMeetings.map((meeting) => _buildMeetingHistoryCard(meeting)).toList(),
        ],
      ),
    );
  }

  Widget _buildAttendanceCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF16A085).withOpacity(0.1),
        border: Border.all(color: const Color(0xFF16A085)),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          const Text("Are you in a meeting right now?", 
            style: TextStyle(color: Colors.white, fontSize: 14)
          ),
          const SizedBox(height: 15),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF16A085),
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 45),
            ),
            onPressed: () {
              // Implementation for check-in code
            },
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text("ENTER SESSION CODE", 
              style: TextStyle(fontWeight: FontWeight.bold)
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeetingHistoryCard(Map<String, dynamic> meeting) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: ExpansionTile(
        iconColor: const Color(0xFF16A085),
        title: Text(meeting['title'], 
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)
        ),
        subtitle: Text("${meeting['date']} • ${meeting['venue']}", 
          style: const TextStyle(fontSize: 12, color: Colors.grey)
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailSection("AGENDA", meeting['agenda']),
                const SizedBox(height: 16),
                _detailSection("ATTENDEES", meeting['attendees']),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Color(0xFFD8CFB4), fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(content, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4)),
      ],
    );
  }
}

final List<Map<String, dynamic>> _pastMeetings = [
  {
    "title": "Robothon '26 Planning",
    "date": "April 15, 2026",
    "venue": "Lab 402",
    "agenda": "• Finalizing prize pool distribution.\n• Selecting track themes (EV, Agri-Tech, IoT).",
    "attendees": "Tejas H J, Abhishek Rao, Havyas M O, +12 members"
  },
  {
    "title": "Budget Approval Q1",
    "date": "April 02, 2026",
    "venue": "Seminar Hall 1",
    "agenda": "• Review of sponsorship from Robu.\n• Allocation for new soldering stations.",
    "attendees": "Management Committee, Faculty Coordinator"
  },
];