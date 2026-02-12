import 'package:flutter/material.dart';

import '../models/mcal_calendar_event.dart';
import '../styles/mcal_theme.dart';
import 'mcal_callback_details.dart';

/// A widget that renders a segment of a multi-day event tile.
///
/// This widget is responsible for rendering contiguous multi-day event tiles
/// that span across cells and potentially multiple week rows. It handles:
/// - Smart border radius based on position within the event and row
/// - Custom builder support for full customization
/// - Tap and long-press gesture handling
///
/// Example:
/// ```dart
/// MCalMultiDayTile(
///   event: myEvent,
///   details: MCalMultiDayTileDetails(
///     event: myEvent,
///     displayDate: DateTime(2024, 2, 15),
///     isFirstDayOfEvent: true,
///     isLastDayOfEvent: false,
///     isFirstDayInRow: true,
///     isLastDayInRow: false,
///     dayIndexInEvent: 0,
///     totalDaysInEvent: 5,
///     dayIndexInRow: 0,
///     totalDaysInRow: 3,
///     rowIndex: 0,
///     totalRows: 2,
///   ),
///   onTap: (context, details) => print('Tapped: ${details.event.title}'),
/// )
/// ```
class MCalMultiDayTile extends StatelessWidget {
  /// The calendar event being rendered.
  final MCalCalendarEvent event;

  /// Details about the tile's position within the event and row.
  final MCalMultiDayTileDetails details;

  /// Optional custom builder for the tile.
  ///
  /// When provided, this builder is called instead of the default tile
  /// rendering. The builder receives the build context and [MCalMultiDayTileDetails].
  final Widget Function(BuildContext, MCalMultiDayTileDetails)? customBuilder;

  /// Callback invoked when the tile is tapped.
  ///
  /// Receives the [BuildContext] and [MCalEventTapDetails] containing the
  /// event and display date.
  final void Function(BuildContext, MCalEventTapDetails)? onTap;

  /// Callback invoked when the tile is long-pressed.
  ///
  /// Receives the [BuildContext] and [MCalEventTapDetails] containing the
  /// event and display date.
  final void Function(BuildContext, MCalEventTapDetails)? onLongPress;

  /// Creates a new [MCalMultiDayTile] widget.
  const MCalMultiDayTile({
    super.key,
    required this.event,
    required this.details,
    this.customBuilder,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    // If custom builder is provided, use it
    if (customBuilder != null) {
      return _wrapWithGestureDetector(
        context,
        customBuilder!(context, details),
      );
    }

    // Build default tile
    return _wrapWithGestureDetector(
      context,
      _buildDefaultTile(context),
    );
  }

  /// Wraps the tile with a GestureDetector for tap/long-press handling.
  Widget _wrapWithGestureDetector(BuildContext context, Widget child) {
    if (onTap == null && onLongPress == null) {
      return child;
    }

    return GestureDetector(
      onTap: onTap != null
          ? () => onTap!(
                context,
                MCalEventTapDetails(
                  event: event,
                  displayDate: details.displayDate,
                ),
              )
          : null,
      onLongPress: onLongPress != null
          ? () => onLongPress!(
                context,
                MCalEventTapDetails(
                  event: event,
                  displayDate: details.displayDate,
                ),
              )
          : null,
      child: child,
    );
  }

  /// Builds the default tile appearance.
  ///
  /// Note: Margins are enforced by the layout delegate ([_MultiDayLayoutDelegate]),
  /// not by this widget. The tile receives its final size (after margin deduction)
  /// and should fill that space completely. The tile IS the clickable/tappable area.
  ///
  /// This widget only handles:
  /// - Background color and border radius
  /// - Internal padding for text spacing from tile edges
  /// - Text content rendering
  Widget _buildDefaultTile(BuildContext context) {
    final theme = MCalTheme.of(context);

    // Determine background color: event.color > theme.allDayEventBackgroundColor
    // > theme.eventTileBackgroundColor > fallback
    final backgroundColor = event.color ??
        theme.allDayEventBackgroundColor ??
        theme.eventTileBackgroundColor ??
        Colors.blue.shade100;

    // Determine text style
    final textStyle = theme.allDayEventTextStyle ??
        theme.eventTileTextStyle ??
        const TextStyle(fontSize: 11, color: Colors.black87);

    // Calculate border radius based on position
    final borderRadius = _calculateBorderRadius(details);

    // Build content: show title only on first day in row for cleaner appearance
    Widget content;
    if (details.isFirstDayInRow) {
      content = Text(
        event.title,
        style: textStyle,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      );
    } else {
      // For non-first days in row, show empty space to maintain tile continuity
      content = const SizedBox.shrink();
    }

    // Calculate inner padding based on position (for text spacing from tile edges)
    EdgeInsetsGeometry padding;
    if (details.isFirstDayInRow && details.isLastDayInRow) {
      padding = const EdgeInsets.symmetric(horizontal: 4, vertical: 2);
    } else if (details.isFirstDayInRow) {
      padding = const EdgeInsetsDirectional.only(start: 4, top: 2, bottom: 2);
    } else if (details.isLastDayInRow) {
      padding = const EdgeInsetsDirectional.only(end: 4, top: 2, bottom: 2);
    } else {
      padding = const EdgeInsets.symmetric(vertical: 2);
    }

    // No margin here - the layout delegate enforces margins
    // This container fills the available space provided by the layout
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
      ),
      padding: padding,
      alignment: Alignment.centerLeft,
      child: content,
    );
  }

  /// Calculates the border radius based on the tile's position flags.
  ///
  /// The border radius is determined by combining two position indicators:
  /// - Position within the event (isFirstDayOfEvent, isLastDayOfEvent)
  /// - Position within the row (isFirstDayInRow, isLastDayInRow)
  ///
  /// A corner is rounded only when both conditions are met:
  /// - Left corners: rounded when isFirstDayOfEvent AND isFirstDayInRow
  /// - Right corners: rounded when isLastDayOfEvent AND isLastDayInRow
  ///
  /// This creates a visual effect where:
  /// - Complete events in a single row have full rounded corners
  /// - Events that wrap to the next row have flat edges at the wrap point
  /// - Continuation segments have flat left edges
  /// - Ending segments have flat left edges but rounded right edges
  BorderRadius _calculateBorderRadius(MCalMultiDayTileDetails details) {
    const double radius = 4.0;

    // Left corners: rounded only if first day of event AND first day in row
    final bool roundLeft =
        details.isFirstDayOfEvent && details.isFirstDayInRow;

    // Right corners: rounded only if last day of event AND last day in row
    final bool roundRight = details.isLastDayOfEvent && details.isLastDayInRow;

    if (roundLeft && roundRight) {
      // Both sides rounded (single-row complete event)
      return BorderRadius.circular(radius);
    } else if (roundLeft) {
      // Only left side rounded
      return const BorderRadius.only(
        topLeft: Radius.circular(radius),
        bottomLeft: Radius.circular(radius),
      );
    } else if (roundRight) {
      // Only right side rounded
      return const BorderRadius.only(
        topRight: Radius.circular(radius),
        bottomRight: Radius.circular(radius),
      );
    } else {
      // No rounding (middle segment or continuation)
      return BorderRadius.zero;
    }
  }
}
