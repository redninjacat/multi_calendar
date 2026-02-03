import 'package:flutter_test/flutter_test.dart';
import 'package:multi_calendar/multi_calendar.dart';

void main() {
  test('MCalCalendarEvent can be created and used', () {
    final event = MCalCalendarEvent(
      id: 'test-1',
      title: 'Test Event',
      start: DateTime(2024, 1, 15, 10, 0),
      end: DateTime(2024, 1, 15, 11, 0),
    );

    expect(event.id, 'test-1');
    expect(event.title, 'Test Event');
    expect(event.start, DateTime(2024, 1, 15, 10, 0));
    expect(event.end, DateTime(2024, 1, 15, 11, 0));
  });

  test('MCalEventController can be instantiated', () {
    final controller = MCalEventController();
    expect(controller, isNotNull);
  });
}
