import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreatePostPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const CreatePostPage({super.key, required this.user});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final TextEditingController _textController = TextEditingController();
  String _selectedCategory = "ANNOUNCEMENT";

  final List<String> _categories = [
    "ANNOUNCEMENT",
    "ACHIEVEMENTS",
    "EXTERNAL OPPORTUNITY",
    "UPCOMING MEETING"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("NEW POST"),
        actions: [
          TextButton(
            onPressed: () async {
              final text = _textController.text.trim();
              if (text.isEmpty) return;

              await Supabase.instance.client.from('posts').insert({
                'category': _selectedCategory,
                'description': text,
                'user_id': widget.user['id'], // 🔥 LINK USER
              });

              Navigator.pop(context);
            },
            child: const Text(
              "PUBLISH",
              style: TextStyle(
                color: Color(0xFF16A085),
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text("SELECT CATEGORY",
                style: TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold)
            ),

            DropdownButton<String>(
              value: _selectedCategory,
              isExpanded: true,
              dropdownColor: const Color(0xFF1A1A1A),
              underline: Container(height: 1, color: Colors.white10),
              items: _categories.map((value) {
                return DropdownMenuItem(
                  value: value,
                  child: Text(value, style: const TextStyle(color: Colors.white)),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedCategory = val!),
            ),

            const SizedBox(height: 30),

            const Text("POST DESCRIPTION",
                style: TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold)
            ),

            const SizedBox(height: 10),

            TextField(
              controller: _textController,
              maxLines: 6,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Write something insightful...",
                hintStyle: const TextStyle(color: Colors.white24),
                filled: true,
                fillColor: Colors.white.withOpacity(0.03),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}