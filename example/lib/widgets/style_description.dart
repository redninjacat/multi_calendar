import 'package:flutter/material.dart';

/// A widget that displays a description for a style tab.
class StyleDescription extends StatelessWidget {
  const StyleDescription({
    super.key,
    required this.description,
    this.compact = false,
  });

  final String description;

  /// When true, uses smaller padding and text for a denser layout (e.g. desktop).
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final padding = compact
        ? const EdgeInsets.symmetric(horizontal: 10, vertical: 6)
        : const EdgeInsets.all(16);
    const spacing = 8.0;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withAlpha(50),
        border: Border(
          bottom: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: compact ? 16 : 20,
            color: colorScheme.primary,
          ),
          SizedBox(width: compact ? spacing : 12),
          Expanded(
            child: Text(
              description,
              style: TextStyle(
                fontSize: compact ? 12 : 13,
                color: colorScheme.onSurface.withAlpha(200),
                height: compact ? 1.3 : 1.4,
              ),
              maxLines: compact ? 2 : null,
              overflow: compact ? TextOverflow.ellipsis : null,
            ),
          ),
        ],
      ),
    );
  }
}
