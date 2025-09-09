import 'package:campus_wellness_app/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'signup_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/toast.dart';
import '../../widgets/retry_dialog.dart';
import '../../theme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  void _signIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ToastService.showWarning(
        context: context,
        title: 'Incomplete Form',
        description: 'Please enter both HTU email and password',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Use enhanced sign in method
      final result = await FirebaseService.signInWithEmailAndPasswordEnhanced(email, password);
      
      if (result.isSuccess) {
        // Success - save login state and navigate
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        
        ToastService.showSuccess(
          context: context,
          title: 'Welcome back, HTU student! 🎓',
          description: 'Successfully signed in to your wellness dashboard.',
        );
        Navigator.pushReplacementNamed(context, '/getStarted');
      } else if (result.userWasNotFound) {
        // User doesn't exist - suggest signup
        _showSignupSuggestion(result.message!);
      } else if (result.isNetworkError) {
        // Network error - show retry dialog
        _showNetworkError(result.message!);
      } else {
        // Other error - show toast
        ToastService.showError(
          context: context,
          title: 'HTU Sign In Failed',
          description: result.message ?? 'Please check your credentials and try again.',
        );
      }
    } catch (e) {
      print('Unexpected sign in error: $e');
      ToastService.showError(
        context: context,
        title: 'Connection Error',
        description: 'Unable to connect to HTU wellness services. Please check your internet connection.',
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _showSignupSuggestion(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  'HTU',
                  style: TextStyle(
                    color: AppTheme.primaryGreen,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text('New Here?'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.lightGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.lightGreen.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.school,
                    color: AppTheme.primaryGreen,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Join the HTU wellness community and start your mental health journey!',
                      style: TextStyle(
                        color: AppTheme.primaryGreen,
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Try Again'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SignupPage(
                    initialEmail: _emailController.text.trim(),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
            ),
            child: const Text('Create Account'),
          ),
        ],
      ),
    );
  }
  
  void _showNetworkError(String message) async {
    final shouldRetry = await HoTechRetryDialog.show(
      context: context,
      title: 'HTU Login Connection Issue',
      message: message,
    );
    
    if (shouldRetry == true) {
      _signIn(); // Retry login
    }
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
                image: AssetImage('assets/images/logo.png'), // watermark
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
          // Semi-transparent overlay
          Container(
            color: Colors.black.withOpacity(0.5),
          ),
          // Login form
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // HTU Logo and branding
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryGreen.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.school,
                            color: Colors.white,
                            size: 32,
                          ),
                          Text(
                            'HTU',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Welcome Back",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "HTU Student Wellness Portal",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
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
                    const SizedBox(height: 30),
                    // Login button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _signIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "Sign In",
                                style: TextStyle(fontSize: 18, color: Colors.white),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Google login button (icon only)
                    ElevatedButton(
                      onPressed: () {
                        // Add Google login logic here
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
                        width: 20,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Signup link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "New Here? ",
                          style: TextStyle(color: Colors.white70),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SignupPage(
                                    initialEmail: _emailController.text.trim(),
                                  )),
                            );
                          },
                          child: Text(
                            "Join HTU Wellness",
                            style: TextStyle(
                              color: AppTheme.lightGreen,
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
}
