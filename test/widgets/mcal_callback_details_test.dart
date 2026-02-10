import 'dart:ui' show Rect;

import 'package:flutter_test/flutter_test.dart';
import 'package:multi_calendar/src/widgets/mcal_callback_details.dart';

void main() {
  group('MCalHighlightCellInfo', () {
    test('equality: identical instances are equal', () {
      final cell = MCalHighlightCellInfo(
        date: _testDate,
        cellIndex: 2,
        weekRowIndex: 1,
        bounds: _testRect,
        isFirst: true,
        isLast: false,
      );

      expect(cell, equals(cell));
      expect(cell.hashCode, equals(cell.hashCode));
    });

    test('equality: same values are equal', () {
      final cell1 = MCalHighlightCellInfo(
        date: _testDate,
        cellIndex: 2,
        weekRowIndex: 1,
        bounds: _testRect,
        isFirst: true,
        isLast: false,
      );
      final cell2 = MCalHighlightCellInfo(
        date: _testDate,
        cellIndex: 2,
        weekRowIndex: 1,
        bounds: _testRect,
        isFirst: true,
        isLast: false,
      );

      expect(cell1, equals(cell2));
      expect(cell1.hashCode, equals(cell2.hashCode));
    });

    test('equality: different date makes instances unequal', () {
      final cell1 = MCalHighlightCellInfo(
        date: _testDate,
        cellIndex: 2,
        weekRowIndex: 1,
        bounds: _testRect,
        isFirst: true,
        isLast: false,
      );
      final cell2 = MCalHighlightCellInfo(
        date: DateTime(2024, 1, 16),
        cellIndex: 2,
        weekRowIndex: 1,
        bounds: _testRect,
        isFirst: true,
        isLast: false,
      );

      expect(cell1, isNot(equals(cell2)));
      expect(cell1.hashCode, isNot(equals(cell2.hashCode)));
    });

    test('equality: different cellIndex makes instances unequal', () {
      final cell1 = MCalHighlightCellInfo(
        date: _testDate,
        cellIndex: 2,
        weekRowIndex: 1,
        bounds: _testRect,
        isFirst: true,
        isLast: false,
      );
      final cell2 = MCalHighlightCellInfo(
        date: _testDate,
        cellIndex: 3,
        weekRowIndex: 1,
        bounds: _testRect,
        isFirst: true,
        isLast: false,
      );

      expect(cell1, isNot(equals(cell2)));
    });

    test('equality: different bounds makes instances unequal', () {
      final cell1 = MCalHighlightCellInfo(
        date: _testDate,
        cellIndex: 2,
        weekRowIndex: 1,
        bounds: _testRect,
        isFirst: true,
        isLast: false,
      );
      final cell2 = MCalHighlightCellInfo(
        date: _testDate,
        cellIndex: 2,
        weekRowIndex: 1,
        bounds: Rect.fromLTWH(10, 20, 60, 40),
        isFirst: true,
        isLast: false,
      );

      expect(cell1, isNot(equals(cell2)));
    });

    test('equality: different isFirst makes instances unequal', () {
      final cell1 = MCalHighlightCellInfo(
        date: _testDate,
        cellIndex: 2,
        weekRowIndex: 1,
        bounds: _testRect,
        isFirst: true,
        isLast: false,
      );
      final cell2 = MCalHighlightCellInfo(
        date: _testDate,
        cellIndex: 2,
        weekRowIndex: 1,
        bounds: _testRect,
        isFirst: false,
        isLast: false,
      );

      expect(cell1, isNot(equals(cell2)));
    });

    test('equality: returns false for non-MCalHighlightCellInfo', () {
      final cell = MCalHighlightCellInfo(
        date: _testDate,
        cellIndex: 2,
        weekRowIndex: 1,
        bounds: _testRect,
        isFirst: true,
        isLast: false,
      );

      expect(cell == 'not a cell', isFalse);
    });

    test('equality: works in list comparison for shouldRepaint', () {
      final cells1 = [
        MCalHighlightCellInfo(
          date: _testDate,
          cellIndex: 0,
          weekRowIndex: 0,
          bounds: _testRect,
          isFirst: true,
          isLast: false,
        ),
        MCalHighlightCellInfo(
          date: DateTime(2024, 1, 16),
          cellIndex: 1,
          weekRowIndex: 0,
          bounds: Rect.fromLTWH(50, 0, 50, 40),
          isFirst: false,
          isLast: true,
        ),
      ];
      final cells2 = [
        MCalHighlightCellInfo(
          date: _testDate,
          cellIndex: 0,
          weekRowIndex: 0,
          bounds: _testRect,
          isFirst: true,
          isLast: false,
        ),
        MCalHighlightCellInfo(
          date: DateTime(2024, 1, 16),
          cellIndex: 1,
          weekRowIndex: 0,
          bounds: Rect.fromLTWH(50, 0, 50, 40),
          isFirst: false,
          isLast: true,
        ),
      ];

      expect(cells1, equals(cells2));
    });
  });
}

final _testDate = DateTime(2024, 1, 15);
final _testRect = Rect.fromLTWH(0, 0, 50, 40);
