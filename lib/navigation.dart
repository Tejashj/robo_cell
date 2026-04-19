import 'package:flutter/material.dart';
import 'screens/home.dart';
import 'screens/chat.dart';
import 'screens/activity.dart';
import 'screens/profile.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeContent(), // Dashboard + Announcements
    const ChatPage(),
    const ActivityPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Leading Logo
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('assets/rcell.jpg'),
        ),
        title: const Text("ROBOCELL"),
        actions: [
          // PROPER TOP-RIGHT PROFILE ACCESS
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: GestureDetector(
              onTap: () => Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => const ProfilePage())
              ),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Color(0xFF16A085),
                  shape: BoxShape.circle,
                ),
                child: const CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.black,
                  child: Icon(Icons.person_outline, size: 18, color: Color(0xFF16A085)),
                ),
              ),
            ),
          ),
        ],
      ),

      // IndexedStack preserves scroll state on all pages
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: const Color(0xFF16A085),
        unselectedItemColor: const Color(0xFFD8CFB4).withOpacity(0.4),
        backgroundColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: "Feed"),
          BottomNavigationBarItem(icon: Icon(Icons.forum_rounded), label: "Chat"),
          BottomNavigationBarItem(icon: Icon(Icons.bolt_rounded), label: "Ops"),
          BottomNavigationBarItem(icon: Icon(Icons.meeting_room_rounded), label: "Meetings"),
          
        ],
      ),
    );
  }
}