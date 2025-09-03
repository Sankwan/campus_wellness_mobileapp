import 'package:flutter/material.dart';
import '../theme.dart';

class QuickActionGrid extends StatelessWidget {
  final Function(String action) onActionTap;

  const QuickActionGrid({
    super.key,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: [
            _buildActionCard(
              context: context,
              icon: Icons.self_improvement,
              title: 'Meditate',
              subtitle: 'Find your calm',
              gradient: AppTheme.calmingGradient,
              action: 'meditate',
            ),
            _buildActionCard(
              context: context,
              icon: Icons.edit_note,
              title: 'Journal',
              subtitle: 'Express yourself',
              gradient: const LinearGradient(
                colors: [AppTheme.softPurple, AppTheme.lightPurple],
              ),
              action: 'journal',
            ),
            _buildActionCard(
              context: context,
              icon: Icons.air,
              title: 'Breathe',
              subtitle: 'Breathing exercises',
              gradient: const LinearGradient(
                colors: [AppTheme.softBlue, AppTheme.lightBlue],
              ),
              action: 'breathe',
            ),
            _buildActionCard(
              context: context,
              icon: Icons.bedtime,
              title: 'Sleep',
              subtitle: 'Relax & unwind',
              gradient: AppTheme.sleepGradient,
              action: 'sleep',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required LinearGradient gradient,
    required String action,
  }) {
    return GestureDetector(
      onTap: () => onActionTap(action),
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
