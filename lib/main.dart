import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/get_started_page.dart';
import 'screens/home_page.dart';
import 'screens/mood_log_page.dart';
import 'screens/onboarding_page.dart';
import 'screens/question_page.dart';
import 'screens/reason_page.dart';
import 'screens/splash_screen.dart';
import 'screens/authentication/login_page.dart';
import 'screens/authentication/signup_page.dart';
import 'screens/journal_page.dart';
import 'screens/meditation_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/ai_chatbot_screen.dart';
import 'screens/mood_assessment_screen.dart';
// import 'screens/onboarding/onboarding_screen.dart';
import 'screens/privacy/privacy_settings_screen.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }
  
  runApp(const CampusWellnessApp());
}

class CampusWellnessApp extends StatefulWidget {
  const CampusWellnessApp({super.key});

  @override
  State<CampusWellnessApp> createState() => _CampusWellnessAppState();
}

class _CampusWellnessAppState extends State<CampusWellnessApp> {
  Widget _defaultHome = const SplashScreen();

  @override
  void initState() {
    super.initState();
    _checkUserStatus();
  }

  Future<void> _checkUserStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isNewUser = prefs.getBool('isNewUser') ?? true;
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    setState(() {
      if (isNewUser) {
        _defaultHome = const SplashScreen();
      } else if (isLoggedIn) {
        _defaultHome = const GetStartedPage();
      } else {
        _defaultHome = const LoginPage();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Campus Wellness',
      theme: AppTheme.lightTheme,
      home: _defaultHome,
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingPage(),
        '/signup': (context) => const SignupPage(),
        '/login': (context) => const LoginPage(),
        '/getStarted': (context) => const GetStartedPage(),
        '/reason': (context) => const ReasonPage(),
        '/questions': (context) => const QuestionPage(),
        '/moodLog': (context) => const MoodLogPage(),
        '/home': (context) => const HomePage(),
        '/journal': (context) => const JournalPage(),
        '/meditation': (context) => const MeditationScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/ai-chatbot': (context) => const AiChatbotScreen(),
        '/mood-assessment': (context) => const MoodAssessmentScreen(),
        // '/new-onboarding': (context) => const OnboardingScreen(),
        '/privacy-settings': (context) => const PrivacySettingsScreen(),
      },
    );
  }
}
