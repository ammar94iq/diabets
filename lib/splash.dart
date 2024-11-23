import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth/signin.dart';
import 'home.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();

    _navigateAfterDelay();
  }

  // Method to handle delayed navigation
  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 5)); // Delay for 5 seconds
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('uid');

    // Ensure the widget is still mounted before navigating
    if (!mounted) return;

    if (uid != null) {
      // Navigate to HomePage if user is logged in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } else {
      // Navigate to SignIn page if user is not logged in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SignIn()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        color: const Color(0xFF505184), // Background color
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'GHND',
              style: TextStyle(
                color: Colors.white,
                fontSize: 40.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Image.asset("images/logo2.png"),
          ],
        ),
      ),
    );
  }
}
