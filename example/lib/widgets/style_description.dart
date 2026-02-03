import 'package:flutter/material.dart';

/// A widget that displays a description for a style tab.
class StyleDescription extends StatelessWidget {
  const StyleDescription({
    super.key,
    required this.description,
  });

  final String description;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
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
            size: 20,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              description,
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurface.withAlpha(200),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
