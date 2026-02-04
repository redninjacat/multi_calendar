import 'package:flutter/material.dart';
import 'package:multi_calendar/multi_calendar.dart';

import '../../../utils/sample_events.dart';
import '../../../widgets/style_description.dart';

/// Features Demo - showcases MCalMonthView features and configuration options.
///
/// This demonstrates:
/// - All theme-configurable properties via sliders and dropdowns
/// - Complete tap, long press, and hover handlers for all elements
/// - Multi-view synchronization
/// - Keyboard navigation
/// - Drag-and-drop
/// - Loading/error states
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

  // ============================================================
  // Feature Toggles
  // ============================================================
  bool _showWeekNumbers = false;
  bool _enableAnimations = true;
  bool _enableDragAndDrop = false;
  int _dragEdgeNavigationDelayMs = 500;

  // ============================================================
  // Theme Settings (matching Layout POC levers)
  // ============================================================

  // Date label settings
  DateLabelPosition _dateLabelPosition = DateLabelPosition.topLeft;
  double _dateLabelHeight = 18.0;

  // Event tile settings
  int _maxVisibleEventsPerDay = 5;
  double _tileHeight = 18.0;
  double _tileVerticalSpacing = 2.0;
  double _tileHorizontalSpacing = 2.0;
  double _tileCornerRadius = 4.0;
  double _tileBorderWidth = 0.0;

  // Overflow indicator settings
  double _overflowIndicatorHeight = 14.0;

  // Control panel expansion state for mobile
  bool _showControls = false;

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

  // ============================================================
  // Alert Helpers
  // ============================================================

  void _showAlert(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Handler Callbacks
  // ============================================================

  void _onCellTap(BuildContext context, MCalCellTapDetails details) {
    final dateStr = _formatDate(details.date);
    final isToday = _isSameDay(details.date, DateTime.now());
    _showAlert(
      context,
      'Cell Tapped',
      'You tapped the cell for $dateStr\n'
          'Events: ${details.events.length}\n'
          'Is today: $isToday\n'
          'Is current month: ${details.isCurrentMonth}',
    );
  }

  void _onCellLongPress(BuildContext context, MCalCellTapDetails details) {
    final dateStr = _formatDate(details.date);
    _showAlert(
      context,
      'Cell Long-Pressed',
      'You long-pressed the cell for $dateStr\n'
          'Events: ${details.events.length}',
    );
  }

  void _onDateLabelTap(BuildContext context, MCalDateLabelTapDetails details) {
    final dateStr = _formatDate(details.date);
    _showAlert(
      context,
      'Date Label Tapped',
      'You tapped the date label for $dateStr\n'
          'Is today: ${details.isToday}\n'
          'Is current month: ${details.isCurrentMonth}',
    );
  }

  void _onDateLabelLongPress(
    BuildContext context,
    MCalDateLabelTapDetails details,
  ) {
    final dateStr = _formatDate(details.date);
    _showAlert(
      context,
      'Date Label Long-Pressed',
      'You long-pressed the date label for $dateStr',
    );
  }

  void _onEventTap(BuildContext context, MCalEventTapDetails details) {
    _showAlert(
      context,
      'Event Tapped',
      'You tapped the event "${details.event.title}"\n'
          'Date: ${_formatDate(details.displayDate)}\n'
          'All-day: ${details.event.isAllDay}\n'
          'Color: ${details.event.color}',
    );
  }

  void _onEventLongPress(BuildContext context, MCalEventTapDetails details) {
    _showAlert(
      context,
      'Event Long-Pressed',
      'You long-pressed the event "${details.event.title}"\n'
          'Start: ${_formatDate(details.event.start)}\n'
          'End: ${_formatDate(details.event.end)}',
    );
  }

  void _onOverflowTap(BuildContext context, MCalOverflowTapDetails details) {
    final visibleTitles = details.visibleEvents.map((e) => e.title).join(', ');
    final hiddenTitles = details.hiddenEvents.map((e) => e.title).join(', ');
    _showAlert(
      context,
      'Overflow Indicator Tapped',
      'Date: ${_formatDate(details.date)}\n'
          'Hidden events (${details.hiddenEvents.length}): $hiddenTitles\n'
          'Visible events (${details.visibleEvents.length}): $visibleTitles\n'
          'Total: ${details.allEvents.length}',
    );
  }

  // ============================================================
  // Hover Callbacks (with Tooltip in status bar)
  // ============================================================
  String _hoverStatus = 'Hover over cells, date labels, or events';

  void _onHoverCell(MCalDayCellContext? ctx) {
    setState(() {
      if (ctx == null) {
        _hoverStatus = 'Hover over cells, date labels, or events';
      } else {
        final dateStr = _formatDate(ctx.date);
        _hoverStatus =
            'CELL: $dateStr | Events: ${ctx.events.length} | '
            'Today: ${ctx.isToday} | Focused: ${ctx.isFocused} | '
            'Current month: ${ctx.isCurrentMonth}';
      }
    });
  }

  void _onHoverEvent(MCalEventTileContext? ctx) {
    setState(() {
      if (ctx == null) {
        _hoverStatus = 'Hover over cells, date labels, or events';
      } else {
        _hoverStatus =
            'EVENT: "${ctx.event.title}" | '
            'Date: ${_formatDate(ctx.displayDate)} | '
            'All-day: ${ctx.isAllDay} | '
            'Start: ${_formatDate(ctx.event.start)} | '
            'End: ${_formatDate(ctx.event.end)}';
      }
    });
  }

  // ============================================================
  // Build Theme from Settings
  // ============================================================

  MCalThemeData _buildTheme(ColorScheme colorScheme) {
    return MCalThemeData(
      // Date label styling
      dateLabelPosition: _dateLabelPosition,
      dateLabelHeight: _dateLabelHeight,

      // Event tile styling
      eventTileHeight: _tileHeight,
      eventTileVerticalSpacing: _tileVerticalSpacing,
      eventTileHorizontalSpacing: _tileHorizontalSpacing,
      tileCornerRadius: _tileCornerRadius,
      eventTileBorderWidth: _tileBorderWidth,
      eventTileBorderColor: _tileBorderWidth > 0 ? colorScheme.outline : null,

      // Overflow indicator
      overflowIndicatorHeight: _overflowIndicatorHeight,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth > 600;
        final isDesktop = constraints.maxWidth > 900;
        final isMobile = !isWideScreen;

        if (isMobile) {
          return _buildMobileLayout(colorScheme);
        }

        // Tablet/Desktop: Full feature layout
        return Column(
          children: [
            StyleDescription(description: widget.description),
            if (isDesktop) _buildKeyboardShortcutsBar(colorScheme),
            _buildControlPanel(colorScheme),
            if (isDesktop) _buildHoverStatusBar(colorScheme),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildPrimaryCalendar(colorScheme, isDesktop),
                  ),
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

  // ============================================================
  // Mobile Layout
  // ============================================================

  Widget _buildMobileLayout(ColorScheme colorScheme) {
    final screenHeight = MediaQuery.of(context).size.height;
    final calendarHeight = screenHeight * 0.55;

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
                IconButton(
                  icon: Icon(
                    _showControls ? Icons.expand_less : Icons.tune,
                    color: colorScheme.primary,
                  ),
                  onPressed: () =>
                      setState(() => _showControls = !_showControls),
                  tooltip: 'Toggle settings',
                ),
              ],
            ),
          ),
          if (_showControls) _buildMobileControlPanel(colorScheme),
          // Calendar with fixed height
          SizedBox(
            height: calendarHeight,
            child: MCalTheme(
              data: _buildTheme(colorScheme),
              child: MCalMonthView(
                controller: _sharedController,
                showNavigator: true,
                enableSwipeNavigation: true,
                locale: widget.locale,
                showWeekNumbers: _showWeekNumbers,
                enableAnimations: _enableAnimations,
                maxVisibleEventsPerDay: _maxVisibleEventsPerDay,
                enableKeyboardNavigation: false,
                enableDragAndDrop: _enableDragAndDrop,
                dragEdgeNavigationDelay: Duration(
                  milliseconds: _dragEdgeNavigationDelayMs,
                ),
                // Tap/LongPress handlers
                onCellTap: _onCellTap,
                onCellLongPress: _onCellLongPress,
                onDateLabelTap: _onDateLabelTap,
                onDateLabelLongPress: _onDateLabelLongPress,
                onEventTap: _onEventTap,
                onEventLongPress: _onEventLongPress,
                onOverflowTap: _onOverflowTap,
                // Drag-and-drop callback
                onEventDropped: _enableDragAndDrop
                    ? (context, details) {
                        _showAlert(
                          context,
                          'Event Dropped',
                          'Moved "${details.event.title}" from '
                              '${_formatDate(details.oldStartDate)} to '
                              '${_formatDate(details.newStartDate)}',
                        );
                        return true;
                      }
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ============================================================
  // Mobile Control Panel
  // ============================================================

  Widget _buildMobileControlPanel(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
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
              Expanded(
                child: _buildCompactToggle(
                  'Animate',
                  _enableAnimations,
                  (v) => setState(() => _enableAnimations = v),
                  colorScheme,
                ),
              ),
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
          // Date label position
          _buildDropdownRow(
            'Label:',
            _dateLabelPosition,
            DateLabelPosition.values,
            (v) => setState(() => _dateLabelPosition = v),
            colorScheme,
          ),
          const SizedBox(height: 8),
          // Sliders
          _buildSliderRow(
            'Events',
            _maxVisibleEventsPerDay.toDouble(),
            1,
            10,
            9,
            (v) => setState(() => _maxVisibleEventsPerDay = v.round()),
            colorScheme,
            suffix: '',
          ),
          _buildSliderRow(
            'Tile H',
            _tileHeight,
            10,
            30,
            20,
            (v) => setState(() => _tileHeight = v),
            colorScheme,
          ),
          _buildSliderRow(
            'Corner',
            _tileCornerRadius,
            0,
            10,
            10,
            (v) => setState(() => _tileCornerRadius = v),
            colorScheme,
          ),
          _buildSliderRow(
            'Border',
            _tileBorderWidth,
            0,
            3,
            6,
            (v) => setState(() => _tileBorderWidth = v),
            colorScheme,
          ),
          _buildSliderRow(
            'V-Space',
            _tileVerticalSpacing,
            0,
            6,
            6,
            (v) => setState(() => _tileVerticalSpacing = v),
            colorScheme,
          ),
          _buildSliderRow(
            'H-Space',
            _tileHorizontalSpacing,
            0,
            6,
            6,
            (v) => setState(() => _tileHorizontalSpacing = v),
            colorScheme,
          ),
          _buildSliderRow(
            'Label H',
            _dateLabelHeight,
            12,
            28,
            16,
            (v) => setState(() => _dateLabelHeight = v),
            colorScheme,
          ),
          _buildSliderRow(
            'Overflow',
            _overflowIndicatorHeight,
            10,
            20,
            10,
            (v) => setState(() => _overflowIndicatorHeight = v),
            colorScheme,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Desktop Control Panel
  // ============================================================

  Widget _buildControlPanel(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withAlpha(100),
        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Column(
        children: [
          // Row 1: Feature toggles
          Wrap(
            spacing: 24,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _buildToggle('Week Numbers', _showWeekNumbers, (v) {
                setState(() => _showWeekNumbers = v);
              }, colorScheme),
              _buildToggle('Animations', _enableAnimations, (v) {
                setState(() => _enableAnimations = v);
              }, colorScheme),
              _buildToggle('Drag & Drop', _enableDragAndDrop, (v) {
                setState(() => _enableDragAndDrop = v);
              }, colorScheme),
              // Loading/Error demo buttons
              FilledButton.tonal(
                onPressed: () {
                  _sharedController.setLoading(true);
                  Future.delayed(const Duration(seconds: 2), () {
                    if (mounted) _sharedController.setLoading(false);
                  });
                },
                child: const Text('Show Loading'),
              ),
              FilledButton.tonal(
                onPressed: () {
                  _sharedController.setError(
                    'Demo error: Something went wrong!',
                  );
                },
                child: const Text('Show Error'),
              ),
              OutlinedButton(
                onPressed: () {
                  _sharedController.clearError();
                  _sharedController.setLoading(false);
                },
                child: const Text('Clear'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Row 2: Theme settings
          Wrap(
            spacing: 16,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Date label position
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Label:',
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 8),
                  DropdownButton<DateLabelPosition>(
                    value: _dateLabelPosition,
                    isDense: true,
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurface,
                    ),
                    items: DateLabelPosition.values.map((pos) {
                      return DropdownMenuItem(
                        value: pos,
                        child: Text(pos.name),
                      );
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _dateLabelPosition = v);
                    },
                  ),
                ],
              ),
              // Max events slider
              _buildCompactSlider(
                'Max Events',
                _maxVisibleEventsPerDay.toDouble(),
                1,
                10,
                9,
                (v) => setState(() => _maxVisibleEventsPerDay = v.round()),
                colorScheme,
                showValue: _maxVisibleEventsPerDay.toString(),
              ),
              // Tile height slider
              _buildCompactSlider(
                'Tile Height',
                _tileHeight,
                10,
                30,
                20,
                (v) => setState(() => _tileHeight = v),
                colorScheme,
                showValue: '${_tileHeight.toInt()}px',
              ),
              // Corner radius slider
              _buildCompactSlider(
                'Corner',
                _tileCornerRadius,
                0,
                10,
                10,
                (v) => setState(() => _tileCornerRadius = v),
                colorScheme,
                showValue: '${_tileCornerRadius.toInt()}px',
              ),
              // Border width slider
              _buildCompactSlider(
                'Border',
                _tileBorderWidth,
                0,
                3,
                6,
                (v) => setState(() => _tileBorderWidth = v),
                colorScheme,
                showValue: '${_tileBorderWidth.toStringAsFixed(1)}px',
              ),
              // Vertical spacing slider
              _buildCompactSlider(
                'V-Space',
                _tileVerticalSpacing,
                0,
                6,
                6,
                (v) => setState(() => _tileVerticalSpacing = v),
                colorScheme,
                showValue: '${_tileVerticalSpacing.toInt()}px',
              ),
              // Horizontal spacing slider
              _buildCompactSlider(
                'H-Space',
                _tileHorizontalSpacing,
                0,
                6,
                6,
                (v) => setState(() => _tileHorizontalSpacing = v),
                colorScheme,
                showValue: '${_tileHorizontalSpacing.toInt()}px',
              ),
              // Label height slider
              _buildCompactSlider(
                'Label H',
                _dateLabelHeight,
                12,
                28,
                16,
                (v) => setState(() => _dateLabelHeight = v),
                colorScheme,
                showValue: '${_dateLabelHeight.toInt()}px',
              ),
              // Overflow indicator height slider
              _buildCompactSlider(
                'Overflow H',
                _overflowIndicatorHeight,
                10,
                20,
                10,
                (v) => setState(() => _overflowIndicatorHeight = v),
                colorScheme,
                showValue: '${_overflowIndicatorHeight.toInt()}px',
              ),
            ],
          ),
          // Row 3: Drag edge delay (only when drag enabled)
          if (_enableDragAndDrop)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _buildCompactSlider(
                'Edge Delay',
                _dragEdgeNavigationDelayMs.toDouble(),
                200,
                1000,
                8,
                (v) => setState(() => _dragEdgeNavigationDelayMs = v.round()),
                colorScheme,
                showValue: '${_dragEdgeNavigationDelayMs}ms',
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // Keyboard Shortcuts Bar
  // ============================================================

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
          style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  // ============================================================
  // Hover Status Bar
  // ============================================================

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

  // ============================================================
  // Primary Calendar
  // ============================================================

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
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
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
            child: MCalTheme(
              data: _buildTheme(colorScheme),
              child: MCalMonthView(
                controller: _sharedController,
                showNavigator: true,
                enableSwipeNavigation: true,
                locale: widget.locale,
                showWeekNumbers: _showWeekNumbers,
                enableAnimations: _enableAnimations,
                maxVisibleEventsPerDay: _maxVisibleEventsPerDay,
                enableKeyboardNavigation: isDesktop,
                enableDragAndDrop: _enableDragAndDrop,
                dragEdgeNavigationDelay: Duration(
                  milliseconds: _dragEdgeNavigationDelayMs,
                ),
                // Hover handlers
                onHoverCell: isDesktop ? _onHoverCell : null,
                onHoverEvent: isDesktop ? _onHoverEvent : null,
                // Tap/LongPress handlers
                onCellTap: _onCellTap,
                onCellLongPress: _onCellLongPress,
                onDateLabelTap: _onDateLabelTap,
                onDateLabelLongPress: _onDateLabelLongPress,
                onEventTap: _onEventTap,
                onEventLongPress: _onEventLongPress,
                onOverflowTap: _onOverflowTap,
                // Drag-and-drop callback
                onEventDropped: _enableDragAndDrop
                    ? (context, details) {
                        _showAlert(
                          context,
                          'Event Dropped',
                          'Moved "${details.event.title}" from '
                              '${_formatDate(details.oldStartDate)} to '
                              '${_formatDate(details.newStartDate)}',
                        );
                        return true;
                      }
                    : null,
                onFocusedDateChanged: isDesktop
                    ? (date) {
                        if (date != null) {
                          setState(() {
                            _hoverStatus = 'FOCUSED: ${_formatDate(date)}';
                          });
                        }
                      }
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Secondary Calendar (Synced)
  // ============================================================

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
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
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
            child: MCalTheme(
              data: MCalThemeData(
                cellBackgroundColor: colorScheme.surfaceContainerLow,
                cellTextStyle: const TextStyle(fontSize: 12),
                dateLabelPosition: _dateLabelPosition,
                eventTileHeight: _tileHeight,
                tileCornerRadius: _tileCornerRadius,
              ),
              child: MCalMonthView(
                controller: _sharedController,
                showNavigator: false,
                locale: widget.locale,
                showWeekNumbers: _showWeekNumbers,
                enableAnimations: _enableAnimations,
                maxVisibleEventsPerDay: 2,
                enableKeyboardNavigation: false,
                enableDragAndDrop: false,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Helper Widgets
  // ============================================================

  Widget _buildToggle(
    String label,
    bool value,
    ValueChanged<bool> onChanged,
    ColorScheme colorScheme,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13, color: colorScheme.onSurface),
        ),
        const SizedBox(width: 8),
        Switch(value: value, onChanged: onChanged),
      ],
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
        Text(
          label,
          style: TextStyle(fontSize: 13, color: colorScheme.onSurface),
        ),
        const SizedBox(width: 4),
        Switch(
          value: value,
          onChanged: onChanged,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ],
    );
  }

  Widget _buildCompactSlider(
    String label,
    double value,
    double min,
    double max,
    int divisions,
    ValueChanged<double> onChanged,
    ColorScheme colorScheme, {
    required String showValue,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: $showValue',
          style: TextStyle(fontSize: 13, color: colorScheme.onSurface),
        ),
        SizedBox(
          width: 100,
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildSliderRow(
    String label,
    double value,
    double min,
    double max,
    int divisions,
    ValueChanged<double> onChanged,
    ColorScheme colorScheme, {
    String suffix = 'px',
  }) {
    final displayValue = suffix.isEmpty
        ? value.toInt().toString()
        : '${value.toInt()}$suffix';
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label: $displayValue',
            style: TextStyle(fontSize: 13, color: colorScheme.onSurface),
          ),
        ),
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownRow<T>(
    String label,
    T value,
    List<T> items,
    ValueChanged<T> onChanged,
    ColorScheme colorScheme,
  ) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13, color: colorScheme.onSurface),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: DropdownButton<T>(
            value: value,
            isDense: true,
            isExpanded: true,
            style: TextStyle(fontSize: 12, color: colorScheme.onSurface),
            items: items.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(
                  item.toString().split('.').last,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
