import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:multi_calendar/src/widgets/mcal_gesture_detector.dart';

import '../../controllers/mcal_event_controller.dart';
import '../../models/mcal_calendar_event.dart';
import '../../models/mcal_region.dart';
import '../../styles/mcal_theme.dart';
import '../../utils/mcal_date_format_utils.dart';
import '../../utils/mcal_l10n_helper.dart';
import '../mcal_builder_wrapper.dart';
import '../mcal_callback_details.dart';
import '../mcal_month_view_contexts.dart';

/// Placeholder widget for day cell (will be fully implemented in task 9).
class DayCellWidget extends StatefulWidget {
  final DateTime date;
  final DateTime displayMonth;
  final bool isCurrentMonth;
  final bool isToday;
  final bool isSelectable;
  final bool isFocused;
  final bool autoFocusOnCellTap;
  final ValueChanged<DateTime>? onSetFocusedDate;

  /// All events for this date, used for callbacks.
  final List<MCalCalendarEvent> events;

  final MCalThemeData theme;
  final Widget Function(BuildContext, MCalDayCellContext, Widget)?
  dayCellBuilder;
  final Widget Function(BuildContext, MCalDateLabelContext, String)?
  dateLabelBuilder;
  final DateFormat? dateFormat;
  final bool Function(BuildContext, MCalCellInteractivityDetails)?
  cellInteractivityCallback;
  final void Function(BuildContext, MCalCellTapDetails)? onCellTap;
  final void Function(BuildContext, MCalCellTapDetails)? onCellLongPress;
  final void Function(BuildContext, MCalCellTapDetails)? onCellSecondaryTap;
  final void Function(BuildContext, MCalDateLabelTapDetails)? onDateLabelTap;
  final void Function(BuildContext, MCalDateLabelTapDetails)?
  onDateLabelLongPress;
  final void Function(BuildContext, MCalDateLabelTapDetails)?
  onDateLabelDoubleTap;
  final void Function(BuildContext, MCalDateLabelTapDetails)?
  onDateLabelSecondaryTap;
  final void Function(BuildContext, MCalCellDoubleTapDetails)? onCellDoubleTap;
  final void Function(BuildContext, MCalDayCellContext?)? onHoverCell;
  final void Function(BuildContext, MCalDateLabelContext?)? onHoverDateLabel;
  final Locale locale;
  final MCalEventController controller;

  /// Whether to show date labels in this cell.
  /// Set to false for Layer 1 grid cells when date labels are rendered in Layer 2.
  final bool showDateLabel;

  /// Optional custom builder for day region overlays.
  final Widget Function(BuildContext, MCalRegionContext, Widget)?
  dayRegionBuilder;

  const DayCellWidget({
    super.key,
    required this.date,
    required this.displayMonth,
    required this.isCurrentMonth,
    required this.isToday,
    required this.isSelectable,
    this.isFocused = false,
    this.autoFocusOnCellTap = true,
    this.onSetFocusedDate,
    required this.events,
    required this.theme,
    this.dayCellBuilder,
    this.dateLabelBuilder,
    this.dateFormat,
    this.cellInteractivityCallback,
    this.onCellTap,
    this.onCellLongPress,
    this.onCellSecondaryTap,
    this.onDateLabelTap,
    this.onDateLabelLongPress,
    this.onDateLabelDoubleTap,
    this.onDateLabelSecondaryTap,
    this.onCellDoubleTap,
    this.onHoverCell,
    this.onHoverDateLabel,
    required this.locale,
    this.showDateLabel = true,
    required this.controller,
    this.dayRegionBuilder,
  });

  @override
  State<DayCellWidget> createState() => DayCellWidgetState();
}

class DayCellWidgetState extends State<DayCellWidget> {
  /// Stores tap position from [onDoubleTapDown] for use in [onDoubleTap].
  /// [onDoubleTap] does not receive position, so we capture it here.
  Offset? _lastDoubleTapDownLocalPosition;
  Offset? _lastDoubleTapDownGlobalPosition;

  @override
  Widget build(BuildContext context) {
    // Check if cell is interactive
    final isInteractive = widget.cellInteractivityCallback != null
        ? widget.cellInteractivityCallback!(
            context,
            MCalCellInteractivityDetails(
              date: widget.date,
              isCurrentMonth: widget.isCurrentMonth,
              isSelectable: widget.isSelectable,
            ),
          )
        : true;

    // Create wrapped date label builder for use in dayCellBuilder context
    // This builder is pre-wrapped with tap handlers (or IgnorePointer)
    final wrappedDateLabelBuilder = MCalBuilderWrapper.wrapDateLabelBuilder(
      developerBuilder: widget.dateLabelBuilder,
      defaultBuilder: _buildDefaultDateLabelWidget,
      onDateLabelTap: widget.onDateLabelTap,
      onDateLabelLongPress: widget.onDateLabelLongPress,
      onDateLabelDoubleTap: widget.onDateLabelDoubleTap,
      onDateLabelSecondaryTap: widget.onDateLabelSecondaryTap,
      onHoverDateLabel: widget.onHoverDateLabel,
    );

    // Build cell decoration (apply non-interactive styling if needed)
    final decoration = _getCellDecoration(context, isInteractive);

    // Build date label (only if showDateLabel is true - Layer 2 handles labels now)
    final dateLabel = widget.showDateLabel ? _buildDateLabel(context) : null;

    // Collect matching regions from controller for this cell (used for
    // overlays and context objects).
    final allRegions = widget.controller.getRegionsForDate(widget.date);
    final allDayRegions = allRegions.where((r) => r.isAllDay).toList();

    // Build the cell widget with clip to prevent overflow on small screens
    // The LayoutBuilder dynamically calculates how many events fit
    Widget cell = LayoutBuilder(
      builder: (context, constraints) {
        Widget cellContent = Opacity(
          opacity: isInteractive ? 1.0 : 0.5,
          child: ClipRect(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (dateLabel != null)
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 4.0,
                      top: 4.0,
                      right: 4.0,
                    ),
                    child: dateLabel,
                  ),
              ],
            ),
          ),
        );

        if (allDayRegions.isNotEmpty) {
          cellContent = Stack(
            fit: StackFit.expand,
            children: [
              for (final region in allDayRegions)
                _buildRegionOverlay(context, region),
              cellContent,
            ],
          );
        }

        return Container(
          decoration: decoration,
          clipBehavior: Clip.hardEdge,
          child: cellContent,
        );
      },
    );

    // Apply builder callback if provided
    if (widget.dayCellBuilder != null) {
      final contextObj = MCalDayCellContext(
        date: widget.date,
        isCurrentMonth: widget.isCurrentMonth,
        isToday: widget.isToday,
        isSelectable: widget.isSelectable,
        isFocused: widget.isFocused,
        events: widget.events,
        regions: allRegions,
        dateLabelBuilder: wrappedDateLabelBuilder,
      );
      cell = widget.dayCellBuilder!(context, contextObj, cell);
    }

    // NOTE: DragTarget is now in Layer 3, not here in Layer 1
    // This ensures drop targets are on top of events and always receive pointer events

    // Wrap in gesture detector for tap/long-press/double-tap (Day View pattern)
    final l10n = mcalL10n(context);
    final hasCellDoubleTap = isInteractive && widget.onCellDoubleTap != null;
    Widget result = MCalGestureDetector(
      onDoubleTapDown: hasCellDoubleTap
          ? (details) {
              _lastDoubleTapDownLocalPosition = details.localPosition;
              _lastDoubleTapDownGlobalPosition = details.globalPosition;
            }
          : null,
      onDoubleTap: hasCellDoubleTap ? _handleCellDoubleTap : null,
      onTap: isInteractive
          ? () {
              // Set focus if autoFocusOnCellTap is enabled
              if (widget.autoFocusOnCellTap) {
                widget.onSetFocusedDate?.call(widget.date);
              }
              // Fire the onCellTap callback if provided
              if (widget.onCellTap != null) {
                widget.onCellTap!(
                  context,
                  MCalCellTapDetails(
                    date: widget.date,
                    events: widget.events,
                    isCurrentMonth: widget.isCurrentMonth,
                  ),
                );
              }
            }
          : null,
      onLongPress: isInteractive && widget.onCellLongPress != null
          ? () => widget.onCellLongPress!(
              context,
              MCalCellTapDetails(
                date: widget.date,
                events: widget.events,
                isCurrentMonth: widget.isCurrentMonth,
              ),
            )
          : null,
      onSecondaryTap: isInteractive && widget.onCellSecondaryTap != null
          ? () => widget.onCellSecondaryTap!(
              context,
              MCalCellTapDetails(
                date: widget.date,
                events: widget.events,
                isCurrentMonth: widget.isCurrentMonth,
              ),
            )
          : null,
      child: Semantics(
        label: _getSemanticLabel(),
        selected: widget.isFocused,
        hint: isInteractive ? l10n.doubleTapToSelect : null,
        child: cell,
      ),
    );

    // Wrap in MouseRegion for hover support (only if callback provided)
    if (widget.onHoverCell != null) {
      result = MouseRegion(
        onEnter: (_) {
          final contextObj = MCalDayCellContext(
            date: widget.date,
            isCurrentMonth: widget.isCurrentMonth,
            isToday: widget.isToday,
            isSelectable: widget.isSelectable,
            isFocused: widget.isFocused,
            events: widget.events,
            regions: allRegions,
            dateLabelBuilder: wrappedDateLabelBuilder,
          );
          widget.onHoverCell!(context, contextObj);
        },
        onExit: (_) => widget.onHoverCell!(context, null),
        child: result,
      );
    }

    // Wrap in RepaintBoundary to isolate repaints so that changes to one
    // cell don't trigger repaints of other cells
    return RepaintBoundary(child: result);
  }

  /// Handles double-tap on day cell.
  ///
  /// Uses [_lastDoubleTapDownLocalPosition] and [_lastDoubleTapDownGlobalPosition]
  /// stored from [onDoubleTapDown] since [onDoubleTap] does not receive position.
  void _handleCellDoubleTap() {
    if (widget.onCellDoubleTap == null) return;

    final localPosition = _lastDoubleTapDownLocalPosition;
    final globalPosition = _lastDoubleTapDownGlobalPosition;
    if (localPosition == null || globalPosition == null) return;

    widget.onCellDoubleTap!(
      context,
      MCalCellDoubleTapDetails(
        date: widget.date,
        events: widget.events,
        isCurrentMonth: widget.isCurrentMonth,
        localPosition: localPosition,
        globalPosition: globalPosition,
      ),
    );
  }

  /// Gets the cell decoration based on date type and theme.
  ///
  /// [isInteractive] parameter indicates if the cell is interactive.
  /// Builds the overlay widget for a single [MCalRegion].
  ///
  /// Produces a default colored container (with optional text/icon) and then
  /// delegates to [widget.dayRegionBuilder] when provided so the consumer can
  /// override the appearance.
  Widget _buildRegionOverlay(BuildContext context, MCalRegion region) {
    final regionContext = MCalRegionContext(
      region: region,
      date: widget.date,
      isCurrentMonth: widget.isCurrentMonth,
      isToday: widget.isToday,
    );

    // Default rendering: semi-transparent color fill with optional text/icon.
    Widget defaultWidget = Container(
      color: region.color,
      child: (region.text != null || region.icon != null)
          ? Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 2.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (region.icon != null)
                      Icon(
                        region.icon,
                        size: 9.0,
                        color: (region.color ??
                            widget.theme.monthTheme?.defaultRegionColor ??
                            MCalThemeData.fromTheme(Theme.of(context))
                                .monthTheme!
                                .defaultRegionColor!),
                      ),
                    if (region.icon != null && region.text != null)
                      const SizedBox(width: 2),
                    if (region.text != null)
                      Flexible(
                        child: Text(
                          region.text!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 8.0,
                            color: (region.color ??
                                widget.theme.monthTheme?.defaultRegionColor ??
                                MCalThemeData.fromTheme(Theme.of(context))
                                    .monthTheme!
                                    .defaultRegionColor!),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            )
          : null,
    );

    if (widget.dayRegionBuilder != null) {
      defaultWidget = widget.dayRegionBuilder!(
        context,
        regionContext,
        defaultWidget,
      );
    }

    return Positioned.fill(child: defaultWidget);
  }

  /// Non-interactive cells may have reduced visual prominence.
  BoxDecoration _getCellDecoration(BuildContext context, [bool isInteractive = true]) {
    final defaults = MCalThemeData.fromTheme(Theme.of(context));
    Color? backgroundColor;
    final borderColor =
        widget.theme.cellBorderColor ?? defaults.cellBorderColor!;

    // Apply focused styling first (takes priority)
    if (widget.isFocused) {
      backgroundColor =
          widget.theme.monthTheme?.focusedDateBackgroundColor ??
          widget.theme.cellBackgroundColor;
    } else if (widget.isToday) {
      backgroundColor =
          widget.theme.monthTheme?.todayBackgroundColor ??
          widget.theme.cellBackgroundColor;
    } else if (widget.isCurrentMonth) {
      backgroundColor = widget.theme.cellBackgroundColor;
    } else {
      // Leading/trailing date
      backgroundColor = widget.isCurrentMonth
          ? widget.theme.cellBackgroundColor
          : (widget.theme.monthTheme?.leadingDatesBackgroundColor ??
                widget.theme.monthTheme?.trailingDatesBackgroundColor ??
                widget.theme.cellBackgroundColor);
    }

    // Apply reduced opacity for non-interactive cells
    if (!isInteractive && backgroundColor != null) {
      backgroundColor = backgroundColor.withValues(alpha: 0.6);
    }

    return BoxDecoration(
      color: backgroundColor,
      border: Border.all(color: borderColor, width: 1.0),
    );
  }

  /// Builds the date label widget.
  ///
  /// Supports dateLabelBuilder callback, dateFormat parameter, or
  /// default formatting via MCalLocalizations.
  Widget _buildDateLabel(BuildContext context) {
    // Determine default formatted string
    String defaultFormattedString;
    if (widget.dateFormat != null) {
      // Use custom date format if provided
      try {
        defaultFormattedString = widget.dateFormat!.format(widget.date);
      } catch (e) {
        // Fallback to day number if format is invalid
        defaultFormattedString = '${widget.date.day}';
      }
    } else {
      // Use default day number
      defaultFormattedString = '${widget.date.day}';
    }

    // Use dateLabelBuilder if provided
    if (widget.dateLabelBuilder != null) {
      final contextObj = MCalDateLabelContext(
        date: widget.date,
        isCurrentMonth: widget.isCurrentMonth,
        isToday: widget.isToday,
        defaultFormattedString: defaultFormattedString,
        locale: widget.locale,
      );
      return widget.dateLabelBuilder!(
        context,
        contextObj,
        defaultFormattedString,
      );
    }

    // Otherwise use default rendering with appropriate styling
    TextStyle? textStyle;
    if (widget.isFocused) {
      // Focused date takes priority for text styling
      textStyle =
          widget.theme.monthTheme?.focusedDateTextStyle ??
          widget.theme.monthTheme?.cellTextStyle;
    } else if (widget.isToday) {
      textStyle =
          widget.theme.monthTheme?.todayTextStyle ??
          widget.theme.monthTheme?.cellTextStyle;
    } else if (widget.isCurrentMonth) {
      textStyle = widget.theme.monthTheme?.cellTextStyle;
    } else {
      // Leading/trailing date
      textStyle =
          widget.theme.monthTheme?.leadingDatesTextStyle ??
          widget.theme.monthTheme?.trailingDatesTextStyle ??
          widget.theme.monthTheme?.cellTextStyle;
    }

    return Text(
      defaultFormattedString,
      style: textStyle?.copyWith(
        fontWeight: (widget.isToday || widget.isFocused)
            ? FontWeight.bold
            : null,
      ),
      textAlign: TextAlign.left,
    );
  }

  /// Builds the default date label widget for use in builder wrapper.
  ///
  /// This method matches the signature required by [MCalBuilderWrapper.wrapDateLabelBuilder]
  /// and provides the default rendering for date labels.
  Widget _buildDefaultDateLabelWidget(
    BuildContext context,
    MCalDateLabelContext labelContext,
  ) {
    // Use the same styling logic as _buildDateLabel but with context-based values
    TextStyle? textStyle;
    if (labelContext.isToday) {
      textStyle =
          widget.theme.monthTheme?.todayTextStyle ??
          widget.theme.monthTheme?.cellTextStyle;
    } else if (labelContext.isCurrentMonth) {
      textStyle = widget.theme.monthTheme?.cellTextStyle;
    } else {
      textStyle =
          widget.theme.monthTheme?.leadingDatesTextStyle ??
          widget.theme.monthTheme?.trailingDatesTextStyle ??
          widget.theme.monthTheme?.cellTextStyle;
    }

    final dateText = Text(
      labelContext.defaultFormattedString,
      style: textStyle?.copyWith(
        fontWeight: labelContext.isToday ? FontWeight.bold : null,
      ),
      textAlign: TextAlign.center,
    );

    // Get alignment from the DateLabelPosition
    final alignment = labelContext.horizontalAlignment;

    // Use theme dateLabelHeight to prevent overflow when cells are constrained
    final labelHeight = widget.theme.monthTheme?.dateLabelHeight ?? 18.0;

    // Use a fixed-size container for uniform spacing
    final circleContainer = Container(
      width: labelHeight,
      height: labelHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: labelContext.isToday
            ? (widget.theme.monthTheme?.todayBackgroundColor ??
                  MCalThemeData.fromTheme(Theme.of(context))
                      .monthTheme!
                      .todayBackgroundColor!)
            : Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: FittedBox(fit: BoxFit.scaleDown, child: dateText),
    );

    return SizedBox(
      height: labelHeight,
      child: Align(alignment: alignment, child: circleContainer),
    );
  }

  /// Gets the semantic label for accessibility.
  ///
  /// Builds a comprehensive label for screen readers including:
  /// - Full date with day name (e.g., "Saturday, January 15, 2026")
  /// - "today" if the cell represents today's date
  /// - "focused" if the cell is currently focused
  /// - "previous month" or "next month" if outside the display month
  /// - Event count (e.g., "3 events")
  String _getSemanticLabel() {
    final l10n = mcalL10n(context);
    final localizations = MCalDateFormatUtils();

    // Full date with day name for better screen reader experience
    final dateStr = localizations.formatFullDateWithDayName(
      widget.date,
      widget.locale,
    );

    final parts = <String>[dateStr];

    // Add "today" indicator
    if (widget.isToday) {
      parts.add(l10n.today);
    }

    // Add focused/selected indicator
    if (widget.isFocused) {
      parts.add(l10n.focused);
    }

    // Add month context for dates outside current month
    if (!widget.isCurrentMonth) {
      // Determine if date is in previous or next month relative to display month
      final dateMonth = DateTime(widget.date.year, widget.date.month, 1);
      final currentDisplayMonth = DateTime(
        widget.displayMonth.year,
        widget.displayMonth.month,
        1,
      );

      if (dateMonth.isBefore(currentDisplayMonth)) {
        parts.add(l10n.previousMonth);
      } else {
        parts.add(l10n.nextMonth);
      }
    }

    // Add event count
    if (widget.events.isNotEmpty) {
      final eventWord = widget.events.length == 1 ? l10n.event : l10n.events;
      parts.add('${widget.events.length} $eventWord');
    }

    return parts.join(', ');
  }
}
