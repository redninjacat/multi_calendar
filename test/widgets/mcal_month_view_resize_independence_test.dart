import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multi_calendar/multi_calendar.dart';

class _MockController extends MCalEventController {
  _MockController() : super(initialDate: DateTime(2026, 3, 2));

  void setEvents(List<MCalCalendarEvent> events) {
    clearEvents();
    addEvents(events);
  }
}

void main() {
  late _MockController controller;

  setUp(() {
    controller = _MockController();
  });

  Future<void> pumpMonthView(
    WidgetTester tester, {
    required _MockController controller,
    bool enableDragToMove = false,
    bool? enableDragToResize,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          MCalLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: MCalLocalizations.supportedLocales,
        theme: ThemeData(platform: TargetPlatform.linux),
        home: Scaffold(
          body: MCalMonthView(
            controller: controller,
            enableDragToMove: enableDragToMove,
            enableDragToResize: enableDragToResize,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  MCalCalendarEvent _multiDayEvent() => MCalCalendarEvent(
        id: 'multi-day',
        title: 'Multi Day Event',
        start: DateTime(2026, 3, 2),
        end: DateTime(2026, 3, 4),
        isAllDay: true,
      );

  group(
      'MCalMonthView enableDragToResize independence from enableDragToMove', () {
    testWidgets(
      'resize handles appear when enableDragToResize: true, enableDragToMove: false',
      (tester) async {
        controller.setEvents([_multiDayEvent()]);
        await pumpMonthView(
          tester,
          controller: controller,
          enableDragToMove: false,
          enableDragToResize: true,
        );

        expect(find.bySemanticsLabel('Resize start edge'), findsWidgets);
        expect(find.bySemanticsLabel('Resize end edge'), findsWidgets);
      },
    );

    testWidgets(
      'resize handles appear when enableDragToResize: true, enableDragToMove: true',
      (tester) async {
        controller.setEvents([_multiDayEvent()]);
        await pumpMonthView(
          tester,
          controller: controller,
          enableDragToMove: true,
          enableDragToResize: true,
        );

        expect(find.bySemanticsLabel('Resize start edge'), findsWidgets);
        expect(find.bySemanticsLabel('Resize end edge'), findsWidgets);
      },
    );

    testWidgets(
      'resize handles do NOT appear when enableDragToResize: false, enableDragToMove: true',
      (tester) async {
        controller.setEvents([_multiDayEvent()]);
        await pumpMonthView(
          tester,
          controller: controller,
          enableDragToMove: true,
          enableDragToResize: false,
        );

        expect(find.bySemanticsLabel('Resize start edge'), findsNothing);
        expect(find.bySemanticsLabel('Resize end edge'), findsNothing);
      },
    );

    testWidgets(
      'resize handles do NOT appear when enableDragToResize: false, enableDragToMove: false',
      (tester) async {
        controller.setEvents([_multiDayEvent()]);
        await pumpMonthView(
          tester,
          controller: controller,
          enableDragToMove: false,
          enableDragToResize: false,
        );

        expect(find.bySemanticsLabel('Resize start edge'), findsNothing);
        expect(find.bySemanticsLabel('Resize end edge'), findsNothing);
      },
    );

    testWidgets(
      'enableDragToMove toggle does not affect resize handles when enableDragToResize: true',
      (tester) async {
        controller.setEvents([_multiDayEvent()]);

        // Start with move=true, resize=true
        await pumpMonthView(
          tester,
          controller: controller,
          enableDragToMove: true,
          enableDragToResize: true,
        );
        expect(find.bySemanticsLabel('Resize start edge'), findsWidgets,
            reason: 'Resize handles should be present with move=true');

        // Rebuild with move=false, resize=true
        await pumpMonthView(
          tester,
          controller: controller,
          enableDragToMove: false,
          enableDragToResize: true,
        );
        expect(find.bySemanticsLabel('Resize start edge'), findsWidgets,
            reason:
                'Resize handles should still be present after disabling move');
      },
    );

    testWidgets(
      'auto-detect (null) works independently of enableDragToMove on desktop',
      (tester) async {
        controller.setEvents([_multiDayEvent()]);

        // enableDragToResize: null on desktop (linux) should auto-enable
        await pumpMonthView(
          tester,
          controller: controller,
          enableDragToMove: false,
          enableDragToResize: null,
        );

        expect(find.bySemanticsLabel('Resize start edge'), findsWidgets,
            reason:
                'Auto-detect should enable resize on desktop even with move=false');
      },
    );
  });
}
