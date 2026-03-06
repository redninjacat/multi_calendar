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

  @override
  String get announcementResizeCancelled => 'تم إلغاء تغيير الحجم';

  @override
  String announcementMoveCancelled(Object title) {
    return 'تم إلغاء النقل لـ $title';
  }

  @override
  String get announcementEventSelectionCancelled => 'تم إلغاء تحديد الحدث';

  @override
  String announcementEventsHighlighted(Object count, Object title) {
    return '$count أحداث. $title مميز. Tab للتنقل، Enter للتأكيد.';
  }

  @override
  String announcementEventSelected(Object title) {
    return 'تم تحديد $title. مفاتيح الأسهم للنقل، Enter للتأكيد، Escape للإلغاء.';
  }

  @override
  String announcementEventCycled(Object title, Object index, Object total) {
    return '$title. $index من $total.';
  }

  @override
  String announcementMovingEvent(Object title, Object date) {
    return 'نقل $title إلى $date';
  }

  @override
  String get announcementResizeModeEntered =>
      'وضع تغيير الحجم. ضبط الحافة النهائية. مفاتيح الأسهم لتغيير الحجم، S للبداية، E للنهاية، M لوضع النقل، Enter للتأكيد.';

  @override
  String get announcementResizingStartEdge => 'تغيير حجم الحافة الأولى';

  @override
  String get announcementResizingEndEdge => 'تغيير حجم الحافة النهائية';

  @override
  String get announcementMoveMode => 'وضع النقل';

  @override
  String get announcementMoveInvalidTarget => 'تم إلغاء النقل. الهدف غير صالح.';

  @override
  String announcementEventMoved(Object title, Object date) {
    return 'تم نقل $title إلى $date';
  }

  @override
  String announcementResizingProgress(
    Object title,
    Object edge,
    Object date,
    Object days,
  ) {
    return 'تغيير حجم $title $edge إلى $date، $days أيام';
  }

  @override
  String get announcementResizeInvalid =>
      'تم إلغاء تغيير الحجم. تغيير الحجم غير صالح.';

  @override
  String announcementEventResized(Object title, Object start, Object end) {
    return 'تم تغيير حجم $title من $start إلى $end';
  }

  @override
  String get announcementDayNavigationMode => 'وضع التنقل';

  @override
  String announcementDayEventMode(Object count) {
    return 'وضع الحدث، $count أحداث';
  }

  @override
  String announcementDayEventCycled(
    Object title,
    Object position,
    Object total,
  ) {
    return '$title، $position من $total';
  }

  @override
  String announcementDayEventSelected(Object title) {
    return 'تم تحديد $title';
  }

  @override
  String announcementDayMoveMode(Object title) {
    return 'وضع النقل لـ $title';
  }

  @override
  String announcementDayResizeMode(Object title) {
    return 'وضع تغيير الحجم لـ $title';
  }

  @override
  String announcementDayMoveCancelled(Object title) {
    return 'تم إلغاء النقل لـ $title';
  }

  @override
  String get announcementDayResizeCancelled => 'تم إلغاء تغيير الحجم';

  @override
  String announcementDayMovingEvent(Object title, Object time) {
    return 'نقل $title إلى $time';
  }

  @override
  String announcementDayResizingEvent(Object title, Object edge, Object time) {
    return 'تغيير حجم $title، حافة $edge عند $time';
  }

  @override
  String announcementDayEventMoved(Object title, Object time) {
    return 'تم نقل $title إلى $time';
  }

  @override
  String announcementDayEventResized(Object title) {
    return 'تم تغيير حجم $title';
  }

  @override
  String get announcementDayAllDaySection => 'قسم طوال اليوم';

  @override
  String announcementDayTimeGrid(Object time) {
    return 'شبكة الوقت، $time';
  }

  @override
  String get announcementDayMoveInvalidTarget => 'لا يمكن النقل هنا';

  @override
  String announcementDayEventDeleted(Object title) {
    return 'تم حذف $title';
  }

  @override
  String announcementDayEventConversionRequested(Object title, Object type) {
    return 'تحويل $title إلى $type';
  }
}
