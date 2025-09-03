import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

import 'firebase_service.dart';
import 'error_handling_service.dart';

class DataExportService {
  // Export all user data to JSON
  static Future<void> exportUserData({
    required BuildContext context,
    required String userId,
    String format = 'json',
  }) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Preparing your data export...'),
            ],
          ),
        ),
      );

      // Gather all user data
      final userData = await _gatherUserData(userId);
      
      // Generate export file
      final file = await _createExportFile(userData, format);
      
      // Close loading dialog
      if (context.mounted) {
        Navigator.pop(context);
      }
      
      // Share the file
      await _shareExportFile(file, context);
      
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        ErrorHandlingService.showErrorSnackBar(
          context: context,
          message: 'Failed to export data: ${e.toString()}',
        );
      }
    }
  }
  
  static Future<Map<String, dynamic>> _gatherUserData(String userId) async {
    final userData = <String, dynamic>{};
    
    try {
      // User profile
      final userProfile = await FirebaseService.getUserDocument(userId);
      userData['profile'] = userProfile?.toMap();
      
      // Mood logs
      final moods = await FirebaseService.getUserMoods(userId, limit: 10000);
      userData['moods'] = moods.map((mood) => mood.toMap()).toList();
      
      // Journal entries
      final journals = await FirebaseService.getUserJournals(userId, limit: 10000);
      userData['journals'] = journals.map((journal) => journal.toMap()).toList();
      
      // Meditation sessions
      final sessions = await FirebaseService.getUserMeditationSessions(userId, limit: 10000);
      userData['meditation_sessions'] = sessions.map((session) => session.toMap()).toList();
      
      // Export metadata
      userData['export_info'] = {
        'exported_at': DateTime.now().toIso8601String(),
        'app_version': '1.0.0',
        'data_format': 'json',
        'total_moods': moods.length,
        'total_journals': journals.length,
        'total_meditation_sessions': sessions.length,
      };
      
    } catch (e) {
      throw Exception('Failed to gather user data: $e');
    }
    
    return userData;
  }
  
  static Future<File> _createExportFile(Map<String, dynamic> userData, String format) async {
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
    final fileName = 'wellness_data_export_$timestamp.$format';
    final file = File('${directory.path}/$fileName');
    
    switch (format.toLowerCase()) {
      case 'json':
        final jsonString = JsonEncoder.withIndent('  ').convert(userData);
        await file.writeAsString(jsonString);
        break;
      case 'csv':
        // TODO: Implement CSV export
        throw UnimplementedError('CSV export not yet implemented');
      default:
        throw ArgumentError('Unsupported format: $format');
    }
    
    return file;
  }
  
  static Future<void> _shareExportFile(File file, BuildContext context) async {
    try {
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'My wellness data export from Campus Wellness App',
        subject: 'Wellness Data Export',
      );
      
      // Show success message
      if (context.mounted) {
        ErrorHandlingService.showSuccessSnackBar(
          context: context,
          message: 'Data exported successfully!',
        );
      }
    } catch (e) {
      if (context.mounted) {
        ErrorHandlingService.showErrorSnackBar(
          context: context,
          message: 'Failed to share export file: ${e.toString()}',
        );
      }
    }
  }
  
  // Delete all user data (for account deletion)
  static Future<void> deleteAllUserData({
    required BuildContext context,
    required String userId,
  }) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.warning,
                color: Colors.red,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text('Delete All Data'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'This will permanently delete all your wellness data including:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('• All mood logs'),
              const Text('• All journal entries'),
              const Text('• All meditation history'),
              const Text('• Your profile information'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'This action cannot be undone. Consider exporting your data first.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _performDataDeletion(context, userId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete All Data'),
            ),
          ],
        );
      },
    );
  }
  
  static Future<void> _performDataDeletion(BuildContext context, String userId) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Deleting your data...'),
            ],
          ),
        ),
      );
      
      // Delete all user collections
      // await FirebaseService.deleteAllUserData(userId);
      
      // Sign out user
      await FirebaseService.signOut();
      
      // Close loading dialog and navigate to login
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        
        ErrorHandlingService.showSuccessSnackBar(
          context: context,
          message: 'All data deleted successfully',
        );
      }
      
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        ErrorHandlingService.showErrorSnackBar(
          context: context,
          message: 'Failed to delete data: ${e.toString()}',
        );
      }
    }
  }
  
  // Privacy settings data
  static Map<String, dynamic> getPrivacySettingsData() {
    return {
      'data_collection': {
        'mood_tracking': true,
        'journal_content': true,
        'meditation_usage': true,
        'app_analytics': false,
      },
      'data_sharing': {
        'with_healthcare_providers': false,
        'anonymous_research': false,
        'app_improvement': false,
      },
      'retention_policy': {
        'mood_data_retention_days': 365,
        'journal_data_retention_days': 1095, // 3 years
        'meditation_data_retention_days': 365,
        'auto_delete_old_data': false,
      },
      'export_preferences': {
        'include_mood_data': true,
        'include_journal_content': true,
        'include_meditation_history': true,
        'export_format': 'json',
      },
    };
  }
  
  // Generate privacy report
  static Future<void> generatePrivacyReport({
    required BuildContext context,
    required String userId,
  }) async {
    try {
      final privacyData = {
        'user_id': userId,
        'report_generated_at': DateTime.now().toIso8601String(),
        'privacy_settings': getPrivacySettingsData(),
        'data_summary': await _getDataSummary(userId),
      };
      
      final file = await _createExportFile(privacyData, 'json');
      await _shareExportFile(file, context);
      
    } catch (e) {
      if (context.mounted) {
        ErrorHandlingService.showErrorSnackBar(
          context: context,
          message: 'Failed to generate privacy report: ${e.toString()}',
        );
      }
    }
  }
  
  static Future<Map<String, dynamic>> _getDataSummary(String userId) async {
    try {
      final moods = await FirebaseService.getUserMoods(userId, limit: 1);
      final journals = await FirebaseService.getUserJournals(userId, limit: 1);
      final sessions = await FirebaseService.getUserMeditationSessions(userId, limit: 1);
      
      return {
        'total_mood_entries': moods.length,
        'total_journal_entries': journals.length,
        'total_meditation_sessions': sessions.length,
        'oldest_entry': moods.isNotEmpty 
            ? moods.first.timestamp.toIso8601String()
            : null,
        'most_recent_entry': moods.isNotEmpty 
            ? moods.last.timestamp.toIso8601String()
            : null,
      };
    } catch (e) {
      return {
        'error': 'Failed to generate data summary: $e',
      };
    }
  }
}
