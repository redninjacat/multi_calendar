import 'package:flutter_test/flutter_test.dart';
import 'package:multi_calendar/multi_calendar.dart';

void main() {
  group('DateLabelPosition', () {
    test('has 6 values', () {
      expect(DateLabelPosition.values.length, 6);
    });

    test('includes all expected positions', () {
      expect(DateLabelPosition.values, contains(DateLabelPosition.topLeft));
      expect(DateLabelPosition.values, contains(DateLabelPosition.topCenter));
      expect(DateLabelPosition.values, contains(DateLabelPosition.topRight));
      expect(DateLabelPosition.values, contains(DateLabelPosition.bottomLeft));
      expect(
        DateLabelPosition.values,
        contains(DateLabelPosition.bottomCenter),
      );
      expect(DateLabelPosition.values, contains(DateLabelPosition.bottomRight));
    });
  });

  group('MCalMonthEventSegment (Month View)', () {
    late MCalCalendarEvent testEvent;

    setUp(() {
      testEvent = MCalCalendarEvent(
        id: 'test-1',
        title: 'Test Event',
        start: DateTime(2024, 1, 15, 10, 0),
        end: DateTime(2024, 1, 17, 11, 0),
      );
    });

    test('calculates spanDays correctly', () {
      final segment = MCalMonthEventSegment(
        event: testEvent,
        weekRowIndex: 0,
        startDayInWeek: 1,
        endDayInWeek: 3,
        isFirstSegment: true,
        isLastSegment: true,
      );
      expect(segment.spanDays, 3);
    });

    test('identifies single day segment', () {
      final segment = MCalMonthEventSegment(
        event: testEvent,
        weekRowIndex: 0,
        startDayInWeek: 2,
        endDayInWeek: 2,
        isFirstSegment: true,
        isLastSegment: true,
      );
      expect(segment.isSingleDay, true);
    });

    test('multi-day segment is not single day', () {
      final segment = MCalMonthEventSegment(
        event: testEvent,
        weekRowIndex: 0,
        startDayInWeek: 1,
        endDayInWeek: 3,
        isFirstSegment: true,
        isLastSegment: true,
      );
      expect(segment.isSingleDay, false);
    });

    test('first segment of multi-week event is not single day', () {
      final segment = MCalMonthEventSegment(
        event: testEvent,
        weekRowIndex: 0,
        startDayInWeek: 5,
        endDayInWeek: 6,
        isFirstSegment: true,
        isLastSegment: false, // continues next week
      );
      expect(segment.isSingleDay, false);
    });

    test('equality works correctly', () {
      final segment1 = MCalMonthEventSegment(
        event: testEvent,
        weekRowIndex: 0,
        startDayInWeek: 1,
        endDayInWeek: 3,
        isFirstSegment: true,
        isLastSegment: true,
      );
      final segment2 = MCalMonthEventSegment(
        event: testEvent,
        weekRowIndex: 0,
        startDayInWeek: 1,
        endDayInWeek: 3,
        isFirstSegment: true,
        isLastSegment: true,
      );
      expect(segment1, segment2);
      expect(segment1.hashCode, segment2.hashCode);
    });
  });

  group('MCalMonthWeekLayoutConfig (Month View)', () {
    test('has correct default values', () {
      final config = MCalMonthWeekLayoutConfig.fromTheme(const MCalThemeData());

      expect(config.tileHeight, 18.0);
      expect(config.tileVerticalSpacing, 2.0);
      expect(config.tileHorizontalSpacing, 2.0);
      expect(config.eventTileCornerRadius, 3.0);
      expect(config.tileBorderWidth, 0.0);
      expect(config.dateLabelHeight, 18.0);
      expect(config.dateLabelPosition, DateLabelPosition.topLeft);
      expect(config.overflowIndicatorHeight, 14.0);
    });

    test('inherits values from theme', () {
      final theme = MCalThemeData(
        monthTheme: MCalMonthThemeData(
          eventTileHeight: 25.0,
          dateLabelPosition: DateLabelPosition.bottomRight,
        ),
      );
      final config = MCalMonthWeekLayoutConfig.fromTheme(theme);

      expect(config.tileHeight, 25.0);
      expect(config.dateLabelPosition, DateLabelPosition.bottomRight);
    });
  });
}
