import 'package:flutter/material.dart';

/// A collapsible section widget for organizing controls within a control panel.
///
/// Uses [ExpansionTile] to provide a consistent, collapsible section with
/// a styled header and organized child controls. All sections follow the same
/// visual styling for consistency across the app.
class ControlPanelSection extends StatelessWidget {
  /// The section title displayed in the header.
  final String title;

  /// The child widgets to display within the section.
  final List<Widget> children;

  /// Whether the section should be initially expanded.
  /// Defaults to true.
  final bool initiallyExpanded;

  const ControlPanelSection({
    super.key,
    required this.title,
    required this.children,
    this.initiallyExpanded = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ExpansionTile(
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        initiallyExpanded: initiallyExpanded,
        childrenPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        children: children,
      ),
    );
  }
}
