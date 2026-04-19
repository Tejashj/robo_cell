import 'package:flutter/material.dart';
import 'package:robo_cell/navigation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final supabase = Supabase.instance.client;

  List committees = [];
  List users = [];

  String? selectedCommitteeId;
  Map<String, dynamic>? selectedUser;

  final passwordController = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchCommittees();
  }

  // 🔥 Fetch Committees
  Future<void> fetchCommittees() async {
    final data = await supabase.from('committees').select();
    setState(() => committees = data);
  }

  // 🔥 Fetch Users based on Committee
  Future<void> fetchUsers(String committeeId) async {
    final data = await supabase
        .from('users')
        .select()
        .eq('committee_id', committeeId);

    setState(() => users = data);
  }

  // 🔐 Login Function
  Future<void> login() async {
    if (selectedCommitteeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select committee")),
      );
      return;
    }

    if (selectedUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select user")),
      );
      return;
    }

    if (passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter password")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final result = await supabase.rpc('check_password', params: {
        'input_password': passwordController.text.trim(),
        'stored_hash': selectedUser!['password'],
      });

      if (result == true) {
        // ✅ Navigate with user data
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainNavigation(user: selectedUser!),
          ),
        );
      } else {
        throw "Wrong password";
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "ROBOCELL LOGIN",
              style: TextStyle(
                color: Color(0xFFD8CFB4),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 40),

            // 🔽 Committee Dropdown
            DropdownButtonFormField(
              dropdownColor: Colors.black,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Committee",
                border: OutlineInputBorder(),
              ),
              value: selectedCommitteeId,
              items: committees.map<DropdownMenuItem<String>>((c) {
                return DropdownMenuItem(
                  value: c['id'],
                  child: Text(c['name']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCommitteeId = value;
                  selectedUser = null;
                  users = [];
                });
                fetchUsers(value!);
              },
            ),

            const SizedBox(height: 20),

            // 🔽 User Dropdown
            DropdownButtonFormField(
              dropdownColor: Colors.black,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "User (USN - Name)",
                border: OutlineInputBorder(),
              ),
              value: selectedUser,
              items: users.map<DropdownMenuItem<Map<String, dynamic>>>((u) {
                return DropdownMenuItem(
                  value: u,
                  child: Text("${u['usn']} - ${u['name']}"),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => selectedUser = value);
              },
            ),

            const SizedBox(height: 20),

            // 🔐 Password Field
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            // 🔥 Login Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A085),
                ),
                onPressed: isLoading ? null : login,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text(
                  "LOGIN",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}