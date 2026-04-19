import 'package:flutter/material.dart';
import 'package:robo_cell/navigation.dart';
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("ROBOCELL LOGIN", style: TextStyle(color: Color(0xFFD8CFB4), fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            TextField(decoration: InputDecoration(labelText: "USN", border: OutlineInputBorder())),
            const SizedBox(height: 20),
            TextField(obscureText: true, decoration: InputDecoration(labelText: "Password", border: OutlineInputBorder())),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity, 
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF16A085)),
                onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainNavigation())),
                child: const Text("LOGIN", style: TextStyle(color: Colors.black)),
              )
            ),
          ],
        ),
      ),
    );
  }
}