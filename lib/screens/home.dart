import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'createpost.dart';

class HomeContent extends StatefulWidget {
  final Map<String, dynamic> user;

  const HomeContent({super.key, required this.user});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {

  Future<List<dynamic>> fetchPosts() async {
    final client = Supabase.instance.client;

    // 🔥 Auto delete old posts
    await client
        .from('posts')
        .delete()
        .lt('expires_at', DateTime.now().toIso8601String());

    // 🔥 Fetch posts with user info
    final data = await client
        .from('posts')
        .select('*, users(name, role)')
        .order('created_at', ascending: false);

    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        Expanded(
          child: FutureBuilder(
            future: fetchPosts(),
            builder: (context, snapshot) {

              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF16A085)),
                );
              }

              final posts = snapshot.data!;

              if (posts.isEmpty) {
                return const Center(
                  child: Text(
                    "No posts yet",
                    style: TextStyle(color: Colors.white54),
                  ),
                );
              }

              return ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];

                  final user = post['users'];

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // 🔥 CATEGORY + NAME + ROLE
                        Text(
                          "${post['category']} - ${user?['name'] ?? 'Unknown'}, ${user?['role'] ?? ''}",
                          style: const TextStyle(
                            color: Color(0xFF16A085),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),

                        const SizedBox(height: 10),

                        // DESCRIPTION
                        Text(
                          post['description'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),

        // 🔥 CREATE POST BUTTON
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CreatePostPage(user: widget.user),
                ),
              ).then((_) => setState(() {}));
            },
            icon: const Icon(Icons.edit_note),
            label: const Text("CREATE NEW POST"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF16A085),
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ),
      ],
    );
  }
}