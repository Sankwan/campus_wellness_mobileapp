import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme.dart';
import '../widgets/mood_quick_log.dart';
import '../widgets/daily_progress_card.dart';
import '../widgets/quick_action_grid.dart';
import '../widgets/insights_summary.dart';
import '../widgets/main_navigation.dart';
import '../services/firebase_service.dart';
import '../models/user_model.dart';
import '../models/mood_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentNavIndex = 0;
  UserModel? currentUser;
  int currentStreak = 0;
  int todayMeditation = 0;
  double moodAverage = 0.0;
  bool hasLoggedMoodToday = false;
  bool isLoading = true;
  String? errorMessage;
  bool isSavingMood = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _checkTodayMoodLog();
  }

  Future<void> _loadUserData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final user = FirebaseService.getCurrentUser();
      if (user != null) {
        // Fetch user document
        final userDoc = await FirebaseService.getUserDocument(user.uid);
        if (userDoc != null) {
          setState(() {
            currentUser = userDoc;
          });
        }
        
        // Load analytics
        await _loadUserAnalytics(user.uid);
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load user data. Please try again.';
      });
      print('Error loading user data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadUserAnalytics(String userId) async {
    try {
      // Calculate streak based on consecutive days with mood logs or meditation
      final streak = await _calculateStreak(userId);
      
      // Get today's meditation minutes
      final todayMinutes = await _getTodayMeditationMinutes(userId);
      
      // Get mood average for last 7 days
      final moodAvg = await _getMoodAverage(userId);
      
      setState(() {
        currentStreak = streak;
        todayMeditation = todayMinutes;
        moodAverage = moodAvg;
      });
    } catch (e) {
      print('Error loading analytics: $e');
    }
  }

  Future<int> _calculateStreak(String userId) async {
    try {
      final now = DateTime.now();
      final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59);
      int streak = 0;
      
      for (int i = 0; i < 365; i++) { // Check up to a year
        final checkDate = endOfToday.subtract(Duration(days: i));
        final startOfDay = DateTime(checkDate.year, checkDate.month, checkDate.day);
        final endOfDay = DateTime(checkDate.year, checkDate.month, checkDate.day, 23, 59, 59);
        
        // Check if user had any mood logs or meditation sessions this day
        final moods = await FirebaseService.getMoodsByDateRange(userId, startOfDay, endOfDay);
        final sessions = await FirebaseService.getUserMeditationSessions(userId, limit: 1000); // Get all for filtering
        final daySessions = sessions.where((session) {
          final sessionDate = session.startTime;
          return sessionDate.isAfter(startOfDay) && sessionDate.isBefore(endOfDay);
        }).toList();
        
        if (moods.isNotEmpty || daySessions.isNotEmpty) {
          streak++;
        } else {
          break; // Streak broken
        }
      }
      
      return streak;
    } catch (e) {
      print('Error calculating streak: $e');
      return 0;
    }
  }

  Future<int> _getTodayMeditationMinutes(String userId) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
      
      final sessions = await FirebaseService.getUserMeditationSessions(userId, limit: 1000);
      final todaySessions = sessions.where((session) {
        final sessionDate = session.startTime;
        return sessionDate.isAfter(startOfDay) && sessionDate.isBefore(endOfDay) && session.isCompleted;
      }).toList();
      
      int totalMinutes = 0;
      for (final session in todaySessions) {
        totalMinutes += session.actualDuration ~/ 60000; // Convert milliseconds to minutes
      }
      
      return totalMinutes;
    } catch (e) {
      print('Error getting today meditation minutes: $e');
      return 0;
    }
  }

  Future<double> _getMoodAverage(String userId) async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 7));
      
      final moods = await FirebaseService.getMoodsByDateRange(userId, startDate, endDate);
      if (moods.isEmpty) return 0.0;
      
      final total = moods.map((mood) => mood.moodValue).reduce((a, b) => a + b);
      return total / moods.length;
    } catch (e) {
      print('Error getting mood average: $e');
      return 0.0;
    }
  }

  Future<void> _checkTodayMoodLog() async {
    try {
      final user = FirebaseService.getCurrentUser();
      if (user != null) {
        final now = DateTime.now();
        final startOfDay = DateTime(now.year, now.month, now.day);
        final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
        
        final todayMoods = await FirebaseService.getMoodsByDateRange(user.uid, startOfDay, endOfDay);
        setState(() {
          hasLoggedMoodToday = todayMoods.isNotEmpty;
        });
      }
    } catch (e) {
      print('Error checking today mood log: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await _loadUserData();
            await _checkTodayMoodLog();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  _buildHeader(theme),
                  const SizedBox(height: 24),
                  
                  // Error State
                  if (errorMessage != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.red, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  errorMessage!,
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () {
                              _loadUserData();
                              _checkTodayMoodLog();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  // Loading State
                  if (isLoading) ...[
                    const Center(
                      child: CircularProgressIndicator(),
                    ),
                    const SizedBox(height: 200),
                  ] else ...[
                    // Daily Progress Card
                    AnimationConfiguration.staggeredList(
                      position: 0,
                      duration: const Duration(milliseconds: 600),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: DailyProgressCard(
                            streak: currentStreak,
                            meditationMinutes: todayMeditation,
                            moodAverage: moodAverage,
                            isLoading: false, // Analytics loading is handled separately
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Quick Mood Check
                    if (!hasLoggedMoodToday) ...[
                      AnimationConfiguration.staggeredList(
                        position: 1,
                        duration: const Duration(milliseconds: 600),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: MoodQuickLog(
                              onMoodSelected: (mood, rating) {
                                _handleMoodLog(mood, rating);
                              },
                              isLoading: isSavingMood,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    
                    // Quick Actions Grid
                    AnimationConfiguration.staggeredList(
                      position: 2,
                      duration: const Duration(milliseconds: 600),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: QuickActionGrid(
                            onActionTap: _handleQuickAction,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Insights Summary
                    AnimationConfiguration.staggeredList(
                      position: 3,
                      duration: const Duration(milliseconds: 600),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: InsightsSummary(
                            weeklyMoodTrend: [], //  data loaded in widget from firebase
                            meditationStreak: currentStreak,
                            journalEntries: 0, //  data loaded in widget from firebase
                            useRealData: true,
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 100), // Space for bottom navigation
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: MainNavigation(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() {
            _currentNavIndex = index;
          });
          _handleNavigation(index);
        },
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    final hour = DateTime.now().hour;
    String greeting;
    String greetingIcon;
    
    if (hour < 12) {
      greeting = "Good morning";
      greetingIcon = "🌅";
    } else if (hour < 17) {
      greeting = "Good afternoon";
      greetingIcon = "☀️";
    } else {
      greeting = "Good evening";
      greetingIcon = "🌙";
    }

    final displayName = currentUser?.displayName ?? 'User';

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              isLoading
                  ? Container(
                      height: 28,
                      width: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    )
                  : Text(
                      '$greeting, $displayName $greetingIcon',
                      style: theme.textTheme.headlineMedium,
                    ),
              const SizedBox(height: 4),
              Text(
                'How are you feeling today?',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
          ),
          child: IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
            icon: Icon(
              Icons.person_outline,
              color: AppTheme.primaryGreen,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleMoodLog(String mood, int rating) async {
    setState(() {
      isSavingMood = true;
    });

    try {
      final user = FirebaseService.getCurrentUser();
      if (user != null) {
        final moodModel = MoodModel(
          id: '',
          userId: user.uid,
          moodType: mood,
          emoji: _getMoodEmoji(rating),
          moodValue: rating,
          timestamp: DateTime.now(),
          note: '', // Could be extended to include a note
        );
        
        await FirebaseService.saveMood(moodModel);
        
        setState(() {
          hasLoggedMoodToday = true;
        });
        
        // Refresh analytics after mood log
        await _loadUserAnalytics(user.uid);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Mood logged: $mood 😊'),
            backgroundColor: AppTheme.primaryGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      print('Error saving mood: $e');
      setState(() {
        hasLoggedMoodToday = false; // Reset so user can try again
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to save mood. Please try again.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    } finally {
      setState(() {
        isSavingMood = false;
      });
    }
  }

  void _handleQuickAction(String action) {
    switch (action) {
      case 'meditate':
        Navigator.pushNamed(context, '/meditation');
        break;
      case 'journal':
        Navigator.pushNamed(context, '/journal');
        break;
      case 'breathe':
        Navigator.pushNamed(context, '/breathing');
        break;
      case 'sleep':
        Navigator.pushNamed(context, '/sleep');
        break;
      case 'affirmations':
        Navigator.pushNamed(context, '/affirmations');
        break;
      case 'cbt':
        Navigator.pushNamed(context, '/cbt');
        break;
    }
  }

  void _handleNavigation(int index) {
    switch (index) {
      case 0:
        // Already on home
        break;
      case 1:
        Navigator.pushNamed(context, '/ai-chatbot');
        break;
      case 2:
        Navigator.pushNamed(context, '/meditation');
        break;
      case 3:
        Navigator.pushNamed(context, '/journal');
        break;
      case 4:
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  String _getMoodEmoji(int rating) {
    switch (rating) {
      case 1:
        return '😞';
      case 2:
        return '😔';
      case 3:
        return '😐';
      case 4:
        return '😊';
      case 5:
        return '😄';
      default:
        return '😐';
    }
  }
}
