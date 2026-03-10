import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:multi_calendar/multi_calendar.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en', null);
    await initializeDateFormatting('en_US', null);
  });

  final testDate = DateTime(2026, 3, 1);

  /// Pumps a minimal MCalDayView suited for focus testing.
  ///
  /// Uses startHour=6, endHour=10, 15-min slots — matches the pattern from
  /// the existing keyboard-nav tests so the same helper patterns work.
  Future<void> pumpDayView(
    WidgetTester tester,
    MCalEventController ctrl, {
    ValueChanged<DateTime?>? onFocusedDateTimeChanged,
    int startHour = 6,
    int endHour = 10,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en', 'US'),
        home: Scaffold(
          body: SizedBox(
            width: 800,
            height: 600,
            child: MCalDayView(
              controller: ctrl,
              startHour: startHour,
              endHour: endHour,
              timeSlotDuration: const Duration(minutes: 15),
              showNavigator: false,
              showCurrentTimeIndicator: false,
              autoScrollToCurrentTime: false,
              enableKeyboardNavigation: true,
              onFocusedDateTimeChanged: onFocusedDateTimeChanged,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Taps the DayView to give it keyboard focus, then sends [key].
  Future<void> sendKey(
    WidgetTester tester,
    LogicalKeyboardKey key,
  ) async {
    await tester.tap(find.byType(MCalDayView));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(key);
    await tester.pumpAndSettle();
  }

  /// Sends [key] without re-tapping (subsequent keys in a sequence).
  Future<void> sendKeyOnly(
    WidgetTester tester,
    LogicalKeyboardKey key,
  ) async {
    await tester.sendKeyEvent(key);
    await tester.pumpAndSettle();
  }

  // ─── Programmatic sync tests ────────────────────────────────────────────────

  group('programmatic setFocusedDateTime sync', () {
    late MCalEventController controller;

    setUp(() {
      controller = MCalEventController(initialDate: testDate);
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets(
        'setFocusedDateTime fires onFocusedDateTimeChanged in DayView',
        (tester) async {
      DateTime? capturedDateTime;

      await pumpDayView(
        tester,
        controller,
        onFocusedDateTimeChanged: (dt) => capturedDateTime = dt,
      );

      controller.setFocusedDateTime(DateTime(2026, 3, 1, 10, 0));
      await tester.pumpAndSettle();

      expect(capturedDateTime, isNotNull);
      expect(capturedDateTime!.hour, 10);
      expect(controller.isFocusedOnAllDay, isFalse);
    });

    testWidgets(
        'setFocusedDateTime with isAllDay:true fires callback and sets isFocusedOnAllDay',
        (tester) async {
      DateTime? capturedDateTime;

      await pumpDayView(
        tester,
        controller,
        onFocusedDateTimeChanged: (dt) => capturedDateTime = dt,
      );

      controller.setFocusedDateTime(
        DateTime(2026, 3, 1),
        isAllDay: true,
      );
      await tester.pumpAndSettle();

      expect(capturedDateTime, isNotNull);
      expect(controller.isFocusedOnAllDay, isTrue);
    });

    testWidgets(
        'setFocusedDateTime(null) fires callback with null',
        (tester) async {
      DateTime? capturedDateTime = DateTime(2026, 3, 1, 10, 0);

      await pumpDayView(
        tester,
        controller,
        onFocusedDateTimeChanged: (dt) => capturedDateTime = dt,
      );

      // Set a focus first
      controller.setFocusedDateTime(DateTime(2026, 3, 1, 10, 0));
      await tester.pumpAndSettle();
      expect(capturedDateTime, isNotNull);

      // Now clear it
      controller.setFocusedDateTime(null);
      await tester.pumpAndSettle();

      expect(capturedDateTime, isNull,
          reason: 'Clearing focus should fire callback with null');
    });

    testWidgets(
        'midnight disambiguation: setFocusedDateTime with midnight+isAllDay:false '
        'maps to slot 0 when startHour=0',
        (tester) async {
      final midnightCtrl = MCalEventController(initialDate: testDate);
      DateTime? capturedDateTime;

      await pumpDayView(
        tester,
        midnightCtrl,
        startHour: 0,
        endHour: 24,
        onFocusedDateTimeChanged: (dt) => capturedDateTime = dt,
      );

      // Midnight as a time SLOT (not all-day)
      midnightCtrl.setFocusedDateTime(DateTime(2026, 3, 1, 0, 0), isAllDay: false);
      await tester.pumpAndSettle();

      expect(capturedDateTime, isNotNull);
      expect(midnightCtrl.isFocusedOnAllDay, isFalse,
          reason:
              'Midnight time-slot focus must NOT set isFocusedOnAllDay');

      // Same midnight as all-day — must notify and set isFocusedOnAllDay
      midnightCtrl.setFocusedDateTime(DateTime(2026, 3, 1, 0, 0), isAllDay: true);
      await tester.pumpAndSettle();

      expect(midnightCtrl.isFocusedOnAllDay, isTrue,
          reason: 'Same midnight with isAllDay:true MUST set isFocusedOnAllDay');

      midnightCtrl.dispose();
    });

    testWidgets(
        'focus on a different date does not update slot index in current view',
        (tester) async {
      DateTime? capturedDateTime;

      await pumpDayView(
        tester,
        controller,
        onFocusedDateTimeChanged: (dt) => capturedDateTime = dt,
      );

      // Focus set on a DIFFERENT date than _displayDate (2026-03-01)
      controller.setFocusedDateTime(DateTime(2026, 3, 2, 9, 0));
      await tester.pumpAndSettle();

      // Callback fires (controller changed), but slot not mapped
      expect(capturedDateTime, isNotNull);
      expect(capturedDateTime!.day, 2,
          reason: 'Callback receives the full focusedDateTime regardless of display date');
    });
  });

  // ─── Keyboard write-back tests ───────────────────────────────────────────────

  group('keyboard writes to controller', () {
    late MCalEventController controller;

    setUp(() {
      controller = MCalEventController(initialDate: testDate);
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('A key sets isFocusedOnAllDay = true', (tester) async {
      await pumpDayView(tester, controller);

      // Tap to activate focus, press ↓ to enter time grid, then A to all-day
      await sendKey(tester, LogicalKeyboardKey.arrowDown);
      expect(controller.isFocusedOnAllDay, isFalse,
          reason: '↓ from all-day should move to time grid');

      await sendKeyOnly(tester, LogicalKeyboardKey.keyA);

      expect(controller.isFocusedOnAllDay, isTrue,
          reason: 'A key must jump to all-day section');
      expect(controller.focusedDateTime, isNotNull);
      expect(controller.focusedDateTime!.hour, 0);
      expect(controller.focusedDateTime!.minute, 0);
    });

    testWidgets('T key sets isFocusedOnAllDay = false', (tester) async {
      await pumpDayView(tester, controller);

      // Activate keyboard, ensure we're in all-day (initial state after first tap)
      await tester.tap(find.byType(MCalDayView));
      await tester.pumpAndSettle();
      // Press A to definitely land in all-day section
      await sendKeyOnly(tester, LogicalKeyboardKey.keyA);
      expect(controller.isFocusedOnAllDay, isTrue);

      // Now press T to jump to time grid
      await sendKeyOnly(tester, LogicalKeyboardKey.keyT);

      expect(controller.isFocusedOnAllDay, isFalse,
          reason: 'T key must jump to time grid (isFocusedOnAllDay = false)');
      expect(controller.focusedDateTime, isNotNull);
    });

    testWidgets('arrow down updates controller.focusedDateTime', (tester) async {
      await pumpDayView(tester, controller);

      // Tap to focus, press ↓ to enter time grid from all-day
      await sendKey(tester, LogicalKeyboardKey.arrowDown);
      expect(controller.focusedDateTime, isNotNull);
      expect(controller.isFocusedOnAllDay, isFalse);

      final firstSlotTime = controller.focusedDateTime!;

      // Press ↓ again to move to next slot
      await sendKeyOnly(tester, LogicalKeyboardKey.arrowDown);

      expect(controller.focusedDateTime, isNotNull);
      expect(controller.focusedDateTime, isNot(equals(firstSlotTime)),
          reason: '↓ should move to a different slot');
      expect(controller.isFocusedOnAllDay, isFalse);
    });

    testWidgets('arrow up from slot 0 sets isFocusedOnAllDay = true',
        (tester) async {
      await pumpDayView(tester, controller);

      // Enter time grid at slot 0
      await sendKey(tester, LogicalKeyboardKey.arrowDown);
      // Ensure we are at slot 0 (Home key)
      await sendKeyOnly(tester, LogicalKeyboardKey.home);
      expect(controller.isFocusedOnAllDay, isFalse);

      // Press ↑ from slot 0 — should go to all-day
      await sendKeyOnly(tester, LogicalKeyboardKey.arrowUp);

      expect(controller.isFocusedOnAllDay, isTrue,
          reason: '↑ from slot 0 must jump to all-day section');
    });

    testWidgets('Home key sets controller.focusedDateTime to startHour',
        (tester) async {
      await pumpDayView(tester, controller);

      // Enter time grid and go to end
      await sendKey(tester, LogicalKeyboardKey.arrowDown);
      await sendKeyOnly(tester, LogicalKeyboardKey.end);

      // Press Home
      await sendKeyOnly(tester, LogicalKeyboardKey.home);

      expect(controller.focusedDateTime, isNotNull);
      expect(controller.focusedDateTime!.hour, 6,
          reason: 'Home should focus startHour (6) first slot');
      expect(controller.isFocusedOnAllDay, isFalse);
    });
  });

  // ─── Left/right day navigation tests ────────────────────────────────────────

  group('left/right day navigation', () {
    late MCalEventController controller;

    setUp(() {
      controller = MCalEventController(initialDate: testDate);
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('left arrow in time grid navigates to previous day same slot',
        (tester) async {
      await pumpDayView(tester, controller);

      // Enter time grid: tap + ↓ to land in the first time slot
      await sendKey(tester, LogicalKeyboardKey.arrowDown);
      expect(controller.isFocusedOnAllDay, isFalse);

      final focusedTime = controller.focusedDateTime!;
      final expectedHour = focusedTime.hour;
      final expectedMinute = focusedTime.minute;

      // Navigate to previous day
      await sendKeyOnly(tester, LogicalKeyboardKey.arrowLeft);

      final expectedPrevDay = DateTime(testDate.year, testDate.month, testDate.day - 1);
      expect(
        controller.displayDate,
        equals(expectedPrevDay),
        reason: 'Left arrow should navigate to previous day',
      );
      expect(controller.focusedDateTime, isNotNull);
      expect(
        controller.focusedDateTime!.hour,
        expectedHour,
        reason: 'Hour must be preserved across day navigation',
      );
      expect(
        controller.focusedDateTime!.minute,
        expectedMinute,
        reason: 'Minute must be preserved across day navigation',
      );
      expect(controller.isFocusedOnAllDay, isFalse);
    });

    testWidgets('right arrow in time grid navigates to next day same slot',
        (tester) async {
      await pumpDayView(tester, controller);

      // Enter time grid: tap + ↓ to land in the first time slot
      await sendKey(tester, LogicalKeyboardKey.arrowDown);
      expect(controller.isFocusedOnAllDay, isFalse);

      final focusedTime = controller.focusedDateTime!;
      final expectedHour = focusedTime.hour;
      final expectedMinute = focusedTime.minute;

      // Navigate to next day
      await sendKeyOnly(tester, LogicalKeyboardKey.arrowRight);

      final expectedNextDay = DateTime(testDate.year, testDate.month, testDate.day + 1);
      expect(
        controller.displayDate,
        equals(expectedNextDay),
        reason: 'Right arrow should navigate to next day',
      );
      expect(controller.focusedDateTime, isNotNull);
      expect(
        controller.focusedDateTime!.hour,
        expectedHour,
        reason: 'Hour must be preserved across day navigation',
      );
      expect(
        controller.focusedDateTime!.minute,
        expectedMinute,
        reason: 'Minute must be preserved across day navigation',
      );
      expect(controller.isFocusedOnAllDay, isFalse);
    });

    testWidgets('left arrow in all-day section navigates to previous day all-day',
        (tester) async {
      await pumpDayView(tester, controller);

      // Activate keyboard nav then press A to land in all-day section
      await tester.tap(find.byType(MCalDayView));
      await tester.pumpAndSettle();
      await sendKeyOnly(tester, LogicalKeyboardKey.keyA);
      expect(controller.isFocusedOnAllDay, isTrue);

      // Navigate to previous day
      await sendKeyOnly(tester, LogicalKeyboardKey.arrowLeft);

      final expectedPrevDay = DateTime(testDate.year, testDate.month, testDate.day - 1);
      expect(
        controller.displayDate,
        equals(expectedPrevDay),
        reason: 'Left arrow should navigate to previous day',
      );
      expect(controller.isFocusedOnAllDay, isTrue,
          reason: 'All-day focus must be preserved after left navigation');
      expect(
        controller.focusedDateTime,
        equals(expectedPrevDay),
        reason: 'focusedDateTime date must match new display day',
      );
    });

    testWidgets('right arrow in all-day section navigates to next day all-day',
        (tester) async {
      await pumpDayView(tester, controller);

      // Activate keyboard nav then press A to land in all-day section
      await tester.tap(find.byType(MCalDayView));
      await tester.pumpAndSettle();
      await sendKeyOnly(tester, LogicalKeyboardKey.keyA);
      expect(controller.isFocusedOnAllDay, isTrue);

      // Navigate to next day
      await sendKeyOnly(tester, LogicalKeyboardKey.arrowRight);

      final expectedNextDay = DateTime(testDate.year, testDate.month, testDate.day + 1);
      expect(
        controller.displayDate,
        equals(expectedNextDay),
        reason: 'Right arrow should navigate to next day',
      );
      expect(controller.isFocusedOnAllDay, isTrue,
          reason: 'All-day focus must be preserved after right navigation');
      expect(
        controller.focusedDateTime,
        equals(expectedNextDay),
        reason: 'focusedDateTime date must match new display day',
      );
    });

    testWidgets('multiple right arrow presses navigate multiple days',
        (tester) async {
      await pumpDayView(tester, controller);

      // Enter time grid
      await sendKey(tester, LogicalKeyboardKey.arrowDown);
      expect(controller.isFocusedOnAllDay, isFalse);

      final focusedTime = controller.focusedDateTime!;

      // Navigate forward 3 days
      await sendKeyOnly(tester, LogicalKeyboardKey.arrowRight);
      await sendKeyOnly(tester, LogicalKeyboardKey.arrowRight);
      await sendKeyOnly(tester, LogicalKeyboardKey.arrowRight);

      final expectedDay3 = DateTime(testDate.year, testDate.month, testDate.day + 3);
      expect(
        controller.displayDate,
        equals(expectedDay3),
        reason: 'Three right presses should advance three days',
      );
      expect(
        controller.focusedDateTime!.hour,
        focusedTime.hour,
        reason: 'Hour must remain consistent after multiple navigations',
      );
      expect(
        controller.focusedDateTime!.minute,
        focusedTime.minute,
        reason: 'Minute must remain consistent after multiple navigations',
      );
    });

    testWidgets('left then right returns to original day and slot',
        (tester) async {
      await pumpDayView(tester, controller);

      // Enter time grid and move to a specific slot via End
      await sendKey(tester, LogicalKeyboardKey.arrowDown);
      await sendKeyOnly(tester, LogicalKeyboardKey.end);

      final originalFocusedTime = controller.focusedDateTime!;

      // Go back then forward — should return to same day and slot
      await sendKeyOnly(tester, LogicalKeyboardKey.arrowLeft);
      await sendKeyOnly(tester, LogicalKeyboardKey.arrowRight);

      expect(
        controller.displayDate,
        equals(testDate),
        reason: 'Left then right should return to original day',
      );
      expect(
        controller.focusedDateTime!.hour,
        originalFocusedTime.hour,
        reason: 'Slot (hour) should be restored',
      );
      expect(
        controller.focusedDateTime!.minute,
        originalFocusedTime.minute,
        reason: 'Slot (minute) should be restored',
      );
    });
  });
}
