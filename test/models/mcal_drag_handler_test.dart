import 'dart:ui' show Offset, Rect;

import 'package:flutter_test/flutter_test.dart';
import 'package:multi_calendar/multi_calendar.dart';
import 'package:multi_calendar/src/widgets/mcal_drag_handler.dart';

/// Unit tests for MCalDragHandler and drag state management.
///
/// Phase 16 of day-view spec. Tests drag/resize state management,
/// validation logic, and listener notifications.
void main() {
  group('MCalDragHandler State Management', () {
    late MCalDragHandler handler;

    setUp(() {
      handler = MCalDragHandler();
    });

    tearDown(() {
      handler.dispose();
    });

    MCalCalendarEvent createEvent({
      String id = 'test-event',
      DateTime? start,
      DateTime? end,
    }) {
      return MCalCalendarEvent(
        id: id,
        title: 'Test Event',
        start: start ?? DateTime(2025, 1, 15),
        end: end ?? DateTime(2025, 1, 15),
      );
    }

    List<MCalHighlightCellInfo> buildCells(DateTime start, int count) {
      return List.generate(count, (i) {
        return MCalHighlightCellInfo(
          date: DateTime(start.year, start.month, start.day + i),
          cellIndex: i,
          weekRowIndex: 0,
          bounds: Rect.fromLTWH(i * 50.0, 0, 50, 100),
          isFirst: i == 0,
          isLast: i == count - 1,
        );
      });
    }

    // ============================================================
    // Start Drag: sets isDragging, draggedEvent
    // ============================================================
    group('Start Drag', () {
      test('sets isDragging to true', () {
        final event = createEvent();
        handler.startDrag(event, DateTime(2025, 1, 15));
        expect(handler.isDragging, isTrue);
      });

      test('sets draggedEvent correctly', () {
        final event = createEvent(id: 'drag-1');
        handler.startDrag(event, DateTime(2025, 1, 15));
        expect(handler.draggedEvent, equals(event));
        expect(handler.draggedEvent!.id, equals('drag-1'));
      });

      test('sets sourceDate and targetDate to source', () {
        final sourceDate = DateTime(2025, 1, 15);
        handler.startDrag(createEvent(), sourceDate);
        expect(handler.sourceDate, equals(sourceDate));
        expect(handler.targetDate, equals(sourceDate));
      });

      test('sets isValidTarget to true initially', () {
        handler.startDrag(createEvent(), DateTime(2025, 1, 15));
        expect(handler.isValidTarget, isTrue);
      });

      test('notifies listeners when drag starts', () {
        var notified = false;
        handler.addListener(() => notified = true);
        handler.startDrag(createEvent(), DateTime(2025, 1, 15));
        expect(notified, isTrue);
      });
    });

    // ============================================================
    // Update Proposed Range: updates proposedRange, notifies listeners
    // ============================================================
    group('Update Proposed Drop Range', () {
      test('updates proposedStartDate and proposedEndDate', () {
        handler.startDrag(createEvent(), DateTime(2025, 1, 15));
        final start = DateTime(2025, 1, 18);
        final end = DateTime(2025, 1, 20);

        handler.updateProposedDropRange(
          proposedStart: start,
          proposedEnd: end,
          isValid: true,
        );

        expect(handler.proposedStartDate, equals(start));
        expect(handler.proposedEndDate, equals(end));
      });

      test('updates isProposedDropValid', () {
        handler.startDrag(createEvent(), DateTime(2025, 1, 15));

        handler.updateProposedDropRange(
          proposedStart: DateTime(2025, 1, 18),
          proposedEnd: DateTime(2025, 1, 20),
          isValid: true,
        );
        expect(handler.isProposedDropValid, isTrue);

        handler.updateProposedDropRange(
          proposedStart: DateTime(2025, 1, 18),
          proposedEnd: DateTime(2025, 1, 20),
          isValid: false,
        );
        expect(handler.isProposedDropValid, isFalse);
      });

      test('notifies listeners when proposed range changes', () {
        handler.startDrag(createEvent(), DateTime(2025, 1, 15));
        var notifyCount = 0;
        handler.addListener(() => notifyCount++);

        handler.updateProposedDropRange(
          proposedStart: DateTime(2025, 1, 18),
          proposedEnd: DateTime(2025, 1, 20),
          isValid: true,
        );
        expect(notifyCount, equals(1));

        handler.updateProposedDropRange(
          proposedStart: DateTime(2025, 1, 19),
          proposedEnd: DateTime(2025, 1, 21),
          isValid: true,
        );
        expect(notifyCount, equals(2));
      });

      test('does not notify when values unchanged', () {
        handler.startDrag(createEvent(), DateTime(2025, 1, 15));
        final start = DateTime(2025, 1, 18);
        final end = DateTime(2025, 1, 20);
        handler.updateProposedDropRange(
          proposedStart: start,
          proposedEnd: end,
          isValid: true,
        );

        var notifyCount = 0;
        handler.addListener(() => notifyCount++);
        handler.updateProposedDropRange(
          proposedStart: start,
          proposedEnd: end,
          isValid: true,
        );
        expect(notifyCount, equals(0));
      });

      test('normalizes to date-only when preserveTime is false', () {
        handler.startDrag(createEvent(), DateTime(2025, 1, 15));
        final startWithTime = DateTime(2025, 1, 18, 10, 30);
        final endWithTime = DateTime(2025, 1, 20, 14, 45);

        handler.updateProposedDropRange(
          proposedStart: startWithTime,
          proposedEnd: endWithTime,
          isValid: true,
          preserveTime: false,
        );

        expect(handler.proposedStartDate, equals(DateTime(2025, 1, 18)));
        expect(handler.proposedEndDate, equals(DateTime(2025, 1, 20)));
      });
    });

    // ============================================================
    // Complete Drag: clears state, notifies
    // ============================================================
    group('Complete Drag', () {
      test('returns target date when valid', () {
        handler.startDrag(createEvent(), DateTime(2025, 1, 15));
        final targetDate = DateTime(2025, 1, 20);
        handler.updateDrag(targetDate, true, const Offset(100, 200));

        final result = handler.completeDrag();
        expect(result, equals(targetDate));
      });

      test('clears all state after completion', () {
        handler.startDrag(createEvent(), DateTime(2025, 1, 15));
        handler.updateDrag(DateTime(2025, 1, 20), true, const Offset(100, 200));
        handler.updateProposedDropRange(
          proposedStart: DateTime(2025, 1, 20),
          proposedEnd: DateTime(2025, 1, 20),
          isValid: true,
        );

        handler.completeDrag();

        expect(handler.isDragging, isFalse);
        expect(handler.draggedEvent, isNull);
        expect(handler.sourceDate, isNull);
        expect(handler.targetDate, isNull);
        expect(handler.isValidTarget, isFalse);
        expect(handler.dragPosition, isNull);
        expect(handler.proposedStartDate, isNull);
        expect(handler.proposedEndDate, isNull);
        expect(handler.isProposedDropValid, isFalse);
      });

      test('notifies listeners on completion', () {
        handler.startDrag(createEvent(), DateTime(2025, 1, 15));
        var notified = false;
        handler.addListener(() => notified = true);
        handler.completeDrag();
        expect(notified, isTrue);
      });

      test('returns null and clears state when target invalid', () {
        handler.startDrag(createEvent(), DateTime(2025, 1, 15));
        handler.updateDrag(DateTime(2025, 1, 20), false, const Offset(100, 200));

        final result = handler.completeDrag();
        expect(result, isNull);
        expect(handler.isDragging, isFalse);
        expect(handler.draggedEvent, isNull);
      });

      test('returns null when no drag active', () {
        final result = handler.completeDrag();
        expect(result, isNull);
      });
    });

    // ============================================================
    // Cancel Drag: clears state, notifies
    // ============================================================
    group('Cancel Drag', () {
      test('clears all state', () {
        handler.startDrag(createEvent(), DateTime(2025, 1, 15));
        handler.updateDrag(DateTime(2025, 1, 20), true, const Offset(100, 200));
        handler.updateProposedDropRange(
          proposedStart: DateTime(2025, 1, 20),
          proposedEnd: DateTime(2025, 1, 20),
          isValid: true,
        );

        handler.cancelDrag();

        expect(handler.isDragging, isFalse);
        expect(handler.draggedEvent, isNull);
        expect(handler.sourceDate, isNull);
        expect(handler.targetDate, isNull);
        expect(handler.proposedStartDate, isNull);
        expect(handler.proposedEndDate, isNull);
        expect(handler.isProposedDropValid, isFalse);
      });

      test('notifies listeners on cancel', () {
        handler.startDrag(createEvent(), DateTime(2025, 1, 15));
        var notified = false;
        handler.addListener(() => notified = true);
        handler.cancelDrag();
        expect(notified, isTrue);
      });

      test('does not notify when no drag was active', () {
        var notified = false;
        handler.addListener(() => notified = true);
        handler.cancelDrag();
        expect(notified, isFalse);
      });
    });

    // ============================================================
    // Start Resize: sets isResizing, resizeEdge (start/end)
    // ============================================================
    group('Start Resize', () {
      test('sets isResizing to true', () {
        handler.startResize(createEvent(), MCalResizeEdge.end);
        expect(handler.isResizing, isTrue);
      });

      test('sets resizingEvent correctly', () {
        final event = createEvent(id: 'resize-1');
        handler.startResize(event, MCalResizeEdge.end);
        expect(handler.resizingEvent, equals(event));
      });

      test('sets resizeEdge to end', () {
        handler.startResize(createEvent(), MCalResizeEdge.end);
        expect(handler.resizeEdge, equals(MCalResizeEdge.end));
      });

      test('sets resizeEdge to start', () {
        handler.startResize(createEvent(), MCalResizeEdge.start);
        expect(handler.resizeEdge, equals(MCalResizeEdge.start));
      });

      test('sets resizeOriginalStart and resizeOriginalEnd', () {
        final event = createEvent(
          start: DateTime(2025, 1, 15),
          end: DateTime(2025, 1, 17),
        );
        handler.startResize(event, MCalResizeEdge.end);
        expect(handler.resizeOriginalStart, equals(DateTime(2025, 1, 15)));
        expect(handler.resizeOriginalEnd, equals(DateTime(2025, 1, 17)));
      });

      test('does NOT notify listeners (deferred to updateResize)', () {
        var notifyCount = 0;
        handler.addListener(() => notifyCount++);
        handler.startResize(createEvent(), MCalResizeEdge.end);
        expect(notifyCount, equals(0));
      });
    });

    // ============================================================
    // Resize State Management
    // ============================================================
    group('Resize State Management', () {
      test('updateResize updates proposed range and cells', () {
        handler.startResize(
          createEvent(start: DateTime(2025, 1, 15), end: DateTime(2025, 1, 17)),
          MCalResizeEdge.end,
        );
        final proposedStart = DateTime(2025, 1, 15);
        final proposedEnd = DateTime(2025, 1, 20);
        final cells = buildCells(proposedStart, 6);

        handler.updateResize(
          proposedStart: proposedStart,
          proposedEnd: proposedEnd,
          isValid: true,
          cells: cells,
        );

        expect(handler.proposedStartDate, equals(proposedStart));
        expect(handler.proposedEndDate, equals(proposedEnd));
        expect(handler.highlightedCells.length, equals(6));
        expect(handler.isProposedDropValid, isTrue);
      });

      test('completeResize returns tuple when valid', () {
        handler.startResize(
          createEvent(start: DateTime(2025, 1, 15), end: DateTime(2025, 1, 17)),
          MCalResizeEdge.end,
        );
        final proposedStart = DateTime(2025, 1, 15);
        final proposedEnd = DateTime(2025, 1, 22);
        handler.updateResize(
          proposedStart: proposedStart,
          proposedEnd: proposedEnd,
          isValid: true,
          cells: buildCells(proposedStart, 8),
        );

        final result = handler.completeResize();
        expect(result, isNotNull);
        expect(result!.$1, equals(proposedStart));
        expect(result.$2, equals(proposedEnd));
      });

      test('completeResize clears state after valid completion', () {
        handler.startResize(createEvent(), MCalResizeEdge.end);
        handler.updateResize(
          proposedStart: DateTime(2025, 1, 15),
          proposedEnd: DateTime(2025, 1, 20),
          isValid: true,
          cells: buildCells(DateTime(2025, 1, 15), 6),
        );

        handler.completeResize();

        expect(handler.isResizing, isFalse);
        expect(handler.resizingEvent, isNull);
        expect(handler.resizeEdge, isNull);
        expect(handler.resizeOriginalStart, isNull);
        expect(handler.resizeOriginalEnd, isNull);
        expect(handler.proposedStartDate, isNull);
        expect(handler.proposedEndDate, isNull);
        expect(handler.highlightedCells, isEmpty);
      });

      test('cancelResize clears all resize state', () {
        handler.startResize(createEvent(), MCalResizeEdge.end);
        handler.updateResize(
          proposedStart: DateTime(2025, 1, 15),
          proposedEnd: DateTime(2025, 1, 20),
          isValid: true,
          cells: buildCells(DateTime(2025, 1, 15), 6),
        );

        handler.cancelResize();

        expect(handler.isResizing, isFalse);
        expect(handler.resizingEvent, isNull);
        expect(handler.resizeEdge, isNull);
        expect(handler.proposedStartDate, isNull);
        expect(handler.proposedEndDate, isNull);
      });
    });

    // ============================================================
    // Validation Logic (isProposedDropValid)
    // ============================================================
    group('Validation Logic (isProposedDropValid)', () {
      test('isProposedDropValid reflects updateProposedDropRange isValid', () {
        handler.startDrag(createEvent(), DateTime(2025, 1, 15));

        handler.updateProposedDropRange(
          proposedStart: DateTime(2025, 1, 18),
          proposedEnd: DateTime(2025, 1, 20),
          isValid: true,
        );
        expect(handler.isProposedDropValid, isTrue);

        handler.updateProposedDropRange(
          proposedStart: DateTime(2025, 1, 18),
          proposedEnd: DateTime(2025, 1, 20),
          isValid: false,
        );
        expect(handler.isProposedDropValid, isFalse);
      });

      test('isProposedDropValid reflects updateResize isValid', () {
        handler.startResize(createEvent(), MCalResizeEdge.end);

        handler.updateResize(
          proposedStart: DateTime(2025, 1, 15),
          proposedEnd: DateTime(2025, 1, 20),
          isValid: true,
          cells: buildCells(DateTime(2025, 1, 15), 6),
        );
        expect(handler.isProposedDropValid, isTrue);

        handler.updateResize(
          proposedStart: DateTime(2025, 1, 15),
          proposedEnd: DateTime(2025, 1, 25),
          isValid: false,
          cells: buildCells(DateTime(2025, 1, 15), 11),
        );
        expect(handler.isProposedDropValid, isFalse);
      });

      test('completeResize returns null when isProposedDropValid is false', () {
        handler.startResize(createEvent(), MCalResizeEdge.end);
        handler.updateResize(
          proposedStart: DateTime(2025, 1, 15),
          proposedEnd: DateTime(2025, 1, 20),
          isValid: false,
          cells: buildCells(DateTime(2025, 1, 15), 6),
        );

        final result = handler.completeResize();
        expect(result, isNull);
      });
    });

    // ============================================================
    // Listener Notifications
    // ============================================================
    group('Listener Notifications', () {
      test('multiple listeners all notified', () {
        var count1 = 0, count2 = 0, count3 = 0;
        handler.addListener(() => count1++);
        handler.addListener(() => count2++);
        handler.addListener(() => count3++);

        handler.startDrag(createEvent(), DateTime(2025, 1, 15));

        expect(count1, equals(1));
        expect(count2, equals(1));
        expect(count3, equals(1));
      });

      test('removed listeners not notified', () {
        var called = false;
        void listener() => called = true;
        handler.addListener(listener);
        handler.removeListener(listener);

        handler.startDrag(createEvent(), DateTime(2025, 1, 15));

        expect(called, isFalse);
      });

      test('updateDrag notifies when state changes', () {
        handler.startDrag(createEvent(), DateTime(2025, 1, 15));
        var notifyCount = 0;
        handler.addListener(() => notifyCount++);

        handler.updateDrag(
          DateTime(2025, 1, 18),
          true,
          const Offset(100, 200),
        );
        expect(notifyCount, equals(1));

        handler.updateDrag(
          DateTime(2025, 1, 19),
          false,
          const Offset(120, 220),
        );
        expect(notifyCount, equals(2));
      });
    });

    // ============================================================
    // State Cleared After Operations
    // ============================================================
    group('State Cleared After Operations', () {
      test('clearProposedDropRange clears proposed range', () {
        handler.startDrag(createEvent(), DateTime(2025, 1, 15));
        handler.updateProposedDropRange(
          proposedStart: DateTime(2025, 1, 18),
          proposedEnd: DateTime(2025, 1, 20),
          isValid: true,
        );

        handler.clearProposedDropRange();

        expect(handler.proposedStartDate, isNull);
        expect(handler.proposedEndDate, isNull);
        expect(handler.isProposedDropValid, isFalse);
        expect(handler.highlightedCells, isEmpty);
      });

      test('can start new drag after completeDrag', () {
        handler.startDrag(createEvent(id: 'event-1'), DateTime(2025, 1, 15));
        handler.completeDrag();

        handler.startDrag(createEvent(id: 'event-2'), DateTime(2025, 1, 16));
        expect(handler.isDragging, isTrue);
        expect(handler.draggedEvent!.id, equals('event-2'));
      });

      test('can start new resize after cancelResize', () {
        handler.startResize(createEvent(id: 'event-1'), MCalResizeEdge.end);
        handler.cancelResize();

        handler.startResize(createEvent(id: 'event-2'), MCalResizeEdge.start);
        expect(handler.isResizing, isTrue);
        expect(handler.resizingEvent!.id, equals('event-2'));
      });

      test('startDrag cancels active resize', () {
        handler.startResize(createEvent(), MCalResizeEdge.end);
        expect(handler.isResizing, isTrue);

        handler.startDrag(createEvent(), DateTime(2025, 1, 15));

        expect(handler.isDragging, isTrue);
        expect(handler.isResizing, isFalse);
      });
    });
  });
}
