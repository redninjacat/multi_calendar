import 'package:flutter/material.dart';

/// Predefined event colors for consistent styling across the app.
const List<Color> eventColors = [
  Color(0xFF6366F1), // Indigo
  Color(0xFF10B981), // Emerald
  Color(0xFFF59E0B), // Amber
  Color(0xFFEF4444), // Red
  Color(0xFF8B5CF6), // Violet
  Color(0xFF06B6D4), // Cyan
];

/// Gets a consistent color for an event based on its ID.
///
/// Uses a hash of the event ID to deterministically select a color
/// from the [eventColors] palette. The same event ID will always
/// return the same color.
Color getEventColor(String eventId) {
  final hash = eventId.hashCode.abs();
  return eventColors[hash % eventColors.length];
}
