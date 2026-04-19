import 'package:flutter/material.dart';
import 'chat.dart';
import 'activity.dart';
import 'profile.dart';
import 'committees.dart';
import 'createpost.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;
  final List<Widget> _tabs = const [
    HomeContent(),    // now contains its own fixed button at the bottom
    ChatPage(),
    ActivityPage()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
              child: Icon(Icons.person, size: 18, color: Colors.black),
            ),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const ProfilePage(user: {}))),
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

// ---------------------------------------------------------------------
// HomeContent – scrollable feed with a fixed button at the bottom
// (button appears once, directly above the bottom navigation bar)
// ---------------------------------------------------------------------
class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    // Feed items (no button inside the list – button will be separate)
    final List<Widget> feedItems = [
      _buildMeetingPost(),
      _buildStandardPost(
        label: "ACHIEVEMENTS",
        icon: Icons.stars,
        author: "Media Team",
        time: "2 hours ago",
        text: "Massive congratulations to the team for securing the top spot at Anveshana '26!",
      ),
      // add more posts as needed
    ];

    // Use a Column: feed expands, button sits at bottom
    return Column(
      children: [
        // Scrollable feed area
        Expanded(
          child: CustomScrollView(
            slivers: [
              const SliverPadding(
                padding: EdgeInsets.symmetric(vertical: 20),
                sliver: SliverToBoxAdapter(
                  child: Center(
                    child: Text("COMMUNITY FEED",
                      style: TextStyle(color: Color(0xFFD8CFB4), fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold)
                    ),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: feedItems[index % feedItems.length],
                  ),
                  childCount: feedItems.length, // no repetition of button
                ),
              ),
            ],
          ),
        ),
        // Fixed button – appears once, above the bottom navigation bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreatePostPage()),
              );
            },
            icon: const Icon(Icons.edit_note, size: 20),
            label: const Text("CREATE NEW POST", style: TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF16A085),
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  // --- REUSABLE WRAPPER (unchanged) ---
  Widget _feedWrapper({required String label, required IconData icon, required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: const Color(0xFF16A085)),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(color: Color(0xFFD8CFB4), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildStandardPost({required String label, required IconData icon, required String author, required String time, required String text}) {
    return _feedWrapper(
      label: label, icon: icon,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(radius: 12, backgroundColor: Colors.white10, child: Icon(Icons.person, size: 14, color: Colors.white)),
              const SizedBox(width: 8),
              Text(author, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const Spacer(),
              Text(time, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 180, width: double.infinity,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.image, color: Colors.white12, size: 40),
          ),
          const SizedBox(height: 12),
          Text(text, style: const TextStyle(fontSize: 13, color: Colors.white70, height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildMeetingPost() {
    return _feedWrapper(
      label: "UPCOMING MEETING", icon: Icons.event,
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
          SizedBox(height: 4),
          Text("Venue: Robotics Lab (Room 402)", style: TextStyle(color: Colors.white60, fontSize: 13)),
          Divider(height: 24, color: Colors.white10),
          Text("AGENDA:", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
          SizedBox(height: 4),
          Text("• Robothon '26 Budget\n• Lab Inventory Audit", style: TextStyle(fontSize: 12, height: 1.6, color: Colors.white70)),
        ],
      ),
    );
  }
}