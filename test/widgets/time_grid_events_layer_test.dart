import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:multi_calendar/multi_calendar.dart';
import 'package:multi_calendar/src/utils/theme_cascade_utils.dart';

class _TestController extends MCalEventController {
  _TestController({required super.initialDate});

  void setEvents(List<MCalCalendarEvent> events) {
    clearEvents();
    addEvents(events);
  }
}

final _testDate = DateTime(2026, 2, 10);

MCalCalendarEvent _timedEvent({required Color color}) => MCalCalendarEvent(
      id: 'ev-timed',
      title: 'Morning Meeting',
      start: DateTime(_testDate.year, _testDate.month, _testDate.day, 6, 0),
      end: DateTime(_testDate.year, _testDate.month, _testDate.day, 6, 30),
      color: color,
    );

MCalCalendarEvent _allDayEvent({required Color color}) => MCalCalendarEvent(
      id: 'ev-allday',
      title: 'All Day Summit',
      start: DateTime(_testDate.year, _testDate.month, _testDate.day),
      end: DateTime(_testDate.year, _testDate.month, _testDate.day, 23, 59),
      color: color,
      isAllDay: true,
    );

/// From focused event title, find the nearest ancestor [Container] whose
/// [BoxDecoration] top border uses [width].
Color? _keyboardBorderColorNearTitle(
  WidgetTester tester,
  Finder titleFinder,
  double width,
) {
  expect(titleFinder, findsOneWidget);
  final element = tester.element(titleFinder);
  Color? found;
  element.visitAncestorElements((ancestor) {
    final w = ancestor.widget;
    if (w is Container && w.decoration is BoxDecoration) {
      final border = (w.decoration as BoxDecoration).border;
      if (border is Border && border.top.width == width) {
        found = border.top.color;
        return false;
      }
    }
    return true;
  });
  return found;
}

int _countAncestorBorderWidth(
  WidgetTester tester,
  Finder titleFinder,
  double width,
) {
  expect(titleFinder, findsOneWidget);
  var n = 0;
  tester.element(titleFinder).visitAncestorElements((ancestor) {
    final w = ancestor.widget;
    if (w is Container && w.decoration is BoxDecoration) {
      final border = (w.decoration as BoxDecoration).border;
      if (border is Border && border.top.width == width) {
        n++;
      }
    }
    return true;
  });
  return n;
}

Future<void> _pumpDayView(
  WidgetTester tester,
  _TestController controller, {
  required List<MCalCalendarEvent> events,
  MCalThemeData? mcalTheme,
  ThemeData? flutterTheme,
}) async {
  controller.setEvents(events);
  final theme = flutterTheme ??
      ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      );
  Widget dayView = MCalDayView(
    controller: controller,
    startHour: 6,
    endHour: 10,
    timeSlotDuration: const Duration(minutes: 15),
    showNavigator: false,
    showCurrentTimeIndicator: false,
    autoScrollToCurrentTime: false,
    enableKeyboardNavigation: true,
  );
  if (mcalTheme != null) {
    dayView = MCalTheme(data: mcalTheme, child: dayView);
  }
  await tester.pumpWidget(
    MaterialApp(
      theme: theme,
      home: Scaffold(
        body: SizedBox(
          width: 800,
          height: 600,
          child: dayView,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Focus day view, normalize to all-day row, then [key] (e.g. arrowDown).
Future<void> _sendKeyFromAllDay(
  WidgetTester tester,
  LogicalKeyboardKey key,
) async {
  await tester.tap(find.byType(MCalDayView));
  await tester.pumpAndSettle();
  await tester.sendKeyEvent(LogicalKeyboardKey.home);
  await tester.pumpAndSettle();
  await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
  await tester.pumpAndSettle();
  await tester.sendKeyEvent(key);
  await tester.pumpAndSettle();
}

Future<void> _enterTimedEventMode(WidgetTester tester) async {
  await _sendKeyFromAllDay(tester, LogicalKeyboardKey.arrowDown);
  await tester.sendKeyEvent(LogicalKeyboardKey.enter);
  await tester.pumpAndSettle();
}

Future<void> _enterAllDayEventMode(WidgetTester tester) async {
  await tester.tap(find.byType(MCalDayView));
  await tester.pumpAndSettle();
  await tester.sendKeyEvent(LogicalKeyboardKey.home);
  await tester.pumpAndSettle();
  await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
  await tester.pumpAndSettle();
  await tester.sendKeyEvent(LogicalKeyboardKey.enter);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en', null);
  });

  group('keyboard border on event tiles', () {
    late _TestController controller;

    setUp(() {
      controller = _TestController(initialDate: _testDate);
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('timed event: single merged keyboard highlight border',
        (tester) async {
      final event = _timedEvent(color: Colors.blue);
      await _pumpDayView(tester, controller, events: [event]);
      await _enterTimedEventMode(tester);

      final ctx = tester.element(find.byType(MCalDayView));
      final kbW = MCalThemeData.fromTheme(Theme.of(ctx))
          .dayViewTheme!
          .keyboardHighlightBorderWidth!;

      expect(
        _countAncestorBorderWidth(tester, find.textContaining(event.title), kbW),
        1,
        reason: 'keyboard border must not be duplicated in an outer wrapper',
      );
    });

    testWidgets('all-day event: single merged keyboard highlight border',
        (tester) async {
      final event = _allDayEvent(color: Colors.teal);
      await _pumpDayView(tester, controller, events: [event]);
      await _enterAllDayEventMode(tester);

      final ctx = tester.element(find.byType(MCalDayView));
      final kbW = MCalThemeData.fromTheme(Theme.of(ctx))
          .dayViewTheme!
          .keyboardHighlightBorderWidth!;

      expect(
        _countAncestorBorderWidth(tester, find.text(event.title), kbW),
        1,
      );
    });

    testWidgets('adaptive highlight border color on light tile', (tester) async {
      const light = Color(0xFFEEEEEE);
      final event = _timedEvent(color: light);
      final flutterTheme = ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      );
      final dayDefs =
          MCalThemeData.fromTheme(flutterTheme).dayViewTheme!;
      final expected = resolveContrastColor(
        backgroundColor: light,
        lightContrastColor: dayDefs.eventTileLightContrastColor!,
        darkContrastColor: dayDefs.eventTileDarkContrastColor!,
      );

      await _pumpDayView(
        tester,
        controller,
        events: [event],
        flutterTheme: flutterTheme,
      );
      await _enterTimedEventMode(tester);

      final kbW = dayDefs.keyboardHighlightBorderWidth!;
      final actual = _keyboardBorderColorNearTitle(
        tester,
        find.textContaining(event.title),
        kbW,
      );
      expect(actual, expected);
    });

    testWidgets('adaptive highlight border color on dark tile', (tester) async {
      const dark = Color(0xFF181818);
      final event = _timedEvent(color: dark);
      final flutterTheme = ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      );
      final dayDefs =
          MCalThemeData.fromTheme(flutterTheme).dayViewTheme!;
      final expected = resolveContrastColor(
        backgroundColor: dark,
        lightContrastColor: dayDefs.eventTileLightContrastColor!,
        darkContrastColor: dayDefs.eventTileDarkContrastColor!,
      );

      await _pumpDayView(
        tester,
        controller,
        events: [event],
        flutterTheme: flutterTheme,
      );
      await _enterTimedEventMode(tester);

      final kbW = dayDefs.keyboardHighlightBorderWidth!;
      final actual = _keyboardBorderColorNearTitle(
        tester,
        find.textContaining(event.title),
        kbW,
      );
      expect(actual, expected);
    });

    testWidgets('explicit keyboardHighlightBorderColor skips adaptive fallback',
        (tester) async {
      const explicit = Color(0xFFE91E63);
      final event = _timedEvent(color: const Color(0xFFEEEEEE));
      await _pumpDayView(
        tester,
        controller,
        events: [event],
        mcalTheme: const MCalThemeData(
          dayViewTheme: MCalDayViewThemeData(
            keyboardHighlightBorderColor: explicit,
          ),
        ),
      );
      await _enterTimedEventMode(tester);

      final kbW = MCalThemeData.fromTheme(
        Theme.of(tester.element(find.byType(MCalDayView))),
      ).dayViewTheme!.keyboardHighlightBorderWidth!;

      expect(
        _keyboardBorderColorNearTitle(
          tester,
          find.textContaining(event.title),
          kbW,
        ),
        explicit,
      );
    });
  });
}
