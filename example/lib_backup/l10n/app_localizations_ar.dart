// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'تقويم متعدد';

  @override
  String get toggleTheme => 'تبديل السمة';

  @override
  String get changeLanguage => 'تغيير اللغة';

  @override
  String get languageEnglish => 'الإنجليزية';

  @override
  String get languageSpanish => 'الإسبانية';

  @override
  String get languageFrench => 'الفرنسية';

  @override
  String get languageArabic => 'العربية (من اليمين لليسار)';

  @override
  String get languageHebrew => 'עברית (מימין לשמאל)';

  @override
  String get monthView => 'عرض الشهر';

  @override
  String get dayView => 'عرض اليوم';

  @override
  String get monthViewDescription => 'أنماط مختلفة لعرض التقويم الشهري';

  @override
  String get dayViewDescription =>
      'عرض يومي بالسحب والإفلات، أحداث مجدولة وطوال اليوم';

  @override
  String get comingSoon => 'قريباً...';

  @override
  String get styleDefault => 'افتراضي';

  @override
  String get styleClassic => 'كلاسيكي';

  @override
  String get styleModern => 'حديث';

  @override
  String get styleColorful => 'ملون';

  @override
  String get styleMinimal => 'Minimal';

  @override
  String get styleMinimalDescription =>
      'Bare bones, text-only design. Maximum whitespace, minimal gridlines, subtle colors. Clean and spacious.';

  @override
  String get styleFeaturesDemo => 'الميزات';

  @override
  String get styleFeaturesDemoDescription =>
      'عرض شامل: مناطق زمنية خاصة (الغداء، بعد ساعات العمل)، فترات محظورة، السحب والإفلات، تغيير الحجم، التنقل بلوحة المفاتيح، المحاذاة مع الوقت. جرب إسقاط الأحداث في المناطق المحظورة.';

  @override
  String get styleDefaultDescription =>
      'عرض يومي افتراضي. اسحب الأحداث للتنقل، تغيير الحجم من الحواف. النقر المزدوج على المساحة الفارغة للإنشاء. يعرض أحداث طوال اليوم والمجدولة.';

  @override
  String get styleClassicDescription =>
      'شبكة تقليدية بحدود وزوايا مربعة وألوان موحدة. ساعات العمل 8–18، خطوط كل 15 دقيقة.';

  @override
  String get styleModernDescription =>
      'تصميم نظيف ومستدير مع مؤشرات أحداث ملونة. ساعات ممتدة 7–21، خطوط رئيسية كل 30 دقيقة.';

  @override
  String get styleColorfulDescription =>
      'تدرجات نابضة بالحياة وألوان جريئة. نطاق كامل 24 ساعة. جمالية مرحة وإبداعية.';

  @override
  String get styleStressTest => 'اختبار الإجهاد';

  @override
  String get styleStressTestDescription =>
      'عرض أداء مع 100–500 حدث. تفعيل وضع الإجهاد، اختيار العدد، عرض FPS والمقاييس. يوضح العرض السلس مع العديد من الأحداث المتداخلة.';

  @override
  String get styleRtlDemo => 'عرض من اليمين لليسار';

  @override
  String get styleRtlDemoDescription =>
      'عرض يومي بتخطيط من اليمين لليسار (العربية). وسيلة الوقت على اليمين، أسهم التنقل معكوسة. يوضح دعم RTL الكامل للعربية واللغات الأخرى.';

  @override
  String get styleThemeCustomization => 'تخصيص السمة';

  @override
  String get styleThemeCustomizationDescription =>
      'تخصيص خصائص السمة: ارتفاع الساعة، الخطوط، الفترات الزمنية، بلاطات الأحداث، مقابض تغيير الحجم. إعدادات مسبقة للتكوينات الشائعة. التغييرات تُطبق فوراً.';

  @override
  String get notes => 'ملاحظات';

  @override
  String get allDay => 'طوال اليوم';

  @override
  String allDayRange(Object startDate, Object endDate) {
    return '$startDate - $endDate (طوال اليوم)';
  }

  @override
  String allDaySingle(Object date) {
    return '$date (طوال اليوم)';
  }

  @override
  String daysCount(Object count) {
    return '$count أيام';
  }

  @override
  String hoursMinutes(Object hours, Object minutes) {
    return '$hours س $minutes د';
  }

  @override
  String hoursOnly(Object hours) {
    return '$hours س';
  }

  @override
  String minutesOnly(Object minutes) {
    return '$minutes د';
  }

  @override
  String eventMoved(Object title, Object time) {
    return 'تم النقل: $title إلى $time';
  }

  @override
  String eventResized(Object title, Object minutes) {
    return 'تم تغيير الحجم: $title إلى $minutes د';
  }

  @override
  String doubleTapCreate(Object time) {
    return 'النقر المزدوج عند $time - إنشاء حدث';
  }

  @override
  String eventId(Object id) {
    return 'معرف الحدث: $id';
  }

  @override
  String externalId(Object id) {
    return 'المعرف الخارجي: $id';
  }

  @override
  String eventCreated(Object title) {
    return 'تم الإنشاء: $title';
  }

  @override
  String eventUpdated(Object title) {
    return 'تم التحديث: $title';
  }

  @override
  String eventDeleted(Object title) {
    return 'تم الحذف: $title';
  }

  @override
  String get deleteEvent => 'حذف الحدث';

  @override
  String deleteEventConfirm(Object title) {
    return 'حذف \"$title\"؟';
  }

  @override
  String get cancel => 'إلغاء';

  @override
  String get delete => 'حذف';

  @override
  String get edit => 'تعديل';

  @override
  String get comparisonView => 'مقارنة';

  @override
  String get comparisonViewDescription =>
      'عرض الشهر واليوم جنباً إلى جنب مع بيانات مشتركة';

  @override
  String get comparisonUseMonthView => 'نظرة عامة، تخطيط، أحداث متعددة الأيام';

  @override
  String get comparisonUseDayView =>
      'تفاصيل الجدول، الفترات الزمنية، السحب والإفلات';

  @override
  String comparisonDaySelected(Object date) {
    return 'تم تحديد $date';
  }

  @override
  String get styleAccessibility => 'Accessibility';

  @override
  String get styleAccessibilityDescription =>
      'Demonstrate accessibility features: keyboard shortcuts, screen reader support, high contrast mode. WCAG 2.1 AA compliant.';

  @override
  String get accessibilityKeyboardShortcuts => 'Keyboard Shortcuts';

  @override
  String get accessibilityShortcutCreate => 'Create event';

  @override
  String get accessibilityShortcutEdit => 'Edit event';

  @override
  String get accessibilityShortcutDelete => 'Delete event';

  @override
  String get accessibilityScreenReaderGuide => 'Screen Reader Guide';

  @override
  String get accessibilityScreenReaderInstructions =>
      'Enable VoiceOver (iOS/macOS) or TalkBack (Android) to hear semantic labels. Events announce title, time range, and duration. Navigator buttons announce Previous day, Today, Next day. Time slots announce hour. Resize handles announce Resize start edge or Resize end edge.';

  @override
  String get accessibilityChecklist => 'Accessibility Checklist';

  @override
  String get accessibilityChecklistItem1 =>
      'Semantic labels on all interactive elements';

  @override
  String get accessibilityChecklistItem2 =>
      'Keyboard navigation (Tab, Arrow keys, Enter, Escape)';

  @override
  String get accessibilityChecklistItem3 =>
      'Keyboard shortcuts (Cmd/Ctrl+N, E, D)';

  @override
  String get accessibilityChecklistItem4 => 'High contrast mode support';

  @override
  String get accessibilityChecklistItem5 =>
      'Screen reader announcements for actions';

  @override
  String get accessibilityChecklistItem6 => 'Focus indicators visible';

  @override
  String get accessibilityHighContrast => 'High Contrast Mode';

  @override
  String get accessibilityHighContrastDescription =>
      'Toggle to see high-contrast styling for low vision users.';

  @override
  String get accessibilityKeyboardNavFlow => 'Keyboard Navigation Flow';

  @override
  String get accessibilityKeyboardNavStep1 => 'Tab or click to focus Day View';

  @override
  String get accessibilityKeyboardNavStep2 =>
      'Tab to move between events chronologically';

  @override
  String get accessibilityKeyboardNavStep3 =>
      'Enter to activate (open event details)';

  @override
  String get accessibilityKeyboardNavStep4 =>
      'Cmd/Ctrl+N to create, E to edit, D to delete focused event';
}
