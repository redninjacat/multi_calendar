import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:multi_calendar/multi_calendar.dart';

/// Predefined event colors for the form dialog.
const List<Color> _eventFormColors = [
  Color(0xFF6366F1), // Indigo
  Color(0xFF10B981), // Emerald
  Color(0xFFF59E0B), // Amber
  Color(0xFFEF4444), // Red
  Color(0xFF8B5CF6), // Violet
  Color(0xFF06B6D4), // Cyan
  Color(0xFFEC4899), // Pink
  Color(0xFF0EA5E9), // Sky
  Color(0xFFF97316), // Orange
  Color(0xFFD946EF), // Fuchsia
];

/// Shows a dialog to create a new event at the given [displayDate] and [initialTime].
///
/// Returns the created [MCalCalendarEvent] or null if cancelled.
/// Uses [initialTime] for start; end defaults to start + 1 hour.
Future<MCalCalendarEvent?> showDayViewEventCreateDialog(
  BuildContext context, {
  required DateTime displayDate,
  required DateTime initialTime,
}) {
  final d = DateTime(displayDate.year, displayDate.month, displayDate.day);
  final start = DateTime(
    d.year,
    d.month,
    d.day,
    initialTime.hour,
    initialTime.minute,
  );
  final end = start.add(const Duration(hours: 1));
  return _DayViewEventFormDialog.show(
    context,
    displayDate: displayDate,
    initialEvent: null,
    initialStart: start,
    initialEnd: end,
    isCreate: true,
  );
}

/// Shows a dialog to edit an existing [event].
///
/// Returns the updated [MCalCalendarEvent] or null if cancelled.
Future<MCalCalendarEvent?> showDayViewEventEditDialog(
  BuildContext context, {
  required MCalCalendarEvent event,
  required DateTime displayDate,
}) {
  return _DayViewEventFormDialog.show(
    context,
    displayDate: displayDate,
    initialEvent: event,
    initialStart: event.start,
    initialEnd: event.end,
    isCreate: false,
  );
}

/// Internal form dialog for creating or editing Day View events.
class _DayViewEventFormDialog extends StatefulWidget {
  const _DayViewEventFormDialog({
    required this.displayDate,
    this.initialEvent,
    required this.initialStart,
    required this.initialEnd,
    required this.isCreate,
  });

  final DateTime displayDate;
  final MCalCalendarEvent? initialEvent;
  final DateTime initialStart;
  final DateTime initialEnd;
  final bool isCreate;

  static Future<MCalCalendarEvent?> show(
    BuildContext context, {
    required DateTime displayDate,
    MCalCalendarEvent? initialEvent,
    required DateTime initialStart,
    required DateTime initialEnd,
    required bool isCreate,
  }) {
    return showDialog<MCalCalendarEvent>(
      context: context,
      builder: (ctx) => _DayViewEventFormDialog(
        displayDate: displayDate,
        initialEvent: initialEvent,
        initialStart: initialStart,
        initialEnd: initialEnd,
        isCreate: isCreate,
      ),
    );
  }

  @override
  State<_DayViewEventFormDialog> createState() =>
      _DayViewEventFormDialogState();
}

class _DayViewEventFormDialogState extends State<_DayViewEventFormDialog> {
  late TextEditingController _titleController;
  late DateTime _start;
  late DateTime _end;
  late bool _isAllDay;
  late Color _selectedColor;
  String? _titleError;
  String? _timeError;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.initialEvent?.title ?? '',
    );
    _start = widget.initialStart;
    _end = widget.initialEnd;
    _isAllDay = widget.initialEvent?.isAllDay ?? false;
    _selectedColor = widget.initialEvent?.color ?? _eventFormColors.first;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  bool _validate() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() {
        _titleError = 'Title is required';
        _timeError = null;
      });
      return false;
    }
    // For timed events, end must be after start. For all-day, allow same day (start == end).
    if (!_isAllDay &&
        (_end.isBefore(_start) || _end.isAtSameMomentAs(_start))) {
      setState(() {
        _titleError = null;
        _timeError = 'End time must be after start time';
      });
      return false;
    }
    setState(() {
      _titleError = null;
      _timeError = null;
    });
    return true;
  }

  void _save() {
    if (!_validate()) return;

    final title = _titleController.text.trim();
    final id =
        widget.initialEvent?.id ??
        'day-event-${DateTime.now().millisecondsSinceEpoch}';
    final event = MCalCalendarEvent(
      id: id,
      title: title,
      start: _start,
      end: _end,
      isAllDay: _isAllDay,
      color: _selectedColor,
      comment: widget.initialEvent?.comment,
    );
    Navigator.of(context).pop(event);
  }

  Future<void> _pickStart() async {
    if (_isAllDay) {
      final date = await showDatePicker(
        context: context,
        initialDate: _start,
        firstDate: widget.displayDate.subtract(const Duration(days: 365)),
        lastDate: widget.displayDate.add(const Duration(days: 365)),
      );
      if (date != null && mounted) {
        setState(() {
          _start = DateTime(date.year, date.month, date.day, 0, 0);
          if (_end.isBefore(_start)) {
            _end = DateTime(date.year, date.month, date.day, 0, 0);
          }
        });
      }
    } else {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(hour: _start.hour, minute: _start.minute),
      );
      if (time != null && mounted) {
        setState(() {
          _start = DateTime(
            _start.year,
            _start.month,
            _start.day,
            time.hour,
            time.minute,
          );
          if (_end.isBefore(_start)) {
            _end = _start.add(const Duration(hours: 1));
          }
        });
      }
    }
  }

  Future<void> _pickEnd() async {
    if (_isAllDay) {
      final date = await showDatePicker(
        context: context,
        initialDate: _end,
        firstDate: _start,
        lastDate: widget.displayDate.add(const Duration(days: 365)),
      );
      if (date != null && mounted) {
        setState(() {
          _end = DateTime(date.year, date.month, date.day, 0, 0);
        });
      }
    } else {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(hour: _end.hour, minute: _end.minute),
      );
      if (time != null && mounted) {
        setState(() {
          _end = DateTime(
            _end.year,
            _end.month,
            _end.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dateFormat = DateFormat.yMd();
    final timeFormat = DateFormat.jm();

    return AlertDialog(
      title: Text(widget.isCreate ? 'New Event' : 'Edit Event'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                errorText: _titleError,
                border: const OutlineInputBorder(),
              ),
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            // All-day toggle
            CheckboxListTile(
              value: _isAllDay,
              onChanged: (v) {
                setState(() {
                  _isAllDay = v ?? false;
                  if (_isAllDay) {
                    _start = DateTime(
                      _start.year,
                      _start.month,
                      _start.day,
                      0,
                      0,
                    );
                    _end = DateTime(_end.year, _end.month, _end.day, 0, 0);
                  } else {
                    _start = DateTime(
                      _start.year,
                      _start.month,
                      _start.day,
                      9,
                      0,
                    );
                    _end = _start.add(const Duration(hours: 1));
                  }
                });
              },
              title: const Text('All-day event'),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: 8),
            // Start
            ListTile(
              leading: Icon(
                Icons.access_time,
                color: colorScheme.onSurfaceVariant,
              ),
              title: Text(
                _isAllDay
                    ? dateFormat.format(_start)
                    : '${dateFormat.format(_start)} ${timeFormat.format(_start)}',
              ),
              trailing: const Icon(Icons.edit),
              onTap: _pickStart,
            ),
            // End
            ListTile(
              leading: Icon(
                Icons.access_time_filled,
                color: colorScheme.onSurfaceVariant,
              ),
              title: Text(
                _isAllDay
                    ? dateFormat.format(_end)
                    : '${dateFormat.format(_end)} ${timeFormat.format(_end)}',
              ),
              trailing: const Icon(Icons.edit),
              onTap: _pickEnd,
            ),
            if (_timeError != null) ...[
              Text(
                _timeError!,
                style: TextStyle(color: colorScheme.error, fontSize: 12),
              ),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 16),
            // Color picker
            Text('Color', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _eventFormColors.map((c) {
                final isSelected = c == _selectedColor;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = c),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: colorScheme.onSurface, width: 3)
                          : null,
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check,
                            size: 18,
                            color:
                                ThemeData.estimateBrightnessForColor(c) ==
                                    Brightness.dark
                                ? Colors.white
                                : Colors.black,
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _save,
          child: Text(widget.isCreate ? 'Create' : 'Save'),
        ),
      ],
    );
  }
}
