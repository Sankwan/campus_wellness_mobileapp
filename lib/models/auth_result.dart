import 'package:firebase_auth/firebase_auth.dart';

/// Result class for authentication operations with better error handling
class AuthResult {
  final AuthStatus status;
  final User? user;
  final String? message;
  
  AuthResult._({
    required this.status,
    this.user,
    this.message,
  });
  
  /// Authentication was successful
  factory AuthResult.success(User? user) => AuthResult._(
    status: AuthStatus.success,
    user: user,
  );
  
  /// User already exists (for signup)
  factory AuthResult.userExists(String message) => AuthResult._(
    status: AuthStatus.userExists,
    message: message,
  );
  
  /// User not found (for login)
  factory AuthResult.userNotFound(String message) => AuthResult._(
    status: AuthStatus.userNotFound,
    message: message,
  );
  
  /// Network or connectivity error
  factory AuthResult.networkError(String message) => AuthResult._(
    status: AuthStatus.networkError,
    message: message,
  );
  
  /// General authentication error
  factory AuthResult.error(String message) => AuthResult._(
    status: AuthStatus.error,
    message: message,
  );
  
  /// Check if the operation was successful
  bool get isSuccess => status == AuthStatus.success;
  
  /// Check if user already exists
  bool get userAlreadyExists => status == AuthStatus.userExists;
  
  /// Check if user was not found
  bool get userWasNotFound => status == AuthStatus.userNotFound;
  
  /// Check if it's a network error
  bool get isNetworkError => status == AuthStatus.networkError;
  
  /// Check if there was an error
  bool get hasError => status == AuthStatus.error;
}

/// Status enum for authentication results
enum AuthStatus {
  success,
  userExists,
  userNotFound,
  networkError,
  error,
}

/// Custom exception for authentication errors
class AuthException implements Exception {
  final String message;
  
  const AuthException(this.message);
  
  @override
  String toString() => 'AuthException: $message';
}

/// Custom exception for network errors
class NetworkException implements Exception {
  final String message;
  
  const NetworkException(this.message);
  
  @override
  String toString() => 'NetworkException: $message';
}
