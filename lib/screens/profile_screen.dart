import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';

import '../theme.dart';
import '../services/firebase_service.dart';
import '../services/data_export_service.dart';
import '../widgets/retry_dialog.dart';
import '../models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? currentUser;
  bool isLoading = true;
  String? errorMessage;
  
  // User stats
  int totalMoods = 0;
  int totalJournals = 0;
  int totalMeditations = 0;
  int currentStreak = 0;
  double averageMood = 0.0;
  DateTime? lastActivity;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final user = FirebaseService.getCurrentUser();
      if (user != null) {
        // Load user document
        final userDoc = await FirebaseService.getUserDocument(user.uid);
        if (userDoc != null) {
          setState(() {
            currentUser = userDoc;
          });
        }

        // Load user stats
        await _loadUserStats(user.uid);
      }
    } catch (e) {
      print('Error loading profile: $e');
      
      if (mounted) {
        final shouldRetry = await HoTechRetryDialog.show(
          context: context,
          title: 'HTU Profile Loading Issue',
          message: 'Unable to load your profile. Let\'s refresh your wellness data!',
        );
        
        if (shouldRetry == true) {
          _loadUserProfile(); // Retry
        } else {
          setState(() {
            errorMessage = 'HTU profile data unavailable. Pull to refresh when ready.';
          });
        }
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadUserStats(String userId) async {
    try {
      // Get all user moods
      final moods = await FirebaseService.getUserMoods(userId, limit: 1000);
      
      // Get all user journals
      final journals = await FirebaseService.getUserJournals(userId, limit: 1000);
      
      // Get all meditation sessions
      final sessions = await FirebaseService.getUserMeditationSessions(userId, limit: 1000);
      
      // Calculate stats
      final moodTotal = moods.isNotEmpty 
          ? moods.map((m) => m.moodValue).reduce((a, b) => a + b) / moods.length
          : 0.0;
      
      // Find last activity
      DateTime? lastAct;
      final allDates = <DateTime>[];
      allDates.addAll(moods.map((m) => m.timestamp));
      allDates.addAll(journals.map((j) => j.createdAt));
      allDates.addAll(sessions.map((s) => s.startTime));
      
      if (allDates.isNotEmpty) {
        allDates.sort((a, b) => b.compareTo(a));
        lastAct = allDates.first;
      }

      // Calculate streak
      final streak = await _calculateStreak(userId);
      
      setState(() {
        totalMoods = moods.length;
        totalJournals = journals.length;
        totalMeditations = sessions.where((s) => s.isCompleted).length;
        averageMood = moodTotal;
        lastActivity = lastAct;
        currentStreak = streak;
      });
    } catch (e) {
      print('Error loading user stats: $e');
    }
  }

  Future<int> _calculateStreak(String userId) async {
    try {
      final now = DateTime.now();
      int streak = 0;
      
      for (int i = 0; i < 365; i++) {
        final checkDate = now.subtract(Duration(days: i));
        final startOfDay = DateTime(checkDate.year, checkDate.month, checkDate.day);
        final endOfDay = DateTime(checkDate.year, checkDate.month, checkDate.day, 23, 59, 59);
        
        final moods = await FirebaseService.getMoodsByDateRange(userId, startOfDay, endOfDay);
        final sessions = await FirebaseService.getUserMeditationSessions(userId, limit: 1000);
        final daySessions = sessions.where((session) {
          final sessionDate = session.startTime;
          return sessionDate.isAfter(startOfDay) && sessionDate.isBefore(endOfDay);
        }).toList();
        
        if (moods.isNotEmpty || daySessions.isNotEmpty) {
          streak++;
        } else {
          break;
        }
      }
      
      return streak;
    } catch (e) {
      print('Error calculating streak: $e');
      return 0;
    }
  }

  String _generateAvatar(String name) {
    final colors = [
      Colors.blue, Colors.green, Colors.purple, Colors.orange,
      Colors.pink, Colors.teal, Colors.indigo, Colors.red
    ];
    
    final colorIndex = name.hashCode % colors.length;
    return name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'U';
  }

  Color _getAvatarColor(String name) {
    final colors = [
      Colors.blue, Colors.green, Colors.purple, Colors.orange,
      Colors.pink, Colors.teal, Colors.indigo, Colors.red
    ];
    
    return colors[name.hashCode % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  'HTU',
                  style: TextStyle(
                    color: AppTheme.primaryGreen,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Student Profile',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _showSettingsMenu,
            icon: Icon(
              Icons.settings_outlined,
              color: AppTheme.primaryGreen,
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? _buildErrorState()
              : RefreshIndicator(
                  onRefresh: _loadUserProfile,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Profile Header
                          _buildProfileHeader(theme),
                          const SizedBox(height: 32),
                          
                          // Stats Cards
                          _buildStatsGrid(theme),
                          const SizedBox(height: 32),
                          
                          // Quick Actions
                          _buildQuickActions(theme),
                          const SizedBox(height: 32),
                          
                          // Account Section
                          _buildAccountSection(theme),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.withOpacity(0.6),
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage!,
              style: TextStyle(
                fontSize: 16,
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadUserProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ThemeData theme) {
    final displayName = currentUser?.displayName ?? 'User';
    final email = currentUser?.email ?? '';
    final joinDate = currentUser?.createdAt ?? DateTime.now();
    
    return Column(
      children: [
        // Avatar
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: _getAvatarColor(displayName),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _getAvatarColor(displayName).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Center(
            child: Text(
              _generateAvatar(displayName),
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Name
        Text(
          displayName,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Email
        Text(
          email,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textLight,
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Member since
        Text(
          'Member since ${_formatDate(joinDate)}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppTheme.textLight,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(ThemeData theme) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildStatCard(
          theme: theme,
          title: 'Mood Logs',
          value: totalMoods.toString(),
          icon: Icons.mood,
          color: AppTheme.primaryGreen,
        ),
        _buildStatCard(
          theme: theme,
          title: 'Journal Entries',
          value: totalJournals.toString(),
          icon: Icons.book,
          color: AppTheme.softPurple,
        ),
        _buildStatCard(
          theme: theme,
          title: 'Meditations',
          value: totalMeditations.toString(),
          icon: Icons.self_improvement,
          color: Colors.blue,
        ),
        _buildStatCard(
          theme: theme,
          title: 'Current Streak',
          value: '$currentStreak days',
          icon: Icons.local_fire_department,
          color: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required ThemeData theme,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                theme: theme,
                title: 'Export Data',
                icon: Icons.download_outlined,
                onTap: _exportUserData,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionButton(
                theme: theme,
                title: 'Share App',
                icon: Icons.share_outlined,
                onTap: _shareApp,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required ThemeData theme,
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.primaryGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.primaryGreen.withOpacity(0.2),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppTheme.primaryGreen,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryGreen,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Account',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Account Options
        _buildAccountOption(
          icon: Icons.edit_outlined,
          title: 'Edit Profile',
          subtitle: 'Update your display name and preferences',
          onTap: _editProfile,
          theme: theme,
        ),
        _buildAccountOption(
          icon: Icons.privacy_tip_outlined,
          title: 'Privacy Settings',
          subtitle: 'Manage your data and privacy preferences',
          onTap: _showPrivacySettings,
          theme: theme,
        ),
        _buildAccountOption(
          icon: Icons.notifications_outlined,
          title: 'Notifications',
          subtitle: 'Customize your notification preferences',
          onTap: _showNotificationSettings,
          theme: theme,
        ),
        _buildAccountOption(
          icon: Icons.help_outline,
          title: 'Help & Support',
          subtitle: 'Get help or contact support',
          onTap: _showHelp,
          theme: theme,
        ),
        _buildAccountOption(
          icon: Icons.info_outline,
          title: 'About',
          subtitle: 'App version and information',
          onTap: _showAbout,
          theme: theme,
        ),
        const SizedBox(height: 24),
        
        // Sign Out Button
        // SizedBox(
        //   width: double.infinity,
        //   child: ElevatedButton(
        //     onPressed: _signOut,
        //     style: ElevatedButton.styleFrom(
        //       backgroundColor: Colors.grey.shade100,
        //       foregroundColor: Colors.white,
        //       padding: const EdgeInsets.symmetric(vertical: 16),
        //       shape: RoundedRectangleBorder(
        //         borderRadius: BorderRadius.circular(12),
        //       ),
        //     ),
        //     child: Text(
        //       'Sign Out',
        //       style: TextStyle(
        //         fontSize: 16,
        //         fontWeight: FontWeight.w600,
        //       ),
        //     ),
        //   ),
        // ),
        Center(child: TextButton(onPressed: _signOut, child: Text('Sign Out', style: TextStyle(color: Colors.grey.shade400, fontSize: 14),)))
      ],
    );
  }

  Widget _buildAccountOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryGreen,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppTheme.textLight,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: AppTheme.textLight,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showSettingsMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Settings',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.edit, color: AppTheme.primaryGreen),
              title: const Text('Edit Profile'),
              onTap: () {
                Navigator.pop(context);
                _editProfile();
              },
            ),
            ListTile(
              leading: Icon(Icons.download, color: AppTheme.primaryGreen),
              title: const Text('Export Data'),
              onTap: () {
                Navigator.pop(context);
                _exportUserData();
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: const Text('Sign Out'),
              onTap: () {
                Navigator.pop(context);
                _signOut();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _editProfile() {
    showDialog(
      context: context,
      builder: (context) => _buildEditProfileDialog(),
    );
  }

  Widget _buildEditProfileDialog() {
    final nameController = TextEditingController(text: currentUser?.displayName ?? '');
    
    return AlertDialog(
      title: const Text('Edit Profile'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: 'Display Name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (nameController.text.trim().isNotEmpty) {
              try {
                final user = FirebaseService.getCurrentUser();
                if (user != null) {
                  await user.updateDisplayName(nameController.text.trim());
                  
                  final updatedUser = currentUser!.copyWith(
                    displayName: nameController.text.trim(),
                  );
                  await FirebaseService.updateUserDocument(updatedUser);
                  
                  setState(() {
                    currentUser = updatedUser;
                  });
                  
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Profile updated successfully'),
                      backgroundColor: AppTheme.primaryGreen,
                    ),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Failed to update profile'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _exportUserData() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Export Data coming soon!'),
        backgroundColor: AppTheme.primaryGreen,
      ),
    );
  }


  void _shareApp() {
    // TODO: Implement app sharing
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Share feature coming soon!'),
        backgroundColor: AppTheme.primaryGreen,
      ),
    );
  }

  void _showPrivacySettings() {
    Navigator.pushNamed(context, '/privacy-settings');
  }

  void _showNotificationSettings() {
    // TODO: Implement notification settings
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Notification settings coming soon!'),
        backgroundColor: AppTheme.primaryGreen,
      ),
    );
  }

  void _showHelp() {
    // TODO: Implement help section
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Help section coming soon!'),
        backgroundColor: AppTheme.primaryGreen,
      ),
    );
  }

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: 'Campus Wellness',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppTheme.primaryGreen,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.self_improvement,
          color: Colors.white,
          size: 24,
        ),
      ),
      children: [
        const Text('A comprehensive wellness app designed to support your mental health journey through mood tracking, meditation, and journaling.'),
      ],
    );
  }

  Future<void> _signOut() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await FirebaseService.signOut();
                Navigator.pushReplacementNamed(context, '/login');
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Failed to sign out'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}
