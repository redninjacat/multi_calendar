// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Multi Calendar';

  @override
  String get toggleTheme => 'Toggle theme';

  @override
  String get changeLanguage => 'Change language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Spanish';

  @override
  String get languageFrench => 'French';

  @override
  String get languageArabic => 'Arabic (RTL)';

  @override
  String get monthView => 'Month View';

  @override
  String get dayView => 'Day View';

  @override
  String get monthViewDescription =>
      'Different styles for the month calendar view';

  @override
  String get dayViewDescription =>
      'Day view with drag-and-drop, timed and all-day events';

  @override
  String get comingSoon => 'Coming soon...';

  @override
  String get styleDefault => 'Default';

  @override
  String get styleClassic => 'Classic';

  @override
  String get styleModern => 'Modern';

  @override
  String get styleColorful => 'Colorful';

  @override
  String get styleMinimal => 'Minimal';

  @override
  String get styleMinimalDescription =>
      'Bare bones, text-only design. Maximum whitespace, minimal gridlines, subtle colors. Clean and spacious.';

  @override
  String get styleFeaturesDemo => 'Features Demo';

  @override
  String get styleFeaturesDemoDescription =>
      'Comprehensive showcase: special time regions (lunch, after-hours), blocked slots, drag-drop, resize, keyboard nav, snap-to-time. Try dropping events into blocked zones.';

  @override
  String get styleDefaultDescription =>
      'Out-of-the-box Day View with default theme. Drag events to move, resize from edges. Double-tap empty space to create. Shows all-day and timed events.';

  @override
  String get styleClassicDescription =>
      'Traditional grid with borders, square corners, uniform colors. Business hours 8–18, 15-minute gridlines.';

  @override
  String get styleModernDescription =>
      'Clean, rounded design with colorful event indicators. Extended hours 7–21, 30-minute major gridlines.';

  @override
  String get styleColorfulDescription =>
      'Vibrant gradients and bold colors. Full 24-hour range. Playful, creative aesthetic.';

  @override
  String get styleStressTest => 'Stress Test';

  @override
  String get styleStressTestDescription =>
      'Performance demo with 100–500 events. Toggle stress mode, select event count, view FPS and frame metrics. Demonstrates smooth rendering with many overlapping events.';

  @override
  String get styleRtlDemo => 'RTL Demo';

  @override
  String get styleRtlDemoDescription =>
      'Day View in right-to-left layout (Arabic). Time legend on right, navigator arrows flipped. Demonstrates full RTL support for Arabic and other RTL languages.';

  @override
  String get styleThemeCustomization => 'Theme Customization';

  @override
  String get styleThemeCustomizationDescription =>
      'Customize theme properties: hour height, gridlines, time slots, event tiles, resize handles. Presets for common configurations. Changes apply immediately.';

  @override
  String get notes => 'Notes';

  @override
  String get allDay => 'All day';

  @override
  String allDayRange(Object startDate, Object endDate) {
    return '$startDate - $endDate (All day)';
  }

  @override
  String allDaySingle(Object date) {
    return '$date (All day)';
  }

  @override
  String daysCount(Object count) {
    return '$count days';
  }

  @override
  String hoursMinutes(Object hours, Object minutes) {
    return '$hours hr $minutes min';
  }

  @override
  String hoursOnly(Object hours) {
    return '$hours hr';
  }

  @override
  String minutesOnly(Object minutes) {
    return '$minutes min';
  }

  @override
  String eventMoved(Object title, Object time) {
    return 'Moved: $title to $time';
  }

  @override
  String eventResized(Object title, Object minutes) {
    return 'Resized: $title to $minutes min';
  }

  @override
  String doubleTapCreate(Object time) {
    return 'Double-tap at $time - Create event';
  }

  @override
  String eventId(Object id) {
    return 'Event ID: $id';
  }

  @override
  String externalId(Object id) {
    return 'External ID: $id';
  }

  @override
  String eventCreated(Object title) {
    return 'Created: $title';
  }

  @override
  String eventUpdated(Object title) {
    return 'Updated: $title';
  }

  @override
  String eventDeleted(Object title) {
    return 'Deleted: $title';
  }

  @override
  String get deleteEvent => 'Delete Event';

  @override
  String deleteEventConfirm(Object title) {
    return 'Delete \"$title\"?';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get comparisonView => 'Comparison';

  @override
  String get comparisonViewDescription =>
      'Month and Day views side by side with shared data';

  @override
  String get comparisonUseMonthView => 'Overview, planning, multi-day events';

  @override
  String get comparisonUseDayView =>
      'Schedule details, time slots, drag-and-drop';

  @override
  String comparisonDaySelected(Object date) {
    return 'Selected $date';
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
