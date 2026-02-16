import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'mcal_localizations_ar.dart';
import 'mcal_localizations_en.dart';
import 'mcal_localizations_es.dart';
import 'mcal_localizations_fr.dart';
import 'mcal_localizations_he.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of MCalLocalizations
/// returned by `MCalLocalizations.of(context)`.
///
/// Applications need to include `MCalLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/mcal_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: MCalLocalizations.localizationsDelegates,
///   supportedLocales: MCalLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the MCalLocalizations.supportedLocales
/// property.
abstract class MCalLocalizations {
  MCalLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static MCalLocalizations of(BuildContext context) {
    return Localizations.of<MCalLocalizations>(context, MCalLocalizations)!;
  }

  static const LocalizationsDelegate<MCalLocalizations> delegate =
      _MCalLocalizationsDelegate();

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

  /// No description provided for @daySunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get daySunday;

  /// No description provided for @dayMonday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get dayMonday;

  /// No description provided for @dayTuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get dayTuesday;

  /// No description provided for @dayWednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get dayWednesday;

  /// No description provided for @dayThursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get dayThursday;

  /// No description provided for @dayFriday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get dayFriday;

  /// No description provided for @daySaturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get daySaturday;

  /// No description provided for @daySundayShort.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get daySundayShort;

  /// No description provided for @dayMondayShort.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get dayMondayShort;

  /// No description provided for @dayTuesdayShort.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get dayTuesdayShort;

  /// No description provided for @dayWednesdayShort.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get dayWednesdayShort;

  /// No description provided for @dayThursdayShort.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get dayThursdayShort;

  /// No description provided for @dayFridayShort.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get dayFridayShort;

  /// No description provided for @daySaturdayShort.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get daySaturdayShort;

  /// No description provided for @monthJanuary.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get monthJanuary;

  /// No description provided for @monthFebruary.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get monthFebruary;

  /// No description provided for @monthMarch.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get monthMarch;

  /// No description provided for @monthApril.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get monthApril;

  /// No description provided for @monthMay.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get monthMay;

  /// No description provided for @monthJune.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get monthJune;

  /// No description provided for @monthJuly.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get monthJuly;

  /// No description provided for @monthAugust.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get monthAugust;

  /// No description provided for @monthSeptember.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get monthSeptember;

  /// No description provided for @monthOctober.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get monthOctober;

  /// No description provided for @monthNovember.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get monthNovember;

  /// No description provided for @monthDecember.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get monthDecember;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @week.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get week;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get day;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// No description provided for @previousDay.
  ///
  /// In en, this message translates to:
  /// **'Previous day'**
  String get previousDay;

  /// No description provided for @nextDay.
  ///
  /// In en, this message translates to:
  /// **'Next day'**
  String get nextDay;

  /// No description provided for @previousMonth.
  ///
  /// In en, this message translates to:
  /// **'previous month'**
  String get previousMonth;

  /// No description provided for @nextMonth.
  ///
  /// In en, this message translates to:
  /// **'next month'**
  String get nextMonth;

  /// No description provided for @currentTime.
  ///
  /// In en, this message translates to:
  /// **'Current time: {time}'**
  String currentTime(Object time);

  /// No description provided for @focused.
  ///
  /// In en, this message translates to:
  /// **'focused'**
  String get focused;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'selected'**
  String get selected;

  /// No description provided for @event.
  ///
  /// In en, this message translates to:
  /// **'event'**
  String get event;

  /// No description provided for @events.
  ///
  /// In en, this message translates to:
  /// **'events'**
  String get events;

  /// No description provided for @doubleTapToSelect.
  ///
  /// In en, this message translates to:
  /// **'Double tap to select'**
  String get doubleTapToSelect;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @dropTargetPrefix.
  ///
  /// In en, this message translates to:
  /// **'Drop target'**
  String get dropTargetPrefix;

  /// No description provided for @dropTargetDateRangeTo.
  ///
  /// In en, this message translates to:
  /// **'to'**
  String get dropTargetDateRangeTo;

  /// No description provided for @dropTargetValid.
  ///
  /// In en, this message translates to:
  /// **'valid'**
  String get dropTargetValid;

  /// No description provided for @dropTargetInvalid.
  ///
  /// In en, this message translates to:
  /// **'invalid'**
  String get dropTargetInvalid;

  /// No description provided for @multiDaySpanLabel.
  ///
  /// In en, this message translates to:
  /// **'{days}-day event, day {position} of {days}'**
  String multiDaySpanLabel(Object days, Object position);

  /// No description provided for @scheduleFor.
  ///
  /// In en, this message translates to:
  /// **'Schedule for {date}'**
  String scheduleFor(Object date);

  /// No description provided for @timeGrid.
  ///
  /// In en, this message translates to:
  /// **'Time grid'**
  String get timeGrid;

  /// No description provided for @doubleTapToCreateEvent.
  ///
  /// In en, this message translates to:
  /// **'Double tap to create event'**
  String get doubleTapToCreateEvent;

  /// No description provided for @allDay.
  ///
  /// In en, this message translates to:
  /// **'All day'**
  String get allDay;

  /// No description provided for @announcementResizeCancelled.
  ///
  /// In en, this message translates to:
  /// **'Resize cancelled'**
  String get announcementResizeCancelled;

  /// No description provided for @announcementMoveCancelled.
  ///
  /// In en, this message translates to:
  /// **'Move cancelled for {title}'**
  String announcementMoveCancelled(Object title);

  /// No description provided for @announcementEventSelectionCancelled.
  ///
  /// In en, this message translates to:
  /// **'Event selection cancelled'**
  String get announcementEventSelectionCancelled;

  /// No description provided for @announcementEventsHighlighted.
  ///
  /// In en, this message translates to:
  /// **'{count} events. {title} highlighted. Tab to cycle, Enter to confirm.'**
  String announcementEventsHighlighted(Object count, Object title);

  /// No description provided for @announcementEventSelected.
  ///
  /// In en, this message translates to:
  /// **'Selected {title}. Arrow keys to move, Enter to confirm, Escape to cancel.'**
  String announcementEventSelected(Object title);

  /// No description provided for @announcementEventCycled.
  ///
  /// In en, this message translates to:
  /// **'{title}. {index} of {total}.'**
  String announcementEventCycled(Object title, Object index, Object total);

  /// No description provided for @announcementMovingEvent.
  ///
  /// In en, this message translates to:
  /// **'Moving {title} to {date}'**
  String announcementMovingEvent(Object title, Object date);

  /// No description provided for @announcementResizeModeEntered.
  ///
  /// In en, this message translates to:
  /// **'Resize mode. Adjusting end edge. Arrow keys to resize, S for start, E for end, M for move mode, Enter to confirm.'**
  String get announcementResizeModeEntered;

  /// No description provided for @announcementResizingStartEdge.
  ///
  /// In en, this message translates to:
  /// **'Resizing start edge'**
  String get announcementResizingStartEdge;

  /// No description provided for @announcementResizingEndEdge.
  ///
  /// In en, this message translates to:
  /// **'Resizing end edge'**
  String get announcementResizingEndEdge;

  /// No description provided for @announcementMoveMode.
  ///
  /// In en, this message translates to:
  /// **'Move mode'**
  String get announcementMoveMode;

  /// No description provided for @announcementMoveInvalidTarget.
  ///
  /// In en, this message translates to:
  /// **'Move cancelled. Invalid target.'**
  String get announcementMoveInvalidTarget;

  /// No description provided for @announcementEventMoved.
  ///
  /// In en, this message translates to:
  /// **'Moved {title} to {date}'**
  String announcementEventMoved(Object title, Object date);

  /// No description provided for @announcementResizingProgress.
  ///
  /// In en, this message translates to:
  /// **'Resizing {title} {edge} to {date}, {days} days'**
  String announcementResizingProgress(
    Object title,
    Object edge,
    Object date,
    Object days,
  );

  /// No description provided for @announcementResizeInvalid.
  ///
  /// In en, this message translates to:
  /// **'Resize cancelled. Invalid resize.'**
  String get announcementResizeInvalid;

  /// No description provided for @announcementEventResized.
  ///
  /// In en, this message translates to:
  /// **'Resized {title} to {start} through {end}'**
  String announcementEventResized(Object title, Object start, Object end);
}

class _MCalLocalizationsDelegate
    extends LocalizationsDelegate<MCalLocalizations> {
  const _MCalLocalizationsDelegate();

  @override
  Future<MCalLocalizations> load(Locale locale) {
    return SynchronousFuture<MCalLocalizations>(
      lookupMCalLocalizations(locale),
    );
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'es', 'fr', 'he'].contains(locale.languageCode);

  @override
  bool shouldReload(_MCalLocalizationsDelegate old) => false;
}

MCalLocalizations lookupMCalLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return MCalLocalizationsAr();
    case 'en':
      return MCalLocalizationsEn();
    case 'es':
      return MCalLocalizationsEs();
    case 'fr':
      return MCalLocalizationsFr();
    case 'he':
      return MCalLocalizationsHe();
  }

  throw FlutterError(
    'MCalLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
