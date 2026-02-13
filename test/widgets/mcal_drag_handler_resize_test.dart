import 'dart:ui' show Rect;

import 'package:flutter_test/flutter_test.dart';
import 'package:multi_calendar/multi_calendar.dart';
import 'package:multi_calendar/src/widgets/mcal_drag_handler.dart';

void main() {
  group('MCalDragHandler Resize State Machine', () {
    late MCalDragHandler handler;

    /// A multi-day event spanning Jan 15–17 2025.
    late MCalCalendarEvent multiDayEvent;

    /// A single-day event on Jan 20 2025.
    late MCalCalendarEvent singleDayEvent;

    setUp(() {
      handler = MCalDragHandler();
      multiDayEvent = MCalCalendarEvent(
        id: 'multi-day-1',
        title: 'Multi Day Event',
        start: DateTime(2025, 1, 15),
        end: DateTime(2025, 1, 17),
      );
      singleDayEvent = MCalCalendarEvent(
        id: 'single-day-1',
        title: 'Single Day Event',
        start: DateTime(2025, 1, 20),
        end: DateTime(2025, 1, 20),
      );
    });

    tearDown(() {
      handler.dispose();
    });

    // ============================================================
    // Helper: build a simple list of MCalHighlightCellInfo
    // ============================================================
    List<MCalHighlightCellInfo> buildCells(
      DateTime start,
      int count, {
      int startCellIndex = 0,
      int weekRowIndex = 0,
    }) {
      return List.generate(count, (i) {
        return MCalHighlightCellInfo(
          date: DateTime(start.year, start.month, start.day + i),
          cellIndex: startCellIndex + i,
          weekRowIndex: weekRowIndex,
          bounds: Rect.fromLTWH((startCellIndex + i) * 50.0, 0, 50, 100),
          isFirst: i == 0,
          isLast: i == count - 1,
        );
      });
    }

    // ============================================================
    // Group 1: startResize
    // ============================================================
    group('startResize', () {
      test('sets isResizing to true', () {
        handler.startResize(multiDayEvent, MCalResizeEdge.end);
        expect(handler.isResizing, isTrue);
      });

      test('sets resizingEvent to the provided event', () {
        handler.startResize(multiDayEvent, MCalResizeEdge.end);
        expect(handler.resizingEvent, equals(multiDayEvent));
        expect(handler.resizingEvent!.id, equals('multi-day-1'));
      });

      test('sets resizeEdge to MCalResizeEdge.end', () {
        handler.startResize(multiDayEvent, MCalResizeEdge.end);
        expect(handler.resizeEdge, equals(MCalResizeEdge.end));
      });

      test('sets resizeEdge to MCalResizeEdge.start', () {
        handler.startResize(multiDayEvent, MCalResizeEdge.start);
        expect(handler.resizeEdge, equals(MCalResizeEdge.start));
      });

      test('sets resizeOriginalStart to event.start', () {
        handler.startResize(multiDayEvent, MCalResizeEdge.end);
        expect(handler.resizeOriginalStart, equals(DateTime(2025, 1, 15)));
      });

      test('sets resizeOriginalEnd to event.end', () {
        handler.startResize(multiDayEvent, MCalResizeEdge.end);
        expect(handler.resizeOriginalEnd, equals(DateTime(2025, 1, 17)));
      });

      test('notifies listeners', () {
        var notifyCount = 0;
        handler.addListener(() => notifyCount++);

        handler.startResize(singleDayEvent, MCalResizeEdge.end);

        expect(notifyCount, equals(1));
      });
    });

    // ============================================================
    // Group 2: updateResize
    // ============================================================
    group('updateResize', () {
      test('updates proposedStartDate and proposedEndDate', () {
        handler.startResize(multiDayEvent, MCalResizeEdge.end);

        final proposedStart = DateTime(2025, 1, 15);
        final proposedEnd = DateTime(2025, 1, 19);
        final cells = buildCells(proposedStart, 5);

        handler.updateResize(
          proposedStart: proposedStart,
          proposedEnd: proposedEnd,
          isValid: true,
          cells: cells,
        );

        expect(handler.proposedStartDate, equals(proposedStart));
        expect(handler.proposedEndDate, equals(proposedEnd));
      });

      test('updates isProposedDropValid', () {
        handler.startResize(multiDayEvent, MCalResizeEdge.end);

        handler.updateResize(
          proposedStart: DateTime(2025, 1, 15),
          proposedEnd: DateTime(2025, 1, 19),
          isValid: true,
          cells: buildCells(DateTime(2025, 1, 15), 5),
        );
        expect(handler.isProposedDropValid, isTrue);

        handler.updateResize(
          proposedStart: DateTime(2025, 1, 15),
          proposedEnd: DateTime(2025, 1, 20),
          isValid: false,
          cells: buildCells(DateTime(2025, 1, 15), 6),
        );
        expect(handler.isProposedDropValid, isFalse);
      });

      test('updates highlightedCells', () {
        handler.startResize(multiDayEvent, MCalResizeEdge.end);

        final cells = buildCells(DateTime(2025, 1, 15), 4);
        handler.updateResize(
          proposedStart: DateTime(2025, 1, 15),
          proposedEnd: DateTime(2025, 1, 18),
          isValid: true,
          cells: cells,
        );

        expect(handler.highlightedCells.length, equals(4));
        expect(handler.highlightedCells.first.date, equals(DateTime(2025, 1, 15)));
        expect(handler.highlightedCells.last.date, equals(DateTime(2025, 1, 18)));
      });

      test('notifies listeners', () {
        handler.startResize(multiDayEvent, MCalResizeEdge.end);

        var notifyCount = 0;
        handler.addListener(() => notifyCount++);

        handler.updateResize(
          proposedStart: DateTime(2025, 1, 15),
          proposedEnd: DateTime(2025, 1, 19),
          isValid: true,
          cells: buildCells(DateTime(2025, 1, 15), 5),
        );

        expect(notifyCount, equals(1));
      });

      test('asserts when not resizing', () {
        expect(
          () => handler.updateResize(
            proposedStart: DateTime(2025, 1, 15),
            proposedEnd: DateTime(2025, 1, 19),
            isValid: true,
            cells: buildCells(DateTime(2025, 1, 15), 5),
          ),
          throwsA(isA<AssertionError>()),
        );
      });
    });

    // ============================================================
    // Group 3: completeResize
    // ============================================================
    group('completeResize', () {
      test('returns (start, end) tuple when valid', () {
        handler.startResize(multiDayEvent, MCalResizeEdge.end);

        final proposedStart = DateTime(2025, 1, 15);
        final proposedEnd = DateTime(2025, 1, 20);

        handler.updateResize(
          proposedStart: proposedStart,
          proposedEnd: proposedEnd,
          isValid: true,
          cells: buildCells(proposedStart, 6),
        );

        final result = handler.completeResize();

        expect(result, isNotNull);
        expect(result!.$1, equals(proposedStart));
        expect(result.$2, equals(proposedEnd));
      });

      test('clears all resize state after valid completion', () {
        handler.startResize(multiDayEvent, MCalResizeEdge.end);
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
        expect(handler.isProposedDropValid, isFalse);
        expect(handler.highlightedCells, isEmpty);
      });

      test('returns null when isProposedDropValid is false', () {
        handler.startResize(multiDayEvent, MCalResizeEdge.end);
        handler.updateResize(
          proposedStart: DateTime(2025, 1, 15),
          proposedEnd: DateTime(2025, 1, 20),
          isValid: false,
          cells: buildCells(DateTime(2025, 1, 15), 6),
        );

        final result = handler.completeResize();

        expect(result, isNull);
      });

      test('clears state when returning null (invalid)', () {
        handler.startResize(multiDayEvent, MCalResizeEdge.end);
        handler.updateResize(
          proposedStart: DateTime(2025, 1, 15),
          proposedEnd: DateTime(2025, 1, 20),
          isValid: false,
          cells: buildCells(DateTime(2025, 1, 15), 6),
        );

        handler.completeResize();

        expect(handler.isResizing, isFalse);
        expect(handler.resizingEvent, isNull);
        expect(handler.proposedStartDate, isNull);
        expect(handler.proposedEndDate, isNull);
        expect(handler.highlightedCells, isEmpty);
      });

      test('returns null when not resizing', () {
        final result = handler.completeResize();
        expect(result, isNull);
      });

      test('returns null when resizing started but no update called', () {
        handler.startResize(multiDayEvent, MCalResizeEdge.end);

        // No updateResize called, so isProposedDropValid is still false
        final result = handler.completeResize();

        expect(result, isNull);
      });
    });

    // ============================================================
    // Group 4: cancelResize
    // ============================================================
    group('cancelResize', () {
      test('clears all resize state', () {
        handler.startResize(multiDayEvent, MCalResizeEdge.end);
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
        expect(handler.resizeOriginalStart, isNull);
        expect(handler.resizeOriginalEnd, isNull);
      });

      test('clears shared fields (proposedStartDate, proposedEndDate, highlightedCells)', () {
        handler.startResize(multiDayEvent, MCalResizeEdge.start);
        handler.updateResize(
          proposedStart: DateTime(2025, 1, 13),
          proposedEnd: DateTime(2025, 1, 17),
          isValid: true,
          cells: buildCells(DateTime(2025, 1, 13), 5),
        );

        handler.cancelResize();

        expect(handler.proposedStartDate, isNull);
        expect(handler.proposedEndDate, isNull);
        expect(handler.isProposedDropValid, isFalse);
        expect(handler.highlightedCells, isEmpty);
      });

      test('notifies listeners', () {
        handler.startResize(multiDayEvent, MCalResizeEdge.end);

        var notifyCount = 0;
        handler.addListener(() => notifyCount++);

        handler.cancelResize();

        expect(notifyCount, equals(1));
      });

      test('can start new resize after cancel', () {
        handler.startResize(multiDayEvent, MCalResizeEdge.end);
        handler.cancelResize();

        handler.startResize(singleDayEvent, MCalResizeEdge.start);

        expect(handler.isResizing, isTrue);
        expect(handler.resizingEvent!.id, equals('single-day-1'));
        expect(handler.resizeEdge, equals(MCalResizeEdge.start));
      });
    });

    // ============================================================
    // Group 5: Mutual exclusivity
    // ============================================================
    group('Mutual exclusivity', () {
      test('startResize while isDragging throws assertion error', () {
        handler.startDrag(multiDayEvent, DateTime(2025, 1, 15));

        expect(handler.isDragging, isTrue);

        expect(
          () => handler.startResize(multiDayEvent, MCalResizeEdge.end),
          throwsA(isA<AssertionError>()),
        );
      });

      test('startDrag while isResizing throws assertion error', () {
        handler.startResize(multiDayEvent, MCalResizeEdge.end);

        expect(handler.isResizing, isTrue);

        expect(
          () => handler.startDrag(multiDayEvent, DateTime(2025, 1, 15)),
          throwsA(isA<AssertionError>()),
        );
      });

      test('can start resize after drag is cancelled', () {
        handler.startDrag(multiDayEvent, DateTime(2025, 1, 15));
        handler.cancelDrag();

        handler.startResize(multiDayEvent, MCalResizeEdge.end);

        expect(handler.isResizing, isTrue);
        expect(handler.isDragging, isFalse);
      });

      test('can start drag after resize is cancelled', () {
        handler.startResize(multiDayEvent, MCalResizeEdge.end);
        handler.cancelResize();

        handler.startDrag(multiDayEvent, DateTime(2025, 1, 15));

        expect(handler.isDragging, isTrue);
        expect(handler.isResizing, isFalse);
      });

      test('can start drag after resize is completed', () {
        handler.startResize(multiDayEvent, MCalResizeEdge.end);
        handler.updateResize(
          proposedStart: DateTime(2025, 1, 15),
          proposedEnd: DateTime(2025, 1, 20),
          isValid: true,
          cells: buildCells(DateTime(2025, 1, 15), 6),
        );
        handler.completeResize();

        handler.startDrag(multiDayEvent, DateTime(2025, 1, 15));

        expect(handler.isDragging, isTrue);
        expect(handler.isResizing, isFalse);
      });
    });

    // ============================================================
    // Group 6: Shared field reuse
    // ============================================================
    group('Shared field reuse', () {
      test('after updateResize, highlightedCells getter returns the cells', () {
        handler.startResize(multiDayEvent, MCalResizeEdge.end);

        final cells = buildCells(DateTime(2025, 1, 15), 5);
        handler.updateResize(
          proposedStart: DateTime(2025, 1, 15),
          proposedEnd: DateTime(2025, 1, 19),
          isValid: true,
          cells: cells,
        );

        expect(handler.highlightedCells.length, equals(5));
        expect(handler.highlightedCells[0].date, equals(DateTime(2025, 1, 15)));
        expect(handler.highlightedCells[1].date, equals(DateTime(2025, 1, 16)));
        expect(handler.highlightedCells[2].date, equals(DateTime(2025, 1, 17)));
        expect(handler.highlightedCells[3].date, equals(DateTime(2025, 1, 18)));
        expect(handler.highlightedCells[4].date, equals(DateTime(2025, 1, 19)));
      });

      test('after updateResize, proposedStartDate returns the start date', () {
        handler.startResize(multiDayEvent, MCalResizeEdge.start);

        final proposedStart = DateTime(2025, 1, 13);
        handler.updateResize(
          proposedStart: proposedStart,
          proposedEnd: DateTime(2025, 1, 17),
          isValid: true,
          cells: buildCells(proposedStart, 5),
        );

        expect(handler.proposedStartDate, equals(proposedStart));
      });

      test('after updateResize, proposedEndDate returns the end date', () {
        handler.startResize(multiDayEvent, MCalResizeEdge.end);

        final proposedEnd = DateTime(2025, 1, 22);
        handler.updateResize(
          proposedStart: DateTime(2025, 1, 15),
          proposedEnd: proposedEnd,
          isValid: true,
          cells: buildCells(DateTime(2025, 1, 15), 8),
        );

        expect(handler.proposedEndDate, equals(proposedEnd));
      });

      test('highlightedCells returns unmodifiable list during resize', () {
        handler.startResize(multiDayEvent, MCalResizeEdge.end);
        handler.updateResize(
          proposedStart: DateTime(2025, 1, 15),
          proposedEnd: DateTime(2025, 1, 17),
          isValid: true,
          cells: buildCells(DateTime(2025, 1, 15), 3),
        );

        final cells = handler.highlightedCells;
        final dummyCell = MCalHighlightCellInfo(
          date: DateTime(2025, 1, 20),
          cellIndex: 0,
          weekRowIndex: 0,
          bounds: Rect.zero,
          isFirst: true,
          isLast: true,
        );
        expect(
          () => (cells as List).add(dummyCell),
          throwsA(isA<UnsupportedError>()),
        );
      });

      test('isProposedDropValid reflects current resize validity', () {
        handler.startResize(multiDayEvent, MCalResizeEdge.end);

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

      test('multiple updateResize calls overwrite previous values', () {
        handler.startResize(multiDayEvent, MCalResizeEdge.end);

        handler.updateResize(
          proposedStart: DateTime(2025, 1, 15),
          proposedEnd: DateTime(2025, 1, 18),
          isValid: true,
          cells: buildCells(DateTime(2025, 1, 15), 4),
        );
        expect(handler.highlightedCells.length, equals(4));
        expect(handler.proposedEndDate, equals(DateTime(2025, 1, 18)));

        handler.updateResize(
          proposedStart: DateTime(2025, 1, 15),
          proposedEnd: DateTime(2025, 1, 22),
          isValid: true,
          cells: buildCells(DateTime(2025, 1, 15), 8),
        );
        expect(handler.highlightedCells.length, equals(8));
        expect(handler.proposedEndDate, equals(DateTime(2025, 1, 22)));
      });
    });
  });
}
