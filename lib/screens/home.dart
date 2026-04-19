import 'package:flutter/material.dart';
import 'chat.dart';
import 'activity.dart';
import 'profile.dart';
import 'committees.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;
  final List<Widget> _tabs = [const HomeContent(), const ChatPage(), const ActivityPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // LOGO CLICK -> ABOUT CLUB
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const CommitteesPage())),
            child: Image.asset('assets/rcell.jpg'),
          ),
        ),
        title: const Text("ROBOCELL"),
        actions: [
          IconButton(
            icon: const CircleAvatar(
              radius: 15, 
              backgroundColor: Color(0xFF16A085), 
              child: Icon(Icons.person, size: 18, color: Colors.black)
            ),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const CommitteesPage())),
          )
        ],
      ),
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        selectedItemColor: const Color(0xFF16A085),
        unselectedItemColor: const Color(0xFFD8CFB4).withOpacity(0.4),
        backgroundColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: "Feed"),
          BottomNavigationBarItem(icon: Icon(Icons.forum), label: "Chat"),
          BottomNavigationBarItem(icon: Icon(Icons.bolt), label: "Activity"),
        ],
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle("NEXT MEETING"),
                _buildMeetingCard(),
                const SizedBox(height: 25),
                _sectionTitle("EXTERNAL OPPORTUNITIES"),
                SizedBox(
                  height: 100,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildExternalCard("IITM Shaastra", "April 28"),
                      _buildExternalCard("NITK Incident", "May 05"),
                      _buildExternalCard("RVCE 8th Mile", "May 12"),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                _sectionTitle("WALL OF FAME"),
              ],
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildAchievementCard(index),
            childCount: 5, 
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(title, style: const TextStyle(color: Color(0xFFD8CFB4), letterSpacing: 1.5, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  Widget _buildMeetingCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16A085).withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF16A085).withOpacity(0.5)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Core Committee Sync", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text("4:00 PM", style: TextStyle(color: Color(0xFF16A085), fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 8),
          Text("Venue: Robotics Lab (Room 402)", style: TextStyle(color: Colors.white70, fontSize: 13)),
          Divider(height: 20, color: Colors.white24),
          Text("AGENDA:", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFD8CFB4))),
          Text("• Robothon '26 Budget\n• Lab Inventory Audit\n• Outreach review", 
            style: TextStyle(fontSize: 12, height: 1.5, color: Colors.white60)),
        ],
      ),
    );
  }

  Widget _buildExternalCard(String name, String date) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white12)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Text(date, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ListTile(
            leading: CircleAvatar(backgroundColor: Colors.white10, child: Icon(Icons.campaign, color: Color(0xFF16A085))),
            title: Text("Media Team", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            subtitle: Text("2 hours ago", style: TextStyle(fontSize: 11)),
          ),
          Container(height: 180, width: double.infinity, color: Colors.white10, child: const Icon(Icons.image, color: Colors.white24)),
          const Padding(
            padding: EdgeInsets.all(15.0),
            child: Text(
              "Massive congratulations to the team for securing the top spot at Anveshana '26! Their autonomous drone project impressed the judges.",
              style: TextStyle(fontSize: 13, color: Colors.white70, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}