import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multi_calendar/src/models/mcal_calendar_event.dart';
import 'package:multi_calendar/src/widgets/mcal_month_view_contexts.dart';

void main() {
  group('MCalDayCellContext', () {
    test('can be instantiated with required parameters', () {
      final date = DateTime(2024, 1, 15);
      final events = <MCalCalendarEvent>[];

      final context = MCalDayCellContext(
        date: date,
        isCurrentMonth: true,
        isToday: false,
        isSelectable: true,
        events: events,
      );

      expect(context.date, date);
      expect(context.isCurrentMonth, true);
      expect(context.isToday, false);
      expect(context.isSelectable, true);
      expect(context.events, events);
    });

    test('can be instantiated with const constructor (where possible)', () {
      final date = DateTime(2024, 1, 15);
      final events = <MCalCalendarEvent>[];

      // Note: DateTime cannot be const
      final context = MCalDayCellContext(
        date: date,
        isCurrentMonth: true,
        isToday: false,
        isSelectable: true,
        events: events,
      );

      expect(context.date, date);
      expect(context.isCurrentMonth, true);
    });

    test('all fields are final and accessible', () {
      final date = DateTime(2024, 1, 15);
      final events = [
        MCalCalendarEvent(
          id: 'event-1',
          title: 'Test Event',
          start: DateTime(2024, 1, 15),
          end: DateTime(2024, 1, 15, 1),
        ),
      ];

      final context = MCalDayCellContext(
        date: date,
        isCurrentMonth: false,
        isToday: true,
        isSelectable: false,
        events: events,
      );

      expect(context.date, date);
      expect(context.isCurrentMonth, false);
      expect(context.isToday, true);
      expect(context.isSelectable, false);
      expect(context.events, events);
    });

    test('fields are correctly typed', () {
      final context = MCalDayCellContext(
        date: DateTime(2024, 1, 15),
        isCurrentMonth: true,
        isToday: false,
        isSelectable: true,
        events: <MCalCalendarEvent>[],
      );

      expect(context.date, isA<DateTime>());
      expect(context.isCurrentMonth, isA<bool>());
      expect(context.isToday, isA<bool>());
      expect(context.isSelectable, isA<bool>());
      expect(context.events, isA<List<MCalCalendarEvent>>());
    });
  });

  group('MCalEventTileContext', () {
    test('can be instantiated with required parameters', () {
      final event = MCalCalendarEvent(
        id: 'event-1',
        title: 'Test Event',
        start: DateTime(2024, 1, 15),
        end: DateTime(2024, 1, 15, 1),
      );
      final displayDate = DateTime(2024, 1, 15);

      final context = MCalEventTileContext(
        event: event,
        displayDate: displayDate,
        isAllDay: false,
      );

      expect(context.event, event);
      expect(context.displayDate, displayDate);
      expect(context.isAllDay, false);
    });

    test('can be instantiated with const constructor (where possible)', () {
      final event = MCalCalendarEvent(
        id: 'event-1',
        title: 'Test Event',
        start: DateTime(2024, 1, 15),
        end: DateTime(2024, 1, 15, 1),
      );
      final displayDate = DateTime(2024, 1, 15);

      // Note: DateTime cannot be const
      final context = MCalEventTileContext(
        event: event,
        displayDate: displayDate,
        isAllDay: true,
      );

      expect(context.event, event);
      expect(context.isAllDay, true);
    });

    test('all fields are final and accessible', () {
      final event = MCalCalendarEvent(
        id: 'event-2',
        title: 'Another Event',
        start: DateTime(2024, 1, 16),
        end: DateTime(2024, 1, 16, 2),
      );
      final displayDate = DateTime(2024, 1, 16);

      final context = MCalEventTileContext(
        event: event,
        displayDate: displayDate,
        isAllDay: true,
      );

      expect(context.event, event);
      expect(context.displayDate, displayDate);
      expect(context.isAllDay, true);
    });

    test('fields are correctly typed', () {
      final context = MCalEventTileContext(
        event: MCalCalendarEvent(
          id: 'event-1',
          title: 'Test',
          start: DateTime(2024, 1, 15),
          end: DateTime(2024, 1, 15, 1),
        ),
        displayDate: DateTime(2024, 1, 15),
        isAllDay: false,
      );

      expect(context.event, isA<MCalCalendarEvent>());
      expect(context.displayDate, isA<DateTime>());
      expect(context.isAllDay, isA<bool>());
    });

    test('keyboardState defaults to none', () {
      final context = MCalEventTileContext(
        event: MCalCalendarEvent(
          id: 'kb-default',
          title: 'Test',
          start: DateTime(2024, 1, 15),
          end: DateTime(2024, 1, 15, 1),
        ),
        displayDate: DateTime(2024, 1, 15),
        isAllDay: false,
      );

      expect(context.keyboardState, MCalEventKeyboardState.none);
    });

    test('keyboardState can be set to highlighted', () {
      final context = MCalEventTileContext(
        event: MCalCalendarEvent(
          id: 'kb-highlighted',
          title: 'Test',
          start: DateTime(2024, 1, 15),
          end: DateTime(2024, 1, 15, 1),
        ),
        displayDate: DateTime(2024, 1, 15),
        isAllDay: false,
        keyboardState: MCalEventKeyboardState.highlighted,
      );

      expect(context.keyboardState, MCalEventKeyboardState.highlighted);
    });

    test('keyboardState can be set to selected', () {
      final context = MCalEventTileContext(
        event: MCalCalendarEvent(
          id: 'kb-selected',
          title: 'Test',
          start: DateTime(2024, 1, 15),
          end: DateTime(2024, 1, 15, 1),
        ),
        displayDate: DateTime(2024, 1, 15),
        isAllDay: false,
        keyboardState: MCalEventKeyboardState.selected,
      );

      expect(context.keyboardState, MCalEventKeyboardState.selected);
    });
  });

  group('MCalEventKeyboardState', () {
    test('has exactly three values', () {
      expect(MCalEventKeyboardState.values.length, 3);
    });

    test('values are none, highlighted, selected', () {
      expect(MCalEventKeyboardState.values, [
        MCalEventKeyboardState.none,
        MCalEventKeyboardState.highlighted,
        MCalEventKeyboardState.selected,
      ]);
    });

    test('none has index 0', () {
      expect(MCalEventKeyboardState.none.index, 0);
    });

    test('highlighted has index 1', () {
      expect(MCalEventKeyboardState.highlighted.index, 1);
    });

    test('selected has index 2', () {
      expect(MCalEventKeyboardState.selected.index, 2);
    });
  });

  group('MCalDayHeaderContext', () {
    test('can be instantiated with required parameters', () {
      final context = MCalDayHeaderContext(
        dayOfWeek: 1,
        dayName: 'Monday',
      );

      expect(context.dayOfWeek, 1);
      expect(context.dayName, 'Monday');
    });

    test('can be instantiated with const constructor', () {
      // All fields can be const for MCalDayHeaderContext
      const context = MCalDayHeaderContext(
        dayOfWeek: 0,
        dayName: 'Sunday',
      );

      expect(context.dayOfWeek, 0);
      expect(context.dayName, 'Sunday');
    });

    test('all fields are final and accessible', () {
      final context = MCalDayHeaderContext(
        dayOfWeek: 6,
        dayName: 'Saturday',
      );

      expect(context.dayOfWeek, 6);
      expect(context.dayName, 'Saturday');
    });

    test('fields are correctly typed', () {
      final context = MCalDayHeaderContext(
        dayOfWeek: 3,
        dayName: 'Wednesday',
      );

      expect(context.dayOfWeek, isA<int>());
      expect(context.dayName, isA<String>());
    });
  });

  group('MCalNavigatorContext', () {
    test('can be instantiated with required parameters', () {
      final currentMonth = DateTime(2024, 1, 1);
      final locale = const Locale('en');
      void onPrevious() {}
      void onNext() {}
      void onToday() {}

      final context = MCalNavigatorContext(
        currentMonth: currentMonth,
        onPrevious: onPrevious,
        onNext: onNext,
        onToday: onToday,
        canGoPrevious: true,
        canGoNext: true,
        locale: locale,
      );

      expect(context.currentMonth, currentMonth);
      expect(context.canGoPrevious, true);
      expect(context.canGoNext, true);
      expect(context.locale, locale);
    });

    test('can be instantiated with const constructor (where possible)', () {
      final currentMonth = DateTime(2024, 1, 1);
      const locale = Locale('en');
      void onPrevious() {}
      void onNext() {}
      void onToday() {}

      // Note: DateTime and VoidCallback cannot be const, but locale can be
      final context = MCalNavigatorContext(
        currentMonth: currentMonth,
        onPrevious: onPrevious,
        onNext: onNext,
        onToday: onToday,
        canGoPrevious: false,
        canGoNext: false,
        locale: locale,
      );

      expect(context.currentMonth, currentMonth);
      expect(context.canGoPrevious, false);
      expect(context.canGoNext, false);
      // Verify locale can be const
      expect(context.locale, locale);
    });

    test('all fields are final and accessible', () {
      final currentMonth = DateTime(2024, 2, 1);
      final locale = const Locale('es', 'MX');
      void onPrevious() {}
      void onNext() {}
      void onToday() {}

      final context = MCalNavigatorContext(
        currentMonth: currentMonth,
        onPrevious: onPrevious,
        onNext: onNext,
        onToday: onToday,
        canGoPrevious: true,
        canGoNext: false,
        locale: locale,
      );

      expect(context.currentMonth, currentMonth);
      expect(context.onPrevious, onPrevious);
      expect(context.onNext, onNext);
      expect(context.onToday, onToday);
      expect(context.canGoPrevious, true);
      expect(context.canGoNext, false);
      expect(context.locale, locale);
    });

    test('fields are correctly typed', () {
      void onPrevious() {}
      void onNext() {}
      void onToday() {}

      final context = MCalNavigatorContext(
        currentMonth: DateTime(2024, 1, 1),
        onPrevious: onPrevious,
        onNext: onNext,
        onToday: onToday,
        canGoPrevious: true,
        canGoNext: true,
        locale: const Locale('en'),
      );

      expect(context.currentMonth, isA<DateTime>());
      expect(context.onPrevious, isA<VoidCallback>());
      expect(context.onNext, isA<VoidCallback>());
      expect(context.onToday, isA<VoidCallback>());
      expect(context.canGoPrevious, isA<bool>());
      expect(context.canGoNext, isA<bool>());
      expect(context.locale, isA<Locale>());
    });
  });

  group('MCalDateLabelContext', () {
    test('can be instantiated with required parameters', () {
      final date = DateTime(2024, 1, 15);
      final locale = const Locale('en');

      final context = MCalDateLabelContext(
        date: date,
        isCurrentMonth: true,
        isToday: false,
        defaultFormattedString: '15',
        locale: locale,
      );

      expect(context.date, date);
      expect(context.isCurrentMonth, true);
      expect(context.isToday, false);
      expect(context.defaultFormattedString, '15');
      expect(context.locale, locale);
    });

    test('can be instantiated with const constructor (where possible)', () {
      final date = DateTime(2024, 1, 15);
      const locale = Locale('en');

      // Note: DateTime cannot be const, but locale and string can be
      final context = MCalDateLabelContext(
        date: date,
        isCurrentMonth: false,
        isToday: true,
        defaultFormattedString: '15',
        locale: locale,
      );

      expect(context.date, date);
      expect(context.isCurrentMonth, false);
      expect(context.isToday, true);
      expect(context.defaultFormattedString, '15');
      // Verify locale can be const
      expect(context.locale, locale);
    });

    test('all fields are final and accessible', () {
      final date = DateTime(2024, 1, 20);
      final locale = const Locale('es', 'MX');

      final context = MCalDateLabelContext(
        date: date,
        isCurrentMonth: true,
        isToday: false,
        defaultFormattedString: '20',
        locale: locale,
      );

      expect(context.date, date);
      expect(context.isCurrentMonth, true);
      expect(context.isToday, false);
      expect(context.defaultFormattedString, '20');
      expect(context.locale, locale);
    });

    test('fields are correctly typed', () {
      final context = MCalDateLabelContext(
        date: DateTime(2024, 1, 15),
        isCurrentMonth: true,
        isToday: false,
        defaultFormattedString: '15',
        locale: const Locale('en'),
      );

      expect(context.date, isA<DateTime>());
      expect(context.isCurrentMonth, isA<bool>());
      expect(context.isToday, isA<bool>());
      expect(context.defaultFormattedString, isA<String>());
      expect(context.locale, isA<Locale>());
    });
  });
}
