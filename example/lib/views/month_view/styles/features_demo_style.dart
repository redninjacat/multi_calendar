import 'package:flutter/material.dart';
import 'package:multi_calendar/multi_calendar.dart';

import '../../../utils/sample_events.dart';
import '../../../widgets/day_events_bottom_sheet.dart';
import '../../../widgets/event_detail_dialog.dart';
import '../../../widgets/style_description.dart';

/// Features Demo - showcases new MCalMonthView features.
///
/// This demonstrates:
/// - Keyboard navigation
/// - Hover feedback
/// - Week numbers toggle
/// - maxVisibleEvents slider
/// - Animation toggle
/// - Multi-view synchronization
/// - Loading/error states
/// - PageView swipe navigation (peek preview)
/// - Multi-day events with contiguous rendering toggle
/// - Drag-and-drop with cross-month navigation
/// - Custom multi-day event tile builder
class FeaturesDemoStyle extends StatefulWidget {
  const FeaturesDemoStyle({
    super.key,
    required this.locale,
    required this.isDarkMode,
    required this.description,
  });

  final Locale locale;
  final bool isDarkMode;
  final String description;

  @override
  State<FeaturesDemoStyle> createState() => _FeaturesDemoStyleState();
}

class _FeaturesDemoStyleState extends State<FeaturesDemoStyle> {
  // Shared controller for multi-view sync demo
  late MCalEventController _sharedController;

  // Feature toggles
  bool _showWeekNumbers = false;
  bool _enableAnimations = true;
  int _maxVisibleEvents = 3;
  
  // New feature toggles (Part 2)
  bool _renderMultiDayEventsAsContiguous = true;
  bool _enableDragAndDrop = false;
  int _dragEdgeNavigationDelayMs = 500;
  bool _useCustomMultiDayTileBuilder = false;

  // Hover state
  String _hoverStatus = 'Hover over cells or events to see details';

  @override
  void initState() {
    super.initState();
    _sharedController = MCalEventController();
    _sharedController.addEvents(createSampleEvents());
  }

  @override
  void dispose() {
    _sharedController.dispose();
    super.dispose();
  }

  void _onHoverCell(MCalDayCellContext? ctx) {
    setState(() {
      if (ctx == null) {
        _hoverStatus = 'Hover over cells or events to see details';
      } else {
        final dateStr =
            '${ctx.date.year}-${ctx.date.month.toString().padLeft(2, '0')}-${ctx.date.day.toString().padLeft(2, '0')}';
        _hoverStatus =
            'Cell: $dateStr | Events: ${ctx.events.length} | Today: ${ctx.isToday} | Focused: ${ctx.isFocused}';
      }
    });
  }

  void _onHoverEvent(MCalEventTileContext? ctx) {
    setState(() {
      if (ctx == null) {
        _hoverStatus = 'Hover over cells or events to see details';
      } else {
        _hoverStatus =
            'Event: "${ctx.event.title}" | All-day: ${ctx.isAllDay} | Date: ${ctx.displayDate.day}/${ctx.displayDate.month}';
      }
    });
  }

  // Control panel expansion state for mobile
  bool _showControls = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Use responsive layout based on screen width
        final isWideScreen = constraints.maxWidth > 600;
        final isDesktop = constraints.maxWidth > 900;
        final isMobile = !isWideScreen;

        if (isMobile) {
          // Mobile: Simple calendar with minimal UI and expandable settings
          return _buildMobileLayout(colorScheme);
        }

        // Tablet/Desktop: Full feature layout
        return Column(
          children: [
            StyleDescription(description: widget.description),
            // Keyboard shortcuts info - only show on desktop
            if (isDesktop) _buildKeyboardShortcutsBar(colorScheme),
            // Control panel
            _buildControlPanel(colorScheme),
            // Hover status bar - only show on desktop (hover doesn't work on mobile)
            if (isDesktop) _buildHoverStatusBar(colorScheme),
            // Main calendar and secondary view
            Expanded(
              child: Row(
                children: [
                  // Primary calendar
                  Expanded(
                    flex: 2,
                    child: _buildPrimaryCalendar(colorScheme, isDesktop),
                  ),
                  // Secondary calendar (synced)
                  Expanded(
                    flex: 1,
                    child: _buildSecondaryCalendar(colorScheme),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// Mobile-optimized layout with collapsible settings
  Widget _buildMobileLayout(ColorScheme colorScheme) {
    // Get screen height for percentage-based calendar sizing
    final screenHeight = MediaQuery.of(context).size.height;
    // Calendar takes 60% of screen height
    final calendarHeight = screenHeight * 0.6;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Compact header with settings toggle
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withAlpha(80),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Features Demo',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                // Settings toggle
                IconButton(
                  icon: Icon(
                    _showControls ? Icons.expand_less : Icons.tune,
                    color: colorScheme.primary,
                  ),
                  onPressed: () => setState(() => _showControls = !_showControls),
                  tooltip: 'Toggle settings',
                ),
              ],
            ),
          ),
          // Collapsible controls
          if (_showControls) _buildMobileControlPanel(colorScheme),
          // Calendar with fixed height (60% of screen)
          SizedBox(
            height: calendarHeight,
            child: MCalMonthView(
              controller: _sharedController,
              showNavigator: true,
              enableSwipeNavigation: true,
              locale: widget.locale,
              showWeekNumbers: _showWeekNumbers,
              enableAnimations: _enableAnimations,
              maxVisibleEvents: _maxVisibleEvents,
              enableKeyboardNavigation: false, // Not useful on mobile
              // New features
              renderMultiDayEventsAsContiguous: _renderMultiDayEventsAsContiguous,
              enableDragAndDrop: _enableDragAndDrop,
              dragEdgeNavigationDelay: Duration(milliseconds: _dragEdgeNavigationDelayMs),
              multiDayEventTileBuilder: _useCustomMultiDayTileBuilder
                  ? _buildCustomMultiDayTile
                  : null,
              // Drag-and-drop callbacks
              onEventDropped: _enableDragAndDrop
                  ? (context, details) {
                      // Show snackbar with drop info
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Moved "${details.event.title}" from ${_formatDate(details.oldStartDate)} to ${_formatDate(details.newStartDate)}',
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                      return true; // Accept the drop
                    }
                  : null,
              // Tap event tile → show event detail dialog
              onEventTap: (context, details) {
                showEventDetailDialog(context, details.event, widget.locale);
              },
              // Tap +N overflow → show bottom sheet with all events
              onOverflowTap: (context, details) {
                showDayEventsBottomSheet(context, details.date, details.allEvents, widget.locale);
              },
              // Cell tap just focuses (no bottom sheet for tile-based view)
            ),
          ),
          // Add some padding at the bottom for comfortable scrolling
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// Compact control panel for mobile
  Widget _buildMobileControlPanel(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Row 1: Toggles
          Row(
            children: [
              Expanded(
                child: _buildCompactToggle(
                  'Week #',
                  _showWeekNumbers,
                  (v) => setState(() => _showWeekNumbers = v),
                  colorScheme,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildCompactToggle(
                  'Animate',
                  _enableAnimations,
                  (v) => setState(() => _enableAnimations = v),
                  colorScheme,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Row 2: New feature toggles
          Row(
            children: [
              Expanded(
                child: _buildCompactToggle(
                  'Multi-Day',
                  _renderMultiDayEventsAsContiguous,
                  (v) => setState(() => _renderMultiDayEventsAsContiguous = v),
                  colorScheme,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildCompactToggle(
                  'Drag',
                  _enableDragAndDrop,
                  (v) => setState(() => _enableDragAndDrop = v),
                  colorScheme,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Row 3: Max events slider
          Row(
            children: [
              Text(
                'Events: $_maxVisibleEvents',
                style: TextStyle(fontSize: 13, color: colorScheme.onSurface),
              ),
              Expanded(
                child: Slider(
                  value: _maxVisibleEvents.toDouble(),
                  min: 1,
                  max: 5,
                  divisions: 4,
                  onChanged: (v) => setState(() => _maxVisibleEvents = v.round()),
                ),
              ),
            ],
          ),
          // Row 4: Drag edge delay slider (only when drag is enabled)
          if (_enableDragAndDrop)
            Row(
              children: [
                Text(
                  'Edge: ${_dragEdgeNavigationDelayMs}ms',
                  style: TextStyle(fontSize: 13, color: colorScheme.onSurface),
                ),
                Expanded(
                  child: Slider(
                    value: _dragEdgeNavigationDelayMs.toDouble(),
                    min: 200,
                    max: 1000,
                    divisions: 8,
                    onChanged: (v) => setState(() => _dragEdgeNavigationDelayMs = v.round()),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildCompactToggle(
    String label,
    bool value,
    ValueChanged<bool> onChanged,
    ColorScheme colorScheme,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: colorScheme.onSurface)),
        const SizedBox(width: 4),
        Switch(
          value: value,
          onChanged: onChanged,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ],
    );
  }

  Widget _buildKeyboardShortcutsBar(ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: colorScheme.primaryContainer.withAlpha(100),
      child: Wrap(
        spacing: 16,
        runSpacing: 4,
        alignment: WrapAlignment.center,
        children: [
          _shortcutChip('←→↑↓', 'Navigate cells', colorScheme),
          _shortcutChip('Enter/Space', 'Select cell', colorScheme),
          _shortcutChip('Home', 'First day', colorScheme),
          _shortcutChip('End', 'Last day', colorScheme),
          _shortcutChip('PgUp/PgDn', 'Prev/Next month', colorScheme),
        ],
      ),
    );
  }

  Widget _shortcutChip(String key, String action, ColorScheme colorScheme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: colorScheme.outline.withAlpha(100)),
          ),
          child: Text(
            key,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              fontFamily: 'monospace',
              color: colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          action,
          style: TextStyle(
            fontSize: 11,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildControlPanel(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withAlpha(100),
        border: Border(
          bottom: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      child: Wrap(
        spacing: 24,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // Week numbers toggle
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Week Numbers',
                  style: TextStyle(fontSize: 13, color: colorScheme.onSurface)),
              const SizedBox(width: 8),
              Switch(
                value: _showWeekNumbers,
                onChanged: (value) => setState(() => _showWeekNumbers = value),
              ),
            ],
          ),
          // Animations toggle
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Animations',
                  style: TextStyle(fontSize: 13, color: colorScheme.onSurface)),
              const SizedBox(width: 8),
              Switch(
                value: _enableAnimations,
                onChanged: (value) => setState(() => _enableAnimations = value),
              ),
            ],
          ),
          // Max visible events slider
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Max Events: $_maxVisibleEvents',
                  style: TextStyle(fontSize: 13, color: colorScheme.onSurface)),
              SizedBox(
                width: 150,
                child: Slider(
                  value: _maxVisibleEvents.toDouble(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  label: _maxVisibleEvents.toString(),
                  onChanged: (value) =>
                      setState(() => _maxVisibleEvents = value.round()),
                ),
              ),
            ],
          ),
          // Multi-day events toggle
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Contiguous Multi-Day',
                  style: TextStyle(fontSize: 13, color: colorScheme.onSurface)),
              const SizedBox(width: 8),
              Switch(
                value: _renderMultiDayEventsAsContiguous,
                onChanged: (value) => setState(() => _renderMultiDayEventsAsContiguous = value),
              ),
            ],
          ),
          // Custom multi-day tile builder toggle
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Custom Tile',
                  style: TextStyle(fontSize: 13, color: colorScheme.onSurface)),
              const SizedBox(width: 8),
              Switch(
                value: _useCustomMultiDayTileBuilder,
                onChanged: (value) => setState(() => _useCustomMultiDayTileBuilder = value),
              ),
            ],
          ),
          // Drag-and-drop toggle
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Drag & Drop',
                  style: TextStyle(fontSize: 13, color: colorScheme.onSurface)),
              const SizedBox(width: 8),
              Switch(
                value: _enableDragAndDrop,
                onChanged: (value) => setState(() => _enableDragAndDrop = value),
              ),
            ],
          ),
          // Drag edge navigation delay slider
          if (_enableDragAndDrop)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Edge Delay: ${_dragEdgeNavigationDelayMs}ms',
                    style: TextStyle(fontSize: 13, color: colorScheme.onSurface)),
                SizedBox(
                  width: 150,
                  child: Slider(
                    value: _dragEdgeNavigationDelayMs.toDouble(),
                    min: 200,
                    max: 1000,
                    divisions: 8,
                    label: '${_dragEdgeNavigationDelayMs}ms',
                    onChanged: (value) =>
                        setState(() => _dragEdgeNavigationDelayMs = value.round()),
                  ),
                ),
              ],
            ),
          // Loading/Error demo buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FilledButton.tonal(
                onPressed: () {
                  _sharedController.setLoading(true);
                  // Auto-clear after 2 seconds
                  Future.delayed(const Duration(seconds: 2), () {
                    if (mounted) {
                      _sharedController.setLoading(false);
                    }
                  });
                },
                child: const Text('Show Loading'),
              ),
              const SizedBox(width: 8),
              FilledButton.tonal(
                onPressed: () {
                  _sharedController.setError('Demo error: Something went wrong!');
                },
                child: const Text('Show Error'),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () {
                  _sharedController.clearError();
                  _sharedController.setLoading(false);
                },
                child: const Text('Clear'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHoverStatusBar(ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: colorScheme.surfaceContainerLow,
      child: Row(
        children: [
          Icon(Icons.mouse, size: 16, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _hoverStatus,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
                fontFamily: 'monospace',
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryCalendar(ColorScheme colorScheme, bool isDesktop) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withAlpha(100),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_month, color: colorScheme.primary),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    isDesktop
                        ? 'Primary View (Click to focus, then use keyboard)'
                        : 'Calendar',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: MCalMonthView(
              controller: _sharedController,
              showNavigator: true,
              enableSwipeNavigation: true,
              locale: widget.locale,
              showWeekNumbers: _showWeekNumbers,
              enableAnimations: _enableAnimations,
              maxVisibleEvents: _maxVisibleEvents,
              enableKeyboardNavigation: isDesktop,
              onHoverCell: isDesktop ? _onHoverCell : null,
              onHoverEvent: isDesktop ? _onHoverEvent : null,
              // New features
              renderMultiDayEventsAsContiguous: _renderMultiDayEventsAsContiguous,
              enableDragAndDrop: _enableDragAndDrop,
              dragEdgeNavigationDelay: Duration(milliseconds: _dragEdgeNavigationDelayMs),
              multiDayEventTileBuilder: _useCustomMultiDayTileBuilder
                  ? _buildCustomMultiDayTile
                  : null,
              // Drag-and-drop callbacks
              onEventDropped: _enableDragAndDrop
                  ? (context, details) {
                      // Show snackbar with drop info
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Moved "${details.event.title}" from ${_formatDate(details.oldStartDate)} to ${_formatDate(details.newStartDate)}',
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                      return true; // Accept the drop
                    }
                  : null,
              // Tap event tile → show event detail dialog
              onEventTap: (context, details) {
                showEventDetailDialog(context, details.event, widget.locale);
              },
              // Tap +N overflow → show bottom sheet with all events
              onOverflowTap: (context, details) {
                showDayEventsBottomSheet(context, details.date, details.allEvents, widget.locale);
              },
              // Cell tap just focuses and updates status (no bottom sheet)
              onCellTap: (context, details) {
                if (isDesktop) {
                  setState(() {
                    _hoverStatus =
                        'Selected: ${details.date.day}/${details.date.month}/${details.date.year} with ${details.events.length} events';
                  });
                }
              },
              onFocusedDateChanged: isDesktop
                  ? (date) {
                      if (date != null) {
                        setState(() {
                          _hoverStatus =
                              'Focused: ${date.day}/${date.month}/${date.year}';
                        });
                      }
                    }
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryCalendar(ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer.withAlpha(100),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Row(
              children: [
                Icon(Icons.sync, color: colorScheme.secondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Synced View',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: MCalMonthView(
              controller: _sharedController,
              showNavigator: false, // Controlled by primary
              locale: widget.locale,
              showWeekNumbers: _showWeekNumbers,
              enableAnimations: _enableAnimations,
              maxVisibleEvents: 2, // Smaller view, fewer events
              enableKeyboardNavigation: false, // Only primary has keyboard nav
              // New features - synced with primary
              renderMultiDayEventsAsContiguous: _renderMultiDayEventsAsContiguous,
              enableDragAndDrop: false, // Only enable on primary
              theme: MCalThemeData(
                cellBackgroundColor: colorScheme.surfaceContainerLow,
                cellTextStyle: const TextStyle(fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Custom multi-day event tile builder for demonstration.
  /// 
  /// Shows a gradient background with an icon and custom styling.
  Widget _buildCustomMultiDayTile(BuildContext context, MCalMultiDayTileDetails details) {
    final colorScheme = Theme.of(context).colorScheme;
    final event = details.event;
    final eventColor = event.color ?? colorScheme.primary;
    
    // Calculate border radius based on row position (not event position)
    // This creates the visual continuation effect across week boundaries
    const radius = Radius.circular(6);
    BorderRadius borderRadius;
    if (details.isFirstDayInRow && details.isLastDayInRow) {
      borderRadius = const BorderRadius.all(radius);
    } else if (details.isFirstDayInRow) {
      borderRadius = const BorderRadius.only(topLeft: radius, bottomLeft: radius);
    } else if (details.isLastDayInRow) {
      borderRadius = const BorderRadius.only(topRight: radius, bottomRight: radius);
    } else {
      borderRadius = BorderRadius.zero;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 1),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            eventColor.withAlpha(230), // 0.9 * 255 ≈ 230
            eventColor.withAlpha(179), // 0.7 * 255 ≈ 179
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: eventColor.withAlpha(77), // 0.3 * 255 ≈ 77
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Row(
          children: [
            // Show icon only on the first day of each row segment
            if (details.isFirstDayInRow) ...[
              Icon(
                event.isAllDay ? Icons.calendar_today : Icons.schedule,
                size: 12,
                color: Colors.white,
              ),
              const SizedBox(width: 4),
            ],
            Expanded(
              child: Text(
                // Show title on first day of each row
                details.isFirstDayInRow ? event.title : '',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            // Show total days badge on the last day of the event
            if (details.isLastDayOfEvent && details.totalDaysInEvent > 1) ...[
              Text(
                '${details.totalDaysInEvent}d',
                style: TextStyle(
                  color: Colors.white.withAlpha(204), // 0.8 * 255 ≈ 204
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Format date for display in snackbar
  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}
