import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:multi_calendar/multi_calendar.dart';

bool _containerHasDecorationColor(Widget w, Color color) {
  if (w is! Container) return false;
  final dec = w.decoration;
  return dec is BoxDecoration && dec.color == color;
}

class _BranchingTestController extends MCalEventController {
  _BranchingTestController({super.initialDate});

  void setTestEvents(List<MCalCalendarEvent> events) {
    clearEvents();
    addEvents(events);
  }
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en', null);
    await initializeDateFormatting('en_US', null);
  });

  const allDayBg = Color(0xFF136C46);
  const timedBg = Color(0xFF8B1538);

  final displayDate = DateTime(2025, 1, 6);

  group('Month View isAllDay theme branching', () {
    MCalThemeData branchingTheme() => MCalThemeData(
          enableEventColorOverrides: true,
          monthViewTheme: const MCalMonthViewThemeData(
            allDayEventBackgroundColor: allDayBg,
            eventTileBackgroundColor: timedBg,
          ),
        );

    Widget pumpMonth(MCalEventController c) => MaterialApp(
          locale: const Locale('en', 'US'),
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: MCalTheme(
                data: branchingTheme(),
                child: MCalMonthView(
                  controller: c,
                  enableAnimations: false,
                ),
              ),
            ),
          ),
        );

    late _BranchingTestController controller;

    setUp(() => controller = _BranchingTestController(initialDate: displayDate));
    tearDown(() => controller.dispose());

    testWidgets(
      'multi-day segments: all-day uses allDayEventBackgroundColor, timed uses eventTileBackgroundColor',
      (tester) async {
        controller.setTestEvents([
          MCalCalendarEvent(
            id: 'multi-all-day',
            title: 'All-day span',
            start: DateTime(2025, 1, 8),
            end: DateTime(2025, 1, 10),
            isAllDay: true,
          ),
          MCalCalendarEvent(
            id: 'multi-timed',
            title: 'Timed span',
            start: DateTime(2025, 1, 13, 10, 0),
            end: DateTime(2025, 1, 15, 18, 0),
            isAllDay: false,
          ),
        ]);

        await tester.pumpWidget(pumpMonth(controller));
        await tester.pumpAndSettle();

        expect(
          find.byWidgetPredicate((w) => _containerHasDecorationColor(w, allDayBg)),
          findsWidgets,
          reason: 'Multi-day all-day segments should use allDayEventBackgroundColor',
        );
        expect(
          find.byWidgetPredicate((w) => _containerHasDecorationColor(w, timedBg)),
          findsWidgets,
          reason: 'Multi-day timed segments should use eventTileBackgroundColor',
        );
      },
    );

    testWidgets(
      'single-day week row tiles: all-day uses allDayEventBackgroundColor, timed uses eventTileBackgroundColor',
      (tester) async {
        controller.setTestEvents([
          MCalCalendarEvent(
            id: 'single-all-day',
            title: 'One-day all-day',
            start: DateTime(2025, 1, 20),
            end: DateTime(2025, 1, 20),
            isAllDay: true,
          ),
          MCalCalendarEvent(
            id: 'single-timed',
            title: 'One-day timed',
            start: DateTime(2025, 1, 22, 9, 0),
            end: DateTime(2025, 1, 22, 10, 0),
            isAllDay: false,
          ),
        ]);

        await tester.pumpWidget(pumpMonth(controller));
        await tester.pumpAndSettle();

        expect(
          find.byWidgetPredicate((w) => _containerHasDecorationColor(w, allDayBg)),
          findsWidgets,
          reason: 'Single-day all-day tile should use allDayEventBackgroundColor',
        );
        expect(
          find.byWidgetPredicate((w) => _containerHasDecorationColor(w, timedBg)),
          findsWidgets,
          reason: 'Single-day timed tile should use eventTileBackgroundColor',
        );
      },
    );
  });
}
