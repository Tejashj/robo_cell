import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';

class HomeContent extends StatefulWidget {
  final Map<String, dynamic> user;
  final VoidCallback onNavigateToMeetings;

  const HomeContent({
    super.key,
    required this.user,
    required this.onNavigateToMeetings,
  });

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AppProvider>(context, listen: false);
      provider.fetchPosts();
      provider.fetchMeetings();
    });
  }

  Future<void> initialize() async {
    final provider = Provider.of<AppProvider>(context, listen: false);
    await Future.wait([
      provider.fetchPosts(forceRefresh: true),
      provider.fetchMeetings(forceRefresh: true),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final loading = provider.isLoadingPosts || provider.isLoadingMeetings;
    final latestPosts = provider.latestPosts;
    final liveMeetings = provider.liveMeetings;

    final committee = widget.user['committees']?['name'] ?? 'General Operations';
    final photo = widget.user['photo_url'];
    final roleString = widget.user['role'].toString().replaceAll('_', ' ').toUpperCase();

    return Theme(
      data: Theme.of(context).copyWith(
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.black,
          selectedItemColor: const Color(0xFF16A085),
          unselectedItemColor: Colors.grey.shade600,
        ),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF09090A),
        body: loading
            ? const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF148F77),
                ),
              )
            : RefreshIndicator(
                color: const Color(0xFF148F77),
                backgroundColor: const Color(0xFF121214),
                onRefresh: initialize,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// USER METRIC HEADER ARCHITECTURE WITH UPDATED SALUTATION
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF121214),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white.withOpacity(0.03)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(2.5),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [Color(0xFF148F77), Color(0xFF1ABC9C)],
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 28,
                                backgroundColor: Colors.black,
                                backgroundImage: photo != null && photo != '' ? NetworkImage(photo) : null,
                                child: photo == null || photo == ''
                                    ? const Icon(Icons.person_rounded, color: Color(0xFF1ABC9C), size: 28)
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "WELCOME BACK,",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.25),
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    widget.user['name'] ?? 'N/A',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "$committee • $roleString",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Color(0xFF1ABC9C),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      /// LIVE OPERATIONS CAROUSEL SEGMENT
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 3,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE74C3C),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                "MEETINGS",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: widget.onNavigateToMeetings,
                            style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                            child: const Row(
                              children: [
                                Text("View All", style: TextStyle(color: Color(0xFF1ABC9C), fontSize: 12)),
                                SizedBox(width: 2),
                                Icon(Icons.keyboard_arrow_right_rounded, size: 16, color: Color(0xFF1ABC9C)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (liveMeetings.isEmpty)
                        InkWell(
                          onTap: widget.onNavigateToMeetings,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF121214),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withOpacity(0.02)),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.sensors_off_rounded, color: Colors.white.withOpacity(0.15), size: 32),
                                const SizedBox(height: 12),
                                const Text(
                                  "No active meetings detected",
                                  style: TextStyle(color: Colors.white38, fontSize: 13, fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  "Tap here to check upcoming meeting schedules",
                                  style: TextStyle(color: Colors.white12, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        SizedBox(
                          height: 150,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: liveMeetings.length,
                            itemBuilder: (context, index) {
                              final meeting = liveMeetings[index];
                              return Container(
                                width: MediaQuery.of(context).size.width * 0.78,
                                margin: const EdgeInsets.only(right: 14),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [const Color(0xFF148F77).withOpacity(0.15), Colors.transparent],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  color: const Color(0xFF121214),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: const Color(0xFF148F77).withOpacity(0.3), width: 1),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: widget.onNavigateToMeetings,
                                  child: Padding(
                                    padding: const EdgeInsets.all(18),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFE74C3C).withOpacity(0.15),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: const Row(
                                                children: [
                                                  Icon(Icons.sensors, size: 10, color: Color(0xFFE74C3C)),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    "LIVE OPERATIONAL",
                                                    style: TextStyle(color: Color(0xFFE74C3C), fontSize: 9, fontWeight: FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.white.withOpacity(0.2)),
                                          ],
                                        ),
                                        const Spacer(),
                                        Text(
                                          meeting['title']?.toString().toUpperCase() ?? 'UNTITLED SESSION',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          meeting['agenda'] ?? 'No agenda matrix supplied.',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12, height: 1.3),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 32),

                      /// INFORMATION FEED BLOCK
                      Row(
                        children: [
                          Container(
                            width: 3,
                            height: 14,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1ABC9C),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "BROADCAST FEED",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      if (latestPosts.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFF121214),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Center(
                            child: Text("Broadcast channel array is empty.", style: TextStyle(color: Colors.white24, fontSize: 12)),
                          ),
                        )
                      else
                        ...latestPosts.map((post) {
                          final creator = post['users'] ?? {};
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: const Color(0xFF121214),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withOpacity(0.02)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 14,
                                      backgroundColor: const Color(0xFF148F77),
                                      backgroundImage: creator['photo_url'] != null && creator['photo_url'] != ''
                                          ? NetworkImage(creator['photo_url'])
                                          : null,
                                      child: creator['photo_url'] == null || creator['photo_url'] == ''
                                          ? const Icon(Icons.person, size: 14, color: Colors.black)
                                          : null,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        creator['name'] ?? 'System Sync',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  post['title'] ?? '',
                                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  post['content'] ?? '',
                                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12, height: 1.5),
                                ),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}