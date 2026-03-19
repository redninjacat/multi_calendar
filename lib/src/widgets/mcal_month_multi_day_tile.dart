import 'package:flutter/material.dart';

import '../models/mcal_calendar_event.dart';
import '../styles/mcal_theme.dart';
import 'mcal_callback_details.dart';
import 'mcal_gesture_detector.dart';

/// A widget that renders a segment of a multi-day event tile in Month View.
///
/// This widget is responsible for rendering contiguous multi-day event tiles
/// that span across cells and potentially multiple week rows. It handles:
/// - Smart border radius based on position within the event and row
/// - Custom builder support for full customization
/// - Tap and long-press gesture handling
///
/// Example:
/// ```dart
/// MCalMonthMultiDayTile(
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
class MCalMonthMultiDayTile extends StatelessWidget {
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

  /// Creates a new [MCalMonthMultiDayTile] widget.
  const MCalMonthMultiDayTile({
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

    return MCalGestureDetector(
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
    final defaults = MCalThemeData.fromTheme(Theme.of(context));

    final monthTheme = theme.monthViewTheme;
    final monthDefaults = defaults.monthViewTheme!;

    // Pick the tile-level theme colour based on whether the event is all-day.
    final Color? themeBg = event.isAllDay
        ? (monthTheme?.allDayEventBackgroundColor ?? monthTheme?.eventTileBackgroundColor)
        : monthTheme?.eventTileBackgroundColor;
    final Color fallbackBg = event.isAllDay
        ? (monthDefaults.allDayEventBackgroundColor ?? monthDefaults.eventTileBackgroundColor!)
        : monthDefaults.eventTileBackgroundColor!;

    final backgroundColor = theme.enableEventColorOverrides
        ? themeBg ?? event.color ?? fallbackBg
        : event.color ?? themeBg ?? fallbackBg;

    // Pick text style: all-day events use allDayEventTextStyle when available.
    final textStyle = event.isAllDay
        ? (monthTheme?.allDayEventTextStyle ?? monthTheme?.eventTileTextStyle ?? monthDefaults.eventTileTextStyle!)
        : (monthTheme?.eventTileTextStyle ?? monthDefaults.eventTileTextStyle!);

    // Calculate border radius based on position
    final tileRadius = monthTheme?.multiDayTileBorderRadius ??
        monthDefaults.multiDayTileBorderRadius!;
    final borderRadius = _calculateBorderRadius(details, tileRadius);

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
      content = const SizedBox.shrink();
    }

    // Determine border — all-day events prefer allDay* border properties.
    final borderWidth = event.isAllDay
        ? (monthTheme?.allDayEventBorderWidth ?? monthTheme?.eventTileBorderWidth ?? 0.0)
        : (monthTheme?.eventTileBorderWidth ?? 0.0);
    final Color? borderColorTheme = event.isAllDay
        ? (monthTheme?.allDayEventBorderColor ?? monthTheme?.eventTileBorderColor)
        : monthTheme?.eventTileBorderColor;
    final hasBorder = borderWidth > 0 && borderColorTheme != null;

    Border? tileBorder;
    if (hasBorder) {
      final borderColor = borderColorTheme;
      final topBorder = BorderSide(color: borderColor, width: borderWidth);
      final bottomBorder = BorderSide(color: borderColor, width: borderWidth);
      final isFirstSegment = details.isFirstDayOfEvent && details.isFirstDayInRow;
      final isLastSegment = details.isLastDayOfEvent && details.isLastDayInRow;
      final leftBorder = isFirstSegment
          ? BorderSide(color: borderColor, width: borderWidth)
          : BorderSide.none;
      final rightBorder = isLastSegment
          ? BorderSide(color: borderColor, width: borderWidth)
          : BorderSide.none;
      tileBorder = Border(
        top: topBorder,
        bottom: bottomBorder,
        left: leftBorder,
        right: rightBorder,
      );
    }

    // Calculate inner padding — all-day events prefer allDayEventPadding.
    final tilePadding = event.isAllDay
        ? (monthTheme?.allDayEventPadding ?? monthTheme?.multiDayTilePadding ?? monthDefaults.multiDayTilePadding!)
        : (monthTheme?.multiDayTilePadding ?? monthDefaults.multiDayTilePadding!);
    final hPad = tilePadding.horizontal / 2;
    final vPad = tilePadding.vertical / 2;
    EdgeInsetsGeometry padding;
    if (details.isFirstDayInRow && details.isLastDayInRow) {
      padding = EdgeInsets.symmetric(horizontal: hPad, vertical: vPad);
    } else if (details.isFirstDayInRow) {
      padding = EdgeInsetsDirectional.only(start: hPad, top: vPad, bottom: vPad);
    } else if (details.isLastDayInRow) {
      padding = EdgeInsetsDirectional.only(end: hPad, top: vPad, bottom: vPad);
    } else {
      padding = EdgeInsets.symmetric(vertical: vPad);
    }

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
        border: tileBorder,
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
  BorderRadius _calculateBorderRadius(
    MCalMultiDayTileDetails details,
    double radius,
  ) {
    // Left corners: rounded only if first day of event AND first day in row
    final bool roundLeft =
        details.isFirstDayOfEvent && details.isFirstDayInRow;

    // Right corners: rounded only if last day of event AND last day in row
    final bool roundRight = details.isLastDayOfEvent && details.isLastDayInRow;

    if (roundLeft && roundRight) {
      return BorderRadius.circular(radius);
    } else if (roundLeft) {
      return BorderRadius.only(
        topLeft: Radius.circular(radius),
        bottomLeft: Radius.circular(radius),
      );
    } else if (roundRight) {
      return BorderRadius.only(
        topRight: Radius.circular(radius),
        bottomRight: Radius.circular(radius),
      );
    } else {
      return BorderRadius.zero;
    }
  }
}
