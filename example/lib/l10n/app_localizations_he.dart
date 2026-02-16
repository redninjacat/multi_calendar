// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hebrew (`he`).
class AppLocalizationsHe extends AppLocalizations {
  AppLocalizationsHe([String locale = 'he']) : super(locale);

  @override
  String get appTitle => 'לוח שנה מרובה';

  @override
  String get toggleTheme => 'החלף ערכת נושא';

  @override
  String get changeLanguage => 'שנה שפה';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageArabic => 'العربية (RTL)';

  @override
  String get languageHebrew => 'עברית (RTL)';

  @override
  String get monthView => 'תצוגת חודש';

  @override
  String get dayView => 'תצוגת יום';

  @override
  String get monthViewDescription => 'סגנונות שונים לתצוגת לוח חודש';

  @override
  String get dayViewDescription =>
      'תצוגת יום עם גרירה ושחרור, אירועים מתוזמנים וכל היום';

  @override
  String get comingSoon => 'בקרוב...';

  @override
  String get styleDefault => 'ברירת מחדל';

  @override
  String get styleClassic => 'קלאסי';

  @override
  String get styleModern => 'מודרני';

  @override
  String get styleColorful => 'צבעוני';

  @override
  String get styleMinimal => 'מינימלי';

  @override
  String get styleMinimalDescription =>
      'עיצוב בסיסי, טקסט בלבד. מרווח מקסימלי, קווי רשת מינימליים, צבעים עדינים. נקי ומרווח.';

  @override
  String get styleFeaturesDemo => 'תכונות';

  @override
  String get styleFeaturesDemoDescription =>
      'מכלול מקיף: אזורי זמן מיוחדים (ארוחת צהריים, אחרי שעות), משבצות חסומות, גרירה ושחרור, שינוי גודל, ניווט במקלדת, יישור לזמן. נסה לשחרר אירועים לאזורים חסומים.';

  @override
  String get styleDefaultDescription =>
      'תצוגת יום מוכנה לשימוש עם ערכת נושא ברירת מחדל. גרור אירועים להזזה, שנה גודל מהקצוות. לחיצה כפולה במקום ריק ליצירה. מציג אירועי כל היום ומתוזמנים.';

  @override
  String get styleClassicDescription =>
      'רשת מסורתית עם גבולות, פינות ריבועיות, צבעים אחידים. שעות עבודה 8-18, קווי רשת של 15 דקות.';

  @override
  String get styleModernDescription =>
      'עיצוב נקי ומעוגל עם אינדיקטורים צבעוניים לאירועים. שעות מורחבות 7-21, קווי רשת עיקריים של 30 דקות.';

  @override
  String get styleColorfulDescription =>
      'גרדיאנטים תוססים וצבעים מודגשים. טווח 24 שעות מלא. אסתטיקה משחקית ויצירתית.';

  @override
  String get styleStressTest => 'בדיקת עומס';

  @override
  String get styleStressTestDescription =>
      'הדגמת ביצועים עם 100-500 אירועים. החלף מצב עומס, בחר מספר אירועים, צפה ב-FPS ומדדי מסגרת. מדגים רנדור חלק עם אירועים חופפים רבים.';

  @override
  String get styleRtlDemo => 'הדגמת RTL';

  @override
  String get styleRtlDemoDescription =>
      'תצוגת יום בפריסת ימין לשמאל (ערבית). מקרא זמן מימין, חצי ניווט הפוכים. מדגים תמיכה מלאה ב-RTL לערבית ושפות RTL אחרות.';

  @override
  String get styleThemeCustomization => 'התאמה אישית של ערכת נושא';

  @override
  String get styleThemeCustomizationDescription =>
      'התאם מאפייני ערכת נושא: גובה שעה, קווי רשת, משבצות זמן, משבצות אירועים, ידיות שינוי גודל. הגדרות מוכנות לתצורות נפוצות. השינויים חלים מיידית.';

  @override
  String get notes => 'הערות';

  @override
  String get allDay => 'כל היום';

  @override
  String allDayRange(Object startDate, Object endDate) {
    return '$startDate - $endDate (כל היום)';
  }

  @override
  String allDaySingle(Object date) {
    return '$date (כל היום)';
  }

  @override
  String daysCount(Object count) {
    return '$count ימים';
  }

  @override
  String hoursMinutes(Object hours, Object minutes) {
    return '$hours שעות $minutes דקות';
  }

  @override
  String hoursOnly(Object hours) {
    return '$hours שעות';
  }

  @override
  String minutesOnly(Object minutes) {
    return '$minutes דקות';
  }

  @override
  String eventMoved(Object title, Object time) {
    return 'הועבר: $title ל-$time';
  }

  @override
  String eventResized(Object title, Object minutes) {
    return 'שונה גודל: $title ל-$minutes דקות';
  }

  @override
  String doubleTapCreate(Object time) {
    return 'לחיצה כפולה ב-$time - צור אירוע';
  }

  @override
  String eventId(Object id) {
    return 'מזהה אירוע: $id';
  }

  @override
  String externalId(Object id) {
    return 'מזהה חיצוני: $id';
  }

  @override
  String eventCreated(Object title) {
    return 'נוצר: $title';
  }

  @override
  String eventUpdated(Object title) {
    return 'עודכן: $title';
  }

  @override
  String eventDeleted(Object title) {
    return 'נמחק: $title';
  }

  @override
  String get deleteEvent => 'מחק אירוע';

  @override
  String deleteEventConfirm(Object title) {
    return 'למחוק את \"$title\"?';
  }

  @override
  String get cancel => 'ביטול';

  @override
  String get delete => 'מחק';

  @override
  String get edit => 'ערוך';

  @override
  String get comparisonView => 'השוואה';

  @override
  String get comparisonViewDescription =>
      'תצוגות חודש ויום זו לצד זו עם נתונים משותפים';

  @override
  String get comparisonUseMonthView => 'סקירה כללית, תכנון, אירועים מרובי ימים';

  @override
  String get comparisonUseDayView => 'פרטי לוח זמנים, משבצות זמן, גרירה ושחרור';

  @override
  String comparisonDaySelected(Object date) {
    return 'נבחר $date';
  }

  @override
  String get styleAccessibility => 'נגישות';

  @override
  String get styleAccessibilityDescription =>
      'הדגמת תכונות נגישות: קיצורי מקלדת, תמיכת קורא מסך, מצב ניגודיות גבוהה. תואם WCAG 2.1 AA.';

  @override
  String get accessibilityKeyboardShortcuts => 'קיצורי מקלדת';

  @override
  String get accessibilityShortcutCreate => 'צור אירוע';

  @override
  String get accessibilityShortcutEdit => 'ערוך אירוע';

  @override
  String get accessibilityShortcutDelete => 'מחק אירוע';

  @override
  String get accessibilityScreenReaderGuide => 'מדריך קורא מסך';

  @override
  String get accessibilityScreenReaderInstructions =>
      'הפעל VoiceOver (iOS/macOS) או TalkBack (Android) לשמיעת תוויות סמנטיות. אירועים מכריזים כותרת, טווח זמן ומשך. כפתורי ניווט מכריזים יום קודם, היום, יום הבא. משבצות זמן מכריזות שעה. ידיות שינוי גודל מכריזות שנה גודל קצה התחלה או שנה גודל קצה סיום.';

  @override
  String get accessibilityChecklist => 'רשימת בדיקה לנגישות';

  @override
  String get accessibilityChecklistItem1 =>
      'תוויות סמנטיות על כל האלמנטים האינטראקטיביים';

  @override
  String get accessibilityChecklistItem2 =>
      'ניווט במקלדת (Tab, מקשי חצים, Enter, Escape)';

  @override
  String get accessibilityChecklistItem3 => 'קיצורי מקלדת (Cmd/Ctrl+N, E, D)';

  @override
  String get accessibilityChecklistItem4 => 'תמיכה במצב ניגודיות גבוהה';

  @override
  String get accessibilityChecklistItem5 => 'הכרזות קורא מסך לפעולות';

  @override
  String get accessibilityChecklistItem6 => 'אינדיקטורים של פוקוס גלויים';

  @override
  String get accessibilityHighContrast => 'מצב ניגודיות גבוהה';

  @override
  String get accessibilityHighContrastDescription =>
      'החלף כדי לראות עיצוב ניגודיות גבוהה למשתמשים עם ראייה חלשה.';

  @override
  String get accessibilityKeyboardNavFlow => 'זרימת ניווט במקלדת';

  @override
  String get accessibilityKeyboardNavStep1 => 'Tab או לחץ כדי למקד תצוגת יום';

  @override
  String get accessibilityKeyboardNavStep2 =>
      'Tab למעבר בין אירועים בסדר כרונולוגי';

  @override
  String get accessibilityKeyboardNavStep3 => 'Enter להפעלה (פתח פרטי אירוע)';

  @override
  String get accessibilityKeyboardNavStep4 =>
      'Cmd/Ctrl+N ליצירה, E לעריכה, D למחיקת אירוע ממוקד';
}
