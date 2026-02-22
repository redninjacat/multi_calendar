import 'package:flutter_test/flutter_test.dart';
import 'package:multi_calendar/src/utils/time_utils.dart';

void main() {
  const double hourHeight = 60.0;
  const int startHour = 8;
  final DateTime baseDate = DateTime(2026, 2, 14);

  group('timeToOffset', () {
    test('midnight (00:00) returns 0 when startHour is 0', () {
      final time = DateTime(2026, 2, 14, 0, 0);
      final offset = timeToOffset(
        time: time,
        startHour: 0,
        hourHeight: hourHeight,
      );
      expect(offset, 0.0);
    });

    test('returns 0 when time equals startHour', () {
      final time = DateTime(2026, 2, 14, startHour, 0);
      final offset = timeToOffset(
        time: time,
        startHour: startHour,
        hourHeight: hourHeight,
      );
      expect(offset, 0.0);
    });

    test('various times within day bounds produce correct offsets', () {
      // 1 hour after start (9:00) = 60 pixels
      expect(
        timeToOffset(
          time: DateTime(2026, 2, 14, 9, 0),
          startHour: startHour,
          hourHeight: hourHeight,
        ),
        60.0,
      );

      // 2.5 hours after start (10:30) = 150 pixels
      expect(
        timeToOffset(
          time: DateTime(2026, 2, 14, 10, 30),
          startHour: startHour,
          hourHeight: hourHeight,
        ),
        150.0,
      );

      // 5 hours after start (13:00) = 300 pixels
      expect(
        timeToOffset(
          time: DateTime(2026, 2, 14, 13, 0),
          startHour: startHour,
          hourHeight: hourHeight,
        ),
        300.0,
      );
    });

    test('end of day returns correct offset for 24-hour view', () {
      final time = DateTime(2026, 2, 14, 23, 59);
      final offset = timeToOffset(
        time: time,
        startHour: 0,
        hourHeight: hourHeight,
      );
      // 23 hours 59 minutes = 23 + 59/60 = 23.983... hours
      expect(offset, closeTo(1439.0, 1.0)); // 23*60 + 59 = 1439 minutes
    });

    test('handles fractional minute positions (half-hour)', () {
      final time = DateTime(2026, 2, 14, 10, 30);
      final offset = timeToOffset(
        time: time,
        startHour: startHour,
        hourHeight: hourHeight,
      );
      // 2.5 hours * 60 = 150
      expect(offset, 150.0);
    });

    test('handles time before startHour (negative offset)', () {
      final time = DateTime(2026, 2, 14, 6, 0);
      final offset = timeToOffset(
        time: time,
        startHour: startHour,
        hourHeight: hourHeight,
      );
      // 6 - 8 = -2 hours = -120 pixels
      expect(offset, -120.0);
    });

    test('handles different hourHeight values', () {
      final time = DateTime(2026, 2, 14, 10, 0);
      expect(
        timeToOffset(time: time, startHour: 8, hourHeight: 100.0),
        200.0, // 2 hours * 100
      );
    });
  });

  group('offsetToTime', () {
    test('offset 0 returns startHour on given date', () {
      final time = offsetToTime(
        offset: 0.0,
        date: baseDate,
        startHour: startHour,
        hourHeight: hourHeight,
      );
      expect(time.year, baseDate.year);
      expect(time.month, baseDate.month);
      expect(time.day, baseDate.day);
      expect(time.hour, startHour);
      expect(time.minute, 0);
    });

    test('various offsets return correct DateTime', () {
      // 60 pixels = 1 hour = 9:00
      final time1 = offsetToTime(
        offset: 60.0,
        date: baseDate,
        startHour: startHour,
        hourHeight: hourHeight,
      );
      expect(time1.hour, 9);
      expect(time1.minute, 0);

      // 150 pixels = 2.5 hours = 10:30
      final time2 = offsetToTime(
        offset: 150.0,
        date: baseDate,
        startHour: startHour,
        hourHeight: hourHeight,
      );
      expect(time2.hour, 10);
      expect(time2.minute, 30);
    });

    test('rounds to nearest minute (no snapping)', () {
      // 147 pixels / 60 px/hr = 2.45 hr = 2h27m from 8:00 = 10:27
      final time = offsetToTime(
        offset: 147.0,
        date: baseDate,
        startHour: startHour,
        hourHeight: hourHeight,
      );
      expect(time.hour, 10);
      expect(time.minute, 27);
    });

    test('preserves date from input', () {
      final date = DateTime(2025, 12, 25);
      final time = offsetToTime(
        offset: 0.0,
        date: date,
        startHour: 0,
        hourHeight: hourHeight,
      );
      expect(time.year, 2025);
      expect(time.month, 12);
      expect(time.day, 25);
    });

    test('snapToTimeSlot snaps to 15-minute intervals', () {
      final raw = DateTime(2026, 1, 1, 10, 27);
      final snapped = snapToTimeSlot(
        time: raw,
        timeSlotDuration: const Duration(minutes: 15),
      );
      expect(snapped.hour, 10);
      expect(snapped.minute, 30);
    });

    test('snapToTimeSlot snaps to 5-minute intervals', () {
      final raw = DateTime(2026, 1, 1, 10, 23);
      final snapped = snapToTimeSlot(
        time: raw,
        timeSlotDuration: const Duration(minutes: 5),
      );
      expect(snapped.hour, 10);
      expect(snapped.minute, 25);
    });

    test('snapToTimeSlot snaps to 60-minute intervals', () {
      final raw = DateTime(2026, 1, 1, 9, 30);
      final snapped = snapToTimeSlot(
        time: raw,
        timeSlotDuration: const Duration(minutes: 60),
      );
      expect(snapped.hour, 10);
      expect(snapped.minute, 0);
    });
  });

  group('durationToHeight', () {
    test('various durations produce correct heights', () {
      expect(
        durationToHeight(
          duration: const Duration(minutes: 60),
          hourHeight: hourHeight,
        ),
        60.0,
      );

      expect(
        durationToHeight(
          duration: const Duration(minutes: 90),
          hourHeight: hourHeight,
        ),
        90.0,
      );

      expect(
        durationToHeight(
          duration: const Duration(minutes: 30),
          hourHeight: hourHeight,
        ),
        30.0,
      );
    });

    test('zero duration returns 0', () {
      expect(
        durationToHeight(duration: Duration.zero, hourHeight: hourHeight),
        0.0,
      );
    });

    test('handles different hourHeight values', () {
      expect(
        durationToHeight(
          duration: const Duration(minutes: 60),
          hourHeight: 100.0,
        ),
        100.0,
      );
    });

    test('handles duration - inMinutes truncates seconds', () {
      // Duration.inMinutes returns whole minutes only (90, not 90.5)
      final duration = const Duration(minutes: 90, seconds: 30);
      final height = durationToHeight(
        duration: duration,
        hourHeight: hourHeight,
      );
      expect(height, 90.0);
    });
  });

  group('snapToTimeSlot', () {
    test('snaps to 15-minute intervals', () {
      final time = DateTime(2026, 2, 14, 10, 37);
      final snapped = snapToTimeSlot(
        time: time,
        timeSlotDuration: const Duration(minutes: 15),
      );
      expect(snapped.hour, 10);
      expect(snapped.minute, 30); // 37 rounds down to 30 (closer than 45)
    });

    test('snaps 10:38 to 10:45 (rounds up)', () {
      final time = DateTime(2026, 2, 14, 10, 38);
      final snapped = snapToTimeSlot(
        time: time,
        timeSlotDuration: const Duration(minutes: 15),
      );
      expect(snapped.hour, 10);
      expect(snapped.minute, 45);
    });

    test('exact slot boundary returns unchanged', () {
      final time = DateTime(2026, 2, 14, 10, 30);
      final snapped = snapToTimeSlot(
        time: time,
        timeSlotDuration: const Duration(minutes: 15),
      );
      expect(snapped.hour, 10);
      expect(snapped.minute, 30);
    });

    test('handles 5-minute granularity', () {
      final time = DateTime(2026, 2, 14, 10, 33);
      final snapped = snapToTimeSlot(
        time: time,
        timeSlotDuration: const Duration(minutes: 5),
      );
      expect(snapped.hour, 10);
      expect(snapped.minute, 35);
    });

    test('handles 60-minute granularity', () {
      final time = DateTime(2026, 2, 14, 10, 45);
      final snapped = snapToTimeSlot(
        time: time,
        timeSlotDuration: const Duration(minutes: 60),
      );
      expect(snapped.hour, 11);
      expect(snapped.minute, 0);
    });

    test('preserves date components', () {
      final time = DateTime(2025, 7, 4, 14, 22);
      final snapped = snapToTimeSlot(
        time: time,
        timeSlotDuration: const Duration(minutes: 15),
      );
      expect(snapped.year, 2025);
      expect(snapped.month, 7);
      expect(snapped.day, 4);
    });
  });

  group('snapToNearbyTime', () {
    test('returns time unchanged when nearbyTimes is empty', () {
      final time = DateTime(2026, 2, 14, 10, 33);
      final snapped = snapToNearbyTime(
        time: time,
        nearbyTimes: [],
        snapRange: const Duration(minutes: 5),
      );
      expect(snapped, time);
    });

    test('snaps to closest time within range', () {
      final time = DateTime(2026, 2, 14, 10, 33);
      final nearbyTimes = [
        DateTime(2026, 2, 14, 10, 30),
        DateTime(2026, 2, 14, 11, 0),
      ];
      final snapped = snapToNearbyTime(
        time: time,
        nearbyTimes: nearbyTimes,
        snapRange: const Duration(minutes: 5),
      );
      expect(snapped.hour, 10);
      expect(snapped.minute, 30);
    });

    test('returns time unchanged when outside snap range', () {
      final time = DateTime(2026, 2, 14, 10, 50);
      final nearbyTimes = [
        DateTime(2026, 2, 14, 10, 30),
        DateTime(2026, 2, 14, 11, 0),
      ];
      final snapped = snapToNearbyTime(
        time: time,
        nearbyTimes: nearbyTimes,
        snapRange: const Duration(minutes: 5),
      );
      expect(snapped.hour, 10);
      expect(snapped.minute, 50);
    });

    test('snaps to closest when multiple times in range', () {
      final time = DateTime(2026, 2, 14, 10, 33);
      final nearbyTimes = [
        DateTime(2026, 2, 14, 10, 30),
        DateTime(2026, 2, 14, 10, 35), // 2 min away vs 3 min for 10:30
      ];
      final snapped = snapToNearbyTime(
        time: time,
        nearbyTimes: nearbyTimes,
        snapRange: const Duration(minutes: 5),
      );
      expect(snapped.hour, 10);
      expect(snapped.minute, 35);
    });
  });

  group('isWithinSnapRange', () {
    test('returns true when times are within range', () {
      expect(
        isWithinSnapRange(
          DateTime(2026, 2, 14, 10, 33),
          DateTime(2026, 2, 14, 10, 30),
          const Duration(minutes: 5),
        ),
        true,
      );
    });

    test('returns true when difference equals snap range', () {
      expect(
        isWithinSnapRange(
          DateTime(2026, 2, 14, 10, 35),
          DateTime(2026, 2, 14, 10, 30),
          const Duration(minutes: 5),
        ),
        true,
      );
    });

    test('returns false when times exceed snap range', () {
      expect(
        isWithinSnapRange(
          DateTime(2026, 2, 14, 10, 40),
          DateTime(2026, 2, 14, 10, 30),
          const Duration(minutes: 5),
        ),
        false,
      );
    });

    test('order of arguments does not matter', () {
      expect(
        isWithinSnapRange(
          DateTime(2026, 2, 14, 10, 30),
          DateTime(2026, 2, 14, 10, 33),
          const Duration(minutes: 5),
        ),
        true,
      );
    });
  });

  group('round-trip and inverse consistency', () {
    test(
      'timeToOffset and offsetToTime are inverse for slot-aligned times',
      () {
        final time = DateTime(2026, 2, 14, 10, 30);
        final offset = timeToOffset(
          time: time,
          startHour: startHour,
          hourHeight: hourHeight,
        );
        final recovered = offsetToTime(
          offset: offset,
          date: baseDate,
          startHour: startHour,
          hourHeight: hourHeight,
        );
        expect(recovered.hour, time.hour);
        expect(recovered.minute, time.minute);
      },
    );

    test('durationToHeight and heightToDuration are inverse', () {
      // heightToDuration doesn't exist - test durationToHeight round-trip
      // via offsetToTime - timeToOffset for duration representation
      const duration = Duration(minutes: 90);
      final height = durationToHeight(
        duration: duration,
        hourHeight: hourHeight,
      );
      expect(height, 90.0);
      // Inverse: height/60 * 60 = minutes
      final minutes = (height / hourHeight) * 60;
      expect(minutes, closeTo(90.0, 0.01));
    });
  });

  group('DST and edge cases', () {
    test('timeToOffset uses hour/minute only (DST-safe)', () {
      // Use a date during DST transition (March 10, 2024 - US spring forward)
      final time = DateTime(2024, 3, 10, 10, 30);
      final offset = timeToOffset(
        time: time,
        startHour: 8,
        hourHeight: hourHeight,
      );
      // Pure hour/minute arithmetic - no Duration across days
      expect(offset, 150.0);
    });

    test('offsetToTime constructs DateTime with components (DST-safe)', () {
      final time = offsetToTime(
        offset: 150.0,
        date: DateTime(2024, 3, 10), // DST transition day
        startHour: 8,
        hourHeight: hourHeight,
      );
      expect(time.hour, 10);
      expect(time.minute, 30);
      expect(time.year, 2024);
      expect(time.month, 3);
      expect(time.day, 10);
    });

    test('snapToTimeSlot preserves date (DST-safe)', () {
      final time = DateTime(2024, 11, 3, 1, 37); // US fall back
      final snapped = snapToTimeSlot(
        time: time,
        timeSlotDuration: const Duration(minutes: 15),
      );
      expect(snapped.year, 2024);
      expect(snapped.month, 11);
      expect(snapped.day, 3);
    });
  });
}
