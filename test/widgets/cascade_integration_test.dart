import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:multi_calendar/multi_calendar.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

bool _containerHasColor(Widget widget, Color color) {
  if (widget is Container) {
    final dec = widget.decoration;
    if (dec is BoxDecoration) {
      return dec.color == color;
    }
  }
  return false;
}

bool _textHasColor(Widget widget, Color color) {
  if (widget is Text) {
    return widget.style?.color == color;
  }
  return false;
}

class _TestController extends MCalEventController {
  _TestController({super.initialDate});

  void setTestEvents(List<MCalCalendarEvent> events) {
    clearEvents();
    addEvents(events);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tests
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en', null);
    await initializeDateFormatting('en_US', null);
  });

  // Display date: a Monday so we get a full week of tiles visible
  final displayDate = DateTime(2025, 1, 6); // Monday

  // ──────────────────────────────────────────────────────────────────────────
  // Group 1: Month View — enableEventColorOverrides cascade
  // ──────────────────────────────────────────────────────────────────────────
  group('Month View — enableEventColorOverrides cascade', () {
    late _TestController controller;

    setUp(() {
      controller = _TestController(initialDate: displayDate);
    });

    tearDown(() => controller.dispose());

    // ── 1a. enableEventColorOverrides: false (default) → event.color wins ─────────
    testWidgets('enableEventColorOverrides false: event color wins over theme color', (
      tester,
    ) async {
      const eventColor = Color(0xFFE53935); // bright red
      const themeColor = Color(0xFF1E88E5); // bright blue

      controller.setTestEvents([
        MCalCalendarEvent(
          id: 'ev-1',
          title: 'Red Event',
          start: DateTime(2025, 1, 6),
          end: DateTime(2025, 1, 7),
          color: eventColor,
        ),
      ]);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: MCalTheme(
                data: MCalThemeData(
                  monthViewTheme: MCalMonthViewThemeData(eventTileBackgroundColor: themeColor),
                  // enableEventColorOverrides defaults to false
                ),
                child: MCalMonthView(
                  controller: controller,
                  enableAnimations: false,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tile should use eventColor, not themeColor
      expect(
        find.byWidgetPredicate((w) => _containerHasColor(w, eventColor)),
        findsWidgets,
        reason: 'event tile should use event.color when enableEventColorOverrides=false',
      );
      expect(
        find.byWidgetPredicate((w) => _containerHasColor(w, themeColor)),
        findsNothing,
        reason: 'themeColor should not appear when event.color takes priority',
      );
    });

    // ── 1b. enableEventColorOverrides: true → theme color wins ────────────────────
    testWidgets('enableEventColorOverrides true: theme color wins over event color', (
      tester,
    ) async {
      const eventColor = Color(0xFFE53935); // bright red
      const themeColor = Color(0xFF1E88E5); // bright blue

      controller.setTestEvents([
        MCalCalendarEvent(
          id: 'ev-2',
          title: 'Ignored Red',
          start: DateTime(2025, 1, 6),
          end: DateTime(2025, 1, 7),
          color: eventColor,
        ),
      ]);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: MCalTheme(
                data: MCalThemeData(
                  monthViewTheme: MCalMonthViewThemeData(eventTileBackgroundColor: themeColor),
                  enableEventColorOverrides: true,
                ),
                child: MCalMonthView(
                  controller: controller,
                  enableAnimations: false,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tile should use themeColor, not eventColor
      expect(
        find.byWidgetPredicate((w) => _containerHasColor(w, themeColor)),
        findsWidgets,
        reason: 'event tile should use themeColor when enableEventColorOverrides=true',
      );
      expect(
        find.byWidgetPredicate((w) => _containerHasColor(w, eventColor)),
        findsNothing,
        reason:
            'event.color should not appear when enableEventColorOverrides=true and themeColor is set',
      );
    });

    // ── 1c. allDayEventBackgroundColor cascade (event.color = null) ────────
    testWidgets(
      'allDayEventBackgroundColor wins when event.color is null (enableEventColorOverrides false)',
      (tester) async {
        const allDayColor = Color(0xFF43A047); // green

        controller.setTestEvents([
          MCalCalendarEvent(
            id: 'ev-3',
            title: 'No Color Event',
            start: DateTime(2025, 1, 6),
            end: DateTime(2025, 1, 7),
            // color: null — no event color
          ),
        ]);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 800,
                height: 600,
                child: MCalTheme(
                  data: MCalThemeData(
                    monthViewTheme: MCalMonthViewThemeData(eventTileBackgroundColor: allDayColor),
                    // enableEventColorOverrides defaults to false
                  ),
                  child: MCalMonthView(
                    controller: controller,
                    enableAnimations: false,
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // With event.color=null the cascade falls through to allDayThemeColor
        expect(
          find.byWidgetPredicate((w) => _containerHasColor(w, allDayColor)),
          findsWidgets,
          reason:
              'allDayEventBackgroundColor should be used when event.color is null',
        );
      },
    );

    // ── 1d. enableEventColorOverrides: true with null theme color → event.color fallback
    testWidgets(
      'enableEventColorOverrides true: event.color used as fallback when theme color is null',
      (tester) async {
        const eventColor = Color(0xFFE53935);

        controller.setTestEvents([
          MCalCalendarEvent(
            id: 'ev-4',
            title: 'Fallback Event',
            start: DateTime(2025, 1, 6),
            end: DateTime(2025, 1, 7),
            color: eventColor,
          ),
        ]);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 800,
                height: 600,
                child: MCalTheme(
                  data: const MCalThemeData(
                    // monthViewTheme.eventTileBackgroundColor: null → falls back to event.color
                    enableEventColorOverrides: true,
                  ),
                  child: MCalMonthView(
                    controller: controller,
                    enableAnimations: false,
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // When allDayThemeColor and themeColor are both null,
        // cascade falls through to eventColor even with enableEventColorOverrides:true
        expect(
          find.byWidgetPredicate((w) => _containerHasColor(w, eventColor)),
          findsWidgets,
          reason:
              'event.color should be used as fallback in enableEventColorOverrides=true when theme colors are null',
        );
      },
    );
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Group 2: Day View — contrast color and Req 10.3 text style precedence
  // ──────────────────────────────────────────────────────────────────────────
  group('Day View — contrast color and text style precedence (Req 10.3)', () {
    late _TestController controller;
    const testHour = 10;

    setUp(() {
      controller = _TestController(initialDate: displayDate);
    });

    tearDown(() => controller.dispose());

    Widget buildDayView(MCalThemeData themeData) {
      return MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 600,
            height: 800,
            child: MCalTheme(
              data: themeData,
              child: MCalDayView(
                controller: controller,
                startHour: testHour - 1,
                endHour: testHour + 3,
              ),
            ),
          ),
        ),
      );
    }

    // ── 2a. Dark tile → light contrast color used for text ─────────────────
    testWidgets('dark tile background → lightContrastColor applied to text', (
      tester,
    ) async {
      // Dark tile color → high luminance value → should use lightContrastColor
      const darkTile = Color(0xFF1A237E); // very dark blue
      const lightContrast = Color(0xFFFFFDE7); // light yellow — custom value
      const darkContrast = Color(0xFF212121); // dark grey

      controller.setTestEvents([
        MCalCalendarEvent(
          id: 'contrast-dark',
          title: 'Dark Event',
          start: DateTime(2025, 1, 6, testHour, 0),
          end: DateTime(2025, 1, 6, testHour + 1, 0),
          color: darkTile,
        ),
      ]);

      await tester.pumpWidget(
        buildDayView(
          MCalThemeData(
            dayViewTheme: MCalDayViewThemeData(
              eventTileLightContrastColor: lightContrast,
              eventTileDarkContrastColor: darkContrast,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // For a dark tile, lightContrastColor should appear on text widgets
      expect(
        find.byWidgetPredicate((w) => _textHasColor(w, lightContrast)),
        findsWidgets,
        reason:
            'lightContrastColor should be used for text on dark tile background',
      );
    });

    // ── 2b. Light tile → dark contrast color used for text ─────────────────
    testWidgets('light tile background → darkContrastColor applied to text', (
      tester,
    ) async {
      const lightTile = Color(0xFFFFF9C4); // very light yellow
      const lightContrast = Color(0xFFFFFDE7);
      const darkContrast = Color(0xFF1A237E); // custom dark indigo

      controller.setTestEvents([
        MCalCalendarEvent(
          id: 'contrast-light',
          title: 'Light Event',
          start: DateTime(2025, 1, 6, testHour, 0),
          end: DateTime(2025, 1, 6, testHour + 1, 0),
          color: lightTile,
        ),
      ]);

      await tester.pumpWidget(
        buildDayView(
          MCalThemeData(
            dayViewTheme: MCalDayViewThemeData(
              eventTileLightContrastColor: lightContrast,
              eventTileDarkContrastColor: darkContrast,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // For a light tile, darkContrastColor should appear on text widgets
      expect(
        find.byWidgetPredicate((w) => _textHasColor(w, darkContrast)),
        findsWidgets,
        reason:
            'darkContrastColor should be used for text on light tile background',
      );
    });

    // ── 2c. Req 10.3: enableEventColorOverrides true + eventTileTextStyle.color ─────
    //        Text style color takes precedence over contrast color
    testWidgets(
      'Req 10.3: eventTileTextStyle.color wins over contrast color when enableEventColorOverrides=true',
      (tester) async {
        const darkTile = Color(0xFF1A237E); // dark → normally → lightContrast
        const lightContrast = Color(0xFFFFFFFF);
        const darkContrast = Color(0xFF000000);
        const textStyleColor = Color(0xFFFF6F00); // orange — clearly different

        controller.setTestEvents([
          MCalCalendarEvent(
            id: 'req-10-3',
            title: 'Orange Text Event',
            start: DateTime(2025, 1, 6, testHour, 0),
            end: DateTime(2025, 1, 6, testHour + 1, 0),
            color: darkTile,
          ),
        ]);

        await tester.pumpWidget(
          buildDayView(
            MCalThemeData(
              enableEventColorOverrides: true,
              dayViewTheme: MCalDayViewThemeData(
                eventTileTextStyle: const TextStyle(color: textStyleColor),
                eventTileLightContrastColor: lightContrast,
                eventTileDarkContrastColor: darkContrast,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Text style color should win — neither lightContrast nor darkContrast appears
        expect(
          find.byWidgetPredicate((w) => _textHasColor(w, textStyleColor)),
          findsWidgets,
          reason:
              'eventTileTextStyle.color should be applied to event text when enableEventColorOverrides=true',
        );
        // The standard contrast colors should not appear (textStyleColor took over)
        expect(
          find.byWidgetPredicate((w) => _textHasColor(w, lightContrast)),
          findsNothing,
          reason:
              'lightContrastColor should not override eventTileTextStyle.color when enableEventColorOverrides=true',
        );
      },
    );

    // ── 2d. enableEventColorOverrides false → contrast color drives text, not style ─
    testWidgets(
      'enableEventColorOverrides false: contrast color drives text even when eventTileTextStyle has a color',
      (tester) async {
        const darkTile = Color(0xFF1A237E);
        const lightContrast = Color(0xFFFFFDE7);
        const darkContrast = Color(0xFF212121);
        const textStyleColor = Color(0xFFFF6F00); // orange

        controller.setTestEvents([
          MCalCalendarEvent(
            id: 'no-override',
            title: 'Contrast Wins',
            start: DateTime(2025, 1, 6, testHour, 0),
            end: DateTime(2025, 1, 6, testHour + 1, 0),
            color: darkTile,
          ),
        ]);

        await tester.pumpWidget(
          buildDayView(
            MCalThemeData(
              enableEventColorOverrides: false,
              dayViewTheme: MCalDayViewThemeData(
                eventTileTextStyle: const TextStyle(color: textStyleColor),
                eventTileLightContrastColor: lightContrast,
                eventTileDarkContrastColor: darkContrast,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // enableEventColorOverrides:false → textStyleColor is NOT used for override;
        // the contrast color (lightContrast for dark tile) drives the text.
        expect(
          find.byWidgetPredicate((w) => _textHasColor(w, lightContrast)),
          findsWidgets,
          reason:
              'lightContrastColor should drive text color when enableEventColorOverrides=false',
        );
        expect(
          find.byWidgetPredicate((w) => _textHasColor(w, textStyleColor)),
          findsNothing,
          reason:
              'eventTileTextStyle.color should NOT override contrast when enableEventColorOverrides=false',
        );
      },
    );
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Group 3: Theme property plumbing — new properties reach widget tree
  // ──────────────────────────────────────────────────────────────────────────
  group('New theme properties reach widget tree', () {
    late _TestController controller;

    setUp(() {
      controller = _TestController(initialDate: displayDate);
    });

    tearDown(() => controller.dispose());

    // ── 3a. eventTileCornerRadius applied to month tiles ───────────────────
    testWidgets(
      'eventTileCornerRadius is applied to month event tile border radius',
      (tester) async {
        const radius = 12.0;
        const eventColor = Color(0xFF6A1B9A);

        controller.setTestEvents([
          MCalCalendarEvent(
            id: 'radius-test',
            title: 'Rounded Event',
            start: DateTime(2025, 1, 6),
            end: DateTime(2025, 1, 7),
            color: eventColor,
          ),
        ]);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 800,
                height: 600,
                child: MCalTheme(
                  data: MCalThemeData(monthViewTheme: MCalMonthViewThemeData(eventTileCornerRadius: radius)),
                  child: MCalMonthView(
                    controller: controller,
                    enableAnimations: false,
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Find a Container whose BoxDecoration has the expected border radius
        final expectedRadius = BorderRadius.horizontal(
          left: const Radius.circular(radius),
          right: const Radius.circular(radius),
        );
        expect(
          find.byWidgetPredicate((widget) {
            if (widget is Container) {
              final dec = widget.decoration;
              if (dec is BoxDecoration) {
                return dec.borderRadius == expectedRadius;
              }
            }
            return false;
          }),
          findsWidgets,
          reason: 'eventTileCornerRadius should be applied to month tile border radius',
        );
      },
    );

    // ── 3b. cellBorderColor propagates to month view cell borders ──────────
    testWidgets('cellBorderColor is applied to month cell borders', (
      tester,
    ) async {
      const borderColor = Color(0xFF00BCD4); // cyan

      controller.setTestEvents([]);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: MCalTheme(
                data: const MCalThemeData(cellBorderColor: borderColor),
                child: MCalMonthView(
                  controller: controller,
                  enableAnimations: false,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify border-bearing containers exist and use the custom color.
      // The cell border is rendered as BoxDecoration border on Container.
      expect(
        find.byWidgetPredicate((widget) {
          if (widget is Container) {
            final dec = widget.decoration;
            if (dec is BoxDecoration && dec.border != null) {
              final border = dec.border! as Border;
              return border.bottom.color == borderColor ||
                  border.right.color == borderColor;
            }
          }
          return false;
        }),
        findsWidgets,
        reason: 'cellBorderColor should be applied to month cell border decorations',
      );
    });

    // ── 3c. MCalTheme.of() returns all-null when no ancestor in tree ───────
    testWidgets(
      'MCalTheme.of() returns all-null MCalThemeData when no MCalTheme ancestor',
      (tester) async {
        MCalThemeData? capturedTheme;

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                capturedTheme = MCalTheme.of(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        expect(capturedTheme, isNotNull);
        expect(capturedTheme!.cellBackgroundColor, isNull);
        expect(capturedTheme!.dayViewTheme?.eventTileBackgroundColor, isNull);
        expect(capturedTheme!.enableEventColorOverrides, isFalse);
        expect(capturedTheme!.dayViewTheme, isNull);
        expect(capturedTheme!.monthViewTheme, isNull);
      },
    );
  });
}
