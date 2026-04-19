import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';


class CommitteesPage extends StatelessWidget {
  const CommitteesPage({super.key});

  // This ensures the single/double cards match the width of the 4-row cards
  double _getCardWidth(BuildContext context) {
    // Screen width - padding - gaps / 4 columns
    return (MediaQuery.of(context).size.width - 32 - (8 * 3)) / 4;
  }

  @override
  Widget build(BuildContext context) {
    final double cardWidth = _getCardWidth(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("ROBOCELL COMMITTEE", 
          style: TextStyle(letterSpacing: 3, fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          children: [
            // --- FACULTY ADVISORS ---
            _sectionLabel("FACULTY "),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                SizedBox(width: cardWidth, child: const MemberCard(name: "Dr. Advisor", role: "Faculty", img: "assets/f1.jpg")),
                SizedBox(width: cardWidth, child: const MemberCard(name: "Prof. Advisor", role: "Faculty", img: "assets/f2.jpg")),
              ],
            ),
            const SizedBox(height: 30),

            // --- PRESIDENT ---
            _sectionLabel("CORE COMMITTEE"),
            Center(
              child: SizedBox(
                width: cardWidth,
                child: const MemberCard(name: "Tejas H J", role: "President", img: "assets/tejas.jpg"),
              ),
            ),
            const SizedBox(height: 20),

            // --- VICE PRESIDENTS ---
            Wrap(
              spacing: 8,
              alignment: WrapAlignment.center,
              children: [
                SizedBox(width: cardWidth, child: const MemberCard(name: "Lasya N S", role: "VP", img: "assets/lasya.jpg")),
                SizedBox(width: cardWidth, child: const MemberCard(name: "VP Name", role: "VP", img: "assets/vp2.jpg")),
              ],
            ),
            const SizedBox(height: 20),

            // --- CORE EXECUTIVES (The 4-Row Reference) ---
           
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _fixedCard(cardWidth, "Name", "Treasurer", "assets/m1.jpg"),
                _fixedCard(cardWidth, "Name", "Secretary", "assets/m2.jpg"),
                _fixedCard(cardWidth, "Name", "Joint Sec", "assets/m3.jpg"),
                _fixedCard(cardWidth, "Name", "Dir. Ops", "assets/m4.jpg"),
              ],
            ),
            const SizedBox(height: 40),

            // --- SUB-COMMITTEES ---
            _sectionLabel("MANAGEMENT COMMITTEE"),
            Wrap(
              spacing: 8,
              alignment: WrapAlignment.center,
              children: [
                SizedBox(width: cardWidth, child: const MemberCard(name: "Mgt Lead", role: "Lead", img: "assets/mgmt1.jpg")),
                SizedBox(width: cardWidth, child: const MemberCard(name: "Mgt Lead", role: "Lead", img: "assets/mgmt2.jpg")),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Text(label, style: const TextStyle(color: Color(0xFF16A085), fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 2)),
    );
  }

  Widget _fixedCard(double width, String n, String r, String i) {
    return SizedBox(width: width, child: MemberCard(name: n, role: r, img: i));
  }
}

class MemberCard extends StatefulWidget {
  final String name, role, img;

  const MemberCard({super.key, required this.name, required this.role, required this.img});

  @override
  State<MemberCard> createState() => _MemberCardState();
}

class _MemberCardState extends State<MemberCard> {
  bool _isTapped = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _isTapped = !_isTapped),
      onDoubleTap: () async {
        final Uri url = Uri.parse('https://linkedin.com');
        if (await canLaunchUrl(url)) await launchUrl(url);
      },
      child: AspectRatio(
        aspectRatio: 0.75, // Standard vertical card ratio
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
              image: AssetImage(widget.img),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(_isTapped ? 0.8 : 0.4), 
                BlendMode.darken
              ),
            ),
            border: Border.all(
              color: _isTapped ? const Color(0xFF16A085) : Colors.white10,
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  widget.name.toUpperCase(),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 8),
                ),
                Text(
                  widget.role,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFF16A085), fontWeight: FontWeight.w600, fontSize: 7),
                ),
                if (_isTapped) ...[
                  const SizedBox(height: 4),
                  const Text("1BI23RI...", style: TextStyle(color: Colors.white54, fontSize: 6)),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}