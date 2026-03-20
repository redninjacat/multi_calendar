import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multi_calendar/multi_calendar.dart';

void main() {
  // A minimal ThemeData sufficient to exercise color-based defaults.
  late ThemeData theme;

  setUp(() {
    theme = ThemeData(useMaterial3: true);
  });

  // ────────────────────────────────────────────────────────────────────────────
  // MCalDayViewThemeData — layout defaults
  // ────────────────────────────────────────────────────────────────────────────
  group('MCalDayViewThemeData.defaults — layout property defaults', () {
    late MCalDayViewThemeData d;
    setUp(() => d = MCalDayViewThemeData.defaults(theme));

    // Day header
    test('dayHeaderPadding matches previous hardcoded EdgeInsets.all(8.0)', () {
      expect(d.dayHeaderPadding, const EdgeInsets.all(8.0));
    });
    test('dayHeaderSpacing matches previous hardcoded 8.0', () {
      expect(d.dayHeaderSpacing, 8.0);
    });
    test('dayHeaderWeekNumberPadding matches previous hardcoded value', () {
      expect(d.dayHeaderWeekNumberPadding,
          const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0));
    });
    test('dayHeaderWeekNumberBorderRadius matches previous hardcoded 4.0', () {
      expect(d.dayHeaderWeekNumberBorderRadius, 4.0);
    });

    // All-day section sizing
    test('allDayTileWidth matches previous hardcoded 120.0', () {
      expect(d.allDayTileWidth, 120.0);
    });
    test('allDayTileHeight matches previous hardcoded 28.0', () {
      expect(d.allDayTileHeight, 28.0);
    });
    test('allDayOverflowIndicatorWidth matches previous hardcoded 80.0', () {
      expect(d.allDayOverflowIndicatorWidth, 80.0);
    });

    // All-day layout
    test('allDayWrapSpacing matches previous hardcoded 4.0', () {
      expect(d.allDayWrapSpacing, 4.0);
    });
    test('allDayWrapRunSpacing matches previous hardcoded 4.0', () {
      expect(d.allDayWrapRunSpacing, 4.0);
    });
    test('allDaySectionPadding matches previous hardcoded value', () {
      expect(d.allDaySectionPadding,
          const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0));
    });
    test('allDayOverflowHandleWidth matches previous hardcoded 3.0', () {
      expect(d.allDayOverflowHandleWidth, 3.0);
    });
    test('allDayOverflowHandleHeight matches previous hardcoded 16.0', () {
      expect(d.allDayOverflowHandleHeight, 16.0);
    });
    test('allDayOverflowHandleBorderRadius matches previous hardcoded 1.5', () {
      expect(d.allDayOverflowHandleBorderRadius, 1.5);
    });
    test('allDayOverflowHandleGap matches previous hardcoded 4.0', () {
      expect(d.allDayOverflowHandleGap, 4.0);
    });
    test('allDayOverflowIndicatorFontSize matches previous hardcoded 11.0', () {
      expect(d.allDayOverflowIndicatorFontSize, 11.0);
    });
    test('allDayOverflowIndicatorBorderWidth matches previous hardcoded 1.0', () {
      expect(d.allDayOverflowIndicatorBorderWidth, 1.0);
    });
    test('allDaySectionLabelBottomPadding matches previous hardcoded 4.0', () {
      expect(d.allDaySectionLabelBottomPadding, 4.0);
    });

    // Time legend
    test('timeLegendLabelHeight matches previous hardcoded 20.0', () {
      expect(d.timeLegendLabelHeight, 20.0);
    });

    // Timed events
    test('timedEventMargin matches previous hardcoded value', () {
      expect(d.timedEventMargin,
          const EdgeInsets.symmetric(horizontal: 2.0, vertical: 1.0));
    });
    test('timedEventCompactFontSize matches previous hardcoded 10.0', () {
      expect(d.timedEventCompactFontSize, 10.0);
    });
    test('timedEventNormalFontSize matches previous hardcoded 12.0', () {
      expect(d.timedEventNormalFontSize, 12.0);
    });
    test('timedEventTitleTimeGap matches previous hardcoded 2.0', () {
      expect(d.timedEventTitleTimeGap, 2.0);
    });

    // Time regions
    test('timeRegionBorderWidth matches previous hardcoded 1.0', () {
      expect(d.timeRegionBorderWidth, 1.0);
    });
    test('timeRegionIconSize matches previous hardcoded 16.0', () {
      expect(d.timeRegionIconSize, 16.0);
    });
    test('timeRegionIconGap matches previous hardcoded 4.0', () {
      expect(d.timeRegionIconGap, 4.0);
    });

    // Resize handle (Day View horizontal bar)
    test('resizeHandleVisualHeight matches previous hardcoded 2.0', () {
      expect(d.resizeHandleVisualHeight, 2.0);
    });
    test('resizeHandleHorizontalMargin matches previous hardcoded 4.0', () {
      expect(d.resizeHandleHorizontalMargin, 4.0);
    });
    test('resizeHandleBorderRadius matches previous hardcoded 1.0', () {
      expect(d.resizeHandleBorderRadius, 1.0);
    });

    // Keyboard focus (event tile mixin)
    test('keyboardSelectionBorderWidth matches day view default 3.0', () {
      expect(d.keyboardSelectionBorderWidth, 3.0);
    });
    test('keyboardHighlightBorderWidth matches day view default 2.0', () {
      expect(d.keyboardHighlightBorderWidth, 2.0);
    });
    test('keyboardSelectionBorderRadius matches previous 4.0', () {
      expect(d.keyboardSelectionBorderRadius, 4.0);
    });
    test('keyboardHighlightBorderRadius matches previous 4.0', () {
      expect(d.keyboardHighlightBorderRadius, 4.0);
    });

    // Event tile mixin on DayViewThemeData
    test('eventTileBorderWidth default is 0.0 (no border)', () {
      expect(d.eventTileBorderWidth, 0.0);
    });
    test('eventTileBorderColor default is null', () {
      expect(d.eventTileBorderColor, isNull);
    });

    // All properties non-null
    test('all layout properties are non-null in defaults()', () {
      expect(d.dayHeaderPadding, isNotNull);
      expect(d.dayHeaderSpacing, isNotNull);
      expect(d.dayHeaderWeekNumberPadding, isNotNull);
      expect(d.dayHeaderWeekNumberBorderRadius, isNotNull);
      expect(d.allDayTileWidth, isNotNull);
      expect(d.allDayTileHeight, isNotNull);
      expect(d.allDayOverflowIndicatorWidth, isNotNull);
      expect(d.allDayWrapSpacing, isNotNull);
      expect(d.allDayWrapRunSpacing, isNotNull);
      expect(d.allDaySectionPadding, isNotNull);
      expect(d.allDayOverflowHandleWidth, isNotNull);
      expect(d.allDayOverflowHandleHeight, isNotNull);
      expect(d.allDayOverflowHandleBorderRadius, isNotNull);
      expect(d.allDayOverflowHandleGap, isNotNull);
      expect(d.allDayOverflowIndicatorFontSize, isNotNull);
      expect(d.allDayOverflowIndicatorBorderWidth, isNotNull);
      expect(d.allDaySectionLabelBottomPadding, isNotNull);
      expect(d.timeLegendLabelHeight, isNotNull);
      expect(d.timedEventMargin, isNotNull);
      expect(d.timedEventCompactFontSize, isNotNull);
      expect(d.timedEventNormalFontSize, isNotNull);
      expect(d.timeRegionBorderWidth, isNotNull);
      expect(d.timeRegionIconSize, isNotNull);
      expect(d.timeRegionIconGap, isNotNull);
      expect(d.resizeHandleVisualHeight, isNotNull);
      expect(d.resizeHandleHorizontalMargin, isNotNull);
      expect(d.resizeHandleBorderRadius, isNotNull);
      expect(d.keyboardSelectionBorderWidth, isNotNull);
      expect(d.keyboardSelectionBorderColor, isNull);
      expect(d.keyboardSelectionBorderRadius, isNotNull);
      expect(d.keyboardHighlightBorderWidth, isNotNull);
      expect(d.keyboardHighlightBorderColor, isNull);
      expect(d.keyboardHighlightBorderRadius, isNotNull);
      expect(d.timedEventTitleTimeGap, isNotNull);
      expect(d.eventTileBorderWidth, isNotNull);
    });
  });

  // ────────────────────────────────────────────────────────────────────────────
  // MCalDayViewThemeData — copyWith / lerp / == / hashCode
  // ────────────────────────────────────────────────────────────────────────────
  group('MCalDayViewThemeData — copyWith includes layout properties', () {
    test('copyWith overrides layout properties', () {
      const base = MCalDayViewThemeData(dayHeaderSpacing: 8.0);
      final copy = base.copyWith(dayHeaderSpacing: 16.0);
      expect(copy.dayHeaderSpacing, 16.0);
    });

    test('copyWith preserves other layout properties', () {
      const base = MCalDayViewThemeData(
          dayHeaderSpacing: 8.0, timeLegendLabelHeight: 20.0);
      final copy = base.copyWith(dayHeaderSpacing: 16.0);
      expect(copy.timeLegendLabelHeight, 20.0);
    });

    test('lerp interpolates layout properties', () {
      const a = MCalDayViewThemeData(dayHeaderSpacing: 0.0);
      const b = MCalDayViewThemeData(dayHeaderSpacing: 20.0);
      final mid = a.lerp(b, 0.5);
      expect(mid.dayHeaderSpacing, closeTo(10.0, 0.001));
    });

    test('== includes layout properties', () {
      const a = MCalDayViewThemeData(dayHeaderSpacing: 8.0);
      const b = MCalDayViewThemeData(dayHeaderSpacing: 8.0);
      const c = MCalDayViewThemeData(dayHeaderSpacing: 16.0);
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('hashCode differs for different layout properties', () {
      const a = MCalDayViewThemeData(dayHeaderSpacing: 8.0);
      const b = MCalDayViewThemeData(dayHeaderSpacing: 16.0);
      expect(a.hashCode, isNot(equals(b.hashCode)));
    });
  });

  // ────────────────────────────────────────────────────────────────────────────
  // MCalMonthViewThemeData — layout defaults
  // ────────────────────────────────────────────────────────────────────────────
  group('MCalMonthViewThemeData.defaults — layout property defaults', () {
    late MCalMonthViewThemeData d;
    setUp(() => d = MCalMonthViewThemeData.defaults(theme));

    test('dateLabelPadding matches previous hardcoded value', () {
      expect(d.dateLabelPadding,
          const EdgeInsets.only(left: 4.0, top: 4.0, right: 4.0));
    });
    test('cellBorderWidth matches previous hardcoded 1.0', () {
      expect(d.cellBorderWidth, 1.0);
    });
    test('keyboardSelectionBorderWidth matches previous hardcoded 2.0', () {
      expect(d.keyboardSelectionBorderWidth, 2.0);
    });
    test('keyboardHighlightBorderWidth matches previous hardcoded 1.5', () {
      expect(d.keyboardHighlightBorderWidth, 1.5);
    });
    test('dateLabelCircleSize matches previous hardcoded 24.0', () {
      expect(d.dateLabelCircleSize, 24.0);
    });
    test('weekNumberColumnWidth matches previous hardcoded 36.0', () {
      expect(d.weekNumberColumnWidth, 36.0);
    });
    test('weekNumberBorderWidth matches previous hardcoded 0.5', () {
      expect(d.weekNumberBorderWidth, 0.5);
    });
    test('multiDayTileBorderRadius matches previous hardcoded 4.0', () {
      expect(d.multiDayTileBorderRadius, 4.0);
    });
    test('weekLayoutDateLabelPadding matches previous hardcoded 2.0', () {
      expect(d.weekLayoutDateLabelPadding, 2.0);
    });
    test('weekLayoutBaseMargin matches previous hardcoded 2.0', () {
      expect(d.weekLayoutBaseMargin, 2.0);
    });
    test('resizeHandleVisualWidth matches previous hardcoded 2.0', () {
      expect(d.resizeHandleVisualWidth, 2.0);
    });
    test('resizeHandleVerticalMargin matches previous hardcoded 1.0', () {
      expect(d.resizeHandleVerticalMargin, 1.0);
    });
    test('resizeHandleBorderRadius matches previous hardcoded 1.0', () {
      expect(d.resizeHandleBorderRadius, 1.0);
    });
    test('dropTargetTileBorderWidth is 1.5', () {
      expect(d.dropTargetTileBorderWidth, 1.5);
    });
    test('eventTileBorderWidth default is 0.0 (no border)', () {
      expect(d.eventTileBorderWidth, 0.0);
    });
    test('eventTileBorderColor default is null', () {
      expect(d.eventTileBorderColor, isNull);
    });

    // All layout properties non-null
    test('all layout properties are non-null in defaults()', () {
      expect(d.dateLabelPadding, isNotNull);
      expect(d.cellBorderWidth, isNotNull);
      expect(d.keyboardSelectionBorderWidth, isNotNull);
      expect(d.keyboardHighlightBorderWidth, isNotNull);
      expect(d.dateLabelCircleSize, isNotNull);
      expect(d.weekNumberColumnWidth, isNotNull);
      expect(d.weekNumberBorderWidth, isNotNull);
      expect(d.multiDayTilePadding, isNotNull);
      expect(d.multiDayTileBorderRadius, isNotNull);
      expect(d.weekLayoutDateLabelPadding, isNotNull);
      expect(d.weekLayoutBaseMargin, isNotNull);
      expect(d.resizeHandleVisualWidth, isNotNull);
      expect(d.resizeHandleVerticalMargin, isNotNull);
      expect(d.resizeHandleBorderRadius, isNotNull);
      expect(d.regionContentPadding, isNotNull);
      expect(d.regionIconSize, isNotNull);
      expect(d.regionIconGap, isNotNull);
      expect(d.regionFontSize, isNotNull);
      expect(d.weekdayHeaderPadding, isNotNull);
    });
  });

  // ────────────────────────────────────────────────────────────────────────────
  // MCalMonthViewThemeData — copyWith / lerp / == / hashCode
  // ────────────────────────────────────────────────────────────────────────────
  group('MCalMonthViewThemeData — copyWith includes layout properties', () {
    test('copyWith overrides layout properties', () {
      const base = MCalMonthViewThemeData(keyboardSelectionBorderWidth: 2.0);
      final copy = base.copyWith(keyboardSelectionBorderWidth: 3.0);
      expect(copy.keyboardSelectionBorderWidth, 3.0);
    });

    test('copyWith preserves other layout properties', () {
      const base = MCalMonthViewThemeData(
          keyboardSelectionBorderWidth: 2.0, cellBorderWidth: 1.0);
      final copy = base.copyWith(keyboardSelectionBorderWidth: 3.0);
      expect(copy.cellBorderWidth, 1.0);
    });

    test('lerp interpolates layout properties', () {
      const a = MCalMonthViewThemeData(dateLabelCircleSize: 0.0);
      const b = MCalMonthViewThemeData(dateLabelCircleSize: 24.0);
      final mid = a.lerp(b, 0.5);
      expect(mid.dateLabelCircleSize, closeTo(12.0, 0.001));
    });

    test('== includes layout properties', () {
      const a = MCalMonthViewThemeData(weekNumberColumnWidth: 36.0);
      const b = MCalMonthViewThemeData(weekNumberColumnWidth: 36.0);
      const c = MCalMonthViewThemeData(weekNumberColumnWidth: 48.0);
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('hashCode differs for different layout properties', () {
      const a = MCalMonthViewThemeData(weekNumberColumnWidth: 36.0);
      const b = MCalMonthViewThemeData(weekNumberColumnWidth: 48.0);
      expect(a.hashCode, isNot(equals(b.hashCode)));
    });
  });

  // ────────────────────────────────────────────────────────────────────────────
  // MCalThemeData.fromTheme — parent structure
  // ────────────────────────────────────────────────────────────────────────────
  group('MCalThemeData.fromTheme — structure and navigatorPadding', () {
    late MCalThemeData d;
    setUp(() => d = MCalThemeData.fromTheme(theme));

    test('navigatorPadding default is EdgeInsets.symmetric(horizontal:8, vertical:8)', () {
      expect(d.navigatorPadding,
          const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0));
    });

    test('cellBorderWidth default is 1.0', () {
      expect(d.cellBorderWidth, 1.0);
    });

    test('dayViewTheme is non-null after fromTheme', () {
      expect(d.dayViewTheme, isNotNull);
    });

    test('monthViewTheme is non-null after fromTheme', () {
      expect(d.monthViewTheme, isNotNull);
    });

    test('dayViewTheme layout properties are populated by fromTheme', () {
      expect(d.dayViewTheme!.dayHeaderPadding, isNotNull);
      expect(d.dayViewTheme!.timeLegendLabelHeight, isNotNull);
      expect(d.dayViewTheme!.resizeHandleVisualHeight, isNotNull);
    });

    test('monthViewTheme layout properties are populated by fromTheme', () {
      expect(d.monthViewTheme!.dateLabelPadding, isNotNull);
      expect(d.monthViewTheme!.weekNumberColumnWidth, isNotNull);
      expect(d.monthViewTheme!.keyboardSelectionBorderWidth, isNotNull);
      expect(d.monthViewTheme!.keyboardSelectionBorderColor, isNull);
      expect(d.monthViewTheme!.keyboardHighlightBorderColor, isNull);
    });
  });

  // ────────────────────────────────────────────────────────────────────────────
  // MCalThemeData — copyWith / lerp include navigatorPadding
  // ────────────────────────────────────────────────────────────────────────────
  group('MCalThemeData — copyWith and lerp include navigatorPadding', () {
    test('copyWith overrides navigatorPadding', () {
      const base = MCalThemeData(
          navigatorPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0));
      final copy =
          base.copyWith(navigatorPadding: const EdgeInsets.all(16.0));
      expect(copy.navigatorPadding, const EdgeInsets.all(16.0));
    });

    test('lerp interpolates navigatorPadding', () {
      const a = MCalThemeData(navigatorPadding: EdgeInsets.zero);
      const b = MCalThemeData(
          navigatorPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0));
      final mid = a.lerp(b, 0.5);
      expect(mid.navigatorPadding?.left, closeTo(8.0, 0.001));
      expect(mid.navigatorPadding?.top, closeTo(4.0, 0.001));
    });

    test('== includes navigatorPadding', () {
      const a = MCalThemeData(
          navigatorPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0));
      const b = MCalThemeData(
          navigatorPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0));
      const c = MCalThemeData(navigatorPadding: EdgeInsets.all(4.0));
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('hashCode includes navigatorPadding', () {
      const a = MCalThemeData(
          navigatorPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0));
      const b = MCalThemeData(navigatorPadding: EdgeInsets.all(4.0));
      expect(a.hashCode, isNot(equals(b.hashCode)));
    });
  });

  // ────────────────────────────────────────────────────────────────────────────
  // Mixin properties — eventTileBorderWidth / Color on both sub-themes
  // ────────────────────────────────────────────────────────────────────────────
  group('MCalEventTileThemeMixin — eventTileBorderWidth/Color on sub-themes', () {
    test('MCalDayViewThemeData accepts eventTileBorderWidth from mixin', () {
      const t = MCalDayViewThemeData(eventTileBorderWidth: 1.5);
      expect(t.eventTileBorderWidth, 1.5);
    });

    test('MCalDayViewThemeData accepts eventTileBorderColor from mixin', () {
      const t = MCalDayViewThemeData(eventTileBorderColor: Colors.red);
      expect(t.eventTileBorderColor, Colors.red);
    });

    test('MCalMonthViewThemeData accepts eventTileBorderWidth from mixin', () {
      const t = MCalMonthViewThemeData(eventTileBorderWidth: 0.5);
      expect(t.eventTileBorderWidth, 0.5);
    });

    test('MCalMonthViewThemeData accepts eventTileBorderColor from mixin', () {
      const t = MCalMonthViewThemeData(eventTileBorderColor: Colors.blue);
      expect(t.eventTileBorderColor, Colors.blue);
    });

    test('MCalDayViewThemeData copyWith preserves eventTileBorderWidth', () {
      const base = MCalDayViewThemeData(eventTileBorderWidth: 1.0);
      final copy = base.copyWith(eventTileBorderWidth: 2.0);
      expect(copy.eventTileBorderWidth, 2.0);
    });

    test('MCalMonthViewThemeData copyWith preserves eventTileBorderColor', () {
      const base = MCalMonthViewThemeData(eventTileBorderColor: Colors.green);
      final copy = base.copyWith(eventTileBorderColor: Colors.red);
      expect(copy.eventTileBorderColor, Colors.red);
    });
  });
}
