import 'package:flutter/material.dart';

class GetStartedPage extends StatefulWidget {
  const GetStartedPage({super.key});

  @override
  State<GetStartedPage> createState() => _GetStartedPageState();
}

class _GetStartedPageState extends State<GetStartedPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _animationController.forward();

    // Auto-navigate after 5 seconds
    //I am commneting this out for now. Not needed. You can delete this if you want.
    // Future.delayed(const Duration(seconds: 10), () {
    //   Navigator.pushReplacementNamed(context, '/reason');
    // });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

// After the user taps "Get Started", navigate to the HomePage
//Thats handled on this page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF56AB2F), // Dark green
              Color(0xFFA8E063), // Light green
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    )
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Image.asset(
                  'assets/images/logo.png', // Replace with your logo
                  width: 120,
                  height: 120,
                ),
              ),
              const SizedBox(height: 30),

              // Headline
              const Text(
                'Welcome to \nCampus Wellness',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 15),

              // Subtitle
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Your personal mental health companion \nLog moods, track progress, and discover insights.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.5,
                    fontStyle: FontStyle.italic
                  ),
                ),
              ),
              const SizedBox(height: 50),

              // Get Started Button
              //Routes to HomePage
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/home');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF56AB2F),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 60, vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(35),
                  ),
                  elevation: 8,
                  shadowColor: Colors.black26,
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('Get Started'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
