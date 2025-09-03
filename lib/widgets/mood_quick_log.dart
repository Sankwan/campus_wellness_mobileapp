import 'package:flutter/material.dart';
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
                Icon(
                  Icons.mood,
                  color: AppTheme.primaryGreen,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Quick Mood Check',
                  style: theme.textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'How are you feeling right now?',
              style: theme.textTheme.bodyMedium,
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
                            setState(() {
                              selectedMoodIndex = index;
                            });
                            
                            // Add slight delay for visual feedback
                            Future.delayed(const Duration(milliseconds: 200), () {
                              widget.onMoodSelected(mood['label'], mood['rating']);
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? AppTheme.primaryGreen.withOpacity(0.1)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
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
