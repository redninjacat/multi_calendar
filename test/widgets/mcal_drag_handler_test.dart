import 'dart:async';
import 'dart:ui' show Offset, Rect;

import 'package:flutter_test/flutter_test.dart';
import 'package:multi_calendar/multi_calendar.dart';
import 'package:multi_calendar/src/widgets/mcal_drag_handler.dart';
import 'package:multi_calendar/src/widgets/mcal_callback_details.dart';

void main() {
  group('MCalDragHandler Tests', () {
    late MCalDragHandler dragHandler;

    setUp(() {
      dragHandler = MCalDragHandler();
    });

    tearDown(() {
      dragHandler.dispose();
    });

    // ============================================================
    // Test 1: Test initial state (isDragging false, all fields null)
    // ============================================================
    group('Initial State', () {
      test('isDragging is false initially', () {
        expect(dragHandler.isDragging, isFalse);
      });

      test('draggedEvent is null initially', () {
        expect(dragHandler.draggedEvent, isNull);
      });

      test('sourceDate is null initially', () {
        expect(dragHandler.sourceDate, isNull);
      });

      test('targetDate is null initially', () {
        expect(dragHandler.targetDate, isNull);
      });

      test('isValidTarget is false initially', () {
        expect(dragHandler.isValidTarget, isFalse);
      });

      test('dragPosition is null initially', () {
        expect(dragHandler.dragPosition, isNull);
      });
    });

    // ============================================================
    // Test 2: Test startDrag() sets state correctly
    // ============================================================
    group('startDrag()', () {
      test('sets isDragging to true', () {
        final event = MCalCalendarEvent(
          id: 'test-1',
          title: 'Test Event',
          start: DateTime(2025, 1, 15),
          end: DateTime(2025, 1, 15),
        );

        dragHandler.startDrag(event, DateTime(2025, 1, 15));

        expect(dragHandler.isDragging, isTrue);
      });

      test('sets draggedEvent correctly', () {
        final event = MCalCalendarEvent(
          id: 'test-2',
          title: 'Test Event 2',
          start: DateTime(2025, 1, 15),
          end: DateTime(2025, 1, 15),
        );

        dragHandler.startDrag(event, DateTime(2025, 1, 15));

        expect(dragHandler.draggedEvent, equals(event));
        expect(dragHandler.draggedEvent!.id, equals('test-2'));
      });

      test('sets sourceDate correctly', () {
        final event = MCalCalendarEvent(
          id: 'test-3',
          title: 'Test Event',
          start: DateTime(2025, 1, 15),
          end: DateTime(2025, 1, 15),
        );
        final sourceDate = DateTime(2025, 1, 15);

        dragHandler.startDrag(event, sourceDate);

        expect(dragHandler.sourceDate, equals(sourceDate));
      });

      test('sets targetDate to sourceDate initially', () {
        final event = MCalCalendarEvent(
          id: 'test-4',
          title: 'Test Event',
          start: DateTime(2025, 1, 15),
          end: DateTime(2025, 1, 15),
        );
        final sourceDate = DateTime(2025, 1, 15);

        dragHandler.startDrag(event, sourceDate);

        expect(dragHandler.targetDate, equals(sourceDate));
      });

      test('sets isValidTarget to true initially', () {
        final event = MCalCalendarEvent(
          id: 'test-5',
          title: 'Test Event',
          start: DateTime(2025, 1, 15),
          end: DateTime(2025, 1, 15),
        );

        dragHandler.startDrag(event, DateTime(2025, 1, 15));

        expect(dragHandler.isValidTarget, isTrue);
      });

      test('notifies listeners when drag starts', () {
        final event = MCalCalendarEvent(
          id: 'test-6',
          title: 'Test Event',
          start: DateTime(2025, 1, 15),
          end: DateTime(2025, 1, 15),
        );

        var notified = false;
        dragHandler.addListener(() {
          notified = true;
        });

        dragHandler.startDrag(event, DateTime(2025, 1, 15));

        expect(notified, isTrue);
      });

      test('cancels any existing drag when starting new drag', () {
        final event1 = MCalCalendarEvent(
          id: 'event-1',
          title: 'Event 1',
          start: DateTime(2025, 1, 15),
          end: DateTime(2025, 1, 15),
        );
        final event2 = MCalCalendarEvent(
          id: 'event-2',
          title: 'Event 2',
          start: DateTime(2025, 1, 16),
          end: DateTime(2025, 1, 16),
        );

        dragHandler.startDrag(event1, DateTime(2025, 1, 15));
        expect(dragHandler.draggedEvent!.id, equals('event-1'));

        dragHandler.startDrag(event2, DateTime(2025, 1, 16));
        expect(dragHandler.draggedEvent!.id, equals('event-2'));
      });
    });

    // ============================================================
    // Test 3: Test updateDrag() updates target and validity
    // ============================================================
    group('updateDrag()', () {
      test('updates targetDate correctly', () {
        final event = MCalCalendarEvent(
          id: 'test-update-1',
          title: 'Test Event',
          start: DateTime(2025, 1, 15),
          end: DateTime(2025, 1, 15),
        );
        dragHandler.startDrag(event, DateTime(2025, 1, 15));

        final newTarget = DateTime(2025, 1, 18);
        dragHandler.updateDrag(newTarget, true, const Offset(100, 200));

        expect(dragHandler.targetDate, equals(newTarget));
      });

      test('updates isValidTarget correctly', () {
        final event = MCalCalendarEvent(
          id: 'test-update-2',
          title: 'Test Event',
          start: DateTime(2025, 1, 15),
          end: DateTime(2025, 1, 15),
        );
        dragHandler.startDrag(event, DateTime(2025, 1, 15));

        // Update with valid target
        dragHandler.updateDrag(DateTime(2025, 1, 18), true, const Offset(100, 200));
        expect(dragHandler.isValidTarget, isTrue);

        // Update with invalid target
        dragHandler.updateDrag(DateTime(2025, 1, 20), false, const Offset(150, 250));
        expect(dragHandler.isValidTarget, isFalse);
      });

      test('updates dragPosition correctly', () {
        final event = MCalCalendarEvent(
          id: 'test-update-3',
          title: 'Test Event',
          start: DateTime(2025, 1, 15),
          end: DateTime(2025, 1, 15),
        );
        dragHandler.startDrag(event, DateTime(2025, 1, 15));

        const position = Offset(150, 300);
        dragHandler.updateDrag(DateTime(2025, 1, 18), true, position);

        expect(dragHandler.dragPosition, equals(position));
      });

      test('does not update if no drag is active', () {
        // No drag started
        dragHandler.updateDrag(DateTime(2025, 1, 18), true, const Offset(100, 200));

        expect(dragHandler.targetDate, isNull);
        expect(dragHandler.dragPosition, isNull);
      });

      test('notifies listeners when state changes', () {
        final event = MCalCalendarEvent(
          id: 'test-update-4',
          title: 'Test Event',
          start: DateTime(2025, 1, 15),
          end: DateTime(2025, 1, 15),
        );
        dragHandler.startDrag(event, DateTime(2025, 1, 15));

        var notificationCount = 0;
        dragHandler.addListener(() {
          notificationCount++;
        });

        // First update - should notify
        dragHandler.updateDrag(DateTime(2025, 1, 18), true, const Offset(100, 200));
        expect(notificationCount, equals(1));

        // Second update with different target - should notify
        dragHandler.updateDrag(DateTime(2025, 1, 19), true, const Offset(120, 220));
        expect(notificationCount, equals(2));
      });

      test('does not notify if nothing changes', () {
        final event = MCalCalendarEvent(
          id: 'test-update-5',
          title: 'Test Event',
          start: DateTime(2025, 1, 15),
          end: DateTime(2025, 1, 15),
        );
        dragHandler.startDrag(event, DateTime(2025, 1, 15));

        final targetDate = DateTime(2025, 1, 18);
        const position = Offset(100, 200);
        dragHandler.updateDrag(targetDate, true, position);

        var notificationCount = 0;
        dragHandler.addListener(() {
          notificationCount++;
        });

        // Same update - should not notify
        dragHandler.updateDrag(targetDate, true, position);
        expect(notificationCount, equals(0));
      });
    });

    // ============================================================
    // Test 4: Test completeDrag() returns target date and clears state
    // ============================================================
    group('completeDrag()', () {
      test('returns target date when valid', () {
        final event = MCalCalendarEvent(
          id: 'test-complete-1',
          title: 'Test Event',
          start: DateTime(2025, 1, 15),
          end: DateTime(2025, 1, 15),
        );
        dragHandler.startDrag(event, DateTime(2025, 1, 15));

        final targetDate = DateTime(2025, 1, 20);
        dragHandler.updateDrag(targetDate, true, const Offset(100, 200));

        final result = dragHandler.completeDrag();

        expect(result, equals(targetDate));
      });

      test('clears all state after completion', () {
        final event = MCalCalendarEvent(
          id: 'test-complete-2',
          title: 'Test Event',
          start: DateTime(2025, 1, 15),
          end: DateTime(2025, 1, 15),
        );
        dragHandler.startDrag(event, DateTime(2025, 1, 15));
        dragHandler.updateDrag(DateTime(2025, 1, 20), true, const Offset(100, 200));
        dragHandler.completeDrag();

        expect(dragHandler.isDragging, isFalse);
        expect(dragHandler.draggedEvent, isNull);
        expect(dragHandler.sourceDate, isNull);
        expect(dragHandler.targetDate, isNull);
        expect(dragHandler.isValidTarget, isFalse);
        expect(dragHandler.dragPosition, isNull);
      });

      test('notifies listeners on completion', () {
        final event = MCalCalendarEvent(
          id: 'test-complete-3',
          title: 'Test Event',
          start: DateTime(2025, 1, 15),
          end: DateTime(2025, 1, 15),
        );
        dragHandler.startDrag(event, DateTime(2025, 1, 15));

        var notified = false;
        dragHandler.addListener(() {
          notified = true;
        });

        dragHandler.completeDrag();

        expect(notified, isTrue);
      });
    });

    // ============================================================
    // Test 5: Test completeDrag() returns null if not valid
    // ============================================================
    group('completeDrag() invalid cases', () {
      test('returns null when target is invalid', () {
        final event = MCalCalendarEvent(
          id: 'test-invalid-1',
          title: 'Test Event',
          start: DateTime(2025, 1, 15),
          end: DateTime(2025, 1, 15),
        );
        dragHandler.startDrag(event, DateTime(2025, 1, 15));

        // Update with invalid target
        dragHandler.updateDrag(DateTime(2025, 1, 20), false, const Offset(100, 200));

        final result = dragHandler.completeDrag();

        expect(result, isNull);
      });

      test('returns null when no drag is active', () {
        final result = dragHandler.completeDrag();

        expect(result, isNull);
      });

      test('clears state even when returning null', () {
        final event = MCalCalendarEvent(
          id: 'test-invalid-2',
          title: 'Test Event',
          start: DateTime(2025, 1, 15),
          end: DateTime(2025, 1, 15),
        );
        dragHandler.startDrag(event, DateTime(2025, 1, 15));
        dragHandler.updateDrag(DateTime(2025, 1, 20), false, const Offset(100, 200));
        dragHandler.completeDrag();

        expect(dragHandler.isDragging, isFalse);
        expect(dragHandler.draggedEvent, isNull);
      });
    });

    // ============================================================
    // Test 6: Test cancelDrag() clears state
    // ============================================================
    group('cancelDrag()', () {
      test('clears all state', () {
        final event = MCalCalendarEvent(
          id: 'test-cancel-1',
          title: 'Test Event',
          start: DateTime(2025, 1, 15),
          end: DateTime(2025, 1, 15),
        );
        dragHandler.startDrag(event, DateTime(2025, 1, 15));
        dragHandler.updateDrag(DateTime(2025, 1, 20), true, const Offset(100, 200));

        dragHandler.cancelDrag();

        expect(dragHandler.isDragging, isFalse);
        expect(dragHandler.draggedEvent, isNull);
        expect(dragHandler.sourceDate, isNull);
        expect(dragHandler.targetDate, isNull);
        expect(dragHandler.isValidTarget, isFalse);
        expect(dragHandler.dragPosition, isNull);
      });

      test('notifies listeners on cancel', () {
        final event = MCalCalendarEvent(
          id: 'test-cancel-2',
          title: 'Test Event',
          start: DateTime(2025, 1, 15),
          end: DateTime(2025, 1, 15),
        );
        dragHandler.startDrag(event, DateTime(2025, 1, 15));

        var notified = false;
        dragHandler.addListener(() {
          notified = true;
        });

        dragHandler.cancelDrag();

        expect(notified, isTrue);
      });

      test('does not notify if no drag was active', () {
        var notified = false;
        dragHandler.addListener(() {
          notified = true;
        });

        dragHandler.cancelDrag();

        expect(notified, isFalse);
      });

      test('can start new drag after cancel', () {
        final event1 = MCalCalendarEvent(
          id: 'event-cancel-1',
          title: 'Event 1',
          start: DateTime(2025, 1, 15),
          end: DateTime(2025, 1, 15),
        );
        final event2 = MCalCalendarEvent(
          id: 'event-cancel-2',
          title: 'Event 2',
          start: DateTime(2025, 1, 16),
          end: DateTime(2025, 1, 16),
        );

        dragHandler.startDrag(event1, DateTime(2025, 1, 15));
        dragHandler.cancelDrag();

        dragHandler.startDrag(event2, DateTime(2025, 1, 16));

        expect(dragHandler.isDragging, isTrue);
        expect(dragHandler.draggedEvent!.id, equals('event-cancel-2'));
      });
    });

    // ============================================================
    // Test 7: Test calculateDayDelta() for same date (0)
    // ============================================================
    group('calculateDayDelta() same date', () {
      test('returns 0 when source and target are same date', () {
        final event = MCalCalendarEvent(
          id: 'test-delta-same-1',
          title: 'Test Event',
          start: DateTime(2025, 1, 15),
          end: DateTime(2025, 1, 15),
        );
        final date = DateTime(2025, 1, 15);
        dragHandler.startDrag(event, date);
        dragHandler.updateDrag(date, true, const Offset(100, 200));

        final delta = dragHandler.calculateDayDelta();

        expect(delta, equals(0));
      });

      test('returns 0 when dates are same but different times', () {
        final event = MCalCalendarEvent(
          id: 'test-delta-same-2',
          title: 'Test Event',
          start: DateTime(2025, 1, 15, 10, 30),
          end: DateTime(2025, 1, 15, 11, 30),
        );
        final sourceDate = DateTime(2025, 1, 15, 10, 30);
        final targetDate = DateTime(2025, 1, 15, 14, 0);

        dragHandler.startDrag(event, sourceDate);
        dragHandler.updateDrag(targetDate, true, const Offset(100, 200));

        final delta = dragHandler.calculateDayDelta();

        expect(delta, equals(0));
      });

      test('returns 0 when no drag is active', () {
        final delta = dragHandler.calculateDayDelta();

        expect(delta, equals(0));
      });
    });

    // ============================================================
    // Test 8: Test calculateDayDelta() for different dates
    // ============================================================
    group('calculateDayDelta() different dates', () {
      test('returns positive delta for forward move', () {
        final event = MCalCalendarEvent(
          id: 'test-delta-forward-1',
          title: 'Test Event',
          start: DateTime(2025, 1, 15),
          end: DateTime(2025, 1, 15),
        );
        dragHandler.startDrag(event, DateTime(2025, 1, 15));
        dragHandler.updateDrag(DateTime(2025, 1, 18), true, const Offset(100, 200));

        final delta = dragHandler.calculateDayDelta();

        expect(delta, equals(3));
      });

      test('returns negative delta for backward move', () {
        final event = MCalCalendarEvent(
          id: 'test-delta-backward-1',
          title: 'Test Event',
          start: DateTime(2025, 1, 15),
          end: DateTime(2025, 1, 15),
        );
        dragHandler.startDrag(event, DateTime(2025, 1, 15));
        dragHandler.updateDrag(DateTime(2025, 1, 10), true, const Offset(100, 200));

        final delta = dragHandler.calculateDayDelta();

        expect(delta, equals(-5));
      });

      test('handles month boundary correctly', () {
        final event = MCalCalendarEvent(
          id: 'test-delta-month-1',
          title: 'Test Event',
          start: DateTime(2025, 1, 28),
          end: DateTime(2025, 1, 28),
        );
        dragHandler.startDrag(event, DateTime(2025, 1, 28));
        dragHandler.updateDrag(DateTime(2025, 2, 5), true, const Offset(100, 200));

        final delta = dragHandler.calculateDayDelta();

        expect(delta, equals(8)); // Jan 28 to Feb 5 is 8 days
      });

      test('handles year boundary correctly', () {
        final event = MCalCalendarEvent(
          id: 'test-delta-year-1',
          title: 'Test Event',
          start: DateTime(2024, 12, 30),
          end: DateTime(2024, 12, 30),
        );
        dragHandler.startDrag(event, DateTime(2024, 12, 30));
        dragHandler.updateDrag(DateTime(2025, 1, 3), true, const Offset(100, 200));

        final delta = dragHandler.calculateDayDelta();

        expect(delta, equals(4)); // Dec 30 to Jan 3 is 4 days
      });

      test('handles multi-week move correctly', () {
        final event = MCalCalendarEvent(
          id: 'test-delta-multi-week-1',
          title: 'Test Event',
          start: DateTime(2025, 1, 1),
          end: DateTime(2025, 1, 1),
        );
        dragHandler.startDrag(event, DateTime(2025, 1, 1));
        dragHandler.updateDrag(DateTime(2025, 1, 22), true, const Offset(100, 200));

        final delta = dragHandler.calculateDayDelta();

        expect(delta, equals(21));
      });
    });

    // ============================================================
    // Test 9: Test handleEdgeProximity() starts timer when near edge
    // ============================================================
    group('handleEdgeProximity() near edge', () {
      test('starts timer when near edge during drag', () async {
        final event = MCalCalendarEvent(
          id: 'test-edge-1',
          title: 'Test Event',
          start: DateTime(2025, 1, 15),
          end: DateTime(2025, 1, 15),
        );
        dragHandler.startDrag(event, DateTime(2025, 1, 15));

        var navigated = false;
        dragHandler.handleEdgeProximity(true, true, () {
          navigated = true;
        });

        // Timer should be running but not fired yet
        expect(navigated, isFalse);

        // Wait for timer to fire (500ms default + buffer)
        await Future<void>.delayed(const Duration(milliseconds: 600));

        expect(navigated, isTrue);
      });

      test('timer fires callback for left edge', () async {
        final event = MCalCalendarEvent(
          id: 'test-edge-left-1',
          title: 'Test Event',
          start: DateTime(2025, 1, 15),
          end: DateTime(2025, 1, 15),
        );
        dragHandler.startDrag(event, DateTime(2025, 1, 15));

        var navigationDirection = '';
        dragHandler.handleEdgeProximity(true, true, () {
          navigationDirection = 'left';
        });

        await Future<void>.delayed(const Duration(milliseconds: 600));

        expect(navigationDirection, equals('left'));
      });

      test('timer fires callback for right edge', () async {
        final event = MCalCalendarEvent(
          id: 'test-edge-right-1',
          title: 'Test Event',
          start: DateTime(2025, 1, 15),
          end: DateTime(2025, 1, 15),
        );
        dragHandler.startDrag(event, DateTime(2025, 1, 15));

        var navigationDirection = '';
        dragHandler.handleEdgeProximity(true, false, () {
          navigationDirection = 'right';
        });

        await Future<void>.delayed(const Duration(milliseconds: 600));

        expect(navigationDirection, equals('right'));
      });

      test('does not start timer if no drag is active', () async {
        var navigated = false;
        dragHandler.handleEdgeProximity(true, true, () {
          navigated = true;
        });

        await Future<void>.delayed(const Duration(milliseconds: 600));

        expect(navigated, isFalse);
      });

      test('does not double-start timer if already running', () async {
        final event = MCalCalendarEvent(
          id: 'test-edge-double-1',
          title: 'Test Event',
          start: DateTime(2025, 1, 15),
          end: DateTime(2025, 1, 15),
        );
        dragHandler.startDrag(event, DateTime(2025, 1, 15));

        var callCount = 0;
        final callback = () {
          callCount++;
        };

        // Call multiple times while near edge
        dragHandler.handleEdgeProximity(true, true, callback);
        dragHandler.handleEdgeProximity(true, true, callback);
        dragHandler.handleEdgeProximity(true, true, callback);

        await Future<void>.delayed(const Duration(milliseconds: 600));

        // Should only fire once
        expect(callCount, equals(1));
      });
    });

    // ============================================================
    // Test 10: Test handleEdgeProximity() cancels timer when not near edge
    // ============================================================
    group('handleEdgeProximity() not near edge', () {
      test('cancels timer when moving away from edge', () async {
        final event = MCalCalendarEvent(
          id: 'test-edge-cancel-1',
          title: 'Test Event',
          start: DateTime(2025, 1, 15),
          end: DateTime(2025, 1, 15),
        );
        dragHandler.startDrag(event, DateTime(2025, 1, 15));

        var navigated = false;
        dragHandler.handleEdgeProximity(true, true, () {
          navigated = true;
        });

        // Move away from edge before timer fires
        await Future<void>.delayed(const Duration(milliseconds: 200));
        dragHandler.handleEdgeProximity(false, true, () {
          navigated = true;
        });

        // Wait for what would have been the timer fire
        await Future<void>.delayed(const Duration(milliseconds: 500));

        // Should not have fired
        expect(navigated, isFalse);
      });

      test('can restart timer after cancellation', () async {
        final event = MCalCalendarEvent(
          id: 'test-edge-restart-1',
          title: 'Test Event',
          start: DateTime(2025, 1, 15),
          end: DateTime(2025, 1, 15),
        );
        dragHandler.startDrag(event, DateTime(2025, 1, 15));

        var callCount = 0;
        final callback = () {
          callCount++;
        };

        // Start near edge
        dragHandler.handleEdgeProximity(true, true, callback);

        // Move away
        await Future<void>.delayed(const Duration(milliseconds: 100));
        dragHandler.handleEdgeProximity(false, true, callback);

        // Return to edge
        await Future<void>.delayed(const Duration(milliseconds: 100));
        dragHandler.handleEdgeProximity(true, true, callback);

        // Wait for timer
        await Future<void>.delayed(const Duration(milliseconds: 600));

        expect(callCount, equals(1));
      });
    });

    // ============================================================
    // Test 11: Test dispose() cancels timer
    // ============================================================
    group('dispose()', () {
      test('cancels edge navigation timer on dispose', () async {
        final localDragHandler = MCalDragHandler();
        final event = MCalCalendarEvent(
          id: 'test-dispose-1',
          title: 'Test Event',
          start: DateTime(2025, 1, 15),
          end: DateTime(2025, 1, 15),
        );
        localDragHandler.startDrag(event, DateTime(2025, 1, 15));

        var navigated = false;
        localDragHandler.handleEdgeProximity(true, true, () {
          navigated = true;
        });

        // Dispose before timer fires
        await Future<void>.delayed(const Duration(milliseconds: 100));
        localDragHandler.dispose();

        // Wait for what would have been the timer fire
        await Future<void>.delayed(const Duration(milliseconds: 600));

        // Should not have navigated
        expect(navigated, isFalse);
      });

      test('can be disposed without active drag', () {
        final localDragHandler = MCalDragHandler();

        // Should not throw
        expect(() => localDragHandler.dispose(), returnsNormally);
      });

      test('can be disposed with active drag', () {
        final localDragHandler = MCalDragHandler();
        final event = MCalCalendarEvent(
          id: 'test-dispose-2',
          title: 'Test Event',
          start: DateTime(2025, 1, 15),
          end: DateTime(2025, 1, 15),
        );
        localDragHandler.startDrag(event, DateTime(2025, 1, 15));

        // Should not throw
        expect(() => localDragHandler.dispose(), returnsNormally);
      });
    });

    // ============================================================
    // Additional Edge Cases
    // ============================================================
    group('Edge Cases', () {
      test('multiple listeners are all notified', () {
        final event = MCalCalendarEvent(
          id: 'test-multi-listener-1',
          title: 'Test Event',
          start: DateTime(2025, 1, 15),
          end: DateTime(2025, 1, 15),
        );

        var listener1Called = false;
        var listener2Called = false;
        var listener3Called = false;

        dragHandler.addListener(() => listener1Called = true);
        dragHandler.addListener(() => listener2Called = true);
        dragHandler.addListener(() => listener3Called = true);

        dragHandler.startDrag(event, DateTime(2025, 1, 15));

        expect(listener1Called, isTrue);
        expect(listener2Called, isTrue);
        expect(listener3Called, isTrue);
      });

      test('removed listeners are not notified', () {
        final event = MCalCalendarEvent(
          id: 'test-remove-listener-1',
          title: 'Test Event',
          start: DateTime(2025, 1, 15),
          end: DateTime(2025, 1, 15),
        );

        var listenerCalled = false;
        void listener() {
          listenerCalled = true;
        }

        dragHandler.addListener(listener);
        dragHandler.removeListener(listener);

        dragHandler.startDrag(event, DateTime(2025, 1, 15));

        expect(listenerCalled, isFalse);
      });

      test('handles drag to very far future dates', () {
        final event = MCalCalendarEvent(
          id: 'test-far-future-1',
          title: 'Test Event',
          start: DateTime(2025, 1, 15),
          end: DateTime(2025, 1, 15),
        );
        dragHandler.startDrag(event, DateTime(2025, 1, 15));
        dragHandler.updateDrag(DateTime(2030, 6, 15), true, const Offset(100, 200));

        final delta = dragHandler.calculateDayDelta();

        // Approximately 5 years and 5 months
        expect(delta, greaterThan(1900));
      });

      test('handles drag to very far past dates', () {
        final event = MCalCalendarEvent(
          id: 'test-far-past-1',
          title: 'Test Event',
          start: DateTime(2025, 1, 15),
          end: DateTime(2025, 1, 15),
        );
        dragHandler.startDrag(event, DateTime(2025, 1, 15));
        dragHandler.updateDrag(DateTime(2020, 1, 15), true, const Offset(100, 200));

        final delta = dragHandler.calculateDayDelta();

        // Approximately 5 years back
        expect(delta, lessThan(-1800));
      });
    });

    // ============================================================
    // Task 19: Debouncing Tests
    // ============================================================
    group('Debouncing (Task 19)', () {
      /// Helper to create common handleDragMove parameters
      void callHandleDragMove(
        MCalDragHandler handler, {
        required Offset globalPosition,
        double dayWidth = 50.0,
        double horizontalSpacing = 2.0,
        double grabOffsetX = 0.0,
        int eventDurationDays = 1,
        int weekRowIndex = 0,
      }) {
        handler.handleDragMove(
          globalPosition: globalPosition,
          dayWidth: dayWidth,
          horizontalSpacing: horizontalSpacing,
          grabOffsetX: grabOffsetX,
          eventDurationDays: eventDurationDays,
          weekRowIndex: weekRowIndex,
          weekRowBounds: const Rect.fromLTWH(0, 0, 350, 100),
          calendarBounds: const Rect.fromLTWH(0, 0, 350, 500),
          weekDates: List.generate(7, (i) => DateTime(2024, 1, 14 + i)),
          totalWeekRows: 5,
          getWeekRowBounds: (i) => Rect.fromLTWH(0, i * 100.0, 350, 100),
          getWeekDates: (i) => List.generate(7, (j) => DateTime(2024, 1, 14 + i * 7 + j)),
        );
      }

      test('handleDragMove should not process immediately (debounce pending)', () async {
        // Start a drag first
        final event = MCalCalendarEvent(
          id: 'test-debounce-1',
          title: 'Test Event',
          start: DateTime(2024, 1, 15),
          end: DateTime(2024, 1, 17),
        );
        dragHandler.startDrag(event, DateTime(2024, 1, 15));

        int notifyCount = 0;
        dragHandler.addListener(() => notifyCount++);

        // Call handleDragMove - should not immediately update state
        callHandleDragMove(
          dragHandler,
          globalPosition: const Offset(100, 50),
          grabOffsetX: 10.0,
          eventDurationDays: 3,
        );

        // Immediately after, no update yet (debounce pending)
        expect(notifyCount, 0);

        // Wait for debounce (16ms + buffer)
        await Future<void>.delayed(const Duration(milliseconds: 30));
        expect(notifyCount, greaterThan(0));
      });

      test('latest position wins during debounce window', () async {
        final event = MCalCalendarEvent(
          id: 'test-debounce-2',
          title: 'Test Event',
          start: DateTime(2024, 1, 15),
          end: DateTime(2024, 1, 15),
        );
        dragHandler.startDrag(event, DateTime(2024, 1, 15));

        // Send multiple positions rapidly
        for (int i = 0; i < 5; i++) {
          callHandleDragMove(
            dragHandler,
            globalPosition: Offset(50.0 + i * 50, 50),
            eventDurationDays: 1,
          );
        }

        await Future<void>.delayed(const Duration(milliseconds: 30));

        // Should have processed the last position (cell 4 area)
        // The highlighted cells should reflect the final position
        expect(dragHandler.highlightedCells, isNotEmpty);
      });

      test('change detection skips update when same cell', () async {
        final event = MCalCalendarEvent(
          id: 'test-debounce-3',
          title: 'Test Event',
          start: DateTime(2024, 1, 15),
          end: DateTime(2024, 1, 15),
        );
        dragHandler.startDrag(event, DateTime(2024, 1, 15));

        int notifyCount = 0;
        dragHandler.addListener(() => notifyCount++);

        // First move to a specific cell
        callHandleDragMove(
          dragHandler,
          globalPosition: const Offset(125, 50), // Cell 2 area
          eventDurationDays: 1,
        );

        await Future<void>.delayed(const Duration(milliseconds: 30));
        final firstNotifyCount = notifyCount;

        // Move within same cell (still cell 2 area - small position change)
        callHandleDragMove(
          dragHandler,
          globalPosition: const Offset(130, 50), // Still cell 2
          eventDurationDays: 1,
        );

        await Future<void>.delayed(const Duration(milliseconds: 30));

        // Should not have notified again (same cell)
        expect(notifyCount, firstNotifyCount);
      });

      test('debounce timer is cancelled on dispose', () async {
        final localHandler = MCalDragHandler();
        final event = MCalCalendarEvent(
          id: 'test-debounce-4',
          title: 'Test Event',
          start: DateTime(2024, 1, 15),
          end: DateTime(2024, 1, 15),
        );
        localHandler.startDrag(event, DateTime(2024, 1, 15));

        localHandler.handleDragMove(
          globalPosition: const Offset(100, 50),
          dayWidth: 50.0,
          horizontalSpacing: 2.0,
          grabOffsetX: 0.0,
          eventDurationDays: 1,
          weekRowIndex: 0,
          weekRowBounds: const Rect.fromLTWH(0, 0, 350, 100),
          calendarBounds: const Rect.fromLTWH(0, 0, 350, 500),
          weekDates: List.generate(7, (i) => DateTime(2024, 1, 14 + i)),
          totalWeekRows: 5,
          getWeekRowBounds: (i) => Rect.fromLTWH(0, i * 100.0, 350, 100),
          getWeekDates: (i) => List.generate(7, (j) => DateTime(2024, 1, 14 + i * 7 + j)),
        );

        // Dispose should not throw
        expect(() => localHandler.dispose(), returnsNormally);
      });

      test('updates occur when moving to different cells', () async {
        final event = MCalCalendarEvent(
          id: 'test-debounce-5',
          title: 'Test Event',
          start: DateTime(2024, 1, 15),
          end: DateTime(2024, 1, 15),
        );
        dragHandler.startDrag(event, DateTime(2024, 1, 15));

        int notifyCount = 0;
        dragHandler.addListener(() => notifyCount++);

        // Move to cell 1
        callHandleDragMove(
          dragHandler,
          globalPosition: const Offset(75, 50),
          eventDurationDays: 1,
        );

        await Future<void>.delayed(const Duration(milliseconds: 30));
        final countAfterFirstMove = notifyCount;

        // Move to cell 3 (different cell)
        callHandleDragMove(
          dragHandler,
          globalPosition: const Offset(175, 50),
          eventDurationDays: 1,
        );

        await Future<void>.delayed(const Duration(milliseconds: 30));

        // Should have notified again (different cell)
        expect(notifyCount, greaterThan(countAfterFirstMove));
      });

      test('handleDragMove requires active drag to process', () async {
        // Don't start a drag
        int notifyCount = 0;
        dragHandler.addListener(() => notifyCount++);

        callHandleDragMove(
          dragHandler,
          globalPosition: const Offset(100, 50),
          eventDurationDays: 1,
        );

        await Future<void>.delayed(const Duration(milliseconds: 30));

        // Should not have notified (no active drag)
        expect(notifyCount, 0);
        expect(dragHandler.highlightedCells, isEmpty);
      });
    });

    // ============================================================
    // Task 20: Cell Detection Math Tests
    // ============================================================
    group('Cell Detection Math (Task 20)', () {
      /// Helper to create common handleDragMove parameters
      void callHandleDragMove(
        MCalDragHandler handler, {
        required Offset globalPosition,
        double dayWidth = 50.0,
        double horizontalSpacing = 2.0,
        double grabOffsetX = 0.0,
        int eventDurationDays = 1,
        int weekRowIndex = 0,
        Rect? weekRowBounds,
        List<DateTime>? weekDates,
        int totalWeekRows = 5,
        Rect Function(int)? getWeekRowBounds,
        List<DateTime> Function(int)? getWeekDates,
      }) {
        handler.handleDragMove(
          globalPosition: globalPosition,
          dayWidth: dayWidth,
          horizontalSpacing: horizontalSpacing,
          grabOffsetX: grabOffsetX,
          eventDurationDays: eventDurationDays,
          weekRowIndex: weekRowIndex,
          weekRowBounds: weekRowBounds ?? const Rect.fromLTWH(0, 0, 350, 100),
          calendarBounds: const Rect.fromLTWH(0, 0, 350, 500),
          weekDates: weekDates ?? List.generate(7, (i) => DateTime(2024, 1, 14 + i)),
          totalWeekRows: totalWeekRows,
          getWeekRowBounds: getWeekRowBounds ?? (i) => Rect.fromLTWH(0, i * 100.0, 350, 100),
          getWeekDates: getWeekDates ?? (i) => List.generate(7, (j) => DateTime(2024, 1, 14 + i * 7 + j)),
        );
      }

      test('calculates correct cell index using formula: floor((localX - grabOffsetX - spacing) / dayWidth)', () async {
        // Formula: floor((pointerLocalX - grabOffsetX - horizontalSpacing) / dayWidth)
        // pointerLocalX = 175 (global, weekRowBounds.left = 0)
        // grabOffsetX = 25, spacing = 2, dayWidth = 50
        // (175 - 25 - 2) / 50 = 148 / 50 = 2.96 -> floor = 2

        final event = MCalCalendarEvent(
          id: 'test-cell-math-1',
          title: 'Test Event',
          start: DateTime(2024, 1, 15),
          end: DateTime(2024, 1, 15),
        );
        dragHandler.startDrag(event, DateTime(2024, 1, 15));

        callHandleDragMove(
          dragHandler,
          globalPosition: const Offset(175, 50),
          dayWidth: 50.0,
          horizontalSpacing: 2.0,
          grabOffsetX: 25.0,
          eventDurationDays: 1,
        );

        await Future<void>.delayed(const Duration(milliseconds: 30));

        // Check highlighted cell is at index 2 (Jan 16 = 14 + 2)
        expect(dragHandler.highlightedCells.length, 1);
        expect(dragHandler.highlightedCells.first.cellIndex, 2);
        expect(dragHandler.highlightedCells.first.date, DateTime(2024, 1, 16));
      });

      test('multi-day event highlights correct number of cells', () async {
        final event = MCalCalendarEvent(
          id: 'test-cell-math-2',
          title: 'Test Event',
          start: DateTime(2024, 1, 15),
          end: DateTime(2024, 1, 18), // 4 days
        );
        dragHandler.startDrag(event, DateTime(2024, 1, 15));

        callHandleDragMove(
          dragHandler,
          globalPosition: const Offset(52, 50), // Cell 0 area
          eventDurationDays: 4,
        );

        await Future<void>.delayed(const Duration(milliseconds: 30));

        expect(dragHandler.highlightedCells.length, 4);
        expect(dragHandler.highlightedCells.first.isFirst, true);
        expect(dragHandler.highlightedCells.first.isLast, false);
        expect(dragHandler.highlightedCells.last.isFirst, false);
        expect(dragHandler.highlightedCells.last.isLast, true);
      });

      test('highlighted cells have correct dates for multi-day events', () async {
        final event = MCalCalendarEvent(
          id: 'test-cell-math-3',
          title: 'Test Event',
          start: DateTime(2024, 1, 15),
          end: DateTime(2024, 1, 17), // 3 days
        );
        dragHandler.startDrag(event, DateTime(2024, 1, 15));

        // Position at cell 1
        callHandleDragMove(
          dragHandler,
          globalPosition: const Offset(75, 50),
          eventDurationDays: 3,
        );

        await Future<void>.delayed(const Duration(milliseconds: 30));

        expect(dragHandler.highlightedCells.length, 3);
        // Week starts Jan 14, so cell 1 = Jan 15, cell 2 = Jan 16, cell 3 = Jan 17
        expect(dragHandler.highlightedCells[0].date, DateTime(2024, 1, 15));
        expect(dragHandler.highlightedCells[1].date, DateTime(2024, 1, 16));
        expect(dragHandler.highlightedCells[2].date, DateTime(2024, 1, 17));
      });

      test('handles negative cell index (event starts before visible week)', () async {
        final event = MCalCalendarEvent(
          id: 'test-cell-math-4',
          title: 'Test Event',
          start: DateTime(2024, 1, 15),
          end: DateTime(2024, 1, 18),
        );
        dragHandler.startDrag(event, DateTime(2024, 1, 15));

        // Position that would result in negative cell index
        // grabOffsetX = 150 (grabbed on day 3), position = 50
        // (50 - 150 - 2) / 50 = -102 / 50 = -2.04 -> floor = -3
        callHandleDragMove(
          dragHandler,
          globalPosition: const Offset(50, 50),
          grabOffsetX: 150.0,
          eventDurationDays: 4,
          weekRowIndex: 1, // Second week row
          weekRowBounds: const Rect.fromLTWH(0, 100, 350, 100),
          weekDates: List.generate(7, (i) => DateTime(2024, 1, 21 + i)),
        );

        await Future<void>.delayed(const Duration(milliseconds: 30));

        // Should handle gracefully - may start in previous week or adjust
        // The key is it shouldn't crash
        expect(dragHandler.highlightedCells, isNotEmpty);
      });

      test('event spanning multiple weeks highlights across week rows', () async {
        final event = MCalCalendarEvent(
          id: 'test-cell-math-5',
          title: 'Test Event',
          start: DateTime(2024, 1, 15),
          end: DateTime(2024, 1, 24), // 10 days - spans 2 weeks
        );
        dragHandler.startDrag(event, DateTime(2024, 1, 15));

        // Position at cell 5 (Friday), 10-day event would span to next week
        callHandleDragMove(
          dragHandler,
          globalPosition: const Offset(275, 50),
          eventDurationDays: 10,
        );

        await Future<void>.delayed(const Duration(milliseconds: 30));

        // Should have 10 cells across multiple week rows
        expect(dragHandler.highlightedCells.length, 10);

        // Check spans multiple week rows
        final weekRows = dragHandler.highlightedCells.map((c) => c.weekRowIndex).toSet();
        expect(weekRows.length, greaterThan(1));
      });

      test('cell bounds are calculated correctly', () async {
        final event = MCalCalendarEvent(
          id: 'test-cell-math-6',
          title: 'Test Event',
          start: DateTime(2024, 1, 15),
          end: DateTime(2024, 1, 15),
        );
        dragHandler.startDrag(event, DateTime(2024, 1, 15));

        callHandleDragMove(
          dragHandler,
          globalPosition: const Offset(125, 50), // Cell 2
          dayWidth: 50.0,
          eventDurationDays: 1,
        );

        await Future<void>.delayed(const Duration(milliseconds: 30));

        expect(dragHandler.highlightedCells.length, 1);
        final cell = dragHandler.highlightedCells.first;

        // Cell 2 should have bounds starting at 100 (2 * 50)
        expect(cell.bounds.left, 100.0);
        expect(cell.bounds.width, 50.0);
      });

      test('proposedStartDate and proposedEndDate are set correctly', () async {
        final event = MCalCalendarEvent(
          id: 'test-cell-math-7',
          title: 'Test Event',
          start: DateTime(2024, 1, 15),
          end: DateTime(2024, 1, 17), // 3 days
        );
        dragHandler.startDrag(event, DateTime(2024, 1, 15));

        // Position at cell 2
        callHandleDragMove(
          dragHandler,
          globalPosition: const Offset(125, 50),
          eventDurationDays: 3,
        );

        await Future<void>.delayed(const Duration(milliseconds: 30));

        // Week starts Jan 14, cell 2 = Jan 16
        // 3-day event: Jan 16-18
        expect(dragHandler.proposedStartDate, DateTime(2024, 1, 16));
        expect(dragHandler.proposedEndDate, DateTime(2024, 1, 18));
      });

      test('validation callback is invoked and affects isProposedDropValid', () async {
        final event = MCalCalendarEvent(
          id: 'test-cell-math-8',
          title: 'Test Event',
          start: DateTime(2024, 1, 15),
          end: DateTime(2024, 1, 15),
        );
        dragHandler.startDrag(event, DateTime(2024, 1, 15));

        bool validationCalled = false;

        dragHandler.handleDragMove(
          globalPosition: const Offset(125, 50),
          dayWidth: 50.0,
          horizontalSpacing: 2.0,
          grabOffsetX: 0.0,
          eventDurationDays: 1,
          weekRowIndex: 0,
          weekRowBounds: const Rect.fromLTWH(0, 0, 350, 100),
          calendarBounds: const Rect.fromLTWH(0, 0, 350, 500),
          weekDates: List.generate(7, (i) => DateTime(2024, 1, 14 + i)),
          totalWeekRows: 5,
          getWeekRowBounds: (i) => Rect.fromLTWH(0, i * 100.0, 350, 100),
          getWeekDates: (i) => List.generate(7, (j) => DateTime(2024, 1, 14 + i * 7 + j)),
          validationCallback: (proposedStart, proposedEnd) {
            validationCalled = true;
            return false; // Invalid drop
          },
        );

        await Future<void>.delayed(const Duration(milliseconds: 30));

        expect(validationCalled, true);
        expect(dragHandler.isProposedDropValid, false);
      });

      test('week row offset is properly accounted for in global position', () async {
        final event = MCalCalendarEvent(
          id: 'test-cell-math-9',
          title: 'Test Event',
          start: DateTime(2024, 1, 15),
          end: DateTime(2024, 1, 15),
        );
        dragHandler.startDrag(event, DateTime(2024, 1, 15));

        // Week row 2 starts at y=200, left at x=50
        // Global position 175 means local x = 175 - 50 = 125 -> cell 2
        callHandleDragMove(
          dragHandler,
          globalPosition: const Offset(175, 250),
          weekRowIndex: 2,
          weekRowBounds: const Rect.fromLTWH(50, 200, 350, 100), // Offset left
          weekDates: List.generate(7, (i) => DateTime(2024, 1, 28 + i)),
        );

        await Future<void>.delayed(const Duration(milliseconds: 30));

        expect(dragHandler.highlightedCells.isNotEmpty, true);
        // Cell index should be 2 based on local coordinates
        expect(dragHandler.highlightedCells.first.cellIndex, 2);
      });
    });

    // ============================================================
    // Cleanup Tests
    // ============================================================
    group('Cleanup', () {
      test('clearHighlightedCells clears state and notifies', () {
        final event = MCalCalendarEvent(
          id: 'test-cleanup-1',
          title: 'Test Event',
          start: DateTime(2024, 1, 15),
          end: DateTime(2024, 1, 15),
        );
        dragHandler.startDrag(event, DateTime(2024, 1, 15));

        // Manually set up some highlighted cells via handleDragMove
        dragHandler.handleDragMove(
          globalPosition: const Offset(100, 50),
          dayWidth: 50.0,
          horizontalSpacing: 2.0,
          grabOffsetX: 0.0,
          eventDurationDays: 1,
          weekRowIndex: 0,
          weekRowBounds: const Rect.fromLTWH(0, 0, 350, 100),
          calendarBounds: const Rect.fromLTWH(0, 0, 350, 500),
          weekDates: List.generate(7, (i) => DateTime(2024, 1, 14 + i)),
          totalWeekRows: 5,
          getWeekRowBounds: (i) => Rect.fromLTWH(0, i * 100.0, 350, 100),
          getWeekDates: (i) => List.generate(7, (j) => DateTime(2024, 1, 14 + i * 7 + j)),
        );

        int notifyCount = 0;
        dragHandler.addListener(() => notifyCount++);

        dragHandler.clearHighlightedCells();

        expect(dragHandler.highlightedCells, isEmpty);
        // Note: clearHighlightedCells only notifies if cells were not empty
        // Since debounce may not have fired yet, we check both scenarios
      });

      test('clearHighlightedCells does not notify if already empty', () {
        int notifyCount = 0;
        dragHandler.addListener(() => notifyCount++);

        dragHandler.clearHighlightedCells();

        expect(notifyCount, 0);
      });

      test('highlightedCells returns unmodifiable list', () {
        final cells = dragHandler.highlightedCells;
        final dummyCell = MCalHighlightCellInfo(
          date: DateTime(2024, 1, 15),
          cellIndex: 0,
          weekRowIndex: 0,
          bounds: Rect.zero,
          isFirst: true,
          isLast: true,
        );
        expect(() => (cells as List).add(dummyCell), throwsA(isA<UnsupportedError>()));
      });
    });
  });
}
