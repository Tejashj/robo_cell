import 'package:flutter/material.dart';

class ActivityPage extends StatelessWidget {
  const ActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("LOGISTICS & OPS"),
        backgroundColor: Colors.black,
        foregroundColor: const Color(0xFFD8CFB4),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SECTION 1: PROJECT ITEM RESERVATION ---
            const Text("RESERVE PROJECT ITEMS", 
              style: TextStyle(color: Color(0xFF16A085), fontWeight: FontWeight.bold, letterSpacing: 1.5)
            ),
            const SizedBox(height: 8),
            const Text("Request components from the lab inventory", 
              style: TextStyle(color: Colors.grey, fontSize: 12)
            ),
            const SizedBox(height: 15),
            
            // Horizontal scroll for quick categories or featured items
            SizedBox(
              height: 160,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildInventoryCard("ESP32-S3", "5 Units Left", Icons.memory),
                  _buildInventoryCard("Li-Po 11.1V", "2 Units Left", Icons.battery_charging_full),
                  _buildInventoryCard("Ultrasonic", "12 Units Left", Icons.settings_input_antenna),
                  _buildInventoryCard("Servo MG996R", "8 Units Left", Icons.precision_manufacturing),
                ],
              ),
            ),

            const SizedBox(height: 35),

            // --- SECTION 2: EVENT CALENDAR ---
            const Text("EVENT CALENDAR", 
              style: TextStyle(color: Color(0xFF16A085), fontWeight: FontWeight.bold, letterSpacing: 1.5)
            ),
            const SizedBox(height: 15),
            _buildEventTile("Robothon '26", "May 20-21", "Main Lab"),
            _buildEventTile("IoT Workshop", "May 28", "Seminar Hall"),
            _buildEventTile("Annual Tech Expo", "June 10", "Main Ground"),

            const SizedBox(height: 35),

            // --- SECTION 3: QUICK ACTIONS ---
            const Text("QUICK LINKS", 
              style: TextStyle(color: Color(0xFF16A085), fontWeight: FontWeight.bold, letterSpacing: 1.5)
            ),
            const SizedBox(height: 15),
            _buildQuickActionTile("Report Equipment Damage", Icons.report_problem_outlined),
            _buildQuickActionTile("Lab Access Request", Icons.door_front_door_outlined),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryCard(String name, String status, IconData icon) {
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFF16A085), size: 30),
          const SizedBox(height: 12),
          Text(name, 
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)
          ),
          const SizedBox(height: 4),
          Text(status, 
            style: const TextStyle(color: Colors.white54, fontSize: 10)
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF16A085).withOpacity(0.2),
              borderRadius: BorderRadius.circular(5),
            ),
            child: const Text("RESERVE", style: TextStyle(color: Color(0xFF16A085), fontSize: 9, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  Widget _buildEventTile(String title, String date, String venue) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        border: Border.all(color: Colors.white10),
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

  Widget _buildQuickActionTile(String title, IconData icon) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.grey),
      title: Text(title, style: const TextStyle(color: Colors.white70, fontSize: 14)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white24),
      onTap: () {},
    );
  }
}