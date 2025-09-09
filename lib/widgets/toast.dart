import 'dart:async';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

/// A service for displaying toast notifications throughout the app
///
/// This class provides methods for showing success, error, info, and warning
/// toast notifications with consistent styling and behavior.
class ToastService {
  /// The default shadow style for all toasts
  static final BoxShadow defaultShadow = BoxShadow(
    color: Colors.black.withOpacity(0.2),
    blurRadius: 4,
    offset: const Offset(0, 2),
  );

  /// Shows a success toast notification
  static void showSuccess({
    required BuildContext context,
    required String title,
    String? description,
    Duration duration = const Duration(seconds: 4),
    Alignment alignment = Alignment.topCenter,
    BorderRadius? borderRadius,
    List<BoxShadow>? boxShadow,
  }) {
    toastification.show(
      context: context,
      type: ToastificationType.success,
      style: ToastificationStyle.flat,
      title: Text(title),
      description: description != null ? Text(description) : null,
      alignment: alignment,
      autoCloseDuration: duration,
      borderRadius: borderRadius ?? BorderRadius.circular(12.0),
      boxShadow: boxShadow ?? [defaultShadow],
    );
  }

  /// Shows an error toast notification
  static void showError({
    required BuildContext context,
    required String title,
    String? description,
    Duration duration = const Duration(seconds: 4),
    Alignment alignment = Alignment.topCenter,
    BorderRadius? borderRadius,
    List<BoxShadow>? boxShadow,
  }) {
    toastification.show(
      context: context,
      type: ToastificationType.error,
      style: ToastificationStyle.flat,
      title: Text(title),
      description: description != null ? Text(description) : null,
      alignment: alignment,
      autoCloseDuration: duration,
      borderRadius: borderRadius ?? BorderRadius.circular(12.0),
      boxShadow: boxShadow ?? [defaultShadow],
    );
  }

  /// Shows an info toast notification
  static void showInfo({
    required BuildContext context,
    required String title,
    String? description,
    Duration duration = const Duration(seconds: 4),
    Alignment alignment = Alignment.topCenter,
    BorderRadius? borderRadius,
    List<BoxShadow>? boxShadow,
  }) {
    toastification.show(
      context: context,
      type: ToastificationType.info,
      style: ToastificationStyle.flat,
      title: Text(title),
      description: description != null ? Text(description) : null,
      alignment: alignment,
      autoCloseDuration: duration,
      borderRadius: borderRadius ?? BorderRadius.circular(12.0),
      boxShadow: boxShadow ?? [defaultShadow],
    );
  }

  /// Shows a warning toast notification
  static void showWarning({
    required BuildContext context,
    required String title,
    String? description,
    Duration duration = const Duration(seconds: 4),
    Alignment alignment = Alignment.topCenter,
    BorderRadius? borderRadius,
    List<BoxShadow>? boxShadow,
  }) {
    toastification.show(
      context: context,
      type: ToastificationType.warning,
      style: ToastificationStyle.flat,
      title: Text(title),
      description: description != null ? Text(description) : null,
      alignment: alignment,
      autoCloseDuration: duration,
      borderRadius: borderRadius ?? BorderRadius.circular(12.0),
      boxShadow: boxShadow ?? [defaultShadow],
    );
  }

  /// Shows a toast notification with custom styling
  static void showCustom({
    required BuildContext context,
    Widget? child,
    ToastificationType type = ToastificationType.info,
    String? title,
    String? description,
    Duration duration = const Duration(seconds: 4),
    Alignment alignment = Alignment.topCenter,
    BorderRadius? borderRadius,
    List<BoxShadow>? boxShadow,
    ToastificationStyle style = ToastificationStyle.flat,
    Color? backgroundColor,
    Color? foregroundColor,
  }) {
    if (child != null) {
      // For completely custom widgets, use an overlay
      final overlay = Overlay.of(context);
      late OverlayEntry entry;
      
      entry = OverlayEntry(
        builder: (context) => Positioned(
          top: alignment == Alignment.topCenter ? 50.0 : null,
          bottom: alignment == Alignment.bottomCenter ? 50.0 : null,
          left: 20.0,
          right: 20.0,
          child: Material(
            color: Colors.transparent,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 300),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.8 + (0.2 * value),
                  child: Opacity(
                    opacity: value,
                    child: child,
                  ),
                );
              },
              child: child,
            ),
          ),
        ),
      );
      
      overlay.insert(entry);
      
      // Remove after duration
      Timer(duration, () {
        entry.remove();
      });
      
      return;
    }
    
    // Use standard toastification for non-widget content
    toastification.show(
      context: context,
      type: type,
      style: style,
      title: title != null ? Text(title) : null,
      description: description != null ? Text(description) : null,
      alignment: alignment,
      autoCloseDuration: duration,
      borderRadius: borderRadius ?? BorderRadius.circular(12.0),
      boxShadow: boxShadow ?? [defaultShadow],
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
    );
  }
}