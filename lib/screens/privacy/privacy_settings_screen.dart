import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../theme.dart';
import '../../services/data_export_service.dart';
import '../../services/error_handling_service.dart';
import '../../services/firebase_service.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  // Privacy settings
  //This is a need for when we want to push to playstore. We will need to have these options.
  bool moodTrackingEnabled = true;
  bool journalContentEnabled = true;
  bool meditationUsageEnabled = true;
  bool appAnalyticsEnabled = false;
  bool anonymousResearchEnabled = false;
  bool autoDeleteEnabled = false;
  int dataRetentionDays = 365;
  
  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadPrivacySettings();
  }

  Future<void> _loadPrivacySettings() async {
    setState(() {
      isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      
      setState(() {
        moodTrackingEnabled = prefs.getBool('privacy_mood_tracking') ?? true;
        journalContentEnabled = prefs.getBool('privacy_journal_content') ?? true;
        meditationUsageEnabled = prefs.getBool('privacy_meditation_usage') ?? true;
        appAnalyticsEnabled = prefs.getBool('privacy_app_analytics') ?? false;
        anonymousResearchEnabled = prefs.getBool('privacy_anonymous_research') ?? false;
        autoDeleteEnabled = prefs.getBool('privacy_auto_delete') ?? false;
        dataRetentionDays = prefs.getInt('privacy_retention_days') ?? 365;
      });
    } catch (e) {
      print('Error loading privacy settings: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _savePrivacySettings() async {
    setState(() {
      isSaving = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      
      await Future.wait([
        prefs.setBool('privacy_mood_tracking', moodTrackingEnabled),
        prefs.setBool('privacy_journal_content', journalContentEnabled),
        prefs.setBool('privacy_meditation_usage', meditationUsageEnabled),
        prefs.setBool('privacy_app_analytics', appAnalyticsEnabled),
        prefs.setBool('privacy_anonymous_research', anonymousResearchEnabled),
        prefs.setBool('privacy_auto_delete', autoDeleteEnabled),
        prefs.setInt('privacy_retention_days', dataRetentionDays),
      ]);
      
      if (mounted) {
        ErrorHandlingService.showSuccessSnackBar(
          context: context,
          message: 'Privacy settings saved successfully',
        );
      }
    } catch (e) {
      if (mounted) {
        ErrorHandlingService.showErrorSnackBar(
          context: context,
          message: 'Failed to save privacy settings',
        );
      }
    } finally {
      setState(() {
        isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Privacy & Security',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          if (isSaving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              onPressed: _savePrivacySettings,
              icon: Icon(
                Icons.save,
                color: AppTheme.primaryGreen,
              ),
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Data Collection Section
                  _buildSectionHeader('Data Collection', Icons.data_usage),
                  const SizedBox(height: 16),
                  _buildPrivacyCard([
                    _buildSettingTile(
                      title: 'Mood Tracking',
                      subtitle: 'Allow the app to store your mood check-ins',
                      value: moodTrackingEnabled,
                      onChanged: (value) => setState(() => moodTrackingEnabled = value),
                    ),
                    _buildSettingTile(
                      title: 'Journal Content',
                      subtitle: 'Store and analyze your journal entries',
                      value: journalContentEnabled,
                      onChanged: (value) => setState(() => journalContentEnabled = value),
                    ),
                    _buildSettingTile(
                      title: 'Meditation Usage',
                      subtitle: 'Track your meditation sessions and progress',
                      value: meditationUsageEnabled,
                      onChanged: (value) => setState(() => meditationUsageEnabled = value),
                    ),
                    _buildSettingTile(
                      title: 'App Analytics',
                      subtitle: 'Help improve the app with anonymous usage data',
                      value: appAnalyticsEnabled,
                      onChanged: (value) => setState(() => appAnalyticsEnabled = value),
                    ),
                  ]),

                  const SizedBox(height: 32),

                  // Data Sharing Section
                  _buildSectionHeader('Data Sharing', Icons.share),
                  const SizedBox(height: 16),
                  _buildPrivacyCard([
                    _buildSettingTile(
                      title: 'Anonymous Research',
                      subtitle: 'Contribute to mental health research (anonymized)',
                      value: anonymousResearchEnabled,
                      onChanged: (value) => setState(() => anonymousResearchEnabled = value),
                    ),
                  ]),

                  const SizedBox(height: 32),

                  // Data Retention Section
                  _buildSectionHeader('Data Retention', Icons.schedule),
                  const SizedBox(height: 16),
                  _buildPrivacyCard([
                    _buildSettingTile(
                      title: 'Auto-Delete Old Data',
                      subtitle: 'Automatically remove data older than retention period',
                      value: autoDeleteEnabled,
                      onChanged: (value) => setState(() => autoDeleteEnabled = value),
                    ),
                    if (autoDeleteEnabled) ...[
                      const Divider(),
                      _buildRetentionSelector(),
                    ],
                  ]),

                  const SizedBox(height: 32),

                  // Data Management Section
                  _buildSectionHeader('Data Management', Icons.folder_open),
                  const SizedBox(height: 16),
                  _buildPrivacyCard([
                    _buildActionTile(
                      title: 'Export My Data',
                      subtitle: 'Download all your data in a portable format',
                      icon: Icons.download,
                      onTap: _exportData,
                    ),
                    const Divider(),
                    _buildActionTile(
                      title: 'Privacy Report',
                      subtitle: 'Generate a detailed privacy and data report',
                      icon: Icons.description,
                      onTap: _generatePrivacyReport,
                    ),
                    const Divider(),
                    _buildActionTile(
                      title: 'Delete All Data',
                      subtitle: 'Permanently remove all your data from our servers',
                      icon: Icons.delete_forever,
                      color: Colors.red,
                      onTap: _deleteAllData,
                    ),
                  ]),

                  const SizedBox(height: 32),

                  // Information Section
                  _buildInfoSection(theme),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppTheme.primaryGreen,
          size: 24,
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacyCard(List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppTheme.textLight,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primaryGreen,
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    final tileColor = color ?? AppTheme.primaryGreen;
    
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: tileColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: tileColor,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: tileColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppTheme.textLight,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: AppTheme.textLight,
      ),
      onTap: onTap,
    );
  }

  Widget _buildRetentionSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Data Retention Period',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            value: dataRetentionDays,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            items: const [
              DropdownMenuItem(value: 30, child: Text('30 days')),
              DropdownMenuItem(value: 90, child: Text('3 months')),
              DropdownMenuItem(value: 180, child: Text('6 months')),
              DropdownMenuItem(value: 365, child: Text('1 year')),
              DropdownMenuItem(value: 730, child: Text('2 years')),
              DropdownMenuItem(value: 1095, child: Text('3 years')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  dataRetentionDays = value;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryGreen.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppTheme.primaryGreen,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Your Privacy Matters',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'We are committed to protecting your privacy and mental health data. All data is encrypted in transit and at rest. You have complete control over your data and can export or delete it at any time.',
            style: TextStyle(height: 1.5),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.security,
                color: AppTheme.primaryGreen,
                size: 16,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'GDPR & HIPAA Compliant',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _exportData() async {
    final user = FirebaseService.getCurrentUser();
    if (user != null) {
      await DataExportService.exportUserData(
        context: context,
        userId: user.uid,
      );
    }
  }

  void _generatePrivacyReport() async {
    final user = FirebaseService.getCurrentUser();
    if (user != null) {
      await DataExportService.generatePrivacyReport(
        context: context,
        userId: user.uid,
      );
    }
  }

  void _deleteAllData() async {
    final user = FirebaseService.getCurrentUser();
    if (user != null) {
      await DataExportService.deleteAllUserData(
        context: context,
        userId: user.uid,
      );
    }
  }
}
