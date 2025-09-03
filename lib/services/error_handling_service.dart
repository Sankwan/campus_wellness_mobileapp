import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

class ErrorHandlingService {
  static StreamController<ConnectivityResult>? _connectivityController;
  static bool _isOnline = true;
  
  // Initialize connectivity monitoring
  static void initialize() {
    _connectivityController = StreamController<ConnectivityResult>.broadcast();
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
      _isOnline = result != ConnectivityResult.none;
      _connectivityController?.add(result);
    });
  }
  
  // Get connectivity stream
  static Stream<ConnectivityResult>? get connectivityStream => 
      _connectivityController?.stream;
  
  // Check if device is online
  static bool get isOnline => _isOnline;
  
  // Show error dialog with retry option
  static Future<void> showErrorDialog({
    required BuildContext context,
    required String title,
    required String message,
    VoidCallback? onRetry,
    VoidCallback? onCancel,
    bool showRetry = true,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message),
              if (!isOnline) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.orange.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.wifi_off,
                        color: Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'No internet connection. Please check your network.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            if (onCancel != null)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onCancel();
                },
                child: const Text('Cancel'),
              ),
            if (showRetry)
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onRetry?.call();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            if (!showRetry)
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('OK'),
              ),
          ],
        );
      },
    );
  }
  
  // Show success snackbar
  static void showSuccessSnackBar({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
  
  // Show error snackbar
  static void showErrorSnackBar({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onActionPressed,
    String actionLabel = 'Retry',
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        action: onActionPressed != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: Colors.white,
                onPressed: onActionPressed,
              )
            : null,
      ),
    );
  }
  
  // Show warning snackbar
  static void showWarningSnackBar({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.warning_outlined,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
  
  // Handle async operations with error handling
  static Future<T?> handleAsyncOperation<T>({
    required BuildContext context,
    required Future<T> Function() operation,
    required String errorTitle,
    String? loadingMessage,
    String? successMessage,
    bool showLoadingDialog = false,
    bool showSuccessMessage = true,
    VoidCallback? onError,
    VoidCallback? onSuccess,
  }) async {
    // Show loading dialog if requested
    if (showLoadingDialog && loadingMessage != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              Expanded(child: Text(loadingMessage)),
            ],
          ),
        ),
      );
    }
    
    try {
      final result = await operation();
      
      // Close loading dialog
      if (showLoadingDialog && loadingMessage != null) {
        Navigator.of(context).pop();
      }
      
      // Show success message
      if (showSuccessMessage && successMessage != null) {
        showSuccessSnackBar(context: context, message: successMessage);
      }
      
      onSuccess?.call();
      return result;
    } catch (e) {
      // Close loading dialog
      if (showLoadingDialog && loadingMessage != null) {
        Navigator.of(context).pop();
      }
      
      // Show error
      showErrorSnackBar(
        context: context,
        message: '$errorTitle: ${e.toString()}',
      );
      
      onError?.call();
      return null;
    }
  }
  
  // Retry mechanism for failed operations
  static Future<T?> retryOperation<T>({
    required Future<T> Function() operation,
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 2),
  }) async {
    int attempts = 0;
    
    while (attempts < maxRetries) {
      try {
        return await operation();
      } catch (e) {
        attempts++;
        if (attempts >= maxRetries) {
          rethrow;
        }
        await Future.delayed(delay);
      }
    }
    
    return null;
  }
  
  // Dispose resources
  static void dispose() {
    _connectivityController?.close();
    _connectivityController = null;
  }
}

// Custom error types
class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
  
  @override
  String toString() => 'NetworkException: $message';
}

class AuthenticationException implements Exception {
  final String message;
  AuthenticationException(this.message);
  
  @override
  String toString() => 'AuthenticationException: $message';
}

class DataException implements Exception {
  final String message;
  DataException(this.message);
  
  @override
  String toString() => 'DataException: $message';
}

// Offline storage manager
class OfflineStorageManager {
  static const String _moodPrefix = 'offline_mood_';
  static const String _journalPrefix = 'offline_journal_';
  static const String _sessionPrefix = 'offline_session_';
  
  // Save mood offline
  static Future<void> saveMoodOffline(Map<String, dynamic> moodData) async {
    // TODO: Implement offline mood storage using Hive or SQLite
  }
  
  // Save journal offline
  static Future<void> saveJournalOffline(Map<String, dynamic> journalData) async {
    // TODO: Implement offline journal storage
  }
  
  // Sync offline data when connection restored
  static Future<void> syncOfflineData() async {
    // TODO: Implement data sync functionality
  }
}

// Loading state widget
class LoadingStateWidget extends StatelessWidget {
  final String? message;
  final double size;
  
  const LoadingStateWidget({
    super.key,
    this.message,
    this.size = 50,
  });
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: const CircularProgressIndicator(),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

// Error state widget
class ErrorStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final IconData icon;
  
  const ErrorStateWidget({
    super.key,
    required this.title,
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Colors.red.withOpacity(0.6),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.red.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Network status widget
class NetworkStatusWidget extends StatefulWidget {
  final Widget child;
  
  const NetworkStatusWidget({super.key, required this.child});
  
  @override
  State<NetworkStatusWidget> createState() => _NetworkStatusWidgetState();
}

class _NetworkStatusWidgetState extends State<NetworkStatusWidget> {
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool _isOnline = true;
  bool _showingOfflineBanner = false;

  @override
  void initState() {
    super.initState();
    _checkInitialConnectivity();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        // Use the first result or handle multiple as needed
        final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
        _onConnectivityChanged(result);
      },
    );
  }

  Future<void> _checkInitialConnectivity() async {
    final connectivityResults = await Connectivity().checkConnectivity();
    final result = connectivityResults.isNotEmpty
        ? connectivityResults.first
        : ConnectivityResult.none;
    _onConnectivityChanged(result);
  }

  void _onConnectivityChanged(ConnectivityResult result) {
    final isOnline = result != ConnectivityResult.none;
    if (_isOnline != isOnline) {
      setState(() {
        _isOnline = isOnline;
      });

      if (!isOnline && !_showingOfflineBanner) {
        _showOfflineBanner();
      } else if (isOnline && _showingOfflineBanner) {
        _hideOfflineBanner();
      }
    }
  }

  void _showOfflineBanner() {
    setState(() {
      _showingOfflineBanner = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.wifi_off,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text('You are offline. Some features may not work.'),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Future.delayed(const Duration(seconds: 5), () {
      setState(() {
        _showingOfflineBanner = false;
      });
    });
  }

  void _hideOfflineBanner() {
    setState(() {
      _showingOfflineBanner = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.wifi,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text('Connection restored!'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
