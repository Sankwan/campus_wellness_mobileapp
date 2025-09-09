import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';

class MoodQuickLog extends StatefulWidget {
  final Function(String mood, int rating) onMoodSelected;
  final bool isLoading;

  const MoodQuickLog({
    super.key,
    required this.onMoodSelected,
    this.isLoading = false,
  });

  @override
  State<MoodQuickLog> createState() => _MoodQuickLogState();
}

class _MoodQuickLogState extends State<MoodQuickLog> {
  int? selectedMoodIndex;

//homepage emoji list
  final List<Map<String, dynamic>> moods = [
    {'emoji': '😢', 'label': 'Very Sad', 'rating': 1, 'color': Colors.red},
    {'emoji': '😔', 'label': 'Sad', 'rating': 2, 'color': Colors.orange},
    {'emoji': '😐', 'label': 'Okay', 'rating': 3, 'color': Colors.yellow},
    {'emoji': '🙂', 'label': 'Good', 'rating': 4, 'color': AppTheme.lightGreen},
    {'emoji': '😄', 'label': 'Great', 'rating': 5, 'color': AppTheme.primaryGreen},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryGreen,
                        AppTheme.lightGreen,
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.psychology,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ' Mood Check 💚',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'How are you feeling on campus today?',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            widget.isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(moods.length, (index) {
                        final mood = moods[index];
                        final isSelected = selectedMoodIndex == index;
                        
                        return GestureDetector(
                          onTap: widget.isLoading ? null : () {
                            // Haptic feedback for better user experience
                            HapticFeedback.lightImpact();
                            
                            setState(() {
                              selectedMoodIndex = index;
                            });
                            
                            // Add slight delay for visual feedback
                            Future.delayed(const Duration(milliseconds: 300), () {
                              widget.onMoodSelected(mood['label'], mood['rating']);
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.elasticOut,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: isSelected 
                                  ? LinearGradient(
                                      colors: [
                                        AppTheme.primaryGreen.withOpacity(0.15),
                                        AppTheme.lightGreen.withOpacity(0.10),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : null,
                              color: isSelected 
                                  ? null
                                  : Colors.grey.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected 
                                    ? AppTheme.primaryGreen 
                                    : Colors.grey.withOpacity(0.2),
                                width: isSelected ? 2.5 : 1,
                              ),
                              boxShadow: isSelected ? [
                                BoxShadow(
                                  color: AppTheme.primaryGreen.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ] : null,
                            ),
                            child: Column(
                              children: [
                                Text(
                                  mood['emoji'],
                                  style: TextStyle(
                                    fontSize: isSelected ? 32 : 28,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  mood['label'],
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: isSelected 
                                        ? FontWeight.bold 
                                        : FontWeight.normal,
                                    color: isSelected 
                                        ? AppTheme.primaryGreen 
                                        : theme.textTheme.bodySmall?.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                ),
          ],
        ),
      ),
    );
  }
}
