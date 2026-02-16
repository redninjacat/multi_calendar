import 'package:flutter/material.dart';

/// A responsive control panel widget that adapts its layout based on screen width.
///
/// On screens >= 900dp wide, displays as a [Row] with the [child] (calendar)
/// on the left (expanded) and the [controlPanel] on the right as a fixed 300dp
/// sidebar with a border.
///
/// On screens < 900dp, displays as a [Column] with an [ExpansionTile] control
/// panel at the top (collapsed by default) and the [child] (calendar) below
/// (expanded).
class ResponsiveControlPanel extends StatelessWidget {
  /// The main content widget (typically a calendar view).
  final Widget child;

  /// The control panel content (typically settings controls).
  final Widget controlPanel;

  /// The title for the control panel (used in mobile layout).
  /// If null, no title is shown on the ExpansionTile in mobile layout.
  final String? controlPanelTitle;

  const ResponsiveControlPanel({
    super.key,
    required this.child,
    required this.controlPanel,
    this.controlPanelTitle,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth >= 900;

        if (isWideScreen) {
          // Desktop/tablet layout: Row with sidebar
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Calendar content (expanded)
              Expanded(
                child: child,
              ),
              // Control panel sidebar (fixed 300dp width)
              Container(
                width: 300,
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: Theme.of(context).dividerColor,
                      width: 1,
                    ),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: controlPanel,
                ),
              ),
            ],
          );
        } else {
          // Mobile layout: Column with collapsible control panel
          return Column(
            children: [
              // Collapsible control panel
              ExpansionTile(
                title: controlPanelTitle != null
                    ? Text(
                        controlPanelTitle!,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      )
                    : const SizedBox.shrink(),
                initiallyExpanded: false,
                childrenPadding: const EdgeInsets.all(16),
                children: [
                  // Constrain the control panel height and make it scrollable
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: constraints.maxHeight * 0.5, // Max 50% of screen height
                    ),
                    child: SingleChildScrollView(
                      child: controlPanel,
                    ),
                  ),
                ],
              ),
              // Divider
              Divider(
                height: 1,
                thickness: 1,
                color: Theme.of(context).dividerColor,
              ),
              // Calendar content (expanded)
              Expanded(
                child: child,
              ),
            ],
          );
        }
      },
    );
  }
}