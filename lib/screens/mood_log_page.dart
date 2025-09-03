import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:uuid/uuid.dart';

import '../theme.dart';
import '../models/mood_model.dart';
import '../services/firebase_service.dart';

class MoodLogPage extends StatefulWidget {
  const MoodLogPage({super.key});

  @override
  State<MoodLogPage> createState() => _MoodLogPageState();
}

class _MoodLogPageState extends State<MoodLogPage> {
  int selectedMoodIndex = -1;
  List<String> selectedTags = [];
  bool isLoading = false;

  // Enhanced mood options with ratings
  final List<Map<String, dynamic>> moods = [
    {'emoji': '😢', 'label': 'Very Sad', 'rating': 1, 'color': Colors.red},
    {'emoji': '😔', 'label': 'Sad', 'rating': 2, 'color': Colors.orange},
    {'emoji': '😐', 'label': 'Neutral', 'rating': 3, 'color': Colors.yellow},
    {'emoji': '🙂', 'label': 'Good', 'rating': 4, 'color': AppTheme.lightGreen},
    {'emoji': '😄', 'label': 'Great', 'rating': 5, 'color': AppTheme.primaryGreen},
  ];

  // Mood context tags
  final List<String> availableTags = [
    'Work', 'Family', 'Friends', 'Health', 'Exercise', 
    'Sleep', 'Weather', 'Finances', 'Relationships', 'School',
    'Hobbies', 'Travel', 'Food', 'Music', 'Nature'
  ];

  final TextEditingController noteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'How are you feeling?',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date and time
              AnimationConfiguration.staggeredList(
                position: 0,
                duration: const Duration(milliseconds: 600),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: Center(
                      child: Text(
                        _formatCurrentDate(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppTheme.textLight,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Mood Selection
              AnimationConfiguration.staggeredList(
                position: 1,
                duration: const Duration(milliseconds: 600),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Text(
                              'Select your mood',
                              style: theme.textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 20),
                            Wrap(
                              spacing: 20,
                              runSpacing: 20,
                              alignment: WrapAlignment.center,
                              children: List.generate(moods.length, (index) {
                                final mood = moods[index];
                                final isSelected = selectedMoodIndex == index;
                                
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedMoodIndex = index;
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppTheme.primaryGreen.withOpacity(0.1)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppTheme.primaryGreen
                                            : Colors.transparent,
                                        width: 2,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          mood['emoji'],
                                          style: TextStyle(
                                            fontSize: isSelected ? 48 : 40,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          mood['label'],
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                            color: isSelected
                                                ? AppTheme.primaryGreen
                                                : theme.textTheme.bodyMedium?.color,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Context Tags
              if (selectedMoodIndex != -1) ...[
                AnimationConfiguration.staggeredList(
                  position: 2,
                  duration: const Duration(milliseconds: 600),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'What\'s affecting your mood?',
                                style: theme.textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Select all that apply (optional)',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.textLight,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: availableTags.map((tag) {
                                  final isSelected = selectedTags.contains(tag);
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (isSelected) {
                                          selectedTags.remove(tag);
                                        } else {
                                          selectedTags.add(tag);
                                        }
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppTheme.primaryGreen
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: isSelected
                                              ? AppTheme.primaryGreen
                                              : AppTheme.textLight,
                                        ),
                                      ),
                                      child: Text(
                                        tag,
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : theme.textTheme.bodyMedium?.color,
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Notes Section
              if (selectedMoodIndex != -1) ...[
                AnimationConfiguration.staggeredList(
                  position: 3,
                  duration: const Duration(milliseconds: 600),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Add a note',
                                style: theme.textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'What\'s on your mind? (optional)',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.textLight,
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: noteController,
                                maxLines: 4,
                                decoration: InputDecoration(
                                  hintText: 'Write about your day, thoughts, or feelings...',
                                  hintStyle: TextStyle(
                                    color: AppTheme.textLight,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: AppTheme.textLight,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: AppTheme.primaryGreen,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],

              // Save Button
              if (selectedMoodIndex != -1) ...[
                AnimationConfiguration.staggeredList(
                  position: 4,
                  duration: const Duration(milliseconds: 600),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _saveMood,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  'Save Mood',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  String _formatCurrentDate() {
    final now = DateTime.now();
    final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final months = ['January', 'February', 'March', 'April', 'May', 'June',
                   'July', 'August', 'September', 'October', 'November', 'December'];
    
    return '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }

  Future<void> _saveMood() async {
    if (selectedMoodIndex == -1) return;

    setState(() {
      isLoading = true;
    });

    try {
      final selectedMood = moods[selectedMoodIndex];
      final user = FirebaseService.getCurrentUser();
      
      if (user != null) {
        final mood = MoodModel(
          id: const Uuid().v4(),
          userId: user.uid,
          moodType: selectedMood['label'].toString().toLowerCase(),
          emoji: selectedMood['emoji'],
          moodValue: selectedMood['rating'],
          note: noteController.text.isEmpty ? null : noteController.text,
          tags: selectedTags,
          timestamp: DateTime.now(),
        );

        await FirebaseService.saveMood(mood);
        
        // Show success feedback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Mood saved successfully! 🎉'),
            backgroundColor: AppTheme.primaryGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        
        // Navigate back to home
        Navigator.of(context).pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save mood. Please try again.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }
}
