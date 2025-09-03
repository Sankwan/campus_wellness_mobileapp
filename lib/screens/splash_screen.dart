import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'authentication/login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateNext();
  }

  Future<void> _navigateNext() async {
    await Future.delayed(const Duration(seconds: 3));
    
    if (!mounted) return; // Check if widget is still mounted
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final isNewUser = prefs.getBool('isNewUser') ?? true;
      
      if (!mounted) return; // Check again before navigation
      
      if (isNewUser) {
        Navigator.pushReplacementNamed(context, '/onboarding');
      } else {
        final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
        if (isLoggedIn) {
          Navigator.pushReplacementNamed(context, '/getStarted');
        } else {
          Navigator.pushReplacementNamed(context, '/login');
        }
      }
    } catch (e) {
      print('Error in splash navigation: $e');
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png', // Place your logo here
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
