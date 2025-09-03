import 'package:flutter/material.dart';
import '../theme.dart';

class DailyProgressCard extends StatelessWidget {
  final int streak;
  final int meditationMinutes;
  final double moodAverage;
  final bool isLoading;

  const DailyProgressCard({
    super.key,
    required this.streak,
    required this.meditationMinutes,
    required this.moodAverage,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.meditationGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.local_fire_department,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Daily Progress',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          isLoading
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                )
              : Row(
                  children: [
                    Expanded(
                      child: _buildProgressItem(
                        icon: Icons.local_fire_department,
                        label: 'Streak',
                        value: '$streak days',
                        theme: theme,
                      ),
                    ),
                    Expanded(
                      child: _buildProgressItem(
                        icon: Icons.self_improvement,
                        label: 'Meditation',
                        value: '${meditationMinutes}m',
                        theme: theme,
                      ),
                    ),
                    Expanded(
                      child: _buildProgressItem(
                        icon: Icons.mood,
                        label: 'Mood Avg',
                        value: moodAverage > 0 ? moodAverage.toStringAsFixed(1) : '--',
                        theme: theme,
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildProgressItem({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white70,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}
