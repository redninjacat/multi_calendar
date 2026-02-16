import 'package:flutter/material.dart';

/// A static helper class for showing consistent SnackBars across the app.
///
/// Provides a centralized way to display transient messages with consistent
/// styling and behavior. Automatically clears any previous SnackBar before
/// showing a new one to prevent message stacking.
class SnackBarHelper {
  /// Shows a SnackBar with the given [message].
  ///
  /// Clears any existing SnackBar before displaying the new one to ensure
  /// only one SnackBar is visible at a time. Uses consistent styling and
  /// a 2-second duration for all messages.
  ///
  /// Example:
  /// ```dart
  /// SnackBarHelper.show(context, 'Event created successfully');
  /// ```
  static void show(BuildContext context, String message) {
    // Clear any existing SnackBar
    ScaffoldMessenger.of(context).clearSnackBars();

    // Show the new SnackBar with consistent styling
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
