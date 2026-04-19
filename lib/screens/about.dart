import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'committees.dart'; 

class AboutRoboCellPage extends StatelessWidget {
  const AboutRoboCellPage({super.key});

  // URL Launcher Helper using the modern Uri API
  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        debugPrint('Could not launch $urlString');
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

  void _viewCommittees(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CommitteesPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          _buildHeroHeader(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  _buildBrandSection(),
                  const SizedBox(height: 40),
                  
                  // Navigation Buttons
                  _buildIndustrialButton(
                    context, 
                    "COMMITTEE HERITAGE", 
                    Icons.account_tree_outlined, 
                    () => _viewCommittees(context)
                  ),
                  const SizedBox(height: 16),
                  _buildIndustrialButton(
                    context, 
                    "VIEW EVENTS", 
                    Icons.bolt_rounded, 
                    () => debugPrint("Navigate to Events Page")
                  ),

                  const SizedBox(height: 50),
                  _buildEstablishedCounter(),
                  const SizedBox(height: 60),
                  _buildSocialGrid(),
                  
                  const SizedBox(height: 80),
                  
                  // Team Tryanuka Signature
                  _buildSignature(),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroHeader() {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      backgroundColor: Colors.black,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: const Text("ROBOCELL • BIT", 
          style: TextStyle(
            fontSize: 12, 
            fontWeight: FontWeight.w900, 
            letterSpacing: 4,
            color: Colors.white
          )
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Opacity(
              opacity: 0.4,
              child: Image.asset(
                'assets/rcell.jpg', 
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[900]),
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label("MISSION"),
        const SizedBox(height: 12),
        const Text(
          "Forging the next generation of robotics engineers through radical innovation and decentralized development.",
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w300, height: 1.4),
        ),
        const SizedBox(height: 24),
        _label("VISION"),
        const SizedBox(height: 12),
        const Text(
          "To bridge the gap between academic theory and industrial autonomy through community-driven engineering.",
          style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.6),
        ),
      ],
    );
  }

  Widget _buildIndustrialButton(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF16A085).withOpacity(0.05),
          border: const Border(
            left: BorderSide(color: Color(0xFF16A085), width: 4),
            top: BorderSide(color: Colors.white10, width: 1),
            bottom: BorderSide(color: Colors.white10, width: 1),
            right: BorderSide(color: Colors.white10, width: 1),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF16A085), size: 20),
            const SizedBox(width: 15),
            Text(
              title, 
              style: const TextStyle(
                color: Colors.white, 
                fontWeight: FontWeight.bold, 
                letterSpacing: 2, 
                fontSize: 12
              )
            ),
            const Spacer(),
            const Icon(Icons.keyboard_arrow_right, color: Colors.white24, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildEstablishedCounter() {
    return Row(
      children: [
        const Text("EST.", style: TextStyle(color: Color(0xFF16A085), fontWeight: FontWeight.bold, fontSize: 10)),
        const SizedBox(width: 15),
        Expanded(child: Container(height: 0.5, color: Colors.white24)),
        const SizedBox(width: 15),
        const Text("2014", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w100)),
      ],
    );
  }

  Widget _buildSocialGrid() {
    return Column(
      children: [
        const Center(
          child: Text("EXTERNAL CHANNELS", 
            style: TextStyle(color: Colors.white24, fontSize: 9, letterSpacing: 3)
          )
        ),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _socialCircle("IG", "https://instagram.com/robocell_bit"),
            _socialCircle("FB", "https://facebook.com/robocell"),
            _socialCircle("LI", "https://linkedin.com/company/robocell"),
            _socialCircle("X", "https://x.com/robocell_bit"),
          ],
        ),
      ],
    );
  }

  Widget _socialCircle(String label, String url) {
    return InkWell(
      onTap: () => _launchURL(url),
      child: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white10),
        ),
        alignment: Alignment.center,
        child: Text(
          label, 
          style: const TextStyle(
            color: Color(0xFF16A085), 
            fontWeight: FontWeight.bold, 
            fontSize: 11
          )
        ),
      ),
    );
  }

  Widget _buildSignature() {
    return Center(
      child: Column(
        children: [
          const Text(
            "BUILT BY",
            style: TextStyle(
              color: Color.fromARGB(60, 2, 1, 1),
              fontSize: 8,
              letterSpacing: 4,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "TECH TRYANUKA",
            style: TextStyle(
              color: const Color(0xFF16A085).withOpacity(0.8),
              fontSize: 12,
              letterSpacing: 2,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text, 
      style: const TextStyle(
        color: Color(0xFF16A085), 
        fontSize: 10, 
        fontWeight: FontWeight.w900, 
        letterSpacing: 2
      )
    );
  }
}