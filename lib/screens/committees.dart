import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CommitteesPage extends StatefulWidget {
  const CommitteesPage({super.key});

  @override
  State<CommitteesPage> createState() => _CommitteesPageState();
}

class _CommitteesPageState extends State<CommitteesPage> {
  final supabase = Supabase.instance.client;

  final List<String> committeeOrder = [
    "Office Bearers",
    "Marketing",
    "Management",
    "Content",
    "Design",
    "Creative",
    "Media",
    "Newsletter",
    "Service",
    "Sports",
    "Cultural",
    "Industrial",
    "Welfare",
    "Disciplinary",
  ];

  Future<Map<String, List<dynamic>>> fetchCommittees() async {
    final response = await supabase
        .from('users')
        .select('name, role, photo_url, committees(name)')
        .order('created_at');

    Map<String, List<dynamic>> grouped = {};

    for (var committee in committeeOrder) {
      grouped[committee] = [];
    }

    for (var user in response) {
      final committeeName = user['committees']['name'];

      if (grouped.containsKey(committeeName)) {
        grouped[committeeName]!.add(user);
      }
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "ROBOCELL HERITAGE",
          style: TextStyle(
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, List<dynamic>>>(
        future: fetchCommittees(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF16A085),
              ),
            );
          }

          final committees = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: committeeOrder.length,
            itemBuilder: (context, index) {
              final committeeName = committeeOrder[index];
              final members = committees[committeeName]!;

              if (members.isEmpty) return const SizedBox();

              return Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // 🔥 COMMITTEE TITLE
                    Center(
                      child: Column(
                        children: [
                          Text(
                            committeeName.toUpperCase(),
                            style: const TextStyle(
                              color: Color(0xFF16A085),
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Container(
                            width: 80,
                            height: 2,
                            color: const Color(0xFF16A085),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    // 🔥 MEMBERS GRID
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: members.length,
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.62,
                      ),
                      itemBuilder: (context, i) {
                        final member = members[i];

                        return _MemberCard(
                          name: member['name'] ?? '',
                          role: member['role'] ?? '',
                          image: member['photo_url'] ?? '',
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _MemberCard extends StatelessWidget {
  final String name;
  final String role;
  final String image;

  const _MemberCard({
    required this.name,
    required this.role,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [

          // 🔥 PHOTO
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: image.isNotEmpty
                  ? Image.network(
                image,
                width: double.infinity,
                fit: BoxFit.cover,
              )
                  : Container(
                color: Colors.white10,
                child: const Center(
                  child: Icon(
                    Icons.person,
                    color: Color(0xFF16A085),
                    size: 40,
                  ),
                ),
              ),
            ),
          ),

          // 🔥 INFO
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Text(
                  name.toUpperCase(),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                    letterSpacing: 1,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  role,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF16A085),
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
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