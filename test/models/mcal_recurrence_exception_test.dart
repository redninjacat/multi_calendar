import 'package:flutter_test/flutter_test.dart';
import 'package:multi_calendar/multi_calendar.dart';

void main() {
  group('MCalRecurrenceException', () {
    final testDate = DateTime(2024, 1, 15);
    final newDate = DateTime(2024, 1, 16);
    final modifiedEvent = MCalCalendarEvent(
      id: 'modified-1',
      title: 'Modified Event',
      start: DateTime(2024, 1, 15, 14, 0),
      end: DateTime(2024, 1, 15, 15, 0),
    );

    group('.deleted() constructor', () {
      test('sets type to deleted', () {
        final exception = MCalRecurrenceException.deleted(
          originalDate: testDate,
        );
        expect(exception.type, MCalExceptionType.deleted);
      });

      test('sets originalDate correctly', () {
        final exception = MCalRecurrenceException.deleted(
          originalDate: testDate,
        );
        expect(exception.originalDate, testDate);
      });

      test('newDate is null', () {
        final exception = MCalRecurrenceException.deleted(
          originalDate: testDate,
        );
        expect(exception.newDate, isNull);
      });

      test('modifiedEvent is null', () {
        final exception = MCalRecurrenceException.deleted(
          originalDate: testDate,
        );
        expect(exception.modifiedEvent, isNull);
      });
    });

    group('.rescheduled() constructor', () {
      test('sets type to rescheduled', () {
        final exception = MCalRecurrenceException.rescheduled(
          originalDate: testDate,
          newDate: newDate,
        );
        expect(exception.type, MCalExceptionType.rescheduled);
      });

      test('sets originalDate correctly', () {
        final exception = MCalRecurrenceException.rescheduled(
          originalDate: testDate,
          newDate: newDate,
        );
        expect(exception.originalDate, testDate);
      });

      test('sets newDate correctly', () {
        final exception = MCalRecurrenceException.rescheduled(
          originalDate: testDate,
          newDate: newDate,
        );
        expect(exception.newDate, newDate);
      });

      test('modifiedEvent is null', () {
        final exception = MCalRecurrenceException.rescheduled(
          originalDate: testDate,
          newDate: newDate,
        );
        expect(exception.modifiedEvent, isNull);
      });
    });

    group('.modified() constructor', () {
      test('sets type to modified', () {
        final exception = MCalRecurrenceException.modified(
          originalDate: testDate,
          modifiedEvent: modifiedEvent,
        );
        expect(exception.type, MCalExceptionType.modified);
      });

      test('sets originalDate correctly', () {
        final exception = MCalRecurrenceException.modified(
          originalDate: testDate,
          modifiedEvent: modifiedEvent,
        );
        expect(exception.originalDate, testDate);
      });

      test('sets modifiedEvent correctly', () {
        final exception = MCalRecurrenceException.modified(
          originalDate: testDate,
          modifiedEvent: modifiedEvent,
        );
        expect(exception.modifiedEvent, modifiedEvent);
      });

      test('newDate is null', () {
        final exception = MCalRecurrenceException.modified(
          originalDate: testDate,
          modifiedEvent: modifiedEvent,
        );
        expect(exception.newDate, isNull);
      });
    });

    group('copyWith', () {
      test('copies with new originalDate', () {
        final original = MCalRecurrenceException.deleted(
          originalDate: testDate,
        );
        final newOriginalDate = DateTime(2024, 2, 1);
        final copied = original.copyWith(originalDate: newOriginalDate);
        expect(copied.originalDate, newOriginalDate);
        expect(copied.type, MCalExceptionType.deleted);
      });

      test('copies with new type', () {
        final original = MCalRecurrenceException.deleted(
          originalDate: testDate,
        );
        final copied = original.copyWith(
          type: MCalExceptionType.rescheduled,
          newDate: newDate,
        );
        expect(copied.type, MCalExceptionType.rescheduled);
        expect(copied.newDate, newDate);
      });

      test('copies with new modifiedEvent', () {
        final original = MCalRecurrenceException.deleted(
          originalDate: testDate,
        );
        final copied = original.copyWith(
          type: MCalExceptionType.modified,
          modifiedEvent: modifiedEvent,
        );
        expect(copied.type, MCalExceptionType.modified);
        expect(copied.modifiedEvent, modifiedEvent);
      });

      test('preserves fields when nothing passed', () {
        final original = MCalRecurrenceException.rescheduled(
          originalDate: testDate,
          newDate: newDate,
        );
        final copied = original.copyWith();
        expect(copied, equals(original));
      });
    });

    group('== and hashCode', () {
      test('equal deleted exceptions', () {
        final a = MCalRecurrenceException.deleted(originalDate: testDate);
        final b = MCalRecurrenceException.deleted(originalDate: testDate);
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('equal rescheduled exceptions', () {
        final a = MCalRecurrenceException.rescheduled(
          originalDate: testDate,
          newDate: newDate,
        );
        final b = MCalRecurrenceException.rescheduled(
          originalDate: testDate,
          newDate: newDate,
        );
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('equal modified exceptions', () {
        final a = MCalRecurrenceException.modified(
          originalDate: testDate,
          modifiedEvent: modifiedEvent,
        );
        final b = MCalRecurrenceException.modified(
          originalDate: testDate,
          modifiedEvent: modifiedEvent,
        );
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('different types are not equal', () {
        final a = MCalRecurrenceException.deleted(originalDate: testDate);
        final b = MCalRecurrenceException.rescheduled(
          originalDate: testDate,
          newDate: newDate,
        );
        expect(a, isNot(equals(b)));
      });

      test('different originalDates are not equal', () {
        final a = MCalRecurrenceException.deleted(
          originalDate: DateTime(2024, 1, 1),
        );
        final b = MCalRecurrenceException.deleted(
          originalDate: DateTime(2024, 1, 2),
        );
        expect(a, isNot(equals(b)));
      });

      test('different newDates are not equal', () {
        final a = MCalRecurrenceException.rescheduled(
          originalDate: testDate,
          newDate: DateTime(2024, 1, 16),
        );
        final b = MCalRecurrenceException.rescheduled(
          originalDate: testDate,
          newDate: DateTime(2024, 1, 17),
        );
        expect(a, isNot(equals(b)));
      });
    });

    group('toString', () {
      test('deleted exception toString contains type and originalDate', () {
        final exception = MCalRecurrenceException.deleted(
          originalDate: testDate,
        );
        final str = exception.toString();
        expect(str, contains('MCalRecurrenceException'));
        expect(str, contains('deleted'));
        expect(str, contains(testDate.toString()));
      });

      test('rescheduled exception toString contains newDate', () {
        final exception = MCalRecurrenceException.rescheduled(
          originalDate: testDate,
          newDate: newDate,
        );
        final str = exception.toString();
        expect(str, contains('rescheduled'));
        expect(str, contains(newDate.toString()));
      });

      test('modified exception toString contains modifiedEvent', () {
        final exception = MCalRecurrenceException.modified(
          originalDate: testDate,
          modifiedEvent: modifiedEvent,
        );
        final str = exception.toString();
        expect(str, contains('modified'));
        expect(str, contains(modifiedEvent.toString()));
      });
    });
  });

  group('MCalExceptionType', () {
    test('has all 3 enum values', () {
      expect(MCalExceptionType.values, hasLength(3));
      expect(MCalExceptionType.values, contains(MCalExceptionType.deleted));
      expect(
        MCalExceptionType.values,
        contains(MCalExceptionType.rescheduled),
      );
      expect(MCalExceptionType.values, contains(MCalExceptionType.modified));
    });
  });
}
