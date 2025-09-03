import 'package:flutter/material.dart';
import '../theme.dart';

class MainNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const MainNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: 'Home',
                index: 0,
              ),
              _buildNavItem(
                icon: Icons.psychology_outlined,
                activeIcon: Icons.psychology,
                label: 'AI Doctor',
                index: 1,
              ),
              _buildNavItem(
                icon: Icons.self_improvement_outlined,
                activeIcon: Icons.self_improvement,
                label: 'Meditate',
                index: 2,
              ),
              _buildNavItem(
                icon: Icons.book_outlined,
                activeIcon: Icons.book,
                label: 'Journal',
                index: 3,
              ),
              _buildNavItem(
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: 'Profile',
                index: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final isActive = currentIndex == index;
    
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive 
              ? AppTheme.primaryGreen.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive 
                  ? AppTheme.primaryGreen 
                  : AppTheme.textLight,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive 
                    ? AppTheme.primaryGreen 
                    : AppTheme.textLight,
                fontSize: 12,
                fontWeight: isActive 
                    ? FontWeight.w600 
                    : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
