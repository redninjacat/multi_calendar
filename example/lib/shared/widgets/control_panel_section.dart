import 'package:flutter/material.dart';

/// A collapsible section widget for organizing controls within a control panel.
///
/// Uses [ExpansionTile] to provide a consistent, collapsible section with
/// a styled header and organized child controls. All sections follow the same
/// visual styling for consistency across the app.
///
/// Set [showTopDivider] to `false` on the first section in a column to avoid
/// a leading divider at the very top. All subsequent sections default to
/// `showTopDivider: true` so that exactly one divider appears between each
/// pair of adjacent sections (no double dividers).
class ControlPanelSection extends StatelessWidget {
  /// The section title displayed in the header.
  final String title;

  /// The child widgets to display within the section.
  final List<Widget> children;

  /// Whether the section should be initially expanded.
  /// Defaults to true.
  final bool initiallyExpanded;

  /// Whether to render a divider above this section.
  ///
  /// Set to `false` for the first section in a control panel to avoid an
  /// unwanted line at the very top. All other sections should use the default
  /// `true` so that one divider separates each pair of adjacent sections.
  final bool showTopDivider;

  const ControlPanelSection({
    super.key,
    required this.title,
    required this.children,
    this.initiallyExpanded = true,
    this.showTopDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Suppress ExpansionTile's built-in M3 top/bottom borders and the divider
    // it inserts between the header and the children when expanded.  Those
    // built-in decorations cause double-dividers between adjacent sections.
    final tile = Theme(
      data: theme.copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
          ),
        ),
        initiallyExpanded: initiallyExpanded,
        // Remove M3's outlined-container shape when expanded/collapsed.
        shape: const RoundedRectangleBorder(),
        collapsedShape: const RoundedRectangleBorder(),
        childrenPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        children: children,
      ),
    );

    if (!showTopDivider) return tile;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Divider(height: 1, thickness: 1),
        tile,
      ],
    );
  }
}
