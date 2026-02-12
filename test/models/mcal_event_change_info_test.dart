import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_test/flutter_test.dart';
import 'package:multi_calendar/multi_calendar.dart';

void main() {
  group('MCalChangeType', () {
    test('has all 7 enum values', () {
      expect(MCalChangeType.values, hasLength(7));
      expect(MCalChangeType.values, contains(MCalChangeType.eventAdded));
      expect(MCalChangeType.values, contains(MCalChangeType.eventUpdated));
      expect(MCalChangeType.values, contains(MCalChangeType.eventRemoved));
      expect(MCalChangeType.values, contains(MCalChangeType.exceptionAdded));
      expect(
        MCalChangeType.values,
        contains(MCalChangeType.exceptionRemoved),
      );
      expect(MCalChangeType.values, contains(MCalChangeType.seriesSplit));
      expect(MCalChangeType.values, contains(MCalChangeType.bulkChange));
    });
  });

  group('MCalEventChangeInfo', () {
    test('construction with all fields', () {
      final range = DateTimeRange(
        start: DateTime(2024, 1, 1),
        end: DateTime(2024, 1, 31),
      );
      final info = MCalEventChangeInfo(
        type: MCalChangeType.eventAdded,
        affectedEventIds: {'event-1', 'event-2'},
        affectedDateRange: range,
      );

      expect(info.type, MCalChangeType.eventAdded);
      expect(info.affectedEventIds, {'event-1', 'event-2'});
      expect(info.affectedDateRange, range);
    });

    test('construction without affectedDateRange', () {
      final info = MCalEventChangeInfo(
        type: MCalChangeType.bulkChange,
        affectedEventIds: {'event-1'},
      );

      expect(info.type, MCalChangeType.bulkChange);
      expect(info.affectedEventIds, {'event-1'});
      expect(info.affectedDateRange, isNull);
    });

    test('construction with empty affectedEventIds', () {
      final info = MCalEventChangeInfo(
        type: MCalChangeType.bulkChange,
        affectedEventIds: {},
      );

      expect(info.affectedEventIds, isEmpty);
    });

    group('toString', () {
      test('includes all fields', () {
        final range = DateTimeRange(
          start: DateTime(2024, 1, 1),
          end: DateTime(2024, 1, 31),
        );
        final info = MCalEventChangeInfo(
          type: MCalChangeType.eventAdded,
          affectedEventIds: {'event-1'},
          affectedDateRange: range,
        );

        final str = info.toString();
        expect(str, contains('MCalEventChangeInfo'));
        expect(str, contains('eventAdded'));
        expect(str, contains('event-1'));
      });

      test('handles null affectedDateRange', () {
        final info = MCalEventChangeInfo(
          type: MCalChangeType.eventRemoved,
          affectedEventIds: {'event-1'},
        );

        final str = info.toString();
        expect(str, contains('affectedDateRange: null'));
      });
    });

    group('== and hashCode', () {
      test('equal instances with same fields', () {
        final range = DateTimeRange(
          start: DateTime(2024, 1, 1),
          end: DateTime(2024, 1, 31),
        );
        final a = MCalEventChangeInfo(
          type: MCalChangeType.eventAdded,
          affectedEventIds: {'event-1', 'event-2'},
          affectedDateRange: range,
        );
        final b = MCalEventChangeInfo(
          type: MCalChangeType.eventAdded,
          affectedEventIds: {'event-1', 'event-2'},
          affectedDateRange: range,
        );
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('equal instances with same affectedEventIds in different order', () {
        final a = MCalEventChangeInfo(
          type: MCalChangeType.eventAdded,
          affectedEventIds: {'event-1', 'event-2'},
        );
        final b = MCalEventChangeInfo(
          type: MCalChangeType.eventAdded,
          affectedEventIds: {'event-2', 'event-1'},
        );
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('different types are not equal', () {
        final a = MCalEventChangeInfo(
          type: MCalChangeType.eventAdded,
          affectedEventIds: {'event-1'},
        );
        final b = MCalEventChangeInfo(
          type: MCalChangeType.eventRemoved,
          affectedEventIds: {'event-1'},
        );
        expect(a, isNot(equals(b)));
      });

      test('different affectedEventIds are not equal', () {
        final a = MCalEventChangeInfo(
          type: MCalChangeType.eventAdded,
          affectedEventIds: {'event-1'},
        );
        final b = MCalEventChangeInfo(
          type: MCalChangeType.eventAdded,
          affectedEventIds: {'event-2'},
        );
        expect(a, isNot(equals(b)));
      });

      test('different affectedDateRange are not equal', () {
        final a = MCalEventChangeInfo(
          type: MCalChangeType.eventAdded,
          affectedEventIds: {'event-1'},
          affectedDateRange: DateTimeRange(
            start: DateTime(2024, 1, 1),
            end: DateTime(2024, 1, 31),
          ),
        );
        final b = MCalEventChangeInfo(
          type: MCalChangeType.eventAdded,
          affectedEventIds: {'event-1'},
          affectedDateRange: DateTimeRange(
            start: DateTime(2024, 2, 1),
            end: DateTime(2024, 2, 28),
          ),
        );
        expect(a, isNot(equals(b)));
      });

      test('null vs non-null affectedDateRange are not equal', () {
        final a = MCalEventChangeInfo(
          type: MCalChangeType.eventAdded,
          affectedEventIds: {'event-1'},
        );
        final b = MCalEventChangeInfo(
          type: MCalChangeType.eventAdded,
          affectedEventIds: {'event-1'},
          affectedDateRange: DateTimeRange(
            start: DateTime(2024, 1, 1),
            end: DateTime(2024, 1, 31),
          ),
        );
        expect(a, isNot(equals(b)));
      });
    });
  });
}
