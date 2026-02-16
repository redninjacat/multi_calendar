// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'mcal_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class MCalLocalizationsAr extends MCalLocalizations {
  MCalLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get daySunday => 'الأحد';

  @override
  String get dayMonday => 'الاثنين';

  @override
  String get dayTuesday => 'الثلاثاء';

  @override
  String get dayWednesday => 'الأربعاء';

  @override
  String get dayThursday => 'الخميس';

  @override
  String get dayFriday => 'الجمعة';

  @override
  String get daySaturday => 'السبت';

  @override
  String get daySundayShort => 'أحد';

  @override
  String get dayMondayShort => 'اثنين';

  @override
  String get dayTuesdayShort => 'ثلاثاء';

  @override
  String get dayWednesdayShort => 'أربعاء';

  @override
  String get dayThursdayShort => 'خميس';

  @override
  String get dayFridayShort => 'جمعة';

  @override
  String get daySaturdayShort => 'سبت';

  @override
  String get monthJanuary => 'يناير';

  @override
  String get monthFebruary => 'فبراير';

  @override
  String get monthMarch => 'مارس';

  @override
  String get monthApril => 'أبريل';

  @override
  String get monthMay => 'مايو';

  @override
  String get monthJune => 'يونيو';

  @override
  String get monthJuly => 'يوليو';

  @override
  String get monthAugust => 'أغسطس';

  @override
  String get monthSeptember => 'سبتمبر';

  @override
  String get monthOctober => 'أكتوبر';

  @override
  String get monthNovember => 'نوفمبر';

  @override
  String get monthDecember => 'ديسمبر';

  @override
  String get today => 'اليوم';

  @override
  String get week => 'أسبوع';

  @override
  String get month => 'شهر';

  @override
  String get day => 'يوم';

  @override
  String get year => 'سنة';

  @override
  String get previousDay => 'اليوم السابق';

  @override
  String get nextDay => 'اليوم التالي';

  @override
  String get previousMonth => 'الشهر السابق';

  @override
  String get nextMonth => 'الشهر التالي';

  @override
  String currentTime(Object time) {
    return 'الوقت الحالي: $time';
  }

  @override
  String get focused => 'مركز';

  @override
  String get selected => 'محدد';

  @override
  String get event => 'حدث';

  @override
  String get events => 'أحداث';

  @override
  String get doubleTapToSelect => 'انقر مرتين للتحديد';

  @override
  String get calendar => 'تقويم';

  @override
  String get dropTargetPrefix => 'هدف الإسقاط';

  @override
  String get dropTargetDateRangeTo => 'إلى';

  @override
  String get dropTargetValid => 'صالح';

  @override
  String get dropTargetInvalid => 'غير صالح';

  @override
  String multiDaySpanLabel(Object days, Object position) {
    return 'حدث $days أيام، اليوم $position من $days';
  }

  @override
  String scheduleFor(Object date) {
    return 'الجدول الزمني لـ $date';
  }

  @override
  String get timeGrid => 'شبكة الوقت';

  @override
  String get doubleTapToCreateEvent => 'انقر مرتين لإنشاء حدث';

  @override
  String get allDay => 'طوال اليوم';
}
