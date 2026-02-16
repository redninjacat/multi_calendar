import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multi_calendar/multi_calendar.dart';

import '../../l10n/app_localizations.dart';

/// A full-featured Material Design 3 dialog for creating and editing
/// [MCalRecurrenceRule]s.
///
/// Accepts an optional [existing] rule to pre-populate the editor. Returns
/// the configured [MCalRecurrenceRule] via `Navigator.pop`, or `null` if the
/// user cancels or selects "No recurrence".
///
/// Usage:
/// ```dart
/// final rule = await RecurrenceEditorDialog.show(context);
/// if (rule != null) { /* use the rule */ }
/// ```
class RecurrenceEditorDialog extends StatefulWidget {
  const RecurrenceEditorDialog({super.key, this.existing});

  /// An existing rule to edit. When `null`, the editor starts with defaults
  /// for creating a new rule.
  final MCalRecurrenceRule? existing;

  /// Shows the dialog and returns the user's configured [MCalRecurrenceRule],
  /// or `null` if cancelled.
  static Future<MCalRecurrenceRule?> show(
    BuildContext context, {
    MCalRecurrenceRule? existing,
  }) {
    return showDialog<MCalRecurrenceRule>(
      context: context,
      builder: (_) => RecurrenceEditorDialog(existing: existing),
    );
  }

  @override
  State<RecurrenceEditorDialog> createState() => _RecurrenceEditorDialogState();
}

/// The three possible end-condition modes for a recurrence rule.
enum _EndCondition { never, afterCount, untilDate }

class _RecurrenceEditorDialogState extends State<RecurrenceEditorDialog> {
  // ── Core fields ──────────────────────────────────────────────────────────
  MCalFrequency _frequency = MCalFrequency.weekly;
  late TextEditingController _intervalController;
  int _weekStart = DateTime.monday;

  // ── Day-of-week (weekly) ─────────────────────────────────────────────────
  final Set<int> _selectedWeekDays = {};

  // ── Day-of-month (monthly) ───────────────────────────────────────────────
  final Set<int> _selectedMonthDays = {};

  // ── Day-of-year (yearly) ────────────────────────────────────────────────
  final Set<int> _selectedYearDays = {};

  // ── Week numbers (yearly) ───────────────────────────────────────────────
  final Set<int> _selectedWeekNumbers = {};

  // ── End condition ────────────────────────────────────────────────────────
  _EndCondition _endCondition = _EndCondition.never;
  late TextEditingController _countController;
  DateTime _untilDate = DateTime.now().add(const Duration(days: 365));

  // ── Validation ───────────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final rule = widget.existing;

    if (rule != null) {
      _frequency = rule.frequency;
      _intervalController =
          TextEditingController(text: rule.interval.toString());
      _weekStart = rule.weekStart;

      // Week days
      if (rule.byWeekDays != null) {
        for (final wd in rule.byWeekDays!) {
          _selectedWeekDays.add(wd.dayOfWeek);
        }
      }

      // Month days
      if (rule.byMonthDays != null) {
        _selectedMonthDays.addAll(rule.byMonthDays!);
      }

      // Year days
      if (rule.byYearDays != null) {
        _selectedYearDays.addAll(rule.byYearDays!);
      }

      // Week numbers
      if (rule.byWeekNumbers != null) {
        _selectedWeekNumbers.addAll(rule.byWeekNumbers!);
      }

      // End condition
      if (rule.count != null) {
        _endCondition = _EndCondition.afterCount;
        _countController =
            TextEditingController(text: rule.count.toString());
      } else if (rule.until != null) {
        _endCondition = _EndCondition.untilDate;
        _untilDate = rule.until!;
        _countController = TextEditingController(text: '10');
      } else {
        _endCondition = _EndCondition.never;
        _countController = TextEditingController(text: '10');
      }
    } else {
      _intervalController = TextEditingController(text: '1');
      _countController = TextEditingController(text: '10');
    }
  }

  @override
  void dispose() {
    _intervalController.dispose();
    _countController.dispose();
    super.dispose();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  String _frequencyUnitLabel(MCalFrequency freq, AppLocalizations l10n) {
    return switch (freq) {
      MCalFrequency.daily => l10n.recurrenceDays,
      MCalFrequency.weekly => l10n.recurrenceWeeks,
      MCalFrequency.monthly => l10n.recurrenceMonths,
      MCalFrequency.yearly => l10n.recurrenceYears,
    };
  }

  String _weekDayShortLabel(int day, AppLocalizations l10n) {
    return switch (day) {
      DateTime.monday => l10n.recurrenceMondayShort,
      DateTime.tuesday => l10n.recurrenceTuesdayShort,
      DateTime.wednesday => l10n.recurrenceWednesdayShort,
      DateTime.thursday => l10n.recurrenceThursdayShort,
      DateTime.friday => l10n.recurrenceFridayShort,
      DateTime.saturday => l10n.recurrenceSaturdayShort,
      DateTime.sunday => l10n.recurrenceSundayShort,
      _ => '?',
    };
  }

  String _weekDayFullLabel(int day, AppLocalizations l10n) {
    return switch (day) {
      DateTime.monday => l10n.recurrenceMonday,
      DateTime.tuesday => l10n.recurrenceTuesday,
      DateTime.wednesday => l10n.recurrenceWednesday,
      DateTime.thursday => l10n.recurrenceThursday,
      DateTime.friday => l10n.recurrenceFriday,
      DateTime.saturday => l10n.recurrenceSaturday,
      DateTime.sunday => l10n.recurrenceSunday,
      _ => '?',
    };
  }

  // ── Build the rule from the current state ────────────────────────────────
  MCalRecurrenceRule? _buildRule() {
    if (!(_formKey.currentState?.validate() ?? false)) return null;

    final interval = int.tryParse(_intervalController.text.trim()) ?? 1;

    Set<MCalWeekDay>? byWeekDays;
    if (_frequency == MCalFrequency.weekly && _selectedWeekDays.isNotEmpty) {
      byWeekDays = _selectedWeekDays
          .map((d) => MCalWeekDay.every(d))
          .toSet();
    }

    List<int>? byMonthDays;
    if (_frequency == MCalFrequency.monthly &&
        _selectedMonthDays.isNotEmpty) {
      byMonthDays = _selectedMonthDays.toList()..sort();
    }

    List<int>? byYearDays;
    if (_frequency == MCalFrequency.yearly && _selectedYearDays.isNotEmpty) {
      byYearDays = _selectedYearDays.toList()..sort();
    }

    List<int>? byWeekNumbers;
    if (_frequency == MCalFrequency.yearly && _selectedWeekNumbers.isNotEmpty) {
      byWeekNumbers = _selectedWeekNumbers.toList()..sort();
    }

    int? count;
    DateTime? until;
    switch (_endCondition) {
      case _EndCondition.never:
        break;
      case _EndCondition.afterCount:
        count = int.tryParse(_countController.text.trim()) ?? 10;
        if (count < 1) count = 1;
        break;
      case _EndCondition.untilDate:
        until = _untilDate;
        break;
    }

    return MCalRecurrenceRule(
      frequency: _frequency,
      interval: interval,
      count: count,
      until: until,
      byWeekDays: byWeekDays,
      byMonthDays: byMonthDays,
      byYearDays: byYearDays,
      byWeekNumbers: byWeekNumbers,
      weekStart: _weekStart,
    );
  }

  // ── UI ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Header ───────────────────────────────────────────────
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                ),
                child: Row(
                  children: [
                    Icon(Icons.repeat, color: colorScheme.onPrimaryContainer),
                    const SizedBox(width: 12),
                    Text(
                      widget.existing != null
                          ? l10n.recurrenceEditTitle
                          : l10n.recurrenceAddTitle,
                      style: textTheme.titleLarge?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Scrollable body ──────────────────────────────────────
              Flexible(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Frequency picker ─────────────────────────────
                      _buildSectionLabel(context, l10n.recurrenceFrequency),
                      const SizedBox(height: 8),
                      _buildFrequencyPicker(colorScheme, l10n),

                      const SizedBox(height: 20),

                      // ── Interval input ───────────────────────────────
                      _buildSectionLabel(context, l10n.recurrenceRepeatEvery),
                      const SizedBox(height: 8),
                      _buildIntervalInput(colorScheme, l10n),

                      // ── Day-of-week selector (weekly only) ───────────
                      if (_frequency == MCalFrequency.weekly) ...[
                        const SizedBox(height: 20),
                        _buildSectionLabel(context, l10n.recurrenceOnDays),
                        const SizedBox(height: 8),
                        _buildWeekDaySelector(colorScheme, l10n),
                      ],

                      // ── Day-of-month selector (monthly only) ─────────
                      if (_frequency == MCalFrequency.monthly) ...[
                        const SizedBox(height: 20),
                        _buildSectionLabel(context, l10n.recurrenceOnDaysOfMonth),
                        const SizedBox(height: 8),
                        _buildMonthDaySelector(colorScheme),
                      ],

                      // ── Day-of-year selector (yearly only) ───────────
                      if (_frequency == MCalFrequency.yearly) ...[
                        const SizedBox(height: 20),
                        _buildSectionLabel(context, l10n.recurrenceOnDaysOfYear),
                        const SizedBox(height: 4),
                        Text(
                          l10n.recurrenceDaysOfYearHint,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: 8),
                        _buildYearDaySelector(colorScheme, l10n),
                      ],

                      // ── Week number selector (yearly only) ────────────
                      if (_frequency == MCalFrequency.yearly) ...[
                        const SizedBox(height: 20),
                        _buildSectionLabel(context, l10n.recurrenceInWeekNumbers),
                        const SizedBox(height: 4),
                        Text(
                          l10n.recurrenceWeekNumbersHint,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: 8),
                        _buildWeekNumberSelector(colorScheme, l10n),
                      ],

                      const SizedBox(height: 20),

                      // ── End condition ────────────────────────────────
                      _buildSectionLabel(context, l10n.recurrenceEnds),
                      const SizedBox(height: 8),
                      _buildEndConditionSection(colorScheme, l10n),

                      const SizedBox(height: 20),

                      // ── Week start dropdown ──────────────────────────
                      _buildSectionLabel(context, l10n.recurrenceWeekStartsOn),
                      const SizedBox(height: 8),
                      _buildWeekStartDropdown(colorScheme, l10n),
                    ],
                  ),
                ),
              ),

              // ── Action buttons ───────────────────────────────────────
              const Divider(height: 1),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(l10n.cancel),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: _onSave,
                      icon: const Icon(Icons.check, size: 18),
                      label: Text(l10n.dialogSave),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Section label ────────────────────────────────────────────────────────

  Widget _buildSectionLabel(BuildContext context, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    return Text(
      label,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
    );
  }

  // ── Frequency picker ─────────────────────────────────────────────────────

  Widget _buildFrequencyPicker(ColorScheme colorScheme, AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<MCalFrequency>(
        segments: MCalFrequency.values.map((freq) {
          final label = switch (freq) {
            MCalFrequency.daily => l10n.recurrenceFrequencyDaily,
            MCalFrequency.weekly => l10n.recurrenceFrequencyWeekly,
            MCalFrequency.monthly => l10n.recurrenceFrequencyMonthly,
            MCalFrequency.yearly => l10n.recurrenceFrequencyYearly,
          };
          return ButtonSegment<MCalFrequency>(
            value: freq,
            label: Text(
              label,
              style: const TextStyle(fontSize: 13),
            ),
          );
        }).toList(),
        selected: {_frequency},
        onSelectionChanged: (selected) {
          setState(() => _frequency = selected.first);
        },
        showSelectedIcon: false,
        style: ButtonStyle(
          visualDensity: VisualDensity.compact,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ),
    );
  }

  // ── Interval input ───────────────────────────────────────────────────────

  Widget _buildIntervalInput(ColorScheme colorScheme, AppLocalizations l10n) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: TextFormField(
            controller: _intervalController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            validator: (value) {
              final n = int.tryParse(value?.trim() ?? '');
              if (n == null || n < 1) return l10n.recurrenceValidationMin1;
              return null;
            },
          ),
        ),
        const SizedBox(width: 12),
        Text(
          _frequencyUnitLabel(_frequency, l10n),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface,
              ),
        ),
      ],
    );
  }

  // ── Day-of-week selector ─────────────────────────────────────────────────

  Widget _buildWeekDaySelector(ColorScheme colorScheme, AppLocalizations l10n) {
    final days = [
      DateTime.monday,
      DateTime.tuesday,
      DateTime.wednesday,
      DateTime.thursday,
      DateTime.friday,
      DateTime.saturday,
      DateTime.sunday,
    ];

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: days.map((day) {
        final selected = _selectedWeekDays.contains(day);
        return FilterChip(
          label: Text(_weekDayShortLabel(day, l10n)),
          selected: selected,
          onSelected: (value) {
            setState(() {
              if (value) {
                _selectedWeekDays.add(day);
              } else {
                _selectedWeekDays.remove(day);
              }
            });
          },
          selectedColor: colorScheme.primaryContainer,
          checkmarkColor: colorScheme.onPrimaryContainer,
          labelStyle: TextStyle(
            color: selected
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurfaceVariant,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          visualDensity: VisualDensity.compact,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        );
      }).toList(),
    );
  }

  // ── Day-of-month selector ────────────────────────────────────────────────

  Widget _buildMonthDaySelector(ColorScheme colorScheme) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: List.generate(31, (i) {
        final day = i + 1;
        final selected = _selectedMonthDays.contains(day);
        return FilterChip(
          label: Text(
            day.toString(),
            style: TextStyle(
              fontSize: 12,
              color: selected
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurfaceVariant,
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          selected: selected,
          onSelected: (value) {
            setState(() {
              if (value) {
                _selectedMonthDays.add(day);
              } else {
                _selectedMonthDays.remove(day);
              }
            });
          },
          selectedColor: colorScheme.primaryContainer,
          checkmarkColor: colorScheme.onPrimaryContainer,
          padding: const EdgeInsets.symmetric(horizontal: 2),
          labelPadding: const EdgeInsets.symmetric(horizontal: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          visualDensity: VisualDensity.compact,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        );
      }),
    );
  }

  // ── Day-of-year selector ────────────────────────────────────────────────

  Widget _buildYearDaySelector(ColorScheme colorScheme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: (_selectedYearDays.toList()..sort()).map((day) {
            return Chip(
              label: Text(l10n.recurrenceDay(day)),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () {
                setState(() => _selectedYearDays.remove(day));
              },
              backgroundColor: colorScheme.primaryContainer,
              labelStyle: TextStyle(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        _buildNumberEntryRow(
          colorScheme: colorScheme,
          hintText: l10n.recurrenceDayPlaceholder,
          onAdd: (value) {
            if (value >= -366 && value <= 366 && value != 0) {
              setState(() => _selectedYearDays.add(value));
            }
          },
        ),
      ],
    );
  }

  // ── Week number selector ────────────────────────────────────────────────

  Widget _buildWeekNumberSelector(ColorScheme colorScheme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: (_selectedWeekNumbers.toList()..sort()).map((week) {
            return Chip(
              label: Text(l10n.recurrenceWeek(week)),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () {
                setState(() => _selectedWeekNumbers.remove(week));
              },
              backgroundColor: colorScheme.primaryContainer,
              labelStyle: TextStyle(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        _buildNumberEntryRow(
          colorScheme: colorScheme,
          hintText: l10n.recurrenceWeekPlaceholder,
          onAdd: (value) {
            if (value >= -53 && value <= 53 && value != 0) {
              setState(() => _selectedWeekNumbers.add(value));
            }
          },
        ),
      ],
    );
  }

  // ── Shared number entry row ─────────────────────────────────────────────

  Widget _buildNumberEntryRow({
    required ColorScheme colorScheme,
    required String hintText,
    required void Function(int value) onAdd,
  }) {
    final textController = TextEditingController();

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: textController,
            keyboardType: const TextInputType.numberWithOptions(signed: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[-\d]')),
            ],
            decoration: InputDecoration(
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              hintText: hintText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filled(
          onPressed: () {
            final value = int.tryParse(textController.text.trim());
            if (value != null) {
              onAdd(value);
              textController.clear();
            }
          },
          icon: const Icon(Icons.add, size: 20),
          style: IconButton.styleFrom(
            padding: const EdgeInsets.all(8),
            visualDensity: VisualDensity.compact,
          ),
        ),
      ],
    );
  }

  // ── End condition ────────────────────────────────────────────────────────

  Widget _buildEndConditionSection(ColorScheme colorScheme, AppLocalizations l10n) {
    return RadioGroup<_EndCondition>(
      groupValue: _endCondition,
      onChanged: (v) {
        if (v != null) setState(() => _endCondition = v);
      },
      child: Column(
        children: [
        // ── Never ──
        _buildEndConditionTile(
          colorScheme: colorScheme,
          l10n: l10n,
          value: _EndCondition.never,
          title: l10n.recurrenceEndsNever,
          subtitle: l10n.recurrenceEndsNeverSubtitle,
          icon: Icons.all_inclusive,
        ),

        // ── After N occurrences ──
        _buildEndConditionTile(
          colorScheme: colorScheme,
          l10n: l10n,
          value: _EndCondition.afterCount,
          title: l10n.recurrenceEndsAfter,
          icon: Icons.pin,
          trailing: _endCondition == _EndCondition.afterCount
              ? _buildCountInput(colorScheme, l10n)
              : null,
        ),

        // ── Until date ──
        _buildEndConditionTile(
          colorScheme: colorScheme,
          l10n: l10n,
          value: _EndCondition.untilDate,
          title: l10n.recurrenceEndsOnDate,
          icon: Icons.calendar_today,
          trailing: _endCondition == _EndCondition.untilDate
              ? _buildUntilDateButton(colorScheme)
              : null,
        ),
      ],
      ),
    );
  }

  Widget _buildEndConditionTile({
    required ColorScheme colorScheme,
    required AppLocalizations l10n,
    required _EndCondition value,
    required String title,
    String? subtitle,
    required IconData icon,
    Widget? trailing,
  }) {
    final isSelected = _endCondition == value;
    return Material(
      color: isSelected
          ? colorScheme.primaryContainer.withAlpha(80)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => setState(() => _endCondition = value),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              Radio<_EndCondition>(
                value: value,
                visualDensity: VisualDensity.compact,
              ),
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected
                            ? colorScheme.onSurface
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                  ],
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCountInput(ColorScheme colorScheme, AppLocalizations l10n) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 64,
          child: TextFormField(
            controller: _countController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            validator: (value) {
              if (_endCondition != _EndCondition.afterCount) return null;
              final n = int.tryParse(value?.trim() ?? '');
              if (n == null || n < 1) return l10n.recurrenceValidationMin1;
              return null;
            },
          ),
        ),
        const SizedBox(width: 6),
        Text(
          l10n.recurrenceTimes,
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildUntilDateButton(ColorScheme colorScheme) {
    return OutlinedButton.icon(
      onPressed: _pickUntilDate,
      icon: const Icon(Icons.edit_calendar, size: 16),
      label: Text(
        '${_untilDate.month}/${_untilDate.day}/${_untilDate.year}',
        style: const TextStyle(fontSize: 13),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        visualDensity: VisualDensity.compact,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _pickUntilDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _untilDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) {
      setState(() => _untilDate = picked);
    }
  }

  // ── Week start dropdown ──────────────────────────────────────────────────

  Widget _buildWeekStartDropdown(ColorScheme colorScheme, AppLocalizations l10n) {
    final days = [
      DateTime.monday,
      DateTime.tuesday,
      DateTime.wednesday,
      DateTime.thursday,
      DateTime.friday,
      DateTime.saturday,
      DateTime.sunday,
    ];

    return DropdownButtonFormField<int>(
      value: _weekStart,
      items: days.map((day) {
        return DropdownMenuItem<int>(
          value: day,
          child: Text(_weekDayFullLabel(day, l10n)),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) setState(() => _weekStart = value);
      },
      decoration: InputDecoration(
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 12, right: 8),
          child: Icon(
            Icons.view_week_outlined,
            size: 20,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        prefixIconConstraints:
            const BoxConstraints(minWidth: 0, minHeight: 0),
      ),
    );
  }

  // ── Save handler ─────────────────────────────────────────────────────────

  void _onSave() {
    final rule = _buildRule();
    if (rule != null) {
      Navigator.of(context).pop(rule);
    }
  }
}
