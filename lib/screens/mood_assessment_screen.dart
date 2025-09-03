import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../theme.dart';
import '../services/firebase_service.dart';

class MoodAssessmentScreen extends StatefulWidget {
  const MoodAssessmentScreen({super.key});

  @override
  State<MoodAssessmentScreen> createState() => _MoodAssessmentScreenState();
}

class _MoodAssessmentScreenState extends State<MoodAssessmentScreen> {
  int currentQuestionIndex = 0;
  Map<String, dynamic> answers = {};
  bool isLoading = false;
  
  final List<AssessmentQuestion> questions = [
    AssessmentQuestion(
      id: 'mood_today',
      question: 'How would you describe your overall mood today?',
      type: QuestionType.scale,
      scaleLabels: ['Very Low', 'Low', 'Neutral', 'Good', 'Excellent'],
      category: 'Mood',
    ),
    AssessmentQuestion(
      id: 'energy_level',
      question: 'What is your energy level right now?',
      type: QuestionType.scale,
      scaleLabels: ['Exhausted', 'Tired', 'Okay', 'Energetic', 'Very Energetic'],
      category: 'Energy',
    ),
    AssessmentQuestion(
      id: 'stress_level',
      question: 'How stressed or anxious are you feeling?',
      type: QuestionType.scale,
      scaleLabels: ['Not at all', 'Slightly', 'Moderately', 'Very', 'Extremely'],
      category: 'Stress',
    ),
    AssessmentQuestion(
      id: 'sleep_quality',
      question: 'How was your sleep last night?',
      type: QuestionType.multipleChoice,
      options: [
        'Excellent - slept deeply and feel refreshed',
        'Good - mostly restful with minor interruptions',
        'Fair - some difficulty falling/staying asleep',
        'Poor - restless night with frequent waking',
        'Very poor - barely slept at all'
      ],
      category: 'Sleep',
    ),
    AssessmentQuestion(
      id: 'social_connection',
      question: 'How connected do you feel to others today?',
      type: QuestionType.scale,
      scaleLabels: ['Very Isolated', 'Lonely', 'Neutral', 'Connected', 'Very Connected'],
      category: 'Social',
    ),
    AssessmentQuestion(
      id: 'motivation',
      question: 'How motivated do you feel to tackle your daily tasks?',
      type: QuestionType.scale,
      scaleLabels: ['No Motivation', 'Low', 'Moderate', 'High', 'Very High'],
      category: 'Motivation',
    ),
    AssessmentQuestion(
      id: 'physical_symptoms',
      question: 'Are you experiencing any of these physical symptoms?',
      type: QuestionType.multipleSelect,
      options: [
        'Headaches',
        'Muscle tension',
        'Stomach issues',
        'Fatigue',
        'Difficulty breathing',
        'Heart racing',
        'None of the above'
      ],
      category: 'Physical',
    ),
    AssessmentQuestion(
      id: 'coping_strategies',
      question: 'What have you tried today to manage your wellbeing?',
      type: QuestionType.multipleSelect,
      options: [
        'Deep breathing',
        'Meditation',
        'Exercise',
        'Talked to someone',
        'Journaling',
        'Listened to music',
        'Spent time in nature',
        'Nothing yet'
      ],
      category: 'Coping',
    ),
    AssessmentQuestion(
      id: 'support_needs',
      question: 'What kind of support would be most helpful right now?',
      type: QuestionType.multipleChoice,
      options: [
        'Relaxation and stress relief techniques',
        'Motivation and goal-setting strategies',
        'Social connection and communication tips',
        'Sleep and rest improvement guidance',
        'Professional mental health resources',
        'General wellness and self-care advice'
      ],
      category: 'Support',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentQuestion = questions[currentQuestionIndex];
    final progress = (currentQuestionIndex + 1) / questions.length;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Mood Assessment',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Progress indicator
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppTheme.primaryGreen.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '${currentQuestionIndex + 1}/${questions.length}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Question
            Expanded(
              child: AnimationConfiguration.staggeredList(
                position: currentQuestionIndex,
                duration: const Duration(milliseconds: 600),
                child: SlideAnimation(
                  horizontalOffset: 50.0,
                  child: FadeInAnimation(
                    child: _buildQuestionCard(currentQuestion, theme),
                  ),
                ),
              ),
            ),
            
            // Navigation buttons
            Row(
              children: [
                if (currentQuestionIndex > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousQuestion,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppTheme.primaryGreen),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Previous',
                        style: TextStyle(
                          color: AppTheme.primaryGreen,
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
                    onPressed: _canProceed() ? (currentQuestionIndex == questions.length - 1 
                        ? _completeAssessment 
                        : _nextQuestion) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            currentQuestionIndex == questions.length - 1 
                                ? 'Complete' 
                                : 'Next',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard(AssessmentQuestion question, ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                question.category,
                style: TextStyle(
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Question text
            Text(
              question.question,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Answer options
            Expanded(
              child: _buildAnswerOptions(question, theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerOptions(AssessmentQuestion question, ThemeData theme) {
    switch (question.type) {
      case QuestionType.scale:
        return _buildScaleOptions(question, theme);
      case QuestionType.multipleChoice:
        return _buildMultipleChoiceOptions(question, theme);
      case QuestionType.multipleSelect:
        return _buildMultipleSelectOptions(question, theme);
    }
  }

  Widget _buildScaleOptions(AssessmentQuestion question, ThemeData theme) {
    final selectedValue = answers[question.id] as int?;
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(5, (index) {
            final value = index + 1;
            final isSelected = selectedValue == value;
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  answers[question.id] = value;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppTheme.primaryGreen 
                      : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected 
                        ? AppTheme.primaryGreen 
                        : AppTheme.textLight,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    value.toString(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected 
                          ? Colors.white 
                          : AppTheme.textLight,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        
        const SizedBox(height: 16),
        
        // Scale labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: question.scaleLabels!.asMap().entries.map((entry) {
            final index = entry.key;
            final label = entry.value;
            final isSelected = selectedValue == index + 1;
            
            return Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isSelected 
                      ? AppTheme.primaryGreen 
                      : AppTheme.textLight,
                  fontWeight: isSelected 
                      ? FontWeight.w600 
                      : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMultipleChoiceOptions(AssessmentQuestion question, ThemeData theme) {
    final selectedOption = answers[question.id] as String?;
    
    return ListView.builder(
      itemCount: question.options!.length,
      itemBuilder: (context, index) {
        final option = question.options![index];
        final isSelected = selectedOption == option;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () {
              setState(() {
                answers[question.id] = option;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected 
                    ? AppTheme.primaryGreen.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected 
                      ? AppTheme.primaryGreen 
                      : AppTheme.textLight.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? AppTheme.primaryGreen 
                          : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected 
                            ? AppTheme.primaryGreen 
                            : AppTheme.textLight,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 12,
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      option,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: isSelected 
                            ? FontWeight.w600 
                            : FontWeight.normal,
                        color: isSelected 
                            ? AppTheme.primaryGreen 
                            : theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMultipleSelectOptions(AssessmentQuestion question, ThemeData theme) {
    final selectedOptions = answers[question.id] as List<String>? ?? [];
    
    return ListView.builder(
      itemCount: question.options!.length,
      itemBuilder: (context, index) {
        final option = question.options![index];
        final isSelected = selectedOptions.contains(option);
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () {
              setState(() {
                if (option == 'None of the above' || option == 'Nothing yet') {
                  // Clear other selections if "none" is selected
                  answers[question.id] = [option];
                } else {
                  final currentAnswers = List<String>.from(selectedOptions);
                  
                  // Remove "none" options if other options are selected
                  currentAnswers.removeWhere((item) => 
                      item == 'None of the above' || item == 'Nothing yet');
                  
                  if (isSelected) {
                    currentAnswers.remove(option);
                  } else {
                    currentAnswers.add(option);
                  }
                  
                  answers[question.id] = currentAnswers;
                }
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected 
                    ? AppTheme.primaryGreen.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected 
                      ? AppTheme.primaryGreen 
                      : AppTheme.textLight.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? AppTheme.primaryGreen 
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: isSelected 
                            ? AppTheme.primaryGreen 
                            : AppTheme.textLight,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 12,
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      option,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: isSelected 
                            ? FontWeight.w600 
                            : FontWeight.normal,
                        color: isSelected 
                            ? AppTheme.primaryGreen 
                            : theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  bool _canProceed() {
    return answers.containsKey(questions[currentQuestionIndex].id);
  }

  void _nextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    }
  }

  void _previousQuestion() {
    if (currentQuestionIndex > 0) {
      setState(() {
        currentQuestionIndex--;
      });
    }
  }

  Future<void> _completeAssessment() async {
    setState(() {
      isLoading = true;
    });
    
    try {
      // Save assessment data to Firebase
      final user = FirebaseService.getCurrentUser();
      if (user != null) {
        // You can save the assessment data to a dedicated collection
        // await FirebaseService.saveAssessment(user.uid, answers);
      }
      
      // Calculate assessment score and insights
      final assessmentResult = _calculateAssessmentResult();
      
      // Return results to AI chatbot
      if (mounted) {
        Navigator.pop(context, assessmentResult);
      }
    } catch (e) {
      print('Error saving assessment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to save assessment. Continuing with results...'),
          backgroundColor: Colors.orange,
        ),
      );
      
      // Still return results even if save failed
      final assessmentResult = _calculateAssessmentResult();
      Navigator.pop(context, assessmentResult);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Map<String, dynamic> _calculateAssessmentResult() {
    // Process answers and create comprehensive assessment data
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'answers': answers,
      'summary': _generateSummary(),
      'riskLevel': _assessRiskLevel(),
      'recommendations': _generateRecommendations(),
    };
  }

  String _generateSummary() {
    final mood = answers['mood_today'] ?? 3;
    final stress = answers['stress_level'] ?? 3;
    final energy = answers['energy_level'] ?? 3;
    final motivation = answers['motivation'] ?? 3;
    
    return 'Mood: $mood/5, Stress: $stress/5, Energy: $energy/5, Motivation: $motivation/5';
  }

  String _assessRiskLevel() {
    final mood = answers['mood_today'] ?? 3;
    final stress = answers['stress_level'] ?? 3;
    final energy = answers['energy_level'] ?? 3;
    
    if (mood <= 2 && stress >= 4) {
      return 'elevated';
    } else if (mood >= 4 && stress <= 2 && energy >= 3) {
      return 'low';
    } else {
      return 'moderate';
    }
  }

  List<String> _generateRecommendations() {
    final recommendations = <String>[];
    final stress = answers['stress_level'] ?? 3;
    final energy = answers['energy_level'] ?? 3;
    final sleep = answers['sleep_quality'] as String? ?? '';
    
    if (stress >= 4) {
      recommendations.add('Practice stress-reduction techniques like deep breathing or meditation');
    }
    
    if (energy <= 2) {
      recommendations.add('Focus on gentle movement and ensure adequate rest');
    }
    
    if (sleep.contains('Poor') || sleep.contains('Very poor')) {
      recommendations.add('Prioritize sleep hygiene and establish a bedtime routine');
    }
    
    if (recommendations.isEmpty) {
      recommendations.add('Continue your current wellness practices and stay mindful');
    }
    
    return recommendations;
  }

  @override
  void dispose() {
    super.dispose();
  }
}

// Assessment question model
class AssessmentQuestion {
  final String id;
  final String question;
  final QuestionType type;
  final List<String>? options;
  final List<String>? scaleLabels;
  final String category;

  AssessmentQuestion({
    required this.id,
    required this.question,
    required this.type,
    required this.category,
    this.options,
    this.scaleLabels,
  });
}

enum QuestionType {
  scale,
  multipleChoice,
  multipleSelect,
}
