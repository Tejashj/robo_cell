import 'package:flutter/material.dart';

class MeetingsHistoryPage extends StatelessWidget {
  const MeetingsHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("MEETING ARCHIVE"),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _pastMeetings.length,
        itemBuilder: (context, index) {
          final meeting = _pastMeetings[index];
          return _buildMeetingHistoryCard(meeting);
        },
      ),
    );
  }

  Widget _buildMeetingHistoryCard(Map<String, dynamic> meeting) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: ExpansionTile(
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF16A085).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.history, color: Color(0xFF16A085), size: 20),
        ),
        title: Text(meeting['title'], 
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)
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
                const Divider(color: Colors.white10),
                const SizedBox(height: 8),
                _detailSection("AGENDA", meeting['agenda']),
                const SizedBox(height: 16),
                _detailSection("ATTENDEES", meeting['attendees']),
                const SizedBox(height: 8),
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
        Text(title, 
          style: const TextStyle(
            color: Color(0xFFD8CFB4), 
            fontSize: 10, 
            fontWeight: FontWeight.bold, 
            letterSpacing: 1
          )
        ),
        const SizedBox(height: 6),
        Text(content, 
          style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.5)
        ),
      ],
    );
  }
}

// Mock Data for RoboCell Meetings
final List<Map<String, dynamic>> _pastMeetings = [
  {
    "title": "Robothon '26 Planning",
    "date": "April 15, 2026",
    "venue": "Lab 402",
    "agenda": "• Finalizing prize pool distribution.\n• Selecting track themes (EV, Agri-Tech, IoT).\n• Volunteer recruitment strategy.",
    "attendees": "Tejas H J, Abhishek Rao, Havyas M O, +12 Core Members"
  },
  {
    "title": "Budget Approval Q1",
    "date": "April 02, 2026",
    "venue": "Seminar Hall 1",
    "agenda": "• Review of sponsorship from Robu.\n• Allocation for new soldering stations.\n• Reimbursements for Anveshana participants.",
    "attendees": "Management Committee, Finance Head, Faculty Coordinator"
  },
  {
    "title": "Tech Stack Discussion",
    "date": "March 20, 2026",
    "venue": "Online (Discord)",
    "agenda": "• Choosing between Supabase and Firebase for the Club App.\n• API documentation standards for the Dev Team.",
    "attendees": "Tejas H J, App Dev Team"
  },
];