// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'mcal_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hebrew (`he`).
class MCalLocalizationsHe extends MCalLocalizations {
  MCalLocalizationsHe([String locale = 'he']) : super(locale);

  @override
  String get daySunday => 'ראשון';

  @override
  String get dayMonday => 'שני';

  @override
  String get dayTuesday => 'שלישי';

  @override
  String get dayWednesday => 'רביעי';

  @override
  String get dayThursday => 'חמישי';

  @override
  String get dayFriday => 'שישי';

  @override
  String get daySaturday => 'שבת';

  @override
  String get daySundayShort => 'א׳';

  @override
  String get dayMondayShort => 'ב׳';

  @override
  String get dayTuesdayShort => 'ג׳';

  @override
  String get dayWednesdayShort => 'ד׳';

  @override
  String get dayThursdayShort => 'ה׳';

  @override
  String get dayFridayShort => 'ו׳';

  @override
  String get daySaturdayShort => 'ש׳';

  @override
  String get monthJanuary => 'ינואר';

  @override
  String get monthFebruary => 'פברואר';

  @override
  String get monthMarch => 'מרץ';

  @override
  String get monthApril => 'אפריל';

  @override
  String get monthMay => 'מאי';

  @override
  String get monthJune => 'יוני';

  @override
  String get monthJuly => 'יולי';

  @override
  String get monthAugust => 'אוגוסט';

  @override
  String get monthSeptember => 'ספטמבר';

  @override
  String get monthOctober => 'אוקטובר';

  @override
  String get monthNovember => 'נובמבר';

  @override
  String get monthDecember => 'דצמבר';

  @override
  String get today => 'היום';

  @override
  String get week => 'שבוע';

  @override
  String get month => 'חודש';

  @override
  String get day => 'יום';

  @override
  String get year => 'שנה';

  @override
  String get previousDay => 'יום קודם';

  @override
  String get nextDay => 'יום הבא';

  @override
  String get previousMonth => 'חודש קודם';

  @override
  String get nextMonth => 'חודש הבא';

  @override
  String currentTime(Object time) {
    return 'זמן נוכחי: $time';
  }

  @override
  String get focused => 'ממוקד';

  @override
  String get selected => 'נבחר';

  @override
  String get event => 'אירוע';

  @override
  String get events => 'אירועים';

  @override
  String get doubleTapToSelect => 'הקש פעמיים לבחירה';

  @override
  String get calendar => 'לוח שנה';

  @override
  String get dropTargetPrefix => 'יעד שחרור';

  @override
  String get dropTargetDateRangeTo => 'עד';

  @override
  String get dropTargetValid => 'תקין';

  @override
  String get dropTargetInvalid => 'לא תקין';

  @override
  String multiDaySpanLabel(Object days, Object position) {
    return 'אירוע של $days ימים, יום $position מתוך $days';
  }

  @override
  String scheduleFor(Object date) {
    return 'לוח זמנים עבור $date';
  }

  @override
  String get timeGrid => 'רשת זמן';

  @override
  String get doubleTapToCreateEvent => 'הקש פעמיים ליצירת אירוע';

  @override
  String get allDay => 'כל היום';

  @override
  String get announcementResizeCancelled => 'שינוי גודל בוטל';

  @override
  String announcementMoveCancelled(Object title) {
    return 'העברה בוטלה עבור $title';
  }

  @override
  String get announcementEventSelectionCancelled => 'בחירת אירוע בוטלה';

  @override
  String announcementEventsHighlighted(Object count, Object title) {
    return '$count אירועים. $title מודגש. Tab למעבר, Enter לאישור.';
  }

  @override
  String announcementEventSelected(Object title) {
    return 'נבחר $title. מקשי חצים להעברה, Enter לאישור, Escape לביטול.';
  }

  @override
  String announcementEventCycled(Object title, Object index, Object total) {
    return '$title. $index מתוך $total.';
  }

  @override
  String announcementMovingEvent(Object title, Object date) {
    return 'מעביר את $title ל-$date';
  }

  @override
  String get announcementResizeModeEntered =>
      'מצב שינוי גודל. התאמת קצה סיום. מקשי חצים לשינוי גודל, S להתחלה, E לסיום, M למצב העברה, Enter לאישור.';

  @override
  String get announcementResizingStartEdge => 'משנה גודל קצה התחלה';

  @override
  String get announcementResizingEndEdge => 'משנה גודל קצה סיום';

  @override
  String get announcementMoveMode => 'מצב העברה';

  @override
  String get announcementMoveInvalidTarget => 'העברה בוטלה. יעד לא תקין.';

  @override
  String announcementEventMoved(Object title, Object date) {
    return 'הועבר $title ל-$date';
  }

  @override
  String announcementResizingProgress(
    Object title,
    Object edge,
    Object date,
    Object days,
  ) {
    return 'משנה גודל $title $edge ל-$date, $days ימים';
  }

  @override
  String get announcementResizeInvalid =>
      'שינוי גודל בוטל. שינוי גודל לא תקין.';

  @override
  String announcementEventResized(Object title, Object start, Object end) {
    return 'שונה גודל $title מ-$start עד $end';
  }
}
