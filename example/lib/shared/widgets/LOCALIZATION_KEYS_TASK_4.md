# Localization Keys Required for Task 4 Dialogs

This document lists all the new AppLocalizations keys that were used in task 4 and must be added to the ARB files in task 14.

## Bottom Sheet Keys (3 keys)

### Event Count
- `bottomSheetEventCount(int count)` - Event count display with plural support
  - Example EN: `{count, plural, =1{1 event} other{{count} events}}`
  - Parameterized: Yes (count: int)

### Tap Hint
- `bottomSheetTapHint` - Hint text to tap an event for details
  - Example EN: "Tap an event to see details"

### Empty State
- `bottomSheetNoEvents` - Empty state message when no events
  - Example EN: "No events"

---

## Recurrence Editor Keys (47 keys)

### Frequency Unit Labels (4 keys)
- `recurrenceDays` - "day(s)"
- `recurrenceWeeks` - "week(s)"
- `recurrenceMonths` - "month(s)"
- `recurrenceYears` - "year(s)"

### Day Names - Short (7 keys)
- `recurrenceMondayShort` - "Mon"
- `recurrenceTuesdayShort` - "Tue"
- `recurrenceWednesdayShort` - "Wed"
- `recurrenceThursdayShort` - "Thu"
- `recurrenceFridayShort` - "Fri"
- `recurrenceSaturdayShort` - "Sat"
- `recurrenceSundayShort` - "Sun"

### Day Names - Full (7 keys)
- `recurrenceMonday` - "Monday"
- `recurrenceTuesday` - "Tuesday"
- `recurrenceWednesday` - "Wednesday"
- `recurrenceThursday` - "Thursday"
- `recurrenceFriday` - "Friday"
- `recurrenceSaturday` - "Saturday"
- `recurrenceSunday` - "Sunday"

### Dialog Titles (2 keys)
- `recurrenceEditTitle` - "Edit Recurrence"
- `recurrenceAddTitle` - "Add Recurrence"

### Section Labels (8 keys)
- `recurrenceFrequency` - "Frequency"
- `recurrenceRepeatEvery` - "Repeat every"
- `recurrenceOnDays` - "On days"
- `recurrenceOnDaysOfMonth` - "On days of month"
- `recurrenceOnDaysOfYear` - "On days of year"
- `recurrenceInWeekNumbers` - "In week numbers"
- `recurrenceEnds` - "Ends"
- `recurrenceWeekStartsOn` - "Week starts on"

### Frequency Options (4 keys)
- `recurrenceFrequencyDaily` - "Daily"
- `recurrenceFrequencyWeekly` - "Weekly"
- `recurrenceFrequencyMonthly` - "Monthly"
- `recurrenceFrequencyYearly` - "Yearly"

### Help Text (2 keys)
- `recurrenceDaysOfYearHint` - "Enter day numbers (1-366). Negative values count from year end."
- `recurrenceWeekNumbersHint` - "Enter ISO week numbers (1-53). Negative values count from year end."

### Validation (1 key)
- `recurrenceValidationMin1` - "Min 1"

### Day/Week Chips and Placeholders (4 keys)
- `recurrenceDay(int day)` - Parameterized, shows "Day {day}"
  - Example EN: "Day {day}"
  - Parameterized: Yes (day: int)
- `recurrenceDayPlaceholder` - Input placeholder
  - Example EN: "e.g. 1, 100, 200"
- `recurrenceWeek(int week)` - Parameterized, shows "Week {week}"
  - Example EN: "Week {week}"
  - Parameterized: Yes (week: int)
- `recurrenceWeekPlaceholder` - Input placeholder
  - Example EN: "e.g. 1, 20, 52"

### End Condition Options (5 keys)
- `recurrenceEndsNever` - "Never"
- `recurrenceEndsNeverSubtitle` - "Repeats indefinitely"
- `recurrenceEndsAfter` - "After"
- `recurrenceEndsOnDate` - "On date"
- `recurrenceTimes` - "times" (suffix for count input)

---

## Recurrence Scope Dialog Keys (7 keys)

### Dialog Title (1 key)
- `recurrenceScopeTitle` - "Edit recurring event"

### This Event Option (2 keys)
- `recurrenceScopeThisEvent` - "This event only"
- `recurrenceScopeThisEventSubtitle` - "Only change this occurrence"

### This and Following Option (2 keys)
- `recurrenceScopeThisAndFollowing` - "This and following events"
- `recurrenceScopeThisAndFollowingSubtitle` - "Change this and all future occurrences"

### All Events Option (2 keys)
- `recurrenceScopeAllEvents` - "All events"
- `recurrenceScopeAllEventsSubtitle` - "Change every occurrence in the series"

---

## Summary

**Total new keys: 57**
- Bottom Sheet: 3 keys
- Recurrence Editor: 47 keys
- Recurrence Scope: 7 keys

**Parameterized keys: 3**
- `bottomSheetEventCount(int count)` - plural support
- `recurrenceDay(int day)`
- `recurrenceWeek(int week)`

---

## Notes for Task 14 (ARB File Creation)

1. All keys use camelCase naming convention
2. Parameterized keys require proper `@key` metadata in ARB files with placeholder definitions
3. Plural support for `bottomSheetEventCount` requires ICU message format
4. All translations must maintain the same parameter signatures
5. RTL languages (Arabic, Hebrew) may need special consideration for day names and formatting
6. Consider cultural differences in calendar preferences (week start day varies by locale)
