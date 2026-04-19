import 'package:flutter/material.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

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
        title: const Text("NEW POST", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: () {
              // Handle post logic
              Navigator.pop(context);
            },
            child: const Text("PUBLISH", 
              style: TextStyle(color: Color(0xFF16A085), fontWeight: FontWeight.bold)
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CATEGORY SELECTOR
            const Text("SELECT CATEGORY", 
              style: TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold)
            ),
            DropdownButton<String>(
              value: _selectedCategory,
              isExpanded: true,
              dropdownColor: const Color(0xFF1A1A1A),
              underline: Container(height: 1, color: Colors.white10),
              items: _categories.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 14)),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedCategory = val!),
            ),
            
            const SizedBox(height: 30),

            // IMAGE UPLOADER
            GestureDetector(
              onTap: () {}, // Integrate image_picker here
              child: Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10, width: 1),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate_outlined, color: Color(0xFF16A085), size: 40),
                    SizedBox(height: 12),
                    Text("Tap to upload cover image", 
                      style: TextStyle(color: Colors.white38, fontSize: 12)
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // CONTENT INPUT
            const Text("POST DESCRIPTION", 
              style: TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _textController,
              maxLines: 6,
              style: const TextStyle(color: Colors.white, fontSize: 15),
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