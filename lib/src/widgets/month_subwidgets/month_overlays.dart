import 'package:flutter/material.dart';

import '../../styles/mcal_theme.dart';

/// Loading overlay widget displayed during event loading.
///
/// Shows a semi-transparent background with a centered loading spinner.
/// The calendar grid remains visible underneath.
class LoadingOverlay extends StatelessWidget {
  /// The theme for styling.
  final MCalThemeData theme;

  const LoadingOverlay({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    final scrimColor = theme.monthTheme?.overlayScrimColor ??
        MCalThemeData.fromTheme(Theme.of(context)).monthTheme!.overlayScrimColor!;
    return Positioned.fill(
      child: Container(
        color: scrimColor,
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

/// Error overlay widget displayed when event loading fails.
///
/// Shows a semi-transparent background with a centered error message,
/// icon, and retry button. The calendar grid remains visible underneath.
class ErrorOverlay extends StatelessWidget {
  /// The error that occurred.
  final Object? error;

  /// Callback to retry loading.
  final VoidCallback onRetry;

  /// The theme for styling.
  final MCalThemeData theme;

  const ErrorOverlay({
    super.key,
    required this.error,
    required this.onRetry,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    // Get error message - use string representation or generic message
    final errorMessage = error is String
        ? error as String
        : 'Failed to load events. Please try again.';

    final defaults = MCalThemeData.fromTheme(Theme.of(context));
    final scrimColor = theme.monthTheme?.overlayScrimColor ??
        defaults.monthTheme!.overlayScrimColor!;
    final errorIconColor = theme.monthTheme?.errorIconColor ??
        defaults.monthTheme!.errorIconColor!;
    return Positioned.fill(
      child: Container(
        color: scrimColor,
        child: Center(
          child: Card(
            margin: const EdgeInsets.all(32),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: errorIconColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    errorMessage,
                    textAlign: TextAlign.center,
                    style:
                        theme.monthTheme?.cellTextStyle?.copyWith(
                          fontSize: 14,
                        ) ??
                        const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
