import 'package:flutter/material.dart';
import '../theme.dart';

class RetryDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onRetry;
  final VoidCallback? onCancel;
  final String retryButtonText;
  final String cancelButtonText;
  final IconData icon;

  const RetryDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onRetry,
    this.onCancel,
    this.retryButtonText = 'Retry',
    this.cancelButtonText = 'Cancel',
    this.icon = Icons.cloud_off,
  });

  static Future<bool?> show({
    required BuildContext context,
    String title = 'Connection Error',
    String message = 'Unable to connect to the server. Please check your internet connection and try again.',
    String retryButtonText = 'Try Again',
    String cancelButtonText = 'Cancel',
    IconData icon = Icons.cloud_off,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => RetryDialog(
        title: title,
        message: message,
        retryButtonText: retryButtonText,
        cancelButtonText: cancelButtonText,
        icon: icon,
        onRetry: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.orange,
                size: 32,
              ),
            ),
            const SizedBox(height: 20),
            
            // Title
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            
            // Message
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Buttons
            Row(
              children: [
                if (onCancel != null) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onCancel,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade400),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        cancelButtonText,
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: ElevatedButton(
                    onPressed: onRetry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.refresh, size: 18),
                        const SizedBox(width: 8),
                        Text(retryButtonText),
                      ],
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
}

// Special Ho Tech University themed retry dialog
class HoTechRetryDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onRetry;
  final VoidCallback? onCancel;

  const HoTechRetryDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onRetry,
    this.onCancel,
  });

  static Future<bool?> show({
    required BuildContext context,
    String title = 'Campus Connection Issue',
    String message = 'Having trouble connecting to Ho Technical University wellness services. Let\'s try again!',
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => HoTechRetryDialog(
        title: title,
        message: message,
        onRetry: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 8,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryGreen.withOpacity(0.05),
              AppTheme.lightGreen.withOpacity(0.05),
            ],
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ho Tech Logo/Icon
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.primaryGreen.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.school,
                    color: AppTheme.primaryGreen,
                    size: 24,
                  ),
                  Text(
                    'HTU',
                    style: TextStyle(
                      color: AppTheme.primaryGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Title
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryGreen,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            
            // Message
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            
            // Encouraging message for students
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.lightGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.lightGreen.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: AppTheme.primaryGreen,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Stay resilient, HTU student! Technical hiccups are just temporary.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.primaryGreen,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Buttons
            Row(
              children: [
                if (onCancel != null) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onCancel,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppTheme.primaryGreen.withOpacity(0.5)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'Later',
                        style: TextStyle(color: AppTheme.primaryGreen),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: ElevatedButton(
                    onPressed: onRetry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.refresh, size: 18),
                        const SizedBox(width: 8),
                        const Text('Try Again'),
                      ],
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
}
