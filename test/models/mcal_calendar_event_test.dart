import 'package:flutter_test/flutter_test.dart';
import 'package:multi_calendar/src/models/mcal_calendar_event.dart';

void main() {
  group('MCalCalendarEvent', () {
    final testStart = DateTime(2024, 1, 15, 10, 0);
    final testEnd = DateTime(2024, 1, 15, 11, 0);

    test('creates instance with all required fields', () {
      final event = MCalCalendarEvent(
        id: 'event-1',
        title: 'Test Event',
        start: testStart,
        end: testEnd,
      );

      expect(event.id, 'event-1');
      expect(event.title, 'Test Event');
      expect(event.start, testStart);
      expect(event.end, testEnd);
      expect(event.isAllDay, isFalse);
      expect(event.comment, isNull);
      expect(event.externalId, isNull);
      expect(event.occurrenceId, isNull);
    });

    test('creates instance with all fields including optional ones', () {
      final event = MCalCalendarEvent(
        id: 'event-2',
        title: 'Meeting',
        start: testStart,
        end: testEnd,
        isAllDay: false,
        comment: 'Team meeting',
        externalId: 'ext-123',
        occurrenceId: 'occ-456',
      );

      expect(event.id, 'event-2');
      expect(event.title, 'Meeting');
      expect(event.start, testStart);
      expect(event.end, testEnd);
      expect(event.isAllDay, isFalse);
      expect(event.comment, 'Team meeting');
      expect(event.externalId, 'ext-123');
      expect(event.occurrenceId, 'occ-456');
    });

    test('creates all-day event with isAllDay true', () {
      final event = MCalCalendarEvent(
        id: 'event-all-day',
        title: 'Holiday',
        start: DateTime(2024, 1, 15, 0, 0),
        end: DateTime(2024, 1, 15, 0, 0),
        isAllDay: true,
      );

      expect(event.isAllDay, isTrue);
      expect(event.id, 'event-all-day');
      expect(event.title, 'Holiday');
    });

    test('creates instance with some optional fields null', () {
      final event = MCalCalendarEvent(
        id: 'event-3',
        title: 'Simple Event',
        start: testStart,
        end: testEnd,
        comment: 'Has comment',
        // externalId and occurrenceId are null
      );

      expect(event.comment, 'Has comment');
      expect(event.externalId, isNull);
      expect(event.occurrenceId, isNull);
    });

    test('equality operator returns true for identical instances', () {
      final event1 = MCalCalendarEvent(
        id: 'event-1',
        title: 'Test',
        start: testStart,
        end: testEnd,
      );
      final event2 = MCalCalendarEvent(
        id: 'event-1',
        title: 'Test',
        start: testStart,
        end: testEnd,
      );

      expect(event1 == event2, isTrue);
    });

    test('equality operator returns false for different instances', () {
      final event1 = MCalCalendarEvent(
        id: 'event-1',
        title: 'Test',
        start: testStart,
        end: testEnd,
      );
      final event2 = MCalCalendarEvent(
        id: 'event-2',
        title: 'Test',
        start: testStart,
        end: testEnd,
      );

      expect(event1 == event2, isFalse);
    });

    test('equality operator handles optional fields correctly', () {
      final event1 = MCalCalendarEvent(
        id: 'event-1',
        title: 'Test',
        start: testStart,
        end: testEnd,
        comment: 'Comment',
      );
      final event2 = MCalCalendarEvent(
        id: 'event-1',
        title: 'Test',
        start: testStart,
        end: testEnd,
        comment: null,
      );

      expect(event1 == event2, isFalse);
    });

    test('equality operator handles isAllDay field correctly', () {
      final event1 = MCalCalendarEvent(
        id: 'event-1',
        title: 'Test',
        start: testStart,
        end: testEnd,
        isAllDay: true,
      );
      final event2 = MCalCalendarEvent(
        id: 'event-1',
        title: 'Test',
        start: testStart,
        end: testEnd,
        isAllDay: false,
      );

      expect(event1 == event2, isFalse);
    });

    test('hashCode is consistent for identical instances', () {
      final event1 = MCalCalendarEvent(
        id: 'event-1',
        title: 'Test',
        start: testStart,
        end: testEnd,
      );
      final event2 = MCalCalendarEvent(
        id: 'event-1',
        title: 'Test',
        start: testStart,
        end: testEnd,
      );

      expect(event1.hashCode, event2.hashCode);
    });

    test('hashCode differs for different instances', () {
      final event1 = MCalCalendarEvent(
        id: 'event-1',
        title: 'Test',
        start: testStart,
        end: testEnd,
      );
      final event2 = MCalCalendarEvent(
        id: 'event-2',
        title: 'Test',
        start: testStart,
        end: testEnd,
      );

      expect(event1.hashCode, isNot(event2.hashCode));
    });

    test('toString includes all fields', () {
      final event = MCalCalendarEvent(
        id: 'event-1',
        title: 'Test Event',
        start: testStart,
        end: testEnd,
        isAllDay: false,
        comment: 'Comment',
        externalId: 'ext-123',
        occurrenceId: 'occ-456',
      );

      final str = event.toString();
      expect(str, contains('event-1'));
      expect(str, contains('Test Event'));
      expect(str, contains('isAllDay: false'));
      expect(str, contains('Comment'));
      expect(str, contains('ext-123'));
      expect(str, contains('occ-456'));
    });

    test('toString handles null optional fields', () {
      final event = MCalCalendarEvent(
        id: 'event-1',
        title: 'Test',
        start: testStart,
        end: testEnd,
      );

      final str = event.toString();
      expect(str, contains('isAllDay: false'));
      expect(str, contains('comment: null'));
      expect(str, contains('externalId: null'));
      expect(str, contains('occurrenceId: null'));
    });
  });
}
