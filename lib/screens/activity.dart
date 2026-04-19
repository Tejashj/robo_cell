import 'package:flutter/material.dart';

class ActivityPage extends StatelessWidget {
  const ActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("LOGISTICS & EVENTS"),
        backgroundColor: Colors.black,
        foregroundColor: const Color(0xFFD8CFB4),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SECTION 1: ATTENDANCE ---
            const Text("ATTENDANCE", style: TextStyle(color: Color(0xFF16A085), fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            const SizedBox(height: 15),
            _buildAttendanceCard(context),

            const SizedBox(height: 35),

            // --- SECTION 2: SCHEDULED MEETINGS ---
            const Text("UPCOMING MEETINGS", style: TextStyle(color: Color(0xFF16A085), fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            const SizedBox(height: 15),
            _buildMeetingTile("General Body Meet", "Tomorrow, 4:00 PM", "Room 402"),
            _buildMeetingTile("Core Committee Sync", "April 22, 5:30 PM", "Online/Discord"),

            const SizedBox(height: 35),

            // --- SECTION 3: EVENT CALENDAR ---
            const Text("EVENT CALENDAR", style: TextStyle(color: Color(0xFF16A085), fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            const SizedBox(height: 15),
            _buildEventTile("Robothon '26", "May 20-21", "Main Lab"),
            _buildEventTile("IoT Workshop", "May 28", "Seminar Hall"),
          ],
        ),
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
          const Text("Are you in a meeting right now?", style: TextStyle(color: Colors.white, fontSize: 14)),
          const SizedBox(height: 15),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF16A085),
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 45),
            ),
            onPressed: () {
              // This is where members enter the 4-digit code
            },
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text("ENTER SESSION CODE", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildMeetingTile(String title, String time, String location) {
    return Card(
      color: Colors.white.withOpacity(0.05),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.groups, color: Color(0xFFD8CFB4)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("$time • $location"),
        trailing: const Icon(Icons.notifications_none, size: 20),
      ),
    );
  }

  Widget _buildEventTile(String title, String date, String venue) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white24),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Color(0xFFD8CFB4), fontWeight: FontWeight.bold)),
              Text(venue, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          Text(date, style: const TextStyle(color: Color(0xFF16A085), fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}