import 'dart:async';
import 'dart:ui' show Offset;

import 'package:flutter_test/flutter_test.dart';
import 'package:multi_calendar/multi_calendar.dart';
import 'package:multi_calendar/src/widgets/mcal_drag_handler.dart';

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
  });
}
