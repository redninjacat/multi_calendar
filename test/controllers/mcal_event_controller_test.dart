import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:multi_calendar/multi_calendar.dart';

void main() {
  group('MCalEventController', () {
    test('creates instance successfully', () {
      final controller = MCalEventController();
      expect(controller, isNotNull);
    });

    test('loadEvents returns empty list initially', () async {
      final controller = MCalEventController();
      final start = DateTime(2024, 1, 1);
      final end = DateTime(2024, 1, 31);

      final events = await controller.loadEvents(start, end);
      expect(events, isEmpty);
    });

    test('getVisibleDateRange returns null initially', () {
      final controller = MCalEventController();
      expect(controller.getVisibleDateRange(), isNull);
    });

    test('setVisibleDateRange updates visible range and notifies listeners', () {
      final controller = MCalEventController();
      final range = DateTimeRange(
        start: DateTime(2024, 1, 1),
        end: DateTime(2024, 1, 31),
      );

      var notified = false;
      controller.addListener(() => notified = true);

      controller.setVisibleDateRange(range);
      
      expect(controller.getVisibleDateRange(), equals(range));
      expect(notified, isTrue);
    });

    test('addEvents adds events to cache', () {
      final controller = MCalEventController();
      final event = MCalCalendarEvent(
        id: 'test-1',
        title: 'Test Event',
        start: DateTime(2024, 1, 15, 10, 0),
        end: DateTime(2024, 1, 15, 11, 0),
      );

      controller.addEvents([event]);
      
      expect(controller.allEvents, contains(event));
      expect(controller.allEvents.length, 1);
    });

    test('removeEvents removes events from cache', () {
      final controller = MCalEventController();
      final event = MCalCalendarEvent(
        id: 'test-1',
        title: 'Test Event',
        start: DateTime(2024, 1, 15, 10, 0),
        end: DateTime(2024, 1, 15, 11, 0),
      );

      controller.addEvents([event]);
      expect(controller.allEvents.length, 1);
      
      controller.removeEvents(['test-1']);
      expect(controller.allEvents, isEmpty);
    });

    test('clearEvents removes all events', () {
      final controller = MCalEventController();
      final events = [
        MCalCalendarEvent(
          id: 'test-1',
          title: 'Event 1',
          start: DateTime(2024, 1, 15),
          end: DateTime(2024, 1, 15, 1),
        ),
        MCalCalendarEvent(
          id: 'test-2',
          title: 'Event 2',
          start: DateTime(2024, 1, 16),
          end: DateTime(2024, 1, 16, 1),
        ),
      ];

      controller.addEvents(events);
      expect(controller.allEvents.length, 2);
      
      controller.clearEvents();
      expect(controller.allEvents, isEmpty);
    });

    test('getEventsForRange returns events within range', () {
      final controller = MCalEventController();
      final event1 = MCalCalendarEvent(
        id: 'test-1',
        title: 'January Event',
        start: DateTime(2024, 1, 15),
        end: DateTime(2024, 1, 15, 1),
      );
      final event2 = MCalCalendarEvent(
        id: 'test-2',
        title: 'February Event',
        start: DateTime(2024, 2, 15),
        end: DateTime(2024, 2, 15, 1),
      );

      controller.addEvents([event1, event2]);

      final januaryRange = DateTimeRange(
        start: DateTime(2024, 1, 1),
        end: DateTime(2024, 1, 31, 23, 59, 59),
      );
      
      final januaryEvents = controller.getEventsForRange(januaryRange);
      expect(januaryEvents.length, 1);
      expect(januaryEvents.first.id, 'test-1');
    });

    test('getEventsForDate returns events on specific date', () {
      final controller = MCalEventController();
      final event = MCalCalendarEvent(
        id: 'test-1',
        title: 'Test Event',
        start: DateTime(2024, 1, 15, 10, 0),
        end: DateTime(2024, 1, 15, 11, 0),
      );

      controller.addEvents([event]);

      final events = controller.getEventsForDate(DateTime(2024, 1, 15));
      expect(events.length, 1);
      expect(events.first.id, 'test-1');

      final noEvents = controller.getEventsForDate(DateTime(2024, 1, 16));
      expect(noEvents, isEmpty);
    });

    test('extends ChangeNotifier and supports listeners', () {
      final controller = MCalEventController();
      var notified = false;

      controller.addListener(() {
        notified = true;
      });

      controller.notifyListeners();
      expect(notified, isTrue);
    });

    test('can remove listeners', () {
      final controller = MCalEventController();
      var notified = false;

      void listener() {
        notified = true;
      }

      controller.addListener(listener);
      controller.removeListener(listener);
      controller.notifyListeners();

      expect(notified, isFalse);
    });

    test('notifies listeners when events are added', () {
      final controller = MCalEventController();
      var notified = false;
      controller.addListener(() => notified = true);

      controller.addEvents([
        MCalCalendarEvent(
          id: 'test-1',
          title: 'Test',
          start: DateTime(2024, 1, 15),
          end: DateTime(2024, 1, 15, 1),
        ),
      ]);

      expect(notified, isTrue);
    });

    // ============================================================
    // Task 1: displayDate and focusedDate tests
    // ============================================================

    group('displayDate and focusedDate', () {
      test('displayDate getter returns DateTime.now() initially (same day)', () {
        final controller = MCalEventController();
        final now = DateTime.now();

        expect(controller.displayDate.year, equals(now.year));
        expect(controller.displayDate.month, equals(now.month));
        expect(controller.displayDate.day, equals(now.day));
      });

      test('focusedDate getter returns null initially', () {
        final controller = MCalEventController();
        expect(controller.focusedDate, isNull);
      });

      test('setDisplayDate() updates displayDate', () {
        final controller = MCalEventController();
        final newDate = DateTime(2024, 6, 15);

        controller.setDisplayDate(newDate);

        expect(controller.displayDate, equals(newDate));
      });

      test('setDisplayDate() calls notifyListeners only when value changes', () {
        final controller = MCalEventController();
        final newDate = DateTime(2024, 6, 15);
        var notifyCount = 0;
        controller.addListener(() => notifyCount++);

        // First call should notify
        controller.setDisplayDate(newDate);
        expect(notifyCount, equals(1));

        // Second call with same value should NOT notify
        controller.setDisplayDate(newDate);
        expect(notifyCount, equals(1));

        // Third call with different value should notify
        controller.setDisplayDate(DateTime(2024, 7, 20));
        expect(notifyCount, equals(2));
      });

      test('setFocusedDate() updates focusedDate', () {
        final controller = MCalEventController();
        final focusDate = DateTime(2024, 6, 15);

        controller.setFocusedDate(focusDate);

        expect(controller.focusedDate, equals(focusDate));
      });

      test('setFocusedDate(null) clears focusedDate', () {
        final controller = MCalEventController();
        final focusDate = DateTime(2024, 6, 15);

        // Set a focus date first
        controller.setFocusedDate(focusDate);
        expect(controller.focusedDate, equals(focusDate));

        // Clear it
        controller.setFocusedDate(null);
        expect(controller.focusedDate, isNull);
      });

      test('setFocusedDate() notifies only when value changes', () {
        final controller = MCalEventController();
        final focusDate = DateTime(2024, 6, 15);
        var notifyCount = 0;
        controller.addListener(() => notifyCount++);

        // First call should notify
        controller.setFocusedDate(focusDate);
        expect(notifyCount, equals(1));

        // Same value should NOT notify
        controller.setFocusedDate(focusDate);
        expect(notifyCount, equals(1));

        // Different value should notify
        controller.setFocusedDate(DateTime(2024, 7, 20));
        expect(notifyCount, equals(2));

        // Setting to null should notify
        controller.setFocusedDate(null);
        expect(notifyCount, equals(3));

        // Setting to null again should NOT notify
        controller.setFocusedDate(null);
        expect(notifyCount, equals(3));
      });

      test('navigateToDate(date, focus: true) sets both displayDate and focusedDate', () {
        final controller = MCalEventController();
        final navDate = DateTime(2024, 6, 15);

        controller.navigateToDate(navDate, focus: true);

        expect(controller.displayDate, equals(navDate));
        expect(controller.focusedDate, equals(navDate));
      });

      test('navigateToDate(date, focus: false) sets only displayDate', () {
        final controller = MCalEventController();
        final navDate = DateTime(2024, 6, 15);

        // Set an initial focused date
        controller.setFocusedDate(DateTime(2024, 5, 10));
        final originalFocused = controller.focusedDate;

        // Navigate without focus
        controller.navigateToDate(navDate, focus: false);

        expect(controller.displayDate, equals(navDate));
        expect(controller.focusedDate, equals(originalFocused));
      });

      test('navigateToDate() only notifies once even when setting both', () {
        final controller = MCalEventController();
        final navDate = DateTime(2024, 6, 15);
        var notifyCount = 0;
        controller.addListener(() => notifyCount++);

        // Navigate with focus: true (setting both displayDate and focusedDate)
        controller.navigateToDate(navDate, focus: true);

        expect(notifyCount, equals(1));
      });

      test('navigateToDate() does not notify when nothing changes', () {
        final controller = MCalEventController();
        final navDate = DateTime(2024, 6, 15);

        // Set up initial state
        controller.navigateToDate(navDate, focus: true);

        var notifyCount = 0;
        controller.addListener(() => notifyCount++);

        // Navigate to same date - should not notify
        controller.navigateToDate(navDate, focus: true);

        expect(notifyCount, equals(0));
      });

      test('navigateToDate() defaults to focus: true', () {
        final controller = MCalEventController();
        final navDate = DateTime(2024, 6, 15);

        controller.navigateToDate(navDate);

        expect(controller.displayDate, equals(navDate));
        expect(controller.focusedDate, equals(navDate));
      });
    });

    // ============================================================
    // Task 2: loading and error state tests
    // ============================================================

    group('loading and error state', () {
      test('isLoading returns false initially', () {
        final controller = MCalEventController();
        expect(controller.isLoading, isFalse);
      });

      test('error returns null initially', () {
        final controller = MCalEventController();
        expect(controller.error, isNull);
      });

      test('hasError returns false initially', () {
        final controller = MCalEventController();
        expect(controller.hasError, isFalse);
      });

      test('setLoading(true) updates isLoading', () {
        final controller = MCalEventController();

        controller.setLoading(true);

        expect(controller.isLoading, isTrue);
      });

      test('setLoading(false) updates isLoading', () {
        final controller = MCalEventController();

        // Set loading true first
        controller.setLoading(true);
        expect(controller.isLoading, isTrue);

        // Then set to false
        controller.setLoading(false);
        expect(controller.isLoading, isFalse);
      });

      test('setLoading() notifies only when value changes', () {
        final controller = MCalEventController();
        var notifyCount = 0;
        controller.addListener(() => notifyCount++);

        // First call should notify (false -> true)
        controller.setLoading(true);
        expect(notifyCount, equals(1));

        // Same value should NOT notify
        controller.setLoading(true);
        expect(notifyCount, equals(1));

        // Different value should notify (true -> false)
        controller.setLoading(false);
        expect(notifyCount, equals(2));

        // Same value should NOT notify
        controller.setLoading(false);
        expect(notifyCount, equals(2));
      });

      test('setError() sets error and clears loading', () {
        final controller = MCalEventController();
        final error = Exception('Test error');

        // Start loading
        controller.setLoading(true);
        expect(controller.isLoading, isTrue);

        // Set error
        controller.setError(error);

        expect(controller.error, equals(error));
        expect(controller.isLoading, isFalse);
      });

      test('setError() notifies listeners', () {
        final controller = MCalEventController();
        var notified = false;
        controller.addListener(() => notified = true);

        controller.setError(Exception('Test error'));

        expect(notified, isTrue);
      });

      test('hasError returns true when error is set', () {
        final controller = MCalEventController();
        expect(controller.hasError, isFalse);

        controller.setError(Exception('Test error'));

        expect(controller.hasError, isTrue);
      });

      test('clearError() clears error', () {
        final controller = MCalEventController();
        final error = Exception('Test error');

        // Set error first
        controller.setError(error);
        expect(controller.error, equals(error));
        expect(controller.hasError, isTrue);

        // Clear it
        controller.clearError();

        expect(controller.error, isNull);
        expect(controller.hasError, isFalse);
      });

      test('clearError() notifies when error is cleared', () {
        final controller = MCalEventController();
        controller.setError(Exception('Test error'));

        var notified = false;
        controller.addListener(() => notified = true);

        controller.clearError();

        expect(notified, isTrue);
      });

      test('clearError() does not notify when error is already null', () {
        final controller = MCalEventController();
        // Error is already null initially
        expect(controller.error, isNull);

        var notified = false;
        controller.addListener(() => notified = true);

        controller.clearError();

        expect(notified, isFalse);
      });

      test('retryLoad() clears error and calls loadEvents', () async {
        final controller = MCalEventController();
        final error = Exception('Test error');

        // Set an error
        controller.setError(error);
        expect(controller.hasError, isTrue);

        // Retry
        final result = await controller.retryLoad();

        // Error should be cleared
        expect(controller.hasError, isFalse);
        expect(controller.error, isNull);
        // loadEvents is called and returns (empty in base implementation)
        expect(result, isA<List<MCalCalendarEvent>>());
      });

      test('retryLoad() uses displayDate for date range calculation', () async {
        final controller = MCalEventController();
        final testDate = DateTime(2024, 6, 15);
        controller.setDisplayDate(testDate);

        // Add an event in the range that should be loaded
        final event = MCalCalendarEvent(
          id: 'test-1',
          title: 'June Event',
          start: DateTime(2024, 6, 10),
          end: DateTime(2024, 6, 10, 1),
        );
        controller.addEvents([event]);

        // Set and then retry
        controller.setError(Exception('Test'));
        final result = await controller.retryLoad();

        // Should find the event since it's within the 3-month range around displayDate
        expect(result, contains(event));
      });

      test('setError(null) clears the error', () {
        final controller = MCalEventController();

        // Set an error
        controller.setError(Exception('Test error'));
        expect(controller.hasError, isTrue);

        // Set error to null
        controller.setError(null);

        expect(controller.error, isNull);
        expect(controller.hasError, isFalse);
        expect(controller.isLoading, isFalse);
      });
    });

    // ============================================================
    // Task 10: Animation Control Tests
    // ============================================================

    group('animation control', () {
      test('shouldAnimateNextChange returns true by default', () {
        final controller = MCalEventController();
        expect(controller.shouldAnimateNextChange, isTrue);
      });

      test('setDisplayDate with animate:true (default) keeps flag true', () {
        final controller = MCalEventController();
        
        // Default behavior - animate is true by default
        controller.setDisplayDate(DateTime(2025, 2, 15));
        
        // Flag should remain true
        expect(controller.shouldAnimateNextChange, isTrue);
      });

      test('setDisplayDate with animate:false sets flag to false', () {
        final controller = MCalEventController();
        
        // Set display date without animation
        controller.setDisplayDate(DateTime(2025, 2, 15), animate: false);
        
        // Flag should be false
        expect(controller.shouldAnimateNextChange, isFalse);
      });

      test('consumeAnimationFlag() resets flag to true', () {
        final controller = MCalEventController();
        
        // Set flag to false
        controller.setDisplayDate(DateTime(2025, 2, 15), animate: false);
        expect(controller.shouldAnimateNextChange, isFalse);
        
        // Consume the flag
        controller.consumeAnimationFlag();
        
        // Flag should be reset to true
        expect(controller.shouldAnimateNextChange, isTrue);
      });

      test('consumeAnimationFlag() can be called when flag is already true', () {
        final controller = MCalEventController();
        
        // Flag starts as true
        expect(controller.shouldAnimateNextChange, isTrue);
        
        // Consuming should not throw and flag should remain true
        controller.consumeAnimationFlag();
        expect(controller.shouldAnimateNextChange, isTrue);
      });

      test('navigateToDateWithoutAnimation() sets flag to false', () {
        final controller = MCalEventController();
        
        // Use convenience method
        controller.navigateToDateWithoutAnimation(DateTime(2025, 3, 20));
        
        // Flag should be false
        expect(controller.shouldAnimateNextChange, isFalse);
        
        // Display date should be updated
        expect(controller.displayDate, equals(DateTime(2025, 3, 20)));
      });

      test('navigateToDateWithoutAnimation() notifies listeners', () {
        final controller = MCalEventController();
        var notifyCount = 0;
        controller.addListener(() => notifyCount++);
        
        controller.navigateToDateWithoutAnimation(DateTime(2025, 3, 20));
        
        expect(notifyCount, equals(1));
      });

      test('setDisplayDate animate:false only affects the next navigation', () {
        final controller = MCalEventController();
        
        // First navigation without animation
        controller.setDisplayDate(DateTime(2025, 2, 15), animate: false);
        expect(controller.shouldAnimateNextChange, isFalse);
        
        // Consume the flag
        controller.consumeAnimationFlag();
        expect(controller.shouldAnimateNextChange, isTrue);
        
        // Second navigation with default animation
        controller.setDisplayDate(DateTime(2025, 3, 20));
        
        // Flag should still be true (default behavior)
        expect(controller.shouldAnimateNextChange, isTrue);
      });

      test('multiple setDisplayDate with animate:false keeps flag false until consumed', () {
        final controller = MCalEventController();
        
        // First call with animate:false
        controller.setDisplayDate(DateTime(2025, 2, 15), animate: false);
        expect(controller.shouldAnimateNextChange, isFalse);
        
        // Second call with animate:true (but this won't change anything if date is same)
        // Use a different date
        controller.setDisplayDate(DateTime(2025, 3, 20), animate: true);
        
        // Flag should still be false because we didn't consume it
        // and animate:true doesn't reset the flag, it just doesn't set it to false
        // Actually, looking at the implementation, setDisplayDate with animate:true
        // doesn't reset the flag - it only sets to false when animate is false
        // So the flag remains false until consumed
        expect(controller.shouldAnimateNextChange, isFalse);
      });

      test('setDisplayDate with same date does not notify even with animate:false', () {
        final controller = MCalEventController();
        final date = DateTime(2025, 2, 15);
        
        // Set initial date
        controller.setDisplayDate(date);
        
        var notifyCount = 0;
        controller.addListener(() => notifyCount++);
        
        // Set same date with animate:false - should not notify
        controller.setDisplayDate(date, animate: false);
        
        expect(notifyCount, equals(0));
      });

      test('animation flag workflow: set animate:false, consume, then check is true', () {
        final controller = MCalEventController();
        
        // Typical workflow in a view:
        // 1. Controller sets animate:false
        controller.setDisplayDate(DateTime(2025, 2, 15), animate: false);
        
        // 2. View checks flag and consumes it
        final shouldAnimate = controller.shouldAnimateNextChange;
        expect(shouldAnimate, isFalse);
        
        controller.consumeAnimationFlag();
        
        // 3. Next navigation uses default animation
        controller.setDisplayDate(DateTime(2025, 3, 20));
        expect(controller.shouldAnimateNextChange, isTrue);
      });
    });
  });
}
