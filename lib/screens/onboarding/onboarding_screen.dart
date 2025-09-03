import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../theme.dart';


//Might not use this. We will see.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  PageController pageController = PageController();
  int currentPage = 0;
  
  final List<OnboardingPage> pages = [
    OnboardingPage(
      title: "Track Your Mood",
      description: "Monitor your emotional wellbeing with simple daily check-ins and gain insights into your mental health patterns.",
      imagePath: "assets/images/mood_tracking.png",
      backgroundColor: AppTheme.primaryGreen,
      animation: "mood",
    ),
    OnboardingPage(
      title: "Meditate Daily",
      description: "Access guided meditations, breathing exercises, and mindfulness practices to reduce stress and improve focus.",
      imagePath: "assets/images/meditation.png", 
      backgroundColor: AppTheme.softPurple,
      animation: "meditation",
    ),
    OnboardingPage(
      title: "Journal & Reflect",
      description: "Write your thoughts, process emotions, and track your personal growth journey through guided prompts.",
      imagePath: "assets/images/journaling.png",
      backgroundColor: Colors.blue,
      animation: "journal",
    ),
    OnboardingPage(
      title: "AI-Powered Support",
      description: "Get personalized mental health guidance from our AI wellness companion, available 24/7 to support you.",
      imagePath: "assets/images/ai_support.png",
      backgroundColor: Colors.deepPurple,
      animation: "ai",
    ),
    OnboardingPage(
      title: "Privacy & Security",
      description: "Your mental health data is encrypted and secure. You have full control over your privacy settings.",
      imagePath: "assets/images/privacy.png",
      backgroundColor: Colors.teal,
      animation: "security",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Page View
          PageView.builder(
            controller: pageController,
            onPageChanged: (index) {
              setState(() {
                currentPage = index;
              });
            },
            itemCount: pages.length,
            itemBuilder: (context, index) {
              return _buildOnboardingPage(pages[index], index);
            },
          ),
          
          // Skip button
          Positioned(
            top: 60,
            right: 20,
            child: TextButton(
              onPressed: _skipOnboarding,
              child: Text(
                'Skip',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          
          // Bottom navigation
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: pages[currentPage].backgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Page indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        pages.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: currentPage == index ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: currentPage == index
                                ? Colors.white
                                : Colors.white.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Navigation buttons
                    Row(
                      children: [
                        if (currentPage > 0)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _previousPage,
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.white),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Back',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          )
                        else
                          const Expanded(child: SizedBox()),
                        
                        const SizedBox(width: 16),
                        
                        Expanded(
                          child: ElevatedButton(
                            onPressed: currentPage == pages.length - 1
                                ? _completeOnboarding
                                : _nextPage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: pages[currentPage].backgroundColor,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              currentPage == pages.length - 1 
                                  ? 'Get Started' 
                                  : 'Next',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
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
  
  Widget _buildOnboardingPage(OnboardingPage page, int index) {
    return AnimationConfiguration.staggeredList(
      position: index,
      duration: const Duration(milliseconds: 600),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  page.backgroundColor,
                  page.backgroundColor.withOpacity(0.8),
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
                child: Column(
                  children: [
                    const Spacer(flex: 1),
                    
                    // Illustration placeholder
                    Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(140),
                      ),
                      child: Center(
                        child: _buildAnimatedIcon(page.animation),
                      ),
                    ),
                    
                    const Spacer(flex: 1),
                    
                    // Title
                    Text(
                      page.title,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Description
                    Text(
                      page.description,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 120), // Space for bottom navigation
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildAnimatedIcon(String animation) {
    IconData iconData;
    switch (animation) {
      case "mood":
        iconData = Icons.mood;
        break;
      case "meditation":
        iconData = Icons.self_improvement;
        break;
      case "journal":
        iconData = Icons.book;
        break;
      case "ai":
        iconData = Icons.smart_toy;
        break;
      case "security":
        iconData = Icons.security;
        break;
      default:
        iconData = Icons.favorite;
    }
    
    return Icon(
      iconData,
      size: 120,
      color: Colors.white,
    );
  }
  
  void _nextPage() {
    if (currentPage < pages.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
  
  void _previousPage() {
    if (currentPage > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
  
  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isNewUser', false);
    
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }
  
  Future<void> _skipOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isNewUser', false);
    
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }
  
  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final String imagePath;
  final Color backgroundColor;
  final String animation;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.backgroundColor,
    required this.animation,
  });
}
