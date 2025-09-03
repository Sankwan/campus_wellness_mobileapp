import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'question_page.dart'; // make sure this exists

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> onboardingData = [
    {
      'image': 'assets/images/mood.png',
      'title': 'Track Your Mood and Journal',
      'subtitle': 'Monitor your emotional wellbeing with simple daily check-ins and gain insights into your mental health patterns.'
    },
    {
      'image': 'assets/images/journal.png',
      'title': 'Reflect on Your Thoughts',
      'subtitle': 'Access guided breathing exercises, and mindfulness practices to reduce stress and improve focus.'
    },
    {
      'image': 'assets/images/support.png',
      'title': 'AI-Powered Support',
      'subtitle': 'Get personalized mental health guidance from our AI wellness companion, available 24/7 to support you.'
    },
  ];

  void _nextPage() {
    if (_currentPage < onboardingData.length - 1) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isNewUser', false);
    Navigator.pushReplacementNamed(context, '/signup');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_currentPage < onboardingData.length - 1)
                    TextButton(
                      onPressed: () {
                        _pageController.animateToPage(
                          onboardingData.length - 1,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          color: Color(0xFF56AB2F),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: onboardingData.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final data = onboardingData[index];
                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          Image.asset(data['image']!, height: 280),
                          const SizedBox(height: 30),
                          Text(
                            data['title']!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF56AB2F),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            data['subtitle']!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Page indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                onboardingData.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  height: 8,
                  width: _currentPage == index ? 24 : 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? const Color(0xFF56AB2F)
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Next button
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF56AB2F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    _currentPage == onboardingData.length - 1
                        ? 'Get Started'
                        : 'Next',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
