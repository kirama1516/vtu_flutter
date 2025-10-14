import 'package:flutter/material.dart';
import 'package:m5data_app/screens/auth/login_screen.dart';
import 'package:m5data_app/screens/auth/register_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Image.asset(
                  "assets/images/logo.jpg", // make sure you added this in pubspec.yaml
                  height: 120,
                ),
                const SizedBox(height: 30),

                // Welcome Text
                const Text(
                  "Welcome",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),

                // Description
                const Text(
                  "M5 DATA App is an innovative digital platform that provides a "
                      "wide range of essential services, making it easier for customers "
                      "to access important products and services in just a few taps.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),

                // Create Account Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo[900],
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => RegisterScreen()),
                      );
                    },
                    child: const Text(
                      "Create Account",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Login Button (Outlined)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Colors.indigo),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    child: const Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.indigo,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Footer
                const Text(
                  "All Right Reserved @ 2025",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // Floating Chat Icon
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo[900],
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Chat support coming soon...")),
          );
        },
        child: const Icon(Icons.chat, color: Colors.white),
      ),
    );
  }
}
