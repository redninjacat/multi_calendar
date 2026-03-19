import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:multi_calendar/multi_calendar.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

Widget _buildMonthView({
  required MCalEventController controller,
  required MCalThemeData theme,
  bool showWeekNumbers = false,
  bool showNavigator = false,
}) {
  return MaterialApp(
    locale: const Locale('en', 'US'),
    home: Scaffold(
      body: SizedBox(
        width: 800,
        height: 600,
        child: MCalTheme(
          data: theme,
          child: MCalMonthView(
            controller: controller,
            showWeekNumbers: showWeekNumbers,
            showNavigator: showNavigator,
            enableAnimations: false,
          ),
        ),
      ),
    ),
  );
}

Widget _buildDayView({
  required MCalEventController controller,
  required MCalThemeData theme,
  bool showNavigator = false,
}) {
  return MaterialApp(
    locale: const Locale('en', 'US'),
    home: Scaffold(
      body: SizedBox(
        width: 800,
        height: 800,
        child: MCalTheme(
          data: theme,
          child: MCalDayView(
            controller: controller,
            startHour: 8,
            endHour: 12,
            showNavigator: showNavigator,
            enableAnimations: false,
          ),
        ),
      ),
    ),
  );
}

bool _containerHasColor(Widget w, Color color) {
  if (w is Container) {
    final dec = w.decoration;
    if (dec is BoxDecoration) return dec.color == color;
  }
  return false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Tests
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en', null);
    await initializeDateFormatting('en_US', null);
  });

  final displayDate = DateTime(2025, 1, 6); // Monday

  // ──────────────────────────────────────────────────────────────────────────
  // Month View — layout properties reach widget tree
  // ──────────────────────────────────────────────────────────────────────────
  group('Month View — theme layout properties reach widget tree', () {
    late MCalEventController controller;

    setUp(() => controller = MCalEventController(initialDate: displayDate));
    tearDown(() => controller.dispose());

    testWidgets('navigatorPadding is applied to month navigator container', (
      tester,
    ) async {
      const customPadding = EdgeInsets.only(
        left: 42.0,
        right: 42.0,
        top: 7.0,
        bottom: 7.0,
      );
      await tester.pumpWidget(
        _buildMonthView(
          controller: controller,
          showNavigator: true,
          theme: const MCalThemeData(navigatorPadding: customPadding),
        ),
      );
      await tester.pumpAndSettle();

      // Container(padding: ...) creates a Padding widget internally.
      // Match by individual inset values for robustness.
      final match = find.byWidgetPredicate((w) {
        if (w is! Padding) return false;
        final p = w.padding;
        if (p is EdgeInsets) {
          return p.left == 42.0 &&
              p.right == 42.0 &&
              p.top == 7.0 &&
              p.bottom == 7.0;
        }
        return false;
      });
      expect(
        match,
        findsWidgets,
        reason: 'A Padding with customPadding should exist in the navigator',
      );
    });

    testWidgets('weekNumberColumnWidth is applied to week number cells', (
      tester,
    ) async {
      const customWidth = 60.0;
      await tester.pumpWidget(
        _buildMonthView(
          controller: controller,
          showWeekNumbers: true,
          theme: MCalThemeData(
            monthViewTheme: MCalMonthViewThemeData(
              weekNumberColumnWidth: customWidth,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // WeekNumberCell default rendering uses Container(width: columnWidth),
      // which stores the constraint as BoxConstraints.tightFor(width: ...).
      final match = find.byWidgetPredicate(
        (w) =>
            w is Container &&
            (w.constraints?.maxWidth == customWidth ||
                w.constraints?.minWidth == customWidth),
      );
      expect(
        match,
        findsWidgets,
        reason:
            'Container with tight width=60.0 should exist in week-number cells',
      );
    });

    testWidgets('eventTileBackgroundColor cascade uses monthViewTheme color', (
      tester,
    ) async {
      const tileColor = Color(0xFF7B1FA2); // distinct purple
      controller.addEvents([
        MCalCalendarEvent(
          id: 'ev-1',
          title: 'Purple Event',
          start: DateTime(2025, 1, 6),
          end: DateTime(2025, 1, 7),
        ),
      ]);

      await tester.pumpWidget(
        _buildMonthView(
          controller: controller,
          theme: MCalThemeData(
            monthViewTheme: MCalMonthViewThemeData(
              eventTileBackgroundColor: tileColor,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate((w) => _containerHasColor(w, tileColor)),
        findsWidgets,
        reason: 'Event tile should use monthViewTheme.eventTileBackgroundColor',
      );
    });

    testWidgets('enableEventColorOverrides true overrides event.color', (
      tester,
    ) async {
      const themeColor = Color(0xFFE53935); // red
      const eventColor = Color(0xFF43A047); // green

      controller.addEvents([
        MCalCalendarEvent(
          id: 'ev-2',
          title: 'Green Event',
          start: DateTime(2025, 1, 6),
          end: DateTime(2025, 1, 7),
          color: eventColor,
        ),
      ]);

      await tester.pumpWidget(
        _buildMonthView(
          controller: controller,
          theme: MCalThemeData(
            monthViewTheme: MCalMonthViewThemeData(
              eventTileBackgroundColor: themeColor,
            ),
            enableEventColorOverrides: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // With enableEventColorOverrides=true the theme color wins
      expect(
        find.byWidgetPredicate((w) => _containerHasColor(w, themeColor)),
        findsWidgets,
        reason: 'Theme color should win when enableEventColorOverrides=true',
      );
      expect(
        find.byWidgetPredicate((w) => _containerHasColor(w, eventColor)),
        findsNothing,
        reason: 'Event color should not appear when theme overrides it',
      );
    });

    testWidgets(
      'enableEventColorOverrides false lets event.color win over theme color',
      (tester) async {
        const themeColor = Color(0xFFE53935); // red
        const eventColor = Color(0xFF43A047); // green

        controller.addEvents([
          MCalCalendarEvent(
            id: 'ev-3',
            title: 'Green Event',
            start: DateTime(2025, 1, 6),
            end: DateTime(2025, 1, 7),
            color: eventColor,
          ),
        ]);

        await tester.pumpWidget(
          _buildMonthView(
            controller: controller,
            theme: MCalThemeData(
              monthViewTheme: MCalMonthViewThemeData(
                eventTileBackgroundColor: themeColor,
              ),
              // enableEventColorOverrides defaults to false
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.byWidgetPredicate((w) => _containerHasColor(w, eventColor)),
          findsWidgets,
          reason: 'event.color should win when enableEventColorOverrides=false',
        );
      },
    );
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Day View — layout properties reach widget tree
  // ──────────────────────────────────────────────────────────────────────────
  group('Day View — theme layout properties reach widget tree', () {
    late MCalEventController controller;

    setUp(() => controller = MCalEventController(initialDate: displayDate));
    tearDown(() => controller.dispose());

    testWidgets('navigatorPadding is applied to day navigator container', (
      tester,
    ) async {
      const customPadding = EdgeInsets.only(
        left: 77.0,
        right: 77.0,
        top: 3.0,
        bottom: 3.0,
      );
      await tester.pumpWidget(
        _buildDayView(
          controller: controller,
          showNavigator: true,
          theme: const MCalThemeData(navigatorPadding: customPadding),
        ),
      );
      await tester.pumpAndSettle();

      // Container(padding: ...) creates a Padding widget internally.
      // Match by individual inset values for robustness.
      final match = find.byWidgetPredicate((w) {
        if (w is! Padding) return false;
        final p = w.padding;
        if (p is EdgeInsets) {
          return p.left == 77.0 &&
              p.right == 77.0 &&
              p.top == 3.0 &&
              p.bottom == 3.0;
        }
        return false;
      });
      expect(
        match,
        findsWidgets,
        reason: 'A Padding with customPadding should exist in the navigator',
      );
    });

    testWidgets('allDayWrapSpacing reaches the Wrap widget', (tester) async {
      const spacing = 99.0;
      controller.addEvents([
        MCalCalendarEvent(
          id: 'ad-1',
          title: 'All Day',
          start: DateTime(2025, 1, 6),
          end: DateTime(2025, 1, 6, 23, 59, 59),
          isAllDay: true,
        ),
        MCalCalendarEvent(
          id: 'ad-2',
          title: 'All Day 2',
          start: DateTime(2025, 1, 6),
          end: DateTime(2025, 1, 6, 23, 59, 59),
          isAllDay: true,
        ),
      ]);

      await tester.pumpWidget(
        _buildDayView(
          controller: controller,
          theme: MCalThemeData(
            dayViewTheme: MCalDayViewThemeData(allDayWrapSpacing: spacing),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final match = find.byWidgetPredicate(
        (w) => w is Wrap && w.spacing == spacing,
      );
      expect(
        match,
        findsWidgets,
        reason: 'Wrap with spacing=99.0 should appear in the all-day section',
      );
    });

    testWidgets(
      'eventTileBackgroundColor in dayViewTheme applies to timed events',
      (tester) async {
        const tileColor = Color(0xFF00ACC1); // distinct teal

        controller.addEvents([
          MCalCalendarEvent(
            id: 'timed-1',
            title: 'Timed Event',
            start: DateTime(2025, 1, 6, 9, 0),
            end: DateTime(2025, 1, 6, 10, 0),
          ),
        ]);

        await tester.pumpWidget(
          _buildDayView(
            controller: controller,
            theme: MCalThemeData(
              dayViewTheme: MCalDayViewThemeData(
                eventTileBackgroundColor: tileColor,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.byWidgetPredicate((w) => _containerHasColor(w, tileColor)),
          findsWidgets,
          reason:
              'Event tile should use dayViewTheme.eventTileBackgroundColor (at 0.85 alpha)',
        );
      },
    );

    testWidgets(
      'allDayEventBackgroundColor in dayViewTheme applies to all-day tiles',
      (tester) async {
        const tileColor = Color(0xFF8D6E63); // distinct brown
        controller.addEvents([
          MCalCalendarEvent(
            id: 'ad-1',
            title: 'All Day Brown',
            start: DateTime(2025, 1, 6),
            end: DateTime(2025, 1, 6, 23, 59, 59),
            isAllDay: true,
          ),
        ]);

        await tester.pumpWidget(
          _buildDayView(
            controller: controller,
            theme: MCalThemeData(
              dayViewTheme: MCalDayViewThemeData(
                allDayEventBackgroundColor: tileColor,
              ),
              enableEventColorOverrides: true,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.byWidgetPredicate((w) => _containerHasColor(w, tileColor)),
          findsWidgets,
          reason:
              'All-day tile should use dayViewTheme.allDayEventBackgroundColor',
        );
      },
    );
  });
}
