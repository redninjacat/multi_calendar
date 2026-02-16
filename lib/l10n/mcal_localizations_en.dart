// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'mcal_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class MCalLocalizationsEn extends MCalLocalizations {
  MCalLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get daySunday => 'Sunday';

  @override
  String get dayMonday => 'Monday';

  @override
  String get dayTuesday => 'Tuesday';

  @override
  String get dayWednesday => 'Wednesday';

  @override
  String get dayThursday => 'Thursday';

  @override
  String get dayFriday => 'Friday';

  @override
  String get daySaturday => 'Saturday';

  @override
  String get daySundayShort => 'Sun';

  @override
  String get dayMondayShort => 'Mon';

  @override
  String get dayTuesdayShort => 'Tue';

  @override
  String get dayWednesdayShort => 'Wed';

  @override
  String get dayThursdayShort => 'Thu';

  @override
  String get dayFridayShort => 'Fri';

  @override
  String get daySaturdayShort => 'Sat';

  @override
  String get monthJanuary => 'January';

  @override
  String get monthFebruary => 'February';

  @override
  String get monthMarch => 'March';

  @override
  String get monthApril => 'April';

  @override
  String get monthMay => 'May';

  @override
  String get monthJune => 'June';

  @override
  String get monthJuly => 'July';

  @override
  String get monthAugust => 'August';

  @override
  String get monthSeptember => 'September';

  @override
  String get monthOctober => 'October';

  @override
  String get monthNovember => 'November';

  @override
  String get monthDecember => 'December';

  @override
  String get today => 'Today';

  @override
  String get week => 'Week';

  @override
  String get month => 'Month';

  @override
  String get day => 'Day';

  @override
  String get year => 'Year';

  @override
  String get previousDay => 'Previous day';

  @override
  String get nextDay => 'Next day';

  @override
  String get previousMonth => 'previous month';

  @override
  String get nextMonth => 'next month';

  @override
  String currentTime(Object time) {
    return 'Current time: $time';
  }

  @override
  String get focused => 'focused';

  @override
  String get selected => 'selected';

  @override
  String get event => 'event';

  @override
  String get events => 'events';

  @override
  String get doubleTapToSelect => 'Double tap to select';

  @override
  String get calendar => 'Calendar';

  @override
  String get dropTargetPrefix => 'Drop target';

  @override
  String get dropTargetDateRangeTo => 'to';

  @override
  String get dropTargetValid => 'valid';

  @override
  String get dropTargetInvalid => 'invalid';

  @override
  String multiDaySpanLabel(Object days, Object position) {
    return '$days-day event, day $position of $days';
  }

  @override
  String scheduleFor(Object date) {
    return 'Schedule for $date';
  }

  @override
  String get timeGrid => 'Time grid';

  @override
  String get doubleTapToCreateEvent => 'Double tap to create event';

  @override
  String get allDay => 'All day';
}
