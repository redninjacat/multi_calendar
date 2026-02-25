import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:multi_calendar/multi_calendar.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

Future<void> pumpDayView(
  WidgetTester tester, {
  required MCalEventController controller,
  bool enableSwipeNavigation = false,
  DateTime? minDate,
  DateTime? maxDate,
  MCalSwipeNavigationDirection swipeDirection =
      MCalSwipeNavigationDirection.horizontal,
  void Function(BuildContext, MCalSwipeNavigationDetails)? onSwipeNavigation,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en', 'US'),
      home: Scaffold(
        body: SizedBox(
          width: 400,
          height: 800,
          child: MCalDayView(
            controller: controller,
            enableSwipeNavigation: enableSwipeNavigation,
            minDate: minDate,
            maxDate: maxDate,
            onSwipeNavigation: onSwipeNavigation,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

// ─────────────────────────────────────────────────────────────────────────────
// Main
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en', null);
    await initializeDateFormatting('en_US', null);
  });

  group('MCalDayView swipe navigation', () {
    late MCalEventController controller;

    setUp(() {
      controller = MCalEventController(initialDate: DateTime(2025, 6, 15));
    });

    tearDown(() => controller.dispose());

    // ─────────────────────────────────────────────────────────────────────────
    // Requirement 1.6: enableSwipeNavigation:false (default) — no PageView
    // ─────────────────────────────────────────────────────────────────────────

    testWidgets(
      'enableSwipeNavigation:false (default) does not install a PageView',
      (tester) async {
        await pumpDayView(
          tester,
          controller: controller,
          enableSwipeNavigation: false,
        );

        expect(find.byType(PageView), findsNothing);
        expect(find.byType(MCalDayView), findsOneWidget);
      },
    );

    testWidgets(
      'enableSwipeNavigation:true installs a PageView',
      (tester) async {
        await pumpDayView(
          tester,
          controller: controller,
          enableSwipeNavigation: true,
        );

        expect(find.byType(PageView), findsOneWidget);
      },
    );

    // ─────────────────────────────────────────────────────────────────────────
    // Requirement 1.2: Swiping calls setDisplayDate with the correct date
    // ─────────────────────────────────────────────────────────────────────────

    testWidgets(
      'swiping LEFT navigates to the NEXT day (LTR layout)',
      (tester) async {
        final startDate = DateTime(2025, 6, 15);
        controller = MCalEventController(initialDate: startDate);

        MCalSwipeNavigationDetails? capturedDetails;

        await pumpDayView(
          tester,
          controller: controller,
          enableSwipeNavigation: true,
          onSwipeNavigation: (_, details) => capturedDetails = details,
        );

        // Fling left (past-halfway swipe to trigger page change).
        await tester.fling(
          find.byType(PageView),
          const Offset(-300, 0),
          800,
        );
        await tester.pumpAndSettle();

        // The controller should now show June 16.
        expect(controller.displayDate.day, 16);
        expect(controller.displayDate.month, 6);

        // The callback should report the correct dates.
        if (capturedDetails != null) {
          expect(
            capturedDetails!.previousMonth.day,
            15,
            reason: 'previousMonth should be the original day (15)',
          );
          expect(
            capturedDetails!.newMonth.day,
            16,
            reason: 'newMonth should be the next day (16)',
          );
          expect(capturedDetails!.direction, AxisDirection.left);
        }
      },
    );

    testWidgets(
      'swiping RIGHT navigates to the PREVIOUS day (LTR layout)',
      (tester) async {
        final startDate = DateTime(2025, 6, 15);
        controller = MCalEventController(initialDate: startDate);

        MCalSwipeNavigationDetails? capturedDetails;

        await pumpDayView(
          tester,
          controller: controller,
          enableSwipeNavigation: true,
          onSwipeNavigation: (_, details) => capturedDetails = details,
        );

        // Fling right to go to previous day.
        await tester.fling(
          find.byType(PageView),
          const Offset(300, 0),
          800,
        );
        await tester.pumpAndSettle();

        // The controller should now show June 14.
        expect(controller.displayDate.day, 14);
        expect(controller.displayDate.month, 6);

        if (capturedDetails != null) {
          expect(capturedDetails!.previousMonth.day, 15);
          expect(capturedDetails!.newMonth.day, 14);
          expect(capturedDetails!.direction, AxisDirection.right);
        }
      },
    );

    // ─────────────────────────────────────────────────────────────────────────
    // Requirement 1.3: Programmatic setDisplayDate syncs the PageView
    // ─────────────────────────────────────────────────────────────────────────

    testWidgets(
      'programmatic setDisplayDate keeps PageView in sync',
      (tester) async {
        await pumpDayView(
          tester,
          controller: controller,
          enableSwipeNavigation: true,
        );

        // Jump to a date 5 days ahead programmatically.
        controller.setDisplayDate(DateTime(2025, 6, 20));
        await tester.pump();
        await tester.pumpAndSettle();

        // Controller should reflect the new date.
        expect(controller.displayDate.day, 20);

        // A subsequent swipe should navigate relative to the new date.
        await tester.fling(
          find.byType(PageView),
          const Offset(-300, 0),
          800,
        );
        await tester.pumpAndSettle();

        expect(controller.displayDate.day, 21);
      },
    );

    // ─────────────────────────────────────────────────────────────────────────
    // Requirement 1.1: Page-to-date mapping is always accurate
    // ─────────────────────────────────────────────────────────────────────────

    testWidgets(
      'multiple consecutive swipes accumulate correctly',
      (tester) async {
        final startDate = DateTime(2025, 6, 15);
        controller = MCalEventController(initialDate: startDate);

        await pumpDayView(
          tester,
          controller: controller,
          enableSwipeNavigation: true,
        );

        // Swipe left three times → should end on June 18.
        for (int i = 0; i < 3; i++) {
          await tester.fling(
            find.byType(PageView),
            const Offset(-300, 0),
            800,
          );
          await tester.pumpAndSettle();
        }

        expect(controller.displayDate.day, 18);
        expect(controller.displayDate.month, 6);
      },
    );

    testWidgets(
      'swipe navigates correctly across month boundary',
      (tester) async {
        // Start on the last day of May.
        controller = MCalEventController(initialDate: DateTime(2025, 5, 31));

        await pumpDayView(
          tester,
          controller: controller,
          enableSwipeNavigation: true,
        );

        // One swipe left → June 1.
        await tester.fling(
          find.byType(PageView),
          const Offset(-300, 0),
          800,
        );
        await tester.pumpAndSettle();

        expect(controller.displayDate.month, 6);
        expect(controller.displayDate.day, 1);
      },
    );

    // ─────────────────────────────────────────────────────────────────────────
    // Requirement 1.6: Disabling swipe navigation leaves existing behavior
    // ─────────────────────────────────────────────────────────────────────────

    testWidgets(
      'setDisplayDate works correctly when swipe is disabled',
      (tester) async {
        await pumpDayView(
          tester,
          controller: controller,
          enableSwipeNavigation: false,
        );

        controller.setDisplayDate(DateTime(2025, 7, 4));
        await tester.pump();

        expect(controller.displayDate.day, 4);
        expect(controller.displayDate.month, 7);
      },
    );
  });
}
