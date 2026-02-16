import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_he.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('he'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Multi Calendar'**
  String get appTitle;

  /// No description provided for @toggleTheme.
  ///
  /// In en, this message translates to:
  /// **'Toggle theme'**
  String get toggleTheme;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change language'**
  String get changeLanguage;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get languageSpanish;

  /// No description provided for @languageFrench.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get languageFrench;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic (RTL)'**
  String get languageArabic;

  /// No description provided for @languageHebrew.
  ///
  /// In en, this message translates to:
  /// **'Hebrew (RTL)'**
  String get languageHebrew;

  /// No description provided for @monthView.
  ///
  /// In en, this message translates to:
  /// **'Month View'**
  String get monthView;

  /// No description provided for @dayView.
  ///
  /// In en, this message translates to:
  /// **'Day View'**
  String get dayView;

  /// No description provided for @monthViewDescription.
  ///
  /// In en, this message translates to:
  /// **'Different styles for the month calendar view'**
  String get monthViewDescription;

  /// No description provided for @dayViewDescription.
  ///
  /// In en, this message translates to:
  /// **'Day view with drag-and-drop, timed and all-day events'**
  String get dayViewDescription;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon...'**
  String get comingSoon;

  /// No description provided for @styleDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get styleDefault;

  /// No description provided for @styleClassic.
  ///
  /// In en, this message translates to:
  /// **'Classic'**
  String get styleClassic;

  /// No description provided for @styleModern.
  ///
  /// In en, this message translates to:
  /// **'Modern'**
  String get styleModern;

  /// No description provided for @styleColorful.
  ///
  /// In en, this message translates to:
  /// **'Colorful'**
  String get styleColorful;

  /// No description provided for @styleMinimal.
  ///
  /// In en, this message translates to:
  /// **'Minimal'**
  String get styleMinimal;

  /// No description provided for @styleMinimalDescription.
  ///
  /// In en, this message translates to:
  /// **'Bare bones, text-only design. Maximum whitespace, minimal gridlines, subtle colors. Clean and spacious.'**
  String get styleMinimalDescription;

  /// No description provided for @styleFeaturesDemo.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get styleFeaturesDemo;

  /// No description provided for @styleFeaturesDemoDescription.
  ///
  /// In en, this message translates to:
  /// **'Comprehensive showcase: special time regions (lunch, after-hours), blocked slots, drag-drop, resize, keyboard nav, snap-to-time. Try dropping events into blocked zones.'**
  String get styleFeaturesDemoDescription;

  /// No description provided for @styleDefaultDescription.
  ///
  /// In en, this message translates to:
  /// **'Out-of-the-box Day View with default theme. Drag events to move, resize from edges. Double-tap empty space to create. Shows all-day and timed events.'**
  String get styleDefaultDescription;

  /// No description provided for @styleClassicDescription.
  ///
  /// In en, this message translates to:
  /// **'Traditional grid with borders, square corners, uniform colors. Business hours 8–18, 15-minute gridlines.'**
  String get styleClassicDescription;

  /// No description provided for @styleModernDescription.
  ///
  /// In en, this message translates to:
  /// **'Clean, rounded design with colorful event indicators. Extended hours 7–21, 30-minute major gridlines.'**
  String get styleModernDescription;

  /// No description provided for @styleColorfulDescription.
  ///
  /// In en, this message translates to:
  /// **'Vibrant gradients and bold colors. Full 24-hour range. Playful, creative aesthetic.'**
  String get styleColorfulDescription;

  /// No description provided for @styleStressTest.
  ///
  /// In en, this message translates to:
  /// **'Stress Test'**
  String get styleStressTest;

  /// No description provided for @styleStressTestDescription.
  ///
  /// In en, this message translates to:
  /// **'Performance demo with 100–500 events. Toggle stress mode, select event count, view FPS and frame metrics. Demonstrates smooth rendering with many overlapping events.'**
  String get styleStressTestDescription;

  /// No description provided for @styleRtlDemo.
  ///
  /// In en, this message translates to:
  /// **'RTL Demo'**
  String get styleRtlDemo;

  /// No description provided for @styleRtlDemoDescription.
  ///
  /// In en, this message translates to:
  /// **'Day View in right-to-left layout (Arabic). Time legend on right, navigator arrows flipped. Demonstrates full RTL support for Arabic and other RTL languages.'**
  String get styleRtlDemoDescription;

  /// No description provided for @styleThemeCustomization.
  ///
  /// In en, this message translates to:
  /// **'Theme Customization'**
  String get styleThemeCustomization;

  /// No description provided for @styleThemeCustomizationDescription.
  ///
  /// In en, this message translates to:
  /// **'Customize theme properties: hour height, gridlines, time slots, event tiles, resize handles. Presets for common configurations. Changes apply immediately.'**
  String get styleThemeCustomizationDescription;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @allDay.
  ///
  /// In en, this message translates to:
  /// **'All day'**
  String get allDay;

  /// No description provided for @allDayRange.
  ///
  /// In en, this message translates to:
  /// **'{startDate} - {endDate} (All day)'**
  String allDayRange(Object startDate, Object endDate);

  /// No description provided for @allDaySingle.
  ///
  /// In en, this message translates to:
  /// **'{date} (All day)'**
  String allDaySingle(Object date);

  /// No description provided for @daysCount.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String daysCount(Object count);

  /// No description provided for @hoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'{hours} hr {minutes} min'**
  String hoursMinutes(Object hours, Object minutes);

  /// No description provided for @hoursOnly.
  ///
  /// In en, this message translates to:
  /// **'{hours} hr'**
  String hoursOnly(Object hours);

  /// No description provided for @minutesOnly.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String minutesOnly(Object minutes);

  /// No description provided for @eventMoved.
  ///
  /// In en, this message translates to:
  /// **'Moved: {title} to {time}'**
  String eventMoved(Object title, Object time);

  /// No description provided for @eventResized.
  ///
  /// In en, this message translates to:
  /// **'Resized: {title} to {minutes} min'**
  String eventResized(Object title, Object minutes);

  /// No description provided for @doubleTapCreate.
  ///
  /// In en, this message translates to:
  /// **'Double-tap at {time} - Create event'**
  String doubleTapCreate(Object time);

  /// No description provided for @eventId.
  ///
  /// In en, this message translates to:
  /// **'Event ID: {id}'**
  String eventId(Object id);

  /// No description provided for @externalId.
  ///
  /// In en, this message translates to:
  /// **'External ID: {id}'**
  String externalId(Object id);

  /// No description provided for @eventCreated.
  ///
  /// In en, this message translates to:
  /// **'Created: {title}'**
  String eventCreated(Object title);

  /// No description provided for @eventUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated: {title}'**
  String eventUpdated(Object title);

  /// No description provided for @eventDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted: {title}'**
  String eventDeleted(Object title);

  /// No description provided for @deleteEvent.
  ///
  /// In en, this message translates to:
  /// **'Delete Event'**
  String get deleteEvent;

  /// No description provided for @deleteEventConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{title}\"?'**
  String deleteEventConfirm(Object title);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @comparisonView.
  ///
  /// In en, this message translates to:
  /// **'Comparison'**
  String get comparisonView;

  /// No description provided for @comparisonViewDescription.
  ///
  /// In en, this message translates to:
  /// **'Month and Day views side by side with shared data'**
  String get comparisonViewDescription;

  /// No description provided for @comparisonUseMonthView.
  ///
  /// In en, this message translates to:
  /// **'Overview, planning, multi-day events'**
  String get comparisonUseMonthView;

  /// No description provided for @comparisonUseDayView.
  ///
  /// In en, this message translates to:
  /// **'Schedule details, time slots, drag-and-drop'**
  String get comparisonUseDayView;

  /// No description provided for @comparisonDaySelected.
  ///
  /// In en, this message translates to:
  /// **'Selected {date}'**
  String comparisonDaySelected(Object date);

  /// No description provided for @styleAccessibility.
  ///
  /// In en, this message translates to:
  /// **'Accessibility'**
  String get styleAccessibility;

  /// No description provided for @styleAccessibilityDescription.
  ///
  /// In en, this message translates to:
  /// **'Demonstrate accessibility features: keyboard shortcuts, screen reader support, high contrast mode. WCAG 2.1 AA compliant.'**
  String get styleAccessibilityDescription;

  /// No description provided for @accessibilityKeyboardShortcuts.
  ///
  /// In en, this message translates to:
  /// **'Keyboard Shortcuts'**
  String get accessibilityKeyboardShortcuts;

  /// No description provided for @accessibilityShortcutCreate.
  ///
  /// In en, this message translates to:
  /// **'Create event'**
  String get accessibilityShortcutCreate;

  /// No description provided for @accessibilityShortcutEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit event'**
  String get accessibilityShortcutEdit;

  /// No description provided for @accessibilityShortcutDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete event'**
  String get accessibilityShortcutDelete;

  /// No description provided for @accessibilityScreenReaderGuide.
  ///
  /// In en, this message translates to:
  /// **'Screen Reader Guide'**
  String get accessibilityScreenReaderGuide;

  /// No description provided for @accessibilityScreenReaderInstructions.
  ///
  /// In en, this message translates to:
  /// **'Enable VoiceOver (iOS/macOS) or TalkBack (Android) to hear semantic labels. Events announce title, time range, and duration. Navigator buttons announce Previous day, Today, Next day. Time slots announce hour. Resize handles announce Resize start edge or Resize end edge.'**
  String get accessibilityScreenReaderInstructions;

  /// No description provided for @accessibilityChecklist.
  ///
  /// In en, this message translates to:
  /// **'Accessibility Checklist'**
  String get accessibilityChecklist;

  /// No description provided for @accessibilityChecklistItem1.
  ///
  /// In en, this message translates to:
  /// **'Semantic labels on all interactive elements'**
  String get accessibilityChecklistItem1;

  /// No description provided for @accessibilityChecklistItem2.
  ///
  /// In en, this message translates to:
  /// **'Keyboard navigation (Tab, Arrow keys, Enter, Escape)'**
  String get accessibilityChecklistItem2;

  /// No description provided for @accessibilityChecklistItem3.
  ///
  /// In en, this message translates to:
  /// **'Keyboard shortcuts (Cmd/Ctrl+N, E, D)'**
  String get accessibilityChecklistItem3;

  /// No description provided for @accessibilityChecklistItem4.
  ///
  /// In en, this message translates to:
  /// **'High contrast mode support'**
  String get accessibilityChecklistItem4;

  /// No description provided for @accessibilityChecklistItem5.
  ///
  /// In en, this message translates to:
  /// **'Screen reader announcements for actions'**
  String get accessibilityChecklistItem5;

  /// No description provided for @accessibilityChecklistItem6.
  ///
  /// In en, this message translates to:
  /// **'Focus indicators visible'**
  String get accessibilityChecklistItem6;

  /// No description provided for @accessibilityHighContrast.
  ///
  /// In en, this message translates to:
  /// **'High Contrast Mode'**
  String get accessibilityHighContrast;

  /// No description provided for @accessibilityHighContrastDescription.
  ///
  /// In en, this message translates to:
  /// **'Toggle to see high-contrast styling for low vision users.'**
  String get accessibilityHighContrastDescription;

  /// No description provided for @accessibilityKeyboardNavFlow.
  ///
  /// In en, this message translates to:
  /// **'Keyboard Navigation Flow'**
  String get accessibilityKeyboardNavFlow;

  /// No description provided for @accessibilityKeyboardNavStep1.
  ///
  /// In en, this message translates to:
  /// **'Tab or click to focus Day View'**
  String get accessibilityKeyboardNavStep1;

  /// No description provided for @accessibilityKeyboardNavStep2.
  ///
  /// In en, this message translates to:
  /// **'Tab to move between events chronologically'**
  String get accessibilityKeyboardNavStep2;

  /// No description provided for @accessibilityKeyboardNavStep3.
  ///
  /// In en, this message translates to:
  /// **'Enter to activate (open event details)'**
  String get accessibilityKeyboardNavStep3;

  /// No description provided for @accessibilityKeyboardNavStep4.
  ///
  /// In en, this message translates to:
  /// **'Cmd/Ctrl+N to create, E to edit, D to delete focused event'**
  String get accessibilityKeyboardNavStep4;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'es', 'fr', 'he'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'he':
      return AppLocalizationsHe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
