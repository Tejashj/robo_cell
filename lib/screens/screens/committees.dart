import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/app_provider.dart';
import '../../widgets/skeleton_loader.dart';

class CommitteesPage extends StatefulWidget {
  const CommitteesPage({super.key});

  @override
  State<CommitteesPage> createState() => _CommitteesPageState();
}

class _CommitteesPageState extends State<CommitteesPage> {
  int? flippedCardId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppProvider>(context, listen: false).fetchHierarchy();
    });
  }

  Color committeeColor(String committee) {
    switch (committee.toLowerCase()) {
      case 'faculty':
        return const Color.fromARGB(255, 249, 250, 250);
      case 'office bearers':
        return const Color.fromARGB(255, 235, 207, 93);
      default:
        return const Color(0xFF16A085);
    }
  }



  Map<String, List<Map<String, dynamic>>> groupMembersByCommittee(
    List<Map<String, dynamic>> data,
  ) {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var row in data) {
      final String committeeName = row['committee_name'] ?? 'Other';
      if (!grouped.containsKey(committeeName)) {
        grouped[committeeName] = [];
      }
      grouped[committeeName]!.add(row);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.black,
          selectedItemColor: const Color(0xFF16A085),
          unselectedItemColor: Colors.grey.shade600,
        ),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A0E),
        appBar: AppBar(
          backgroundColor: Colors.black,
          centerTitle: true,
          elevation: 0,
          title: const Text(
            "ROBO CELL HERITAGE",
            style: TextStyle(
              color: Color(0xFFE5DDC8),
              fontWeight: FontWeight.w900,
              letterSpacing: 5,
              fontSize: 22,
            ),
          ),
        ),
        body: Consumer<AppProvider>(
          builder: (context, provider, child) {
            if (provider.isLoadingHierarchy && provider.hierarchyData.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF16A085),
                ),
              );
            }
            if (provider.hierarchyData.isEmpty) {
              return const Center(
                child: Text(
                  'No hierarchy data',
                  style: TextStyle(color: Colors.white70),
                ),
              );
            }

            final groupedData = groupMembersByCommittee(provider.hierarchyData);

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 28),
              itemCount: groupedData.keys.length,
              itemBuilder: (context, index) {
                final String committeeName = groupedData.keys.elementAt(index);
                final List<Map<String, dynamic>> members = groupedData[committeeName]!;
                final Color accentColor = committeeColor(committeeName);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 60),
                  child: Column(
                    children: [
                      Text(
                        committeeName.toUpperCase(),
                        style: TextStyle(
                          color: accentColor,
                          fontWeight: FontWeight.w900,
                          fontSize: 19,
                          letterSpacing: 6,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: 50,
                        height: 3.5,
                        decoration: BoxDecoration(
                          color: accentColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 36),
                      ...buildGeometricLayout(members, accentColor),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  List<Widget> buildGeometricLayout(
    List<Map<String, dynamic>> members,
    Color color,
  ) {
    final bool isOdd = members.length % 2 != 0;
    final List<Map<String, dynamic>> gridItems = isOdd ? members.sublist(1) : members;

    return [
      if (isOdd)
        Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Center(
            child: SizedBox(
              width: 165,
              height: 255,
              child: buildCard(members[0], color),
            ),
          ),
        ),
      if (gridItems.isNotEmpty)
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: gridItems.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 24,
            crossAxisSpacing: 20,
            childAspectRatio: 165 / 255,
          ),
          itemBuilder: (context, gridIndex) {
            return Center(
              child: SizedBox(
                width: 165,
                height: 255,
                child: buildCard(gridItems[gridIndex], color),
              ),
            );
          },
        ),
    ];
  }

  Widget buildCard(Map<String, dynamic> member, Color color) {
    final int memberId = member['id'] is int ? member['id'] : member['id'].hashCode;

    return MemberCard(
      member: member,
      color: color,
      isFlipped: flippedCardId == memberId,
      onTap: () {
        setState(() {
          flippedCardId = (flippedCardId == memberId) ? null : memberId;
        });
      },
    );
  }
}

class MemberCard extends StatefulWidget {
  final Map<String, dynamic> member;
  final bool isFlipped;
  final VoidCallback onTap;
  final Color color;

  const MemberCard({
    super.key,
    required this.member,
    required this.isFlipped,
    required this.onTap,
    required this.color,
  });

  @override
  State<MemberCard> createState() => _MemberCardState();
}

class _MemberCardState extends State<MemberCard> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );

    animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void didUpdateWidget(covariant MemberCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFlipped) {
      controller.forward();
    } else {
      controller.reverse();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> openLinkedin() async {
    HapticFeedback.lightImpact();
    String url = (widget.member['linkedin'] ?? '').toString().trim();

    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF161622),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          content: Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: Colors.orangeAccent),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "${widget.member['name']} HAS NOT ADDED A LINKEDIN PROFILE",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      );
      return;
    }

    if (!url.startsWith('http')) {
      url = 'https://$url';
    }

    final Uri uri = Uri.parse(url);

    try {
      final launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text("FAILED TO OPEN LINKEDIN"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final image = widget.member['photo_url'] ?? '';
    final role = widget.member['role'] ?? 'MEMBER';
    final name = widget.member['name'] ?? '';
    final usn = widget.member['usn'] ?? 'FACULTY';

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final angle = animation.value * 3.1415926535;
        final isFront = angle < (3.1415926535 / 2);

        // Single external detector wraps the entire matrix structure cleanly
        return GestureDetector(
          onTap: widget.onTap,
          onDoubleTap: () {
            if (!isFront) {
              openLinkedin(); // Directly launch LinkedIn if showing the card back
            }
          },
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0015)
              ..rotateY(angle),
            child: isFront
                ? frontCard(image, name, role)
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(3.1415926535),
                    child: backCard(name, role, usn),
                  ),
          ),
        );
      },
    );
  }

  Widget frontCard(String image, String name, String role) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF13131A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: widget.color.withOpacity(0.2), width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            Expanded(
              flex: 66,
              child: image.toString().isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: image,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (c, u) => const SkeletonBox(height: double.infinity, borderRadius: 16),
                      errorWidget: (c, u, e) => fallbackAvatar(),
                    )
                  : fallbackAvatar(),
            ),
            Expanded(
              flex: 34,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                width: double.infinity,
                color: const Color(0xFF1A1A24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      name.toUpperCase(),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      decoration: BoxDecoration(
                        color: widget.color.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        role.replaceAll('_', ' ').toUpperCase(),
                        style: TextStyle(
                          color: widget.color,
                          fontWeight: FontWeight.w900,
                          fontSize: 8.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget fallbackAvatar() {
    return Container(
      width: double.infinity,
      color: const Color(0xFF1A1A22),
      child: Center(
        child: Icon(
          Icons.blur_on_rounded,
          size: 46,
          color: widget.color.withOpacity(0.25),
        ),
      ),
    );
  }

  Widget backCard(String name, String role, String usn) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.color.withOpacity(0.1),
            const Color(0xFF111116),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 6),
          CircleAvatar(
            radius: 20,
            backgroundColor: widget.color.withOpacity(0.08),
            child: Icon(
              Icons.bolt_rounded,
              color: widget.color,
              size: 20,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            name.toUpperCase(),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            role.replaceAll('_', ' ').toUpperCase(),
            style: TextStyle(
              color: widget.color,
              fontWeight: FontWeight.w700,
              fontSize: 8.5,
            ),
          ),
          const Spacer(),
          Text(
            usn,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.touch_app_outlined,
                  size: 10,
                  color: widget.color.withOpacity(0.7),
                ),
                const SizedBox(width: 5),
                Text(
                  "DOUBLE TAP FOR LINKEDIN",
                  style: TextStyle(
                    color: widget.color.withOpacity(0.7),
                    fontSize: 7,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}