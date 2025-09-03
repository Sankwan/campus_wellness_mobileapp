import 'package:campus_wellness_app/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart'; // Make sure this is correct


class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController(); // Add this
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    // Replace _confirmPasswordController with _usernameController
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Watermark background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/logo.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Semi-transparent overlay
          Container(
            color: Colors.black.withOpacity(0.5),
          ),
          // Signup form
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Sign Up",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 50),
                    // Email field
                    TextField(
                      controller: _emailController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Email",
                        hintStyle: const TextStyle(color: Colors.white70),
                        prefixIcon:
                            const Icon(Icons.email, color: Colors.white),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Password field
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Password",
                        hintStyle: const TextStyle(color: Colors.white70),
                        prefixIcon: const Icon(Icons.lock, color: Colors.white),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Username field
                    TextField(
                      controller: _usernameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Username",
                        hintStyle: const TextStyle(color: Colors.white70),
                        prefixIcon: const Icon(Icons.person, color: Colors.white),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Signup button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final email = _emailController.text.trim();
                          final password = _passwordController.text;
                          final username = _usernameController.text.trim();

                          if (email.isEmpty || password.isEmpty || username.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please fill all fields')),
                            );
                            return;
                          }

                          try {
                            final user = await FirebaseService.createUserWithEmailAndPassword(email, password, username);
                            if (user != null) {
                              final prefs = await SharedPreferences.getInstance();
                              await prefs.setBool('isLoggedIn', true);
                              Navigator.pushReplacementNamed(context, '/getStarted');
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Signup failed: $e')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Google signup button (small)
                    ElevatedButton(
                      onPressed: () {
                        // Add Google signup logic here
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(12),
                      ),
                      child: Image.asset(
                        'assets/images/google_icon.png',
                        height: 30,
                        width: 20, // same as Login page
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Login link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Already have an account? ",
                          style: TextStyle(color: Colors.white70),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginPage()),
                            );
                          },
                          child: const Text(
                            "Login",
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onSignupSuccess(dynamic SharedPreferences) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    Navigator.pushReplacementNamed(context, '/getStarted');
  }

  // Call _onSignupSuccess() after Firebase signup
}
