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

  /// No description provided for @tabMonthView.
  ///
  /// In en, this message translates to:
  /// **'Month View'**
  String get tabMonthView;

  /// No description provided for @tabDayView.
  ///
  /// In en, this message translates to:
  /// **'Day View'**
  String get tabDayView;

  /// No description provided for @tabComparison.
  ///
  /// In en, this message translates to:
  /// **'Comparison'**
  String get tabComparison;

  /// No description provided for @tabFeatures.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get tabFeatures;

  /// No description provided for @tabTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get tabTheme;

  /// No description provided for @tabStyles.
  ///
  /// In en, this message translates to:
  /// **'Styles'**
  String get tabStyles;

  /// No description provided for @tabStressTest.
  ///
  /// In en, this message translates to:
  /// **'Stress Test'**
  String get tabStressTest;

  /// No description provided for @tabAccessibility.
  ///
  /// In en, this message translates to:
  /// **'Accessibility'**
  String get tabAccessibility;

  /// No description provided for @tabDayFeatures.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get tabDayFeatures;

  /// No description provided for @tabDayTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get tabDayTheme;

  /// No description provided for @tabDayStyles.
  ///
  /// In en, this message translates to:
  /// **'Styles'**
  String get tabDayStyles;

  /// No description provided for @tabDayStressTest.
  ///
  /// In en, this message translates to:
  /// **'Stress Test'**
  String get tabDayStressTest;

  /// No description provided for @tabDayAccessibility.
  ///
  /// In en, this message translates to:
  /// **'Accessibility'**
  String get tabDayAccessibility;

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

  /// No description provided for @sectionSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get sectionSettings;

  /// No description provided for @sectionNavigation.
  ///
  /// In en, this message translates to:
  /// **'Navigation'**
  String get sectionNavigation;

  /// No description provided for @sectionDisplay.
  ///
  /// In en, this message translates to:
  /// **'Display'**
  String get sectionDisplay;

  /// No description provided for @sectionDragDrop.
  ///
  /// In en, this message translates to:
  /// **'Drag & Drop'**
  String get sectionDragDrop;

  /// No description provided for @sectionDragAndDrop.
  ///
  /// In en, this message translates to:
  /// **'Drag & Drop'**
  String get sectionDragAndDrop;

  /// No description provided for @sectionResize.
  ///
  /// In en, this message translates to:
  /// **'Resize'**
  String get sectionResize;

  /// No description provided for @sectionSnapping.
  ///
  /// In en, this message translates to:
  /// **'Snapping'**
  String get sectionSnapping;

  /// No description provided for @sectionAnimation.
  ///
  /// In en, this message translates to:
  /// **'Animation'**
  String get sectionAnimation;

  /// No description provided for @sectionKeyboard.
  ///
  /// In en, this message translates to:
  /// **'Keyboard'**
  String get sectionKeyboard;

  /// No description provided for @sectionTimeRange.
  ///
  /// In en, this message translates to:
  /// **'Time Range'**
  String get sectionTimeRange;

  /// No description provided for @sectionTimeRegions.
  ///
  /// In en, this message translates to:
  /// **'Time Regions'**
  String get sectionTimeRegions;

  /// No description provided for @sectionBlackoutDays.
  ///
  /// In en, this message translates to:
  /// **'Blackout Days'**
  String get sectionBlackoutDays;

  /// No description provided for @sectionCells.
  ///
  /// In en, this message translates to:
  /// **'Cells'**
  String get sectionCells;

  /// No description provided for @sectionEventTiles.
  ///
  /// In en, this message translates to:
  /// **'Event Tiles'**
  String get sectionEventTiles;

  /// No description provided for @sectionHeaders.
  ///
  /// In en, this message translates to:
  /// **'Headers'**
  String get sectionHeaders;

  /// No description provided for @sectionDateLabels.
  ///
  /// In en, this message translates to:
  /// **'Date Labels'**
  String get sectionDateLabels;

  /// No description provided for @sectionOverflow.
  ///
  /// In en, this message translates to:
  /// **'Overflow'**
  String get sectionOverflow;

  /// No description provided for @sectionNavigator.
  ///
  /// In en, this message translates to:
  /// **'Navigator'**
  String get sectionNavigator;

  /// No description provided for @sectionHover.
  ///
  /// In en, this message translates to:
  /// **'Hover'**
  String get sectionHover;

  /// No description provided for @sectionWeekNumbers.
  ///
  /// In en, this message translates to:
  /// **'Week Numbers'**
  String get sectionWeekNumbers;

  /// No description provided for @sectionTimeLegend.
  ///
  /// In en, this message translates to:
  /// **'Time Legend'**
  String get sectionTimeLegend;

  /// No description provided for @sectionGridlines.
  ///
  /// In en, this message translates to:
  /// **'Gridlines'**
  String get sectionGridlines;

  /// No description provided for @sectionCurrentTime.
  ///
  /// In en, this message translates to:
  /// **'Current Time Indicator'**
  String get sectionCurrentTime;

  /// No description provided for @sectionEvents.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get sectionEvents;

  /// No description provided for @sectionAllDayEvents.
  ///
  /// In en, this message translates to:
  /// **'All-Day Events'**
  String get sectionAllDayEvents;

  /// No description provided for @settingShowNavigator.
  ///
  /// In en, this message translates to:
  /// **'Show Navigator'**
  String get settingShowNavigator;

  /// No description provided for @settingEnableSwipeNavigation.
  ///
  /// In en, this message translates to:
  /// **'Enable Swipe Navigation'**
  String get settingEnableSwipeNavigation;

  /// No description provided for @settingSwipeDirection.
  ///
  /// In en, this message translates to:
  /// **'Swipe Direction'**
  String get settingSwipeDirection;

  /// No description provided for @settingFirstDayOfWeek.
  ///
  /// In en, this message translates to:
  /// **'First Day of Week'**
  String get settingFirstDayOfWeek;

  /// No description provided for @settingShowWeekNumbers.
  ///
  /// In en, this message translates to:
  /// **'Show Week Numbers'**
  String get settingShowWeekNumbers;

  /// No description provided for @settingShowWeekNumber.
  ///
  /// In en, this message translates to:
  /// **'Show Week Number'**
  String get settingShowWeekNumber;

  /// No description provided for @settingShowSubHourLabels.
  ///
  /// In en, this message translates to:
  /// **'Show Sub-Hour Labels'**
  String get settingShowSubHourLabels;

  /// No description provided for @settingSubHourLabelInterval.
  ///
  /// In en, this message translates to:
  /// **'Sub-Hour Label Interval'**
  String get settingSubHourLabelInterval;

  /// No description provided for @settingMaxVisibleEventsPerDay.
  ///
  /// In en, this message translates to:
  /// **'Max Visible Events Per Day'**
  String get settingMaxVisibleEventsPerDay;

  /// No description provided for @settingEnableDragToMove.
  ///
  /// In en, this message translates to:
  /// **'Enable Drag to Move'**
  String get settingEnableDragToMove;

  /// No description provided for @settingShowDropTargetTiles.
  ///
  /// In en, this message translates to:
  /// **'Show Drop Target Tiles'**
  String get settingShowDropTargetTiles;

  /// No description provided for @settingShowDropTargetPreview.
  ///
  /// In en, this message translates to:
  /// **'Show Drop Target Preview'**
  String get settingShowDropTargetPreview;

  /// No description provided for @settingShowDropTargetOverlay.
  ///
  /// In en, this message translates to:
  /// **'Show Drop Target Overlay'**
  String get settingShowDropTargetOverlay;

  /// No description provided for @settingDropTargetTilesAboveOverlay.
  ///
  /// In en, this message translates to:
  /// **'Drop Target Tiles Above Overlay'**
  String get settingDropTargetTilesAboveOverlay;

  /// No description provided for @settingDragEdgeNavigationEnabled.
  ///
  /// In en, this message translates to:
  /// **'Drag Edge Navigation Enabled'**
  String get settingDragEdgeNavigationEnabled;

  /// No description provided for @settingDragEdgeNavigationDelay.
  ///
  /// In en, this message translates to:
  /// **'Drag Edge Navigation Delay'**
  String get settingDragEdgeNavigationDelay;

  /// No description provided for @settingDragLongPressDelay.
  ///
  /// In en, this message translates to:
  /// **'Drag Long Press Delay'**
  String get settingDragLongPressDelay;

  /// No description provided for @settingEnableDragToResize.
  ///
  /// In en, this message translates to:
  /// **'Enable Drag to Resize'**
  String get settingEnableDragToResize;

  /// No description provided for @settingEnableAnimations.
  ///
  /// In en, this message translates to:
  /// **'Enable Animations'**
  String get settingEnableAnimations;

  /// No description provided for @settingAnimationDuration.
  ///
  /// In en, this message translates to:
  /// **'Animation Duration'**
  String get settingAnimationDuration;

  /// No description provided for @settingAnimationCurve.
  ///
  /// In en, this message translates to:
  /// **'Animation Curve'**
  String get settingAnimationCurve;

  /// No description provided for @settingEnableKeyboardNavigation.
  ///
  /// In en, this message translates to:
  /// **'Enable Keyboard Navigation'**
  String get settingEnableKeyboardNavigation;

  /// No description provided for @settingAutoFocusOnCellTap.
  ///
  /// In en, this message translates to:
  /// **'Auto Focus on Cell Tap'**
  String get settingAutoFocusOnCellTap;

  /// No description provided for @settingAutoFocusOnEventTap.
  ///
  /// In en, this message translates to:
  /// **'Auto Focus on Event Tap'**
  String get settingAutoFocusOnEventTap;

  /// No description provided for @settingEnableBlackoutDays.
  ///
  /// In en, this message translates to:
  /// **'Enable Blackout Days'**
  String get settingEnableBlackoutDays;

  /// No description provided for @settingCellBackgroundColor.
  ///
  /// In en, this message translates to:
  /// **'Cell Background Color'**
  String get settingCellBackgroundColor;

  /// No description provided for @settingCellBorderColor.
  ///
  /// In en, this message translates to:
  /// **'Cell Border Color'**
  String get settingCellBorderColor;

  /// No description provided for @settingTodayBackgroundColor.
  ///
  /// In en, this message translates to:
  /// **'Today Background Color'**
  String get settingTodayBackgroundColor;

  /// No description provided for @settingEventTileBackgroundColor.
  ///
  /// In en, this message translates to:
  /// **'Event Tile Background Color'**
  String get settingEventTileBackgroundColor;

  /// No description provided for @settingEventTileHeight.
  ///
  /// In en, this message translates to:
  /// **'Event Tile Height'**
  String get settingEventTileHeight;

  /// No description provided for @settingEventTileCornerRadius.
  ///
  /// In en, this message translates to:
  /// **'Event Tile Corner Radius'**
  String get settingEventTileCornerRadius;

  /// No description provided for @settingEventTileHorizontalSpacing.
  ///
  /// In en, this message translates to:
  /// **'Event Tile Horizontal Spacing'**
  String get settingEventTileHorizontalSpacing;

  /// No description provided for @settingEventTileVerticalSpacing.
  ///
  /// In en, this message translates to:
  /// **'Event Tile Vertical Spacing'**
  String get settingEventTileVerticalSpacing;

  /// No description provided for @settingEventTileBorderWidth.
  ///
  /// In en, this message translates to:
  /// **'Event Tile Border Width'**
  String get settingEventTileBorderWidth;

  /// No description provided for @settingIgnoreEventColors.
  ///
  /// In en, this message translates to:
  /// **'Ignore Event Colors'**
  String get settingIgnoreEventColors;

  /// No description provided for @settingWeekdayHeaderBackgroundColor.
  ///
  /// In en, this message translates to:
  /// **'Weekday Header Background Color'**
  String get settingWeekdayHeaderBackgroundColor;

  /// No description provided for @settingDateLabelHeight.
  ///
  /// In en, this message translates to:
  /// **'Date Label Height'**
  String get settingDateLabelHeight;

  /// No description provided for @settingDateLabelPosition.
  ///
  /// In en, this message translates to:
  /// **'Date Label Position'**
  String get settingDateLabelPosition;

  /// No description provided for @settingOverflowIndicatorHeight.
  ///
  /// In en, this message translates to:
  /// **'Overflow Indicator Height'**
  String get settingOverflowIndicatorHeight;

  /// No description provided for @settingNavigatorBackgroundColor.
  ///
  /// In en, this message translates to:
  /// **'Navigator Background Color'**
  String get settingNavigatorBackgroundColor;

  /// No description provided for @settingDropTargetCellValidColor.
  ///
  /// In en, this message translates to:
  /// **'Valid Drop Target Color'**
  String get settingDropTargetCellValidColor;

  /// No description provided for @settingDropTargetCellInvalidColor.
  ///
  /// In en, this message translates to:
  /// **'Invalid Drop Target Color'**
  String get settingDropTargetCellInvalidColor;

  /// No description provided for @settingDragSourceOpacity.
  ///
  /// In en, this message translates to:
  /// **'Drag Source Opacity'**
  String get settingDragSourceOpacity;

  /// No description provided for @settingDraggedTileElevation.
  ///
  /// In en, this message translates to:
  /// **'Dragged Tile Elevation'**
  String get settingDraggedTileElevation;

  /// No description provided for @settingHoverCellBackgroundColor.
  ///
  /// In en, this message translates to:
  /// **'Hover Cell Background Color'**
  String get settingHoverCellBackgroundColor;

  /// No description provided for @settingHoverEventBackgroundColor.
  ///
  /// In en, this message translates to:
  /// **'Hover Event Background Color'**
  String get settingHoverEventBackgroundColor;

  /// No description provided for @settingWeekNumberBackgroundColor.
  ///
  /// In en, this message translates to:
  /// **'Week Number Background Color'**
  String get settingWeekNumberBackgroundColor;

  /// No description provided for @settingStartHour.
  ///
  /// In en, this message translates to:
  /// **'Start Hour'**
  String get settingStartHour;

  /// No description provided for @settingEndHour.
  ///
  /// In en, this message translates to:
  /// **'End Hour'**
  String get settingEndHour;

  /// No description provided for @settingTimeSlotDuration.
  ///
  /// In en, this message translates to:
  /// **'Time Slot Duration'**
  String get settingTimeSlotDuration;

  /// No description provided for @settingGridlineInterval.
  ///
  /// In en, this message translates to:
  /// **'Gridline Interval'**
  String get settingGridlineInterval;

  /// No description provided for @settingHourHeight.
  ///
  /// In en, this message translates to:
  /// **'Hour Height'**
  String get settingHourHeight;

  /// No description provided for @settingAutoScrollToCurrentTime.
  ///
  /// In en, this message translates to:
  /// **'Auto Scroll to Current Time'**
  String get settingAutoScrollToCurrentTime;

  /// No description provided for @settingShowCurrentTimeIndicator.
  ///
  /// In en, this message translates to:
  /// **'Show Current Time Indicator'**
  String get settingShowCurrentTimeIndicator;

  /// No description provided for @settingAllDaySectionMaxRows.
  ///
  /// In en, this message translates to:
  /// **'All-Day Section Max Rows'**
  String get settingAllDaySectionMaxRows;

  /// No description provided for @settingAllDayToTimedDuration.
  ///
  /// In en, this message translates to:
  /// **'All-Day to Timed Duration'**
  String get settingAllDayToTimedDuration;

  /// No description provided for @settingSnapToTimeSlots.
  ///
  /// In en, this message translates to:
  /// **'Snap to Time Slots'**
  String get settingSnapToTimeSlots;

  /// No description provided for @settingSnapToOtherEvents.
  ///
  /// In en, this message translates to:
  /// **'Snap to Other Events'**
  String get settingSnapToOtherEvents;

  /// No description provided for @settingSnapToCurrentTime.
  ///
  /// In en, this message translates to:
  /// **'Snap to Current Time'**
  String get settingSnapToCurrentTime;

  /// No description provided for @settingSnapRange.
  ///
  /// In en, this message translates to:
  /// **'Snap Range'**
  String get settingSnapRange;

  /// No description provided for @settingEnableSpecialTimeRegions.
  ///
  /// In en, this message translates to:
  /// **'Enable Special Time Regions'**
  String get settingEnableSpecialTimeRegions;

  /// No description provided for @settingEnableBlackoutTimes.
  ///
  /// In en, this message translates to:
  /// **'Enable Blackout Times'**
  String get settingEnableBlackoutTimes;

  /// No description provided for @settingTimeLegendWidth.
  ///
  /// In en, this message translates to:
  /// **'Time Legend Width'**
  String get settingTimeLegendWidth;

  /// No description provided for @settingShowTimeLegendTicks.
  ///
  /// In en, this message translates to:
  /// **'Show Time Legend Ticks'**
  String get settingShowTimeLegendTicks;

  /// No description provided for @settingTimeLegendTickColor.
  ///
  /// In en, this message translates to:
  /// **'Time Legend Tick Color'**
  String get settingTimeLegendTickColor;

  /// No description provided for @settingTimeLegendTickWidth.
  ///
  /// In en, this message translates to:
  /// **'Time Legend Tick Width'**
  String get settingTimeLegendTickWidth;

  /// No description provided for @settingTimeLegendTickLength.
  ///
  /// In en, this message translates to:
  /// **'Time Legend Tick Length'**
  String get settingTimeLegendTickLength;

  /// No description provided for @settingHourGridlineColor.
  ///
  /// In en, this message translates to:
  /// **'Hour Gridline Color'**
  String get settingHourGridlineColor;

  /// No description provided for @settingHourGridlineWidth.
  ///
  /// In en, this message translates to:
  /// **'Hour Gridline Width'**
  String get settingHourGridlineWidth;

  /// No description provided for @settingMajorGridlineColor.
  ///
  /// In en, this message translates to:
  /// **'Major Gridline Color'**
  String get settingMajorGridlineColor;

  /// No description provided for @settingMajorGridlineWidth.
  ///
  /// In en, this message translates to:
  /// **'Major Gridline Width'**
  String get settingMajorGridlineWidth;

  /// No description provided for @settingMinorGridlineColor.
  ///
  /// In en, this message translates to:
  /// **'Minor Gridline Color'**
  String get settingMinorGridlineColor;

  /// No description provided for @settingMinorGridlineWidth.
  ///
  /// In en, this message translates to:
  /// **'Minor Gridline Width'**
  String get settingMinorGridlineWidth;

  /// No description provided for @settingCurrentTimeIndicatorColor.
  ///
  /// In en, this message translates to:
  /// **'Current Time Indicator Color'**
  String get settingCurrentTimeIndicatorColor;

  /// No description provided for @settingCurrentTimeIndicatorWidth.
  ///
  /// In en, this message translates to:
  /// **'Current Time Indicator Width'**
  String get settingCurrentTimeIndicatorWidth;

  /// No description provided for @settingCurrentTimeIndicatorDotRadius.
  ///
  /// In en, this message translates to:
  /// **'Current Time Indicator Dot Radius'**
  String get settingCurrentTimeIndicatorDotRadius;

  /// No description provided for @settingTimedEventBorderRadius.
  ///
  /// In en, this message translates to:
  /// **'Timed Event Border Radius'**
  String get settingTimedEventBorderRadius;

  /// No description provided for @settingTimedEventMinHeight.
  ///
  /// In en, this message translates to:
  /// **'Timed Event Min Height'**
  String get settingTimedEventMinHeight;

  /// No description provided for @settingTimedEventPadding.
  ///
  /// In en, this message translates to:
  /// **'Timed Event Padding'**
  String get settingTimedEventPadding;

  /// No description provided for @settingAllDayEventBackgroundColor.
  ///
  /// In en, this message translates to:
  /// **'All-Day Event Background Color'**
  String get settingAllDayEventBackgroundColor;

  /// No description provided for @settingAllDayEventBorderColor.
  ///
  /// In en, this message translates to:
  /// **'All-Day Event Border Color'**
  String get settingAllDayEventBorderColor;

  /// No description provided for @settingAllDayEventBorderWidth.
  ///
  /// In en, this message translates to:
  /// **'All-Day Event Border Width'**
  String get settingAllDayEventBorderWidth;

  /// No description provided for @settingSpecialTimeRegionColor.
  ///
  /// In en, this message translates to:
  /// **'Special Time Region Color'**
  String get settingSpecialTimeRegionColor;

  /// No description provided for @settingBlockedTimeRegionColor.
  ///
  /// In en, this message translates to:
  /// **'Blocked Time Region Color'**
  String get settingBlockedTimeRegionColor;

  /// No description provided for @settingTimeRegionBorderColor.
  ///
  /// In en, this message translates to:
  /// **'Time Region Border Color'**
  String get settingTimeRegionBorderColor;

  /// No description provided for @settingTimeRegionTextColor.
  ///
  /// In en, this message translates to:
  /// **'Time Region Text Color'**
  String get settingTimeRegionTextColor;

  /// No description provided for @settingResizeHandleSize.
  ///
  /// In en, this message translates to:
  /// **'Resize Handle Size'**
  String get settingResizeHandleSize;

  /// No description provided for @settingMinResizeDurationMinutes.
  ///
  /// In en, this message translates to:
  /// **'Min Resize Duration (Minutes)'**
  String get settingMinResizeDurationMinutes;

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

  /// No description provided for @styleFeaturesDemo.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get styleFeaturesDemo;

  /// No description provided for @styleStressTest.
  ///
  /// In en, this message translates to:
  /// **'Stress Test'**
  String get styleStressTest;

  /// No description provided for @featureSettings.
  ///
  /// In en, this message translates to:
  /// **'Feature Settings'**
  String get featureSettings;

  /// No description provided for @testSettings.
  ///
  /// In en, this message translates to:
  /// **'Test Settings'**
  String get testSettings;

  /// No description provided for @accessibilitySettings.
  ///
  /// In en, this message translates to:
  /// **'Accessibility Settings'**
  String get accessibilitySettings;

  /// No description provided for @styleAccessibility.
  ///
  /// In en, this message translates to:
  /// **'Accessibility'**
  String get styleAccessibility;

  /// No description provided for @styleRtlDemo.
  ///
  /// In en, this message translates to:
  /// **'RTL Demo'**
  String get styleRtlDemo;

  /// No description provided for @styleThemeCustomization.
  ///
  /// In en, this message translates to:
  /// **'Theme Customization'**
  String get styleThemeCustomization;

  /// No description provided for @styleDefaultDescription.
  ///
  /// In en, this message translates to:
  /// **'Out-of-the-box view with default theme. Drag events to move, resize from edges. Shows all features with library defaults.'**
  String get styleDefaultDescription;

  /// No description provided for @styleClassicDescription.
  ///
  /// In en, this message translates to:
  /// **'Traditional grid with borders, square corners, uniform colors. Business-focused aesthetic.'**
  String get styleClassicDescription;

  /// No description provided for @styleModernDescription.
  ///
  /// In en, this message translates to:
  /// **'Clean, rounded design with colorful event indicators. Contemporary look and feel.'**
  String get styleModernDescription;

  /// No description provided for @styleColorfulDescription.
  ///
  /// In en, this message translates to:
  /// **'Vibrant gradients and bold colors. Playful, creative aesthetic.'**
  String get styleColorfulDescription;

  /// No description provided for @styleMinimalDescription.
  ///
  /// In en, this message translates to:
  /// **'Bare bones, text-only design. Maximum whitespace, minimal gridlines, subtle colors. Clean and spacious.'**
  String get styleMinimalDescription;

  /// No description provided for @styleFeaturesDemoDescription.
  ///
  /// In en, this message translates to:
  /// **'Comprehensive showcase of all calendar features: drag-drop, resize, keyboard navigation, gesture handlers, and interactive controls.'**
  String get styleFeaturesDemoDescription;

  /// No description provided for @styleStressTestDescription.
  ///
  /// In en, this message translates to:
  /// **'Performance demo with 100–500 events. Toggle stress mode, select event count, view FPS and frame metrics. Demonstrates smooth rendering with many overlapping events.'**
  String get styleStressTestDescription;

  /// No description provided for @styleAccessibilityDescription.
  ///
  /// In en, this message translates to:
  /// **'Demonstrate accessibility features: keyboard shortcuts, screen reader support, high contrast mode. WCAG 2.1 AA compliant.'**
  String get styleAccessibilityDescription;

  /// No description provided for @styleRtlDemoDescription.
  ///
  /// In en, this message translates to:
  /// **'Day View in right-to-left layout (Arabic). Time legend on right, navigator arrows flipped. Demonstrates full RTL support for Arabic and other RTL languages.'**
  String get styleRtlDemoDescription;

  /// No description provided for @styleThemeCustomizationDescription.
  ///
  /// In en, this message translates to:
  /// **'Customize theme properties: hour height, gridlines, time slots, event tiles, resize handles. Presets for common configurations. Changes apply immediately.'**
  String get styleThemeCustomizationDescription;

  /// No description provided for @themeSettings.
  ///
  /// In en, this message translates to:
  /// **'Theme Settings'**
  String get themeSettings;

  /// No description provided for @themePresets.
  ///
  /// In en, this message translates to:
  /// **'Theme Presets'**
  String get themePresets;

  /// No description provided for @presetDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get presetDefault;

  /// No description provided for @presetCompact.
  ///
  /// In en, this message translates to:
  /// **'Compact'**
  String get presetCompact;

  /// No description provided for @presetSpacious.
  ///
  /// In en, this message translates to:
  /// **'Spacious'**
  String get presetSpacious;

  /// No description provided for @presetHighContrast.
  ///
  /// In en, this message translates to:
  /// **'High Contrast'**
  String get presetHighContrast;

  /// No description provided for @presetMinimal.
  ///
  /// In en, this message translates to:
  /// **'Minimal'**
  String get presetMinimal;

  /// No description provided for @dateLabelPositionTopLeft.
  ///
  /// In en, this message translates to:
  /// **'Top Left'**
  String get dateLabelPositionTopLeft;

  /// No description provided for @dateLabelPositionTopCenter.
  ///
  /// In en, this message translates to:
  /// **'Top Center'**
  String get dateLabelPositionTopCenter;

  /// No description provided for @dateLabelPositionTopRight.
  ///
  /// In en, this message translates to:
  /// **'Top Right'**
  String get dateLabelPositionTopRight;

  /// No description provided for @dateLabelPositionBottomLeft.
  ///
  /// In en, this message translates to:
  /// **'Bottom Left'**
  String get dateLabelPositionBottomLeft;

  /// No description provided for @dateLabelPositionBottomCenter.
  ///
  /// In en, this message translates to:
  /// **'Bottom Center'**
  String get dateLabelPositionBottomCenter;

  /// No description provided for @dateLabelPositionBottomRight.
  ///
  /// In en, this message translates to:
  /// **'Bottom Right'**
  String get dateLabelPositionBottomRight;

  /// No description provided for @swipeDirectionHorizontal.
  ///
  /// In en, this message translates to:
  /// **'Horizontal'**
  String get swipeDirectionHorizontal;

  /// No description provided for @swipeDirectionVertical.
  ///
  /// In en, this message translates to:
  /// **'Vertical'**
  String get swipeDirectionVertical;

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

  /// No description provided for @daySunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get daySunday;

  /// No description provided for @stressTestMode.
  ///
  /// In en, this message translates to:
  /// **'Stress Test Mode'**
  String get stressTestMode;

  /// No description provided for @stressTestEventCount.
  ///
  /// In en, this message translates to:
  /// **'Event Count'**
  String get stressTestEventCount;

  /// No description provided for @stressTestEventCount100.
  ///
  /// In en, this message translates to:
  /// **'100 Events'**
  String get stressTestEventCount100;

  /// No description provided for @stressTestEventCount200.
  ///
  /// In en, this message translates to:
  /// **'200 Events'**
  String get stressTestEventCount200;

  /// No description provided for @stressTestEventCount300.
  ///
  /// In en, this message translates to:
  /// **'300 Events'**
  String get stressTestEventCount300;

  /// No description provided for @stressTestEventCount500.
  ///
  /// In en, this message translates to:
  /// **'500 Events'**
  String get stressTestEventCount500;

  /// No description provided for @stressTestShowOverlay.
  ///
  /// In en, this message translates to:
  /// **'Show Performance Overlay'**
  String get stressTestShowOverlay;

  /// No description provided for @stressTestSettings.
  ///
  /// In en, this message translates to:
  /// **'Stress Test Settings'**
  String get stressTestSettings;

  /// No description provided for @stressTestControls.
  ///
  /// In en, this message translates to:
  /// **'Controls'**
  String get stressTestControls;

  /// No description provided for @stressTestMetrics.
  ///
  /// In en, this message translates to:
  /// **'Performance Metrics'**
  String get stressTestMetrics;

  /// No description provided for @stressTestPerformanceGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get stressTestPerformanceGood;

  /// No description provided for @stressTestPerformancePoor.
  ///
  /// In en, this message translates to:
  /// **'Poor'**
  String get stressTestPerformancePoor;

  /// Number of events in stress test
  ///
  /// In en, this message translates to:
  /// **'Event Count: {count}'**
  String stressTestEventCountLabel(String count);

  /// Average frame time in milliseconds
  ///
  /// In en, this message translates to:
  /// **'Avg Frame Time: {ms} ms'**
  String stressTestAvgFrameTime(String ms);

  /// Frames per second
  ///
  /// In en, this message translates to:
  /// **'FPS: {fps}'**
  String stressTestFps(String fps);

  /// Number of events in stress test
  ///
  /// In en, this message translates to:
  /// **'Event Count: {count}'**
  String stressTestMetricEventCount(int count);

  /// Average frame time in milliseconds
  ///
  /// In en, this message translates to:
  /// **'Avg Frame Time: {ms} ms'**
  String stressTestMetricAvgFrame(String ms);

  /// Frames per second
  ///
  /// In en, this message translates to:
  /// **'FPS: {fps}'**
  String stressTestMetricFps(String fps);

  /// No description provided for @accessibilityTitle.
  ///
  /// In en, this message translates to:
  /// **'Accessibility'**
  String get accessibilityTitle;

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

  /// No description provided for @accessibilityShortcutDeleteKeys.
  ///
  /// In en, this message translates to:
  /// **'D: Delete selected event'**
  String get accessibilityShortcutDeleteKeys;

  /// No description provided for @accessibilityShortcutNavigate.
  ///
  /// In en, this message translates to:
  /// **'Navigate'**
  String get accessibilityShortcutNavigate;

  /// No description provided for @accessibilityShortcutNavigateDays.
  ///
  /// In en, this message translates to:
  /// **'Arrow keys: Navigate days'**
  String get accessibilityShortcutNavigateDays;

  /// No description provided for @accessibilityShortcutCycleEvents.
  ///
  /// In en, this message translates to:
  /// **'Tab: Cycle through events'**
  String get accessibilityShortcutCycleEvents;

  /// No description provided for @accessibilityShortcutActivate.
  ///
  /// In en, this message translates to:
  /// **'Enter: Activate event'**
  String get accessibilityShortcutActivate;

  /// No description provided for @accessibilityShortcutDrag.
  ///
  /// In en, this message translates to:
  /// **'Drag'**
  String get accessibilityShortcutDrag;

  /// No description provided for @accessibilityShortcutDragMove.
  ///
  /// In en, this message translates to:
  /// **'Arrow keys during drag: Move event'**
  String get accessibilityShortcutDragMove;

  /// No description provided for @accessibilityShortcutResize.
  ///
  /// In en, this message translates to:
  /// **'Resize'**
  String get accessibilityShortcutResize;

  /// No description provided for @accessibilityShortcutResizeEvent.
  ///
  /// In en, this message translates to:
  /// **'Shift+Arrow keys: Resize event'**
  String get accessibilityShortcutResizeEvent;

  /// No description provided for @accessibilityShortcutArrows.
  ///
  /// In en, this message translates to:
  /// **'Arrow keys'**
  String get accessibilityShortcutArrows;

  /// No description provided for @accessibilityShortcutEnter.
  ///
  /// In en, this message translates to:
  /// **'Enter / Space'**
  String get accessibilityShortcutEnter;

  /// No description provided for @accessibilityShortcutHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get accessibilityShortcutHome;

  /// No description provided for @accessibilityShortcutEnd.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get accessibilityShortcutEnd;

  /// No description provided for @accessibilityShortcutPageUp.
  ///
  /// In en, this message translates to:
  /// **'Page Up'**
  String get accessibilityShortcutPageUp;

  /// No description provided for @accessibilityShortcutPageDown.
  ///
  /// In en, this message translates to:
  /// **'Page Down'**
  String get accessibilityShortcutPageDown;

  /// No description provided for @accessibilityShortcutTab.
  ///
  /// In en, this message translates to:
  /// **'Tab / Shift+Tab'**
  String get accessibilityShortcutTab;

  /// No description provided for @accessibilityShortcutEscape.
  ///
  /// In en, this message translates to:
  /// **'Escape'**
  String get accessibilityShortcutEscape;

  /// No description provided for @accessibilityShortcutR.
  ///
  /// In en, this message translates to:
  /// **'R'**
  String get accessibilityShortcutR;

  /// No description provided for @accessibilityShortcutS.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get accessibilityShortcutS;

  /// No description provided for @accessibilityShortcutE.
  ///
  /// In en, this message translates to:
  /// **'E'**
  String get accessibilityShortcutE;

  /// No description provided for @accessibilityShortcutM.
  ///
  /// In en, this message translates to:
  /// **'M'**
  String get accessibilityShortcutM;

  /// No description provided for @accessibilityKeyboardNavInstructions.
  ///
  /// In en, this message translates to:
  /// **'Keyboard Navigation Instructions'**
  String get accessibilityKeyboardNavInstructions;

  /// No description provided for @accessibilityKeyboardNavInstructionsDetail.
  ///
  /// In en, this message translates to:
  /// **'Use Tab to focus the calendar, then use arrow keys to navigate between days and events. Press Enter to activate an event, Cmd/Ctrl+N to create a new event, E to edit, and D to delete.'**
  String get accessibilityKeyboardNavInstructionsDetail;

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
  /// **'Tab or click to focus calendar view'**
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

  /// No description provided for @accessibilityMonthKeyboardShortcuts.
  ///
  /// In en, this message translates to:
  /// **'Month View Keyboard Shortcuts'**
  String get accessibilityMonthKeyboardShortcuts;

  /// No description provided for @accessibilityMonthKeyboardNavInstructionsDetail.
  ///
  /// In en, this message translates to:
  /// **'Tab or click to focus the calendar, then use arrow keys to navigate between cells. Press Enter or Space to select a cell. Tab to cycle through events within a cell. With an event focused, press Enter to enter move mode and use arrow keys to move it to a target cell, then Enter to confirm or Escape to cancel. Press R to enter resize mode, S/E to choose the start or end edge, then arrow keys to resize.'**
  String get accessibilityMonthKeyboardNavInstructionsDetail;

  /// No description provided for @accessibilityMonthShortcutArrows.
  ///
  /// In en, this message translates to:
  /// **'Arrow keys: Navigate cells'**
  String get accessibilityMonthShortcutArrows;

  /// No description provided for @accessibilityMonthShortcutEnterSpace.
  ///
  /// In en, this message translates to:
  /// **'Enter/Space: Select cell or enter event mode'**
  String get accessibilityMonthShortcutEnterSpace;

  /// No description provided for @accessibilityMonthShortcutHome.
  ///
  /// In en, this message translates to:
  /// **'Home: First day of month'**
  String get accessibilityMonthShortcutHome;

  /// No description provided for @accessibilityMonthShortcutEnd.
  ///
  /// In en, this message translates to:
  /// **'End: Last day of month'**
  String get accessibilityMonthShortcutEnd;

  /// No description provided for @accessibilityMonthShortcutPageUp.
  ///
  /// In en, this message translates to:
  /// **'Page Up: Previous month'**
  String get accessibilityMonthShortcutPageUp;

  /// No description provided for @accessibilityMonthShortcutPageDown.
  ///
  /// In en, this message translates to:
  /// **'Page Down: Next month'**
  String get accessibilityMonthShortcutPageDown;

  /// No description provided for @accessibilityMonthShortcutTab.
  ///
  /// In en, this message translates to:
  /// **'Tab/Shift+Tab: Cycle events in selected cell'**
  String get accessibilityMonthShortcutTab;

  /// No description provided for @accessibilityMonthShortcutEnterConfirm.
  ///
  /// In en, this message translates to:
  /// **'Enter: Confirm move'**
  String get accessibilityMonthShortcutEnterConfirm;

  /// No description provided for @accessibilityMonthShortcutEscape.
  ///
  /// In en, this message translates to:
  /// **'Escape: Cancel operation'**
  String get accessibilityMonthShortcutEscape;

  /// No description provided for @accessibilityMonthShortcutR.
  ///
  /// In en, this message translates to:
  /// **'R: Enter resize mode'**
  String get accessibilityMonthShortcutR;

  /// No description provided for @accessibilityMonthShortcutS.
  ///
  /// In en, this message translates to:
  /// **'S: Switch to start edge'**
  String get accessibilityMonthShortcutS;

  /// No description provided for @accessibilityMonthShortcutE.
  ///
  /// In en, this message translates to:
  /// **'E: Switch to end edge'**
  String get accessibilityMonthShortcutE;

  /// No description provided for @accessibilityMonthShortcutM.
  ///
  /// In en, this message translates to:
  /// **'M: Return to move mode'**
  String get accessibilityMonthShortcutM;

  /// No description provided for @accessibilityDayKeyboardShortcuts.
  ///
  /// In en, this message translates to:
  /// **'Day View Keyboard Shortcuts'**
  String get accessibilityDayKeyboardShortcuts;

  /// No description provided for @accessibilityDayShortcutArrows.
  ///
  /// In en, this message translates to:
  /// **'Arrow keys: Navigate days/events'**
  String get accessibilityDayShortcutArrows;

  /// No description provided for @accessibilityDayShortcutTab.
  ///
  /// In en, this message translates to:
  /// **'Tab: Cycle through events'**
  String get accessibilityDayShortcutTab;

  /// No description provided for @accessibilityDayShortcutEnter.
  ///
  /// In en, this message translates to:
  /// **'Enter: Activate event'**
  String get accessibilityDayShortcutEnter;

  /// No description provided for @accessibilityDayShortcutCreate.
  ///
  /// In en, this message translates to:
  /// **'Cmd/Ctrl+N: Create new event'**
  String get accessibilityDayShortcutCreate;

  /// No description provided for @accessibilityDayShortcutEdit.
  ///
  /// In en, this message translates to:
  /// **'E: Edit selected event'**
  String get accessibilityDayShortcutEdit;

  /// No description provided for @accessibilityDayShortcutDelete.
  ///
  /// In en, this message translates to:
  /// **'D: Delete selected event'**
  String get accessibilityDayShortcutDelete;

  /// No description provided for @accessibilityDayShortcutDragMove.
  ///
  /// In en, this message translates to:
  /// **'Arrow keys during drag: Move event'**
  String get accessibilityDayShortcutDragMove;

  /// No description provided for @accessibilityDayShortcutResize.
  ///
  /// In en, this message translates to:
  /// **'Shift+Arrow keys: Resize event'**
  String get accessibilityDayShortcutResize;

  /// Message shown when a cell is tapped
  ///
  /// In en, this message translates to:
  /// **'Cell tapped: {date}'**
  String snackbarCellTap(String date);

  /// Message shown when a cell is long pressed
  ///
  /// In en, this message translates to:
  /// **'Cell long pressed: {date}'**
  String snackbarCellLongPress(String date);

  /// Message shown when a cell is double tapped
  ///
  /// In en, this message translates to:
  /// **'Cell double tapped: {date}'**
  String snackbarCellDoubleTap(String date);

  /// Message shown when a date label is tapped
  ///
  /// In en, this message translates to:
  /// **'Date label tapped: {date}'**
  String snackbarDateLabelTap(String date);

  /// Message shown when a date label is long pressed
  ///
  /// In en, this message translates to:
  /// **'Date label long pressed: {date}'**
  String snackbarDateLabelLongPress(String date);

  /// Message shown when an event is tapped
  ///
  /// In en, this message translates to:
  /// **'Event tapped: {title}'**
  String snackbarEventTap(String title);

  /// Message shown when an event is long pressed
  ///
  /// In en, this message translates to:
  /// **'Event long pressed: {title}'**
  String snackbarEventLongPress(String title);

  /// Message shown when an event is double tapped
  ///
  /// In en, this message translates to:
  /// **'Event double tapped: {title}'**
  String snackbarEventDoubleTap(String title);

  /// Message shown when overflow indicator is tapped
  ///
  /// In en, this message translates to:
  /// **'Overflow tapped: {count} events'**
  String snackbarOverflowTap(int count);

  /// Message shown when overflow indicator is long pressed
  ///
  /// In en, this message translates to:
  /// **'Overflow long pressed: {date} ({count} hidden events)'**
  String snackbarOverflowLongPress(String date, int count);

  /// Message shown when hovering over a cell
  ///
  /// In en, this message translates to:
  /// **'Hovering over cell: {date}'**
  String snackbarHoverCell(String date);

  /// Message shown when hovering over an event
  ///
  /// In en, this message translates to:
  /// **'Hovering over event: {title}'**
  String snackbarHoverEvent(String title);

  /// Message shown when drag operation will be accepted
  ///
  /// In en, this message translates to:
  /// **'Drag will accept: {title} at {date}'**
  String snackbarDragWillAccept(String title, String date);

  /// Message shown when drop is rejected due to blackout date
  ///
  /// In en, this message translates to:
  /// **'Drop rejected: {date} is blocked'**
  String snackbarDropRejected(String date);

  /// Message shown when an event is dropped
  ///
  /// In en, this message translates to:
  /// **'Event dropped: {title} at {time}'**
  String snackbarEventDropped(String title, String time);

  /// Message shown when an event is resized
  ///
  /// In en, this message translates to:
  /// **'Event resized: {title} to {minutes} min'**
  String snackbarEventResized(String title, String minutes);

  /// Message shown when resize operation will be accepted
  ///
  /// In en, this message translates to:
  /// **'Resize will accept: {title} to {minutes} min'**
  String snackbarResizeWillAccept(String title, String minutes);

  /// Message shown when a multi-day event is resized
  ///
  /// In en, this message translates to:
  /// **'Event resized: {title} to {days} days'**
  String snackbarEventResizedDays(String title, int days);

  /// Message shown when focused date changes
  ///
  /// In en, this message translates to:
  /// **'Focused date changed: {date}'**
  String snackbarFocusedDateChanged(String date);

  /// Message shown when swipe navigation occurs
  ///
  /// In en, this message translates to:
  /// **'Swiped to {direction}'**
  String snackbarSwipeNavigation(String direction);

  /// Message shown when day header is tapped
  ///
  /// In en, this message translates to:
  /// **'Day header tapped: {date}'**
  String snackbarDayHeaderTap(String date);

  /// Message shown when day header is long pressed
  ///
  /// In en, this message translates to:
  /// **'Day header long pressed: {date}'**
  String snackbarDayHeaderLongPress(String date);

  /// Message shown when time label is tapped
  ///
  /// In en, this message translates to:
  /// **'Time label tapped: {time}'**
  String snackbarTimeLabelTap(String time);

  /// Message shown when time slot is tapped
  ///
  /// In en, this message translates to:
  /// **'Time slot tapped: {time}'**
  String snackbarTimeSlotTap(String time);

  /// Message shown when time slot is long pressed
  ///
  /// In en, this message translates to:
  /// **'Time slot long pressed: {time}'**
  String snackbarTimeSlotLongPress(String time);

  /// Message shown when empty space is double tapped
  ///
  /// In en, this message translates to:
  /// **'Empty space double tapped: {time}'**
  String snackbarEmptySpaceDoubleTap(String time);

  /// Message shown when hovering over time slot
  ///
  /// In en, this message translates to:
  /// **'Hovering over time slot: {time}'**
  String snackbarHoverTimeSlot(String time);

  /// Message shown when event is created
  ///
  /// In en, this message translates to:
  /// **'Created: {title}'**
  String snackbarEventCreated(String title);

  /// Message shown when event is updated
  ///
  /// In en, this message translates to:
  /// **'Updated: {title}'**
  String snackbarEventUpdated(String title);

  /// Message shown when event is deleted
  ///
  /// In en, this message translates to:
  /// **'Deleted: {title}'**
  String snackbarEventDeleted(String title);

  /// No description provided for @dialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Event Details'**
  String get dialogTitle;

  /// No description provided for @dialogTitleCreate.
  ///
  /// In en, this message translates to:
  /// **'Create Event'**
  String get dialogTitleCreate;

  /// No description provided for @dialogTitleEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Event'**
  String get dialogTitleEdit;

  /// No description provided for @dialogNewEvent.
  ///
  /// In en, this message translates to:
  /// **'New Event'**
  String get dialogNewEvent;

  /// No description provided for @dialogEditEvent.
  ///
  /// In en, this message translates to:
  /// **'Edit Event'**
  String get dialogEditEvent;

  /// No description provided for @dialogSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get dialogSave;

  /// No description provided for @dialogCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get dialogCancel;

  /// No description provided for @dialogDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get dialogDelete;

  /// No description provided for @dialogEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get dialogEdit;

  /// No description provided for @dialogClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get dialogClose;

  /// No description provided for @dialogCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get dialogCreate;

  /// No description provided for @dialogStartDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get dialogStartDate;

  /// No description provided for @dialogEndDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get dialogEndDate;

  /// No description provided for @dialogStartTime.
  ///
  /// In en, this message translates to:
  /// **'Start Time'**
  String get dialogStartTime;

  /// No description provided for @dialogEndTime.
  ///
  /// In en, this message translates to:
  /// **'End Time'**
  String get dialogEndTime;

  /// No description provided for @dialogAllDay.
  ///
  /// In en, this message translates to:
  /// **'All Day'**
  String get dialogAllDay;

  /// No description provided for @dialogAllDayEvent.
  ///
  /// In en, this message translates to:
  /// **'All Day Event'**
  String get dialogAllDayEvent;

  /// No description provided for @dialogColor.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get dialogColor;

  /// No description provided for @dialogTitleField.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get dialogTitleField;

  /// No description provided for @dialogTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Title is required'**
  String get dialogTitleRequired;

  /// No description provided for @dialogEndTimeAfterStart.
  ///
  /// In en, this message translates to:
  /// **'End time must be after start time'**
  String get dialogEndTimeAfterStart;

  /// No description provided for @dialogSelectStartDate.
  ///
  /// In en, this message translates to:
  /// **'Select start date'**
  String get dialogSelectStartDate;

  /// No description provided for @dialogSelectStartTime.
  ///
  /// In en, this message translates to:
  /// **'Select start time'**
  String get dialogSelectStartTime;

  /// No description provided for @dialogSelectEndDate.
  ///
  /// In en, this message translates to:
  /// **'Select end date'**
  String get dialogSelectEndDate;

  /// No description provided for @dialogSelectEndTime.
  ///
  /// In en, this message translates to:
  /// **'Select end time'**
  String get dialogSelectEndTime;

  /// No description provided for @dialogDeleteEventTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Event'**
  String get dialogDeleteEventTitle;

  /// Confirmation message for deleting event
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{title}\"?'**
  String dialogDeleteEventConfirm(String title);

  /// No description provided for @dialogDescriptionField.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get dialogDescriptionField;

  /// No description provided for @dialogLocationField.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get dialogLocationField;

  /// No description provided for @dialogRecurrence.
  ///
  /// In en, this message translates to:
  /// **'Recurrence'**
  String get dialogRecurrence;

  /// No description provided for @dialogAddRecurrence.
  ///
  /// In en, this message translates to:
  /// **'Add Recurrence'**
  String get dialogAddRecurrence;

  /// No description provided for @dialogEditRecurrence.
  ///
  /// In en, this message translates to:
  /// **'Edit Recurrence'**
  String get dialogEditRecurrence;

  /// No description provided for @dialogRemoveRecurrence.
  ///
  /// In en, this message translates to:
  /// **'Remove Recurrence'**
  String get dialogRemoveRecurrence;

  /// No description provided for @buttonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get buttonSave;

  /// No description provided for @buttonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get buttonCancel;

  /// No description provided for @buttonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get buttonDelete;

  /// No description provided for @buttonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get buttonEdit;

  /// No description provided for @buttonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get buttonClose;

  /// No description provided for @buttonCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get buttonCreate;

  /// No description provided for @buttonAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get buttonAdd;

  /// No description provided for @buttonRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get buttonRemove;

  /// No description provided for @buttonApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get buttonApply;

  /// No description provided for @buttonReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get buttonReset;

  /// No description provided for @valueEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get valueEnabled;

  /// No description provided for @valueDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get valueDisabled;

  /// No description provided for @valueNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get valueNone;

  /// Minutes value label
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String valueMinutes(int minutes);

  /// Milliseconds value label
  ///
  /// In en, this message translates to:
  /// **'{ms} ms'**
  String valueMilliseconds(int ms);

  /// No description provided for @valuePrevious.
  ///
  /// In en, this message translates to:
  /// **'previous'**
  String get valuePrevious;

  /// No description provided for @valueNext.
  ///
  /// In en, this message translates to:
  /// **'next'**
  String get valueNext;

  /// No description provided for @valueEaseInOut.
  ///
  /// In en, this message translates to:
  /// **'Ease In Out'**
  String get valueEaseInOut;

  /// No description provided for @valueLinear.
  ///
  /// In en, this message translates to:
  /// **'Linear'**
  String get valueLinear;

  /// No description provided for @valueEaseIn.
  ///
  /// In en, this message translates to:
  /// **'Ease In'**
  String get valueEaseIn;

  /// No description provided for @valueEaseOut.
  ///
  /// In en, this message translates to:
  /// **'Ease Out'**
  String get valueEaseOut;

  /// No description provided for @valueBounceInOut.
  ///
  /// In en, this message translates to:
  /// **'Bounce In Out'**
  String get valueBounceInOut;

  /// No description provided for @instructionSelectDaysToBlock.
  ///
  /// In en, this message translates to:
  /// **'Select days of week to block:'**
  String get instructionSelectDaysToBlock;

  /// No description provided for @accessibilityScreenReaderCellLabels.
  ///
  /// In en, this message translates to:
  /// **'Cell Labels'**
  String get accessibilityScreenReaderCellLabels;

  /// No description provided for @accessibilityScreenReaderCellLabelsContent.
  ///
  /// In en, this message translates to:
  /// **'Each cell announces date, day of week, and number of events. Example: \"Monday, February 10, 2026. 3 events.\"'**
  String get accessibilityScreenReaderCellLabelsContent;

  /// No description provided for @accessibilityScreenReaderEventLabels.
  ///
  /// In en, this message translates to:
  /// **'Event Labels'**
  String get accessibilityScreenReaderEventLabels;

  /// No description provided for @accessibilityScreenReaderEventLabelsContent.
  ///
  /// In en, this message translates to:
  /// **'Events announce title, duration, and position. Example: \"Team Meeting. February 10-12. Spans 3 days.\"'**
  String get accessibilityScreenReaderEventLabelsContent;

  /// No description provided for @accessibilityScreenReaderMultiDayEvents.
  ///
  /// In en, this message translates to:
  /// **'Multi-day Events'**
  String get accessibilityScreenReaderMultiDayEvents;

  /// No description provided for @accessibilityScreenReaderMultiDayEventsContent.
  ///
  /// In en, this message translates to:
  /// **'Multi-day event spans are announced with clear start and end dates and total duration.'**
  String get accessibilityScreenReaderMultiDayEventsContent;

  /// No description provided for @accessibilityScreenReaderNavigator.
  ///
  /// In en, this message translates to:
  /// **'Navigator'**
  String get accessibilityScreenReaderNavigator;

  /// No description provided for @accessibilityScreenReaderNavigatorContent.
  ///
  /// In en, this message translates to:
  /// **'Navigation buttons announce current month/year and action. Example: \"February 2026. Previous month button.\"'**
  String get accessibilityScreenReaderNavigatorContent;

  /// No description provided for @accessibilityScreenReaderOverflow.
  ///
  /// In en, this message translates to:
  /// **'Overflow Indicators'**
  String get accessibilityScreenReaderOverflow;

  /// No description provided for @accessibilityScreenReaderOverflowContent.
  ///
  /// In en, this message translates to:
  /// **'When a day has more events than can display, overflow indicator announces: \"+3 more events. Tap to view all.\"'**
  String get accessibilityScreenReaderOverflowContent;

  /// No description provided for @settingEnableHighContrast.
  ///
  /// In en, this message translates to:
  /// **'Enable High Contrast'**
  String get settingEnableHighContrast;

  /// No description provided for @accessibilityChecklistItem7.
  ///
  /// In en, this message translates to:
  /// **'Full keyboard navigation support'**
  String get accessibilityChecklistItem7;

  /// No description provided for @accessibilityChecklistItem8.
  ///
  /// In en, this message translates to:
  /// **'Respects reduced motion preferences'**
  String get accessibilityChecklistItem8;

  /// No description provided for @accessibilityKeyboardNavFlowStep5.
  ///
  /// In en, this message translates to:
  /// **'Use arrow keys to navigate between calendar cells. Focus indicator shows current cell.'**
  String get accessibilityKeyboardNavFlowStep5;

  /// No description provided for @accessibilityKeyboardNavFlowStep6.
  ///
  /// In en, this message translates to:
  /// **'Press Enter or Space on a cell to select it. If the cell has events, press Tab to cycle through them.'**
  String get accessibilityKeyboardNavFlowStep6;

  /// No description provided for @accessibilityKeyboardNavFlowStep7.
  ///
  /// In en, this message translates to:
  /// **'With an event focused, press Enter to start move mode. Use arrows to navigate to target cell, Enter to confirm, or Escape to cancel.'**
  String get accessibilityKeyboardNavFlowStep7;

  /// No description provided for @accessibilityKeyboardNavFlowStep8.
  ///
  /// In en, this message translates to:
  /// **'Press R to enter resize mode. Use S/E to switch which edge to resize, arrows to resize, Enter to confirm, or M to return to move mode.'**
  String get accessibilityKeyboardNavFlowStep8;

  /// No description provided for @accessibilityShortcutEnterOnEvent.
  ///
  /// In en, this message translates to:
  /// **'Enter (on event)'**
  String get accessibilityShortcutEnterOnEvent;

  /// No description provided for @accessibilityShortcutSE.
  ///
  /// In en, this message translates to:
  /// **'S / E'**
  String get accessibilityShortcutSE;

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

  /// Message when a day is selected in comparison view
  ///
  /// In en, this message translates to:
  /// **'Selected {date}'**
  String comparisonDaySelected(String date);

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

  /// All day date range display
  ///
  /// In en, this message translates to:
  /// **'{startDate} - {endDate} (All day)'**
  String allDayRange(String startDate, String endDate);

  /// Single day all-day event display
  ///
  /// In en, this message translates to:
  /// **'{date} (All day)'**
  String allDaySingle(String date);

  /// Number of days
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String daysCount(int count);

  /// Hours and minutes duration
  ///
  /// In en, this message translates to:
  /// **'{hours} hr {minutes} min'**
  String hoursMinutes(int hours, int minutes);

  /// Hours only duration
  ///
  /// In en, this message translates to:
  /// **'{hours} hr'**
  String hoursOnly(int hours);

  /// Minutes only duration
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String minutesOnly(int minutes);

  /// Message when event is moved
  ///
  /// In en, this message translates to:
  /// **'Moved: {title} to {time}'**
  String eventMoved(String title, String time);

  /// Message when event is resized
  ///
  /// In en, this message translates to:
  /// **'Resized: {title} to {minutes} min'**
  String eventResized(String title, String minutes);

  /// Message for double tap to create
  ///
  /// In en, this message translates to:
  /// **'Double-tap at {time} - Create event'**
  String doubleTapCreate(String time);

  /// Event ID display
  ///
  /// In en, this message translates to:
  /// **'Event ID: {id}'**
  String eventId(String id);

  /// External ID display
  ///
  /// In en, this message translates to:
  /// **'External ID: {id}'**
  String externalId(String id);

  /// Message when event is created
  ///
  /// In en, this message translates to:
  /// **'Created: {title}'**
  String eventCreated(String title);

  /// Message when event is updated
  ///
  /// In en, this message translates to:
  /// **'Updated: {title}'**
  String eventUpdated(String title);

  /// Message when event is deleted
  ///
  /// In en, this message translates to:
  /// **'Deleted: {title}'**
  String eventDeleted(String title);

  /// No description provided for @deleteEvent.
  ///
  /// In en, this message translates to:
  /// **'Delete Event'**
  String get deleteEvent;

  /// Confirmation message for deleting event
  ///
  /// In en, this message translates to:
  /// **'Delete \"{title}\"?'**
  String deleteEventConfirm(String title);

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

  /// Event count with plural support
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 event} other{{count} events}}'**
  String bottomSheetEventCount(int count);

  /// No description provided for @bottomSheetTapHint.
  ///
  /// In en, this message translates to:
  /// **'Tap an event to see details'**
  String get bottomSheetTapHint;

  /// No description provided for @bottomSheetNoEvents.
  ///
  /// In en, this message translates to:
  /// **'No events'**
  String get bottomSheetNoEvents;

  /// No description provided for @recurrenceDays.
  ///
  /// In en, this message translates to:
  /// **'day(s)'**
  String get recurrenceDays;

  /// No description provided for @recurrenceWeeks.
  ///
  /// In en, this message translates to:
  /// **'week(s)'**
  String get recurrenceWeeks;

  /// No description provided for @recurrenceMonths.
  ///
  /// In en, this message translates to:
  /// **'month(s)'**
  String get recurrenceMonths;

  /// No description provided for @recurrenceYears.
  ///
  /// In en, this message translates to:
  /// **'year(s)'**
  String get recurrenceYears;

  /// No description provided for @recurrenceMondayShort.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get recurrenceMondayShort;

  /// No description provided for @recurrenceTuesdayShort.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get recurrenceTuesdayShort;

  /// No description provided for @recurrenceWednesdayShort.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get recurrenceWednesdayShort;

  /// No description provided for @recurrenceThursdayShort.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get recurrenceThursdayShort;

  /// No description provided for @recurrenceFridayShort.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get recurrenceFridayShort;

  /// No description provided for @recurrenceSaturdayShort.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get recurrenceSaturdayShort;

  /// No description provided for @recurrenceSundayShort.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get recurrenceSundayShort;

  /// No description provided for @recurrenceMonday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get recurrenceMonday;

  /// No description provided for @recurrenceTuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get recurrenceTuesday;

  /// No description provided for @recurrenceWednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get recurrenceWednesday;

  /// No description provided for @recurrenceThursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get recurrenceThursday;

  /// No description provided for @recurrenceFriday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get recurrenceFriday;

  /// No description provided for @recurrenceSaturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get recurrenceSaturday;

  /// No description provided for @recurrenceSunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get recurrenceSunday;

  /// No description provided for @recurrenceEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Recurrence'**
  String get recurrenceEditTitle;

  /// No description provided for @recurrenceAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Recurrence'**
  String get recurrenceAddTitle;

  /// No description provided for @recurrenceFrequency.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get recurrenceFrequency;

  /// No description provided for @recurrenceRepeatEvery.
  ///
  /// In en, this message translates to:
  /// **'Repeat every'**
  String get recurrenceRepeatEvery;

  /// No description provided for @recurrenceOnDays.
  ///
  /// In en, this message translates to:
  /// **'On days'**
  String get recurrenceOnDays;

  /// No description provided for @recurrenceOnDaysOfMonth.
  ///
  /// In en, this message translates to:
  /// **'On days of month'**
  String get recurrenceOnDaysOfMonth;

  /// No description provided for @recurrenceOnDaysOfYear.
  ///
  /// In en, this message translates to:
  /// **'On days of year'**
  String get recurrenceOnDaysOfYear;

  /// No description provided for @recurrenceInWeekNumbers.
  ///
  /// In en, this message translates to:
  /// **'In week numbers'**
  String get recurrenceInWeekNumbers;

  /// No description provided for @recurrenceEnds.
  ///
  /// In en, this message translates to:
  /// **'Ends'**
  String get recurrenceEnds;

  /// No description provided for @recurrenceWeekStartsOn.
  ///
  /// In en, this message translates to:
  /// **'Week starts on'**
  String get recurrenceWeekStartsOn;

  /// No description provided for @recurrenceFrequencyDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get recurrenceFrequencyDaily;

  /// No description provided for @recurrenceFrequencyWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get recurrenceFrequencyWeekly;

  /// No description provided for @recurrenceFrequencyMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get recurrenceFrequencyMonthly;

  /// No description provided for @recurrenceFrequencyYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get recurrenceFrequencyYearly;

  /// No description provided for @recurrenceDaysOfYearHint.
  ///
  /// In en, this message translates to:
  /// **'Enter day numbers (1-366). Negative values count from year end.'**
  String get recurrenceDaysOfYearHint;

  /// No description provided for @recurrenceWeekNumbersHint.
  ///
  /// In en, this message translates to:
  /// **'Enter ISO week numbers (1-53). Negative values count from year end.'**
  String get recurrenceWeekNumbersHint;

  /// No description provided for @recurrenceValidationMin1.
  ///
  /// In en, this message translates to:
  /// **'Min 1'**
  String get recurrenceValidationMin1;

  /// Day number label for recurrence
  ///
  /// In en, this message translates to:
  /// **'Day {day}'**
  String recurrenceDay(int day);

  /// No description provided for @recurrenceDayPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g. 1, 100, 200'**
  String get recurrenceDayPlaceholder;

  /// Week number label for recurrence
  ///
  /// In en, this message translates to:
  /// **'Week {week}'**
  String recurrenceWeek(int week);

  /// No description provided for @recurrenceWeekPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g. 1, 20, 52'**
  String get recurrenceWeekPlaceholder;

  /// No description provided for @recurrenceEndsNever.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get recurrenceEndsNever;

  /// No description provided for @recurrenceEndsNeverSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Repeats indefinitely'**
  String get recurrenceEndsNeverSubtitle;

  /// No description provided for @recurrenceEndsAfter.
  ///
  /// In en, this message translates to:
  /// **'After'**
  String get recurrenceEndsAfter;

  /// No description provided for @recurrenceEndsOnDate.
  ///
  /// In en, this message translates to:
  /// **'On date'**
  String get recurrenceEndsOnDate;

  /// No description provided for @recurrenceTimes.
  ///
  /// In en, this message translates to:
  /// **'times'**
  String get recurrenceTimes;

  /// No description provided for @recurrenceScopeTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit recurring event'**
  String get recurrenceScopeTitle;

  /// No description provided for @recurrenceScopeThisEvent.
  ///
  /// In en, this message translates to:
  /// **'This event only'**
  String get recurrenceScopeThisEvent;

  /// No description provided for @recurrenceScopeThisEventSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Only change this occurrence'**
  String get recurrenceScopeThisEventSubtitle;

  /// No description provided for @recurrenceScopeThisAndFollowing.
  ///
  /// In en, this message translates to:
  /// **'This and following events'**
  String get recurrenceScopeThisAndFollowing;

  /// No description provided for @recurrenceScopeThisAndFollowingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Change this and all future occurrences'**
  String get recurrenceScopeThisAndFollowingSubtitle;

  /// No description provided for @recurrenceScopeAllEvents.
  ///
  /// In en, this message translates to:
  /// **'All events'**
  String get recurrenceScopeAllEvents;

  /// No description provided for @recurrenceScopeAllEventsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Change every occurrence in the series'**
  String get recurrenceScopeAllEventsSubtitle;
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
