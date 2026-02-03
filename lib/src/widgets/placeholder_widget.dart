import 'package:flutter/material.dart';
import '../models/mcal_calendar_event.dart';
import '../controllers/mcal_event_controller.dart';

/// A simple placeholder widget demonstrating package integration.
///
/// This widget displays basic information about the Multi Calendar package
/// and demonstrates how to use MCalCalendarEvent and MCalEventController.
/// It serves as a verification that the package structure works end-to-end.
///
/// Example:
/// ```dart
/// PlaceholderWidget(
///   controller: eventController,
/// )
/// ```
class PlaceholderWidget extends StatelessWidget {
  /// The event controller instance.
  final MCalEventController controller;

  /// Creates a new [PlaceholderWidget] instance.
  const PlaceholderWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    // Create a sample event to demonstrate usage
    final sampleEvent = MCalCalendarEvent(
      id: 'sample-1',
      title: 'Sample Event',
      start: DateTime.now(),
      end: DateTime.now().add(const Duration(hours: 1)),
      comment: 'This is a sample calendar event',
    );

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Multi Calendar Package',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Package structure is working correctly!',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sample Calendar Event:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('ID: ${sampleEvent.id}'),
                    Text('Title: ${sampleEvent.title}'),
                    Text('Start: ${sampleEvent.start}'),
                    Text('End: ${sampleEvent.end}'),
                    if (sampleEvent.comment != null)
                      Text('Comment: ${sampleEvent.comment}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'MCalEventController is ready for future implementation.',
              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}
