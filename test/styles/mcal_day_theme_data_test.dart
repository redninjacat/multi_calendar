import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multi_calendar/multi_calendar.dart';

void main() {
  group('MCalDayThemeData constructor', () {
    test('default constructor creates instance with all null properties', () {
      const theme = MCalDayThemeData();

      expect(theme.dayHeaderDayOfWeekStyle, isNull);
      expect(theme.dayHeaderDateStyle, isNull);
      expect(theme.weekNumberTextColor, isNull);
      expect(theme.timeLegendWidth, isNull);
      expect(theme.timeLegendTextStyle, isNull);
      expect(theme.timeLegendBackgroundColor, isNull);
      expect(theme.showTimeLegendTicks, isNull);
      expect(theme.timeLegendTickColor, isNull);
      expect(theme.timeLegendTickWidth, isNull);
      expect(theme.timeLegendTickLength, isNull);
      expect(theme.hourGridlineColor, isNull);
      expect(theme.hourGridlineWidth, isNull);
      expect(theme.majorGridlineColor, isNull);
      expect(theme.majorGridlineWidth, isNull);
      expect(theme.minorGridlineColor, isNull);
      expect(theme.minorGridlineWidth, isNull);
      expect(theme.currentTimeIndicatorColor, isNull);
      expect(theme.currentTimeIndicatorWidth, isNull);
      expect(theme.currentTimeIndicatorDotRadius, isNull);
      expect(theme.allDaySectionMaxRows, isNull);
      expect(theme.timedEventMinHeight, isNull);
      expect(theme.timedEventBorderRadius, isNull);
      expect(theme.timedEventPadding, isNull);
      expect(theme.specialTimeRegionColor, isNull);
      expect(theme.blockedTimeRegionColor, isNull);
      expect(theme.timeRegionBorderColor, isNull);
      expect(theme.timeRegionTextColor, isNull);
      expect(theme.timeRegionTextStyle, isNull);
      expect(theme.resizeHandleSize, isNull);
      expect(theme.minResizeDurationMinutes, isNull);
    });

    test('constructor accepts all properties', () {
      const dayStyle = TextStyle(fontSize: 14);
      const dateStyle = TextStyle(fontSize: 24);
      const padding = EdgeInsets.all(4.0);

      const theme = MCalDayThemeData(
        dayHeaderDayOfWeekStyle: dayStyle,
        dayHeaderDateStyle: dateStyle,
        weekNumberTextColor: Colors.blue,
        timeLegendWidth: 72.0,
        timeLegendTextStyle: dayStyle,
        timeLegendBackgroundColor: Colors.grey,
        showTimeLegendTicks: true,
        timeLegendTickColor: Colors.black,
        timeLegendTickWidth: 2.0,
        timeLegendTickLength: 12.0,
        hourGridlineColor: Colors.red,
        hourGridlineWidth: 1.5,
        majorGridlineColor: Colors.green,
        majorGridlineWidth: 1.0,
        minorGridlineColor: Colors.orange,
        minorGridlineWidth: 0.5,
        currentTimeIndicatorColor: Colors.purple,
        currentTimeIndicatorWidth: 3.0,
        currentTimeIndicatorDotRadius: 8.0,
        allDaySectionMaxRows: 5,
        timedEventMinHeight: 24.0,
        timedEventBorderRadius: 6.0,
        timedEventPadding: padding,
        specialTimeRegionColor: Colors.cyan,
        blockedTimeRegionColor: Colors.amber,
        timeRegionBorderColor: Colors.brown,
        timeRegionTextColor: Colors.indigo,
        timeRegionTextStyle: dateStyle,
        resizeHandleSize: 10.0,
        minResizeDurationMinutes: 30,
      );

      expect(theme.dayHeaderDayOfWeekStyle, dayStyle);
      expect(theme.dayHeaderDateStyle, dateStyle);
      expect(theme.weekNumberTextColor, Colors.blue);
      expect(theme.timeLegendWidth, 72.0);
      expect(theme.showTimeLegendTicks, true);
      expect(theme.timeLegendTickColor, Colors.black);
      expect(theme.timeLegendTickWidth, 2.0);
      expect(theme.timeLegendTickLength, 12.0);
      expect(theme.hourGridlineColor, Colors.red);
      expect(theme.currentTimeIndicatorColor, Colors.purple);
      expect(theme.allDaySectionMaxRows, 5);
      expect(theme.timedEventMinHeight, 24.0);
      expect(theme.timedEventPadding, padding);
      expect(theme.resizeHandleSize, 10.0);
      expect(theme.minResizeDurationMinutes, 30);
    });
  });

  group('MCalDayThemeData.defaults', () {
    test('defaults factory creates non-null values from ThemeData', () {
      final themeData = ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      );

      final theme = MCalDayThemeData.defaults(themeData);

      expect(theme.dayHeaderDayOfWeekStyle, isNotNull);
      expect(theme.dayHeaderDateStyle, isNotNull);
      expect(theme.weekNumberTextColor, isNotNull);
      expect(theme.timeLegendWidth, 60.0);
      expect(theme.timeLegendTextStyle, isNotNull);
      expect(theme.timeLegendBackgroundColor, isNotNull);
      expect(theme.showTimeLegendTicks, true);
      expect(theme.timeLegendTickColor, isNotNull);
      expect(theme.timeLegendTickWidth, 1.0);
      expect(theme.timeLegendTickLength, 8.0);
      expect(theme.hourGridlineColor, isNotNull);
      expect(theme.hourGridlineWidth, 1.0);
      expect(theme.majorGridlineColor, isNotNull);
      expect(theme.minorGridlineColor, isNotNull);
      expect(theme.currentTimeIndicatorColor, isNotNull);
      expect(theme.currentTimeIndicatorWidth, 2.0);
      expect(theme.currentTimeIndicatorDotRadius, 6.0);
      expect(theme.allDaySectionMaxRows, 3);
      expect(theme.timedEventMinHeight, 20.0);
      expect(theme.timedEventBorderRadius, 4.0);
      expect(theme.timedEventPadding, isNotNull);
      expect(theme.specialTimeRegionColor, isNotNull);
      expect(theme.blockedTimeRegionColor, isNotNull);
      expect(theme.resizeHandleSize, 8.0);
      expect(theme.minResizeDurationMinutes, 15);
    });

    test('defaults uses colorScheme from ThemeData', () {
      final themeData = ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
      );

      final theme = MCalDayThemeData.defaults(themeData);

      expect(theme.currentTimeIndicatorColor, themeData.colorScheme.primary);
      expect(theme.timeLegendBackgroundColor, themeData.colorScheme.surfaceContainerLow);
    });

    test('defaults uses textTheme from ThemeData', () {
      final themeData = ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        textTheme: const TextTheme(
          labelMedium: TextStyle(fontSize: 12),
          headlineMedium: TextStyle(fontSize: 28),
        ),
      );

      final theme = MCalDayThemeData.defaults(themeData);

      expect(theme.dayHeaderDayOfWeekStyle?.fontSize, 12);
      expect(theme.dayHeaderDateStyle?.fontSize, 28);
    });

    test('defaults differs between light and dark themes', () {
      final lightTheme = ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
      );
      final darkTheme = ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
      );

      final light = MCalDayThemeData.defaults(lightTheme);
      final dark = MCalDayThemeData.defaults(darkTheme);

      expect(light.timeLegendBackgroundColor, isNot(dark.timeLegendBackgroundColor));
      expect(light.currentTimeIndicatorColor, isNot(dark.currentTimeIndicatorColor));
    });
  });

  group('MCalDayThemeData copyWith', () {
    test('copyWith with no arguments returns identical instance', () {
      const original = MCalDayThemeData(
        timeLegendWidth: 80.0,
        showTimeLegendTicks: true,
      );

      final copied = original.copyWith();

      expect(copied.timeLegendWidth, 80.0);
      expect(copied.showTimeLegendTicks, true);
      expect(copied, original);
    });

    test('copyWith updates single property', () {
      const original = MCalDayThemeData(timeLegendWidth: 60.0);

      final updated = original.copyWith(timeLegendWidth: 72.0);

      expect(updated.timeLegendWidth, 72.0);
      expect(original.timeLegendWidth, 60.0);
    });

    test('copyWith preserves unspecified properties', () {
      const original = MCalDayThemeData(
        timeLegendWidth: 60.0,
        timeLegendTickWidth: 1.0,
        hourGridlineColor: Colors.blue,
      );

      final updated = original.copyWith(timeLegendWidth: 80.0);

      expect(updated.timeLegendWidth, 80.0);
      expect(updated.timeLegendTickWidth, 1.0);
      expect(updated.hourGridlineColor, Colors.blue);
    });

    test('copyWith preserves null when not specified', () {
      const original = MCalDayThemeData(timeLegendWidth: 60.0);

      final updated = original.copyWith(showTimeLegendTicks: true);

      expect(updated.timeLegendWidth, 60.0);
      expect(updated.timeLegendTickColor, isNull);
    });

    test('copyWith updates TextStyle properties', () {
      const original = MCalDayThemeData(
        dayHeaderDayOfWeekStyle: TextStyle(fontSize: 12),
      );
      const newStyle = TextStyle(fontSize: 16, color: Colors.red);

      final updated = original.copyWith(dayHeaderDayOfWeekStyle: newStyle);

      expect(updated.dayHeaderDayOfWeekStyle?.fontSize, 16);
      expect(updated.dayHeaderDayOfWeekStyle?.color, Colors.red);
    });

    test('copyWith updates Color properties', () {
      const original = MCalDayThemeData(hourGridlineColor: Colors.blue);

      final updated = original.copyWith(hourGridlineColor: Colors.red);

      expect(updated.hourGridlineColor, Colors.red);
    });

    test('copyWith updates double properties', () {
      const original = MCalDayThemeData(
        timeLegendWidth: 60.0,
        timeLegendTickLength: 8.0,
      );

      final updated = original.copyWith(
        timeLegendWidth: 100.0,
        timeLegendTickLength: 16.0,
      );

      expect(updated.timeLegendWidth, 100.0);
      expect(updated.timeLegendTickLength, 16.0);
    });

    test('copyWith updates int properties', () {
      const original = MCalDayThemeData(allDaySectionMaxRows: 3);

      final updated = original.copyWith(allDaySectionMaxRows: 5);

      expect(updated.allDaySectionMaxRows, 5);
    });

    test('copyWith updates bool properties', () {
      const original = MCalDayThemeData(showTimeLegendTicks: true);

      final updated = original.copyWith(showTimeLegendTicks: false);

      expect(updated.showTimeLegendTicks, false);
    });

    test('copyWith updates EdgeInsets', () {
      const original = MCalDayThemeData(
        timedEventPadding: EdgeInsets.all(2.0),
      );
      const newPadding = EdgeInsets.symmetric(horizontal: 4, vertical: 2);

      final updated = original.copyWith(timedEventPadding: newPadding);

      expect(updated.timedEventPadding, newPadding);
    });

    test('copyWith updates multiple properties at once', () {
      const original = MCalDayThemeData(
        timeLegendWidth: 60.0,
        showTimeLegendTicks: true,
        hourGridlineColor: Colors.blue,
      );

      final updated = original.copyWith(
        timeLegendWidth: 80.0,
        showTimeLegendTicks: false,
        hourGridlineColor: Colors.red,
      );

      expect(updated.timeLegendWidth, 80.0);
      expect(updated.showTimeLegendTicks, false);
      expect(updated.hourGridlineColor, Colors.red);
    });

    test('copyWith updates time legend tick properties', () {
      const original = MCalDayThemeData(
        showTimeLegendTicks: false,
        timeLegendTickColor: Colors.grey,
        timeLegendTickWidth: 1.0,
        timeLegendTickLength: 8.0,
      );

      final updated = original.copyWith(
        showTimeLegendTicks: true,
        timeLegendTickColor: Colors.blue,
        timeLegendTickWidth: 2.0,
        timeLegendTickLength: 12.0,
      );

      expect(updated.showTimeLegendTicks, true);
      expect(updated.timeLegendTickColor, Colors.blue);
      expect(updated.timeLegendTickWidth, 2.0);
      expect(updated.timeLegendTickLength, 12.0);
    });

    test('copyWith updates gridline properties', () {
      const original = MCalDayThemeData(
        hourGridlineColor: Colors.blue,
        majorGridlineColor: Colors.green,
        minorGridlineColor: Colors.orange,
      );

      final updated = original.copyWith(
        hourGridlineColor: Colors.red,
        majorGridlineColor: Colors.yellow,
        minorGridlineColor: Colors.purple,
      );

      expect(updated.hourGridlineColor, Colors.red);
      expect(updated.majorGridlineColor, Colors.yellow);
      expect(updated.minorGridlineColor, Colors.purple);
    });

    test('copyWith updates time region properties', () {
      const original = MCalDayThemeData(
        specialTimeRegionColor: Colors.cyan,
        blockedTimeRegionColor: Colors.amber,
        timeRegionBorderColor: Colors.brown,
        timeRegionTextColor: Colors.indigo,
      );

      final updated = original.copyWith(
        specialTimeRegionColor: Colors.red,
        blockedTimeRegionColor: Colors.blue,
        timeRegionBorderColor: Colors.green,
        timeRegionTextColor: Colors.orange,
      );

      expect(updated.specialTimeRegionColor, Colors.red);
      expect(updated.blockedTimeRegionColor, Colors.blue);
      expect(updated.timeRegionBorderColor, Colors.green);
      expect(updated.timeRegionTextColor, Colors.orange);
    });

    test('copyWith updates current time indicator properties', () {
      const original = MCalDayThemeData(
        currentTimeIndicatorColor: Colors.blue,
        currentTimeIndicatorWidth: 2.0,
        currentTimeIndicatorDotRadius: 6.0,
      );

      final updated = original.copyWith(
        currentTimeIndicatorColor: Colors.red,
        currentTimeIndicatorWidth: 4.0,
        currentTimeIndicatorDotRadius: 10.0,
      );

      expect(updated.currentTimeIndicatorColor, Colors.red);
      expect(updated.currentTimeIndicatorWidth, 4.0);
      expect(updated.currentTimeIndicatorDotRadius, 10.0);
    });

    test('copyWith updates resize handle properties', () {
      const original = MCalDayThemeData(
        resizeHandleSize: 8.0,
        minResizeDurationMinutes: 15,
      );

      final updated = original.copyWith(
        resizeHandleSize: 12.0,
        minResizeDurationMinutes: 30,
      );

      expect(updated.resizeHandleSize, 12.0);
      expect(updated.minResizeDurationMinutes, 30);
    });
  });

  group('MCalDayThemeData lerp', () {
    test('lerp with null other returns this', () {
      const theme = MCalDayThemeData(timeLegendWidth: 60.0);

      final result = theme.lerp(null, 0.5);

      expect(result, theme);
    });

    test('lerp at t=0.0 returns this theme', () {
      const theme1 = MCalDayThemeData(
        timeLegendWidth: 60.0,
        hourGridlineColor: Colors.white,
      );
      const theme2 = MCalDayThemeData(
        timeLegendWidth: 100.0,
        hourGridlineColor: Colors.black,
      );

      final result = theme1.lerp(theme2, 0.0);

      expect(result.timeLegendWidth, 60.0);
      expect(result.hourGridlineColor?.toARGB32(), Colors.white.toARGB32());
    });

    test('lerp at t=1.0 returns other theme', () {
      const theme1 = MCalDayThemeData(
        timeLegendWidth: 60.0,
        hourGridlineColor: Colors.white,
      );
      const theme2 = MCalDayThemeData(
        timeLegendWidth: 100.0,
        hourGridlineColor: Colors.black,
      );

      final result = theme1.lerp(theme2, 1.0);

      expect(result.timeLegendWidth, 100.0);
      expect(result.hourGridlineColor?.toARGB32(), Colors.black.toARGB32());
    });

    test('lerp at t=0.5 interpolates double values', () {
      const theme1 = MCalDayThemeData(timeLegendWidth: 60.0);
      const theme2 = MCalDayThemeData(timeLegendWidth: 100.0);

      final result = theme1.lerp(theme2, 0.5);

      expect(result.timeLegendWidth, 80.0);
    });

    test('lerp interpolates Color values', () {
      const theme1 = MCalDayThemeData(hourGridlineColor: Colors.white);
      const theme2 = MCalDayThemeData(hourGridlineColor: Colors.black);

      final atHalf = theme1.lerp(theme2, 0.5);

      expect(atHalf.hourGridlineColor, isNotNull);
      expect(atHalf.hourGridlineColor, isNot(Colors.white));
      expect(atHalf.hourGridlineColor, isNot(Colors.black));
    });

    test('lerp interpolates bool at t<0.5 uses this value', () {
      const theme1 = MCalDayThemeData(showTimeLegendTicks: true);
      const theme2 = MCalDayThemeData(showTimeLegendTicks: false);

      final result = theme1.lerp(theme2, 0.3);

      expect(result.showTimeLegendTicks, true);
    });

    test('lerp interpolates bool at t>=0.5 uses other value', () {
      const theme1 = MCalDayThemeData(showTimeLegendTicks: true);
      const theme2 = MCalDayThemeData(showTimeLegendTicks: false);

      final result = theme1.lerp(theme2, 0.5);

      expect(result.showTimeLegendTicks, false);
    });

    test('lerp interpolates int at t<0.5 uses this value', () {
      const theme1 = MCalDayThemeData(allDaySectionMaxRows: 3);
      const theme2 = MCalDayThemeData(allDaySectionMaxRows: 5);

      final result = theme1.lerp(theme2, 0.4);

      expect(result.allDaySectionMaxRows, 3);
    });

    test('lerp interpolates int at t>=0.5 uses other value', () {
      const theme1 = MCalDayThemeData(allDaySectionMaxRows: 3);
      const theme2 = MCalDayThemeData(allDaySectionMaxRows: 5);

      final result = theme1.lerp(theme2, 0.5);

      expect(result.allDaySectionMaxRows, 5);
    });

    test('lerp interpolates TextStyle', () {
      const theme1 = MCalDayThemeData(
        dayHeaderDayOfWeekStyle: TextStyle(fontSize: 12, color: Colors.white),
      );
      const theme2 = MCalDayThemeData(
        dayHeaderDayOfWeekStyle: TextStyle(fontSize: 24, color: Colors.black),
      );

      final result = theme1.lerp(theme2, 0.5);

      expect(result.dayHeaderDayOfWeekStyle?.fontSize, 18.0);
    });

    test('lerp interpolates EdgeInsets', () {
      const theme1 = MCalDayThemeData(
        timedEventPadding: EdgeInsets.all(2.0),
      );
      const theme2 = MCalDayThemeData(
        timedEventPadding: EdgeInsets.all(10.0),
      );

      final result = theme1.lerp(theme2, 0.5);

      expect(result.timedEventPadding?.left, 6.0);
      expect(result.timedEventPadding?.top, 6.0);
    });

    test('lerp handles null double values', () {
      const theme1 = MCalDayThemeData(timeLegendWidth: null);
      const theme2 = MCalDayThemeData(timeLegendWidth: 100.0);

      final result = theme1.lerp(theme2, 0.5);

      expect(result.timeLegendWidth, 50.0);
    });

    test('lerp handles both null doubles', () {
      const theme1 = MCalDayThemeData(timeLegendWidth: null);
      const theme2 = MCalDayThemeData(timeLegendWidth: null);

      final result = theme1.lerp(theme2, 0.5);

      expect(result.timeLegendWidth, isNull);
    });

    test('lerp interpolates minResizeDurationMinutes at boundary', () {
      const theme1 = MCalDayThemeData(minResizeDurationMinutes: 15);
      const theme2 = MCalDayThemeData(minResizeDurationMinutes: 30);

      final atStart = theme1.lerp(theme2, 0.0);
      final atEnd = theme1.lerp(theme2, 1.0);

      expect(atStart.minResizeDurationMinutes, 15);
      expect(atEnd.minResizeDurationMinutes, 30);
    });

    test('lerp interpolates all double properties correctly', () {
      const theme1 = MCalDayThemeData(
        timeLegendWidth: 40.0,
        timeLegendTickWidth: 0.5,
        timeLegendTickLength: 4.0,
        hourGridlineWidth: 1.0,
        currentTimeIndicatorWidth: 1.0,
        currentTimeIndicatorDotRadius: 4.0,
        timedEventMinHeight: 16.0,
        timedEventBorderRadius: 2.0,
        resizeHandleSize: 4.0,
      );
      const theme2 = MCalDayThemeData(
        timeLegendWidth: 80.0,
        timeLegendTickWidth: 2.0,
        timeLegendTickLength: 16.0,
        hourGridlineWidth: 3.0,
        currentTimeIndicatorWidth: 5.0,
        currentTimeIndicatorDotRadius: 12.0,
        timedEventMinHeight: 32.0,
        timedEventBorderRadius: 8.0,
        resizeHandleSize: 16.0,
      );

      final result = theme1.lerp(theme2, 0.5);

      expect(result.timeLegendWidth, 60.0);
      expect(result.timeLegendTickWidth, 1.25);
      expect(result.timeLegendTickLength, 10.0);
      expect(result.hourGridlineWidth, 2.0);
      expect(result.currentTimeIndicatorWidth, 3.0);
      expect(result.currentTimeIndicatorDotRadius, 8.0);
      expect(result.timedEventMinHeight, 24.0);
      expect(result.timedEventBorderRadius, 5.0);
      expect(result.resizeHandleSize, 10.0);
    });

    test('lerp interpolates all Color properties', () {
      const theme1 = MCalDayThemeData(
        weekNumberTextColor: Colors.white,
        timeLegendBackgroundColor: Colors.white,
        timeLegendTickColor: Colors.white,
        hourGridlineColor: Colors.white,
        majorGridlineColor: Colors.white,
        minorGridlineColor: Colors.white,
        currentTimeIndicatorColor: Colors.white,
        specialTimeRegionColor: Colors.white,
        blockedTimeRegionColor: Colors.white,
        timeRegionBorderColor: Colors.white,
        timeRegionTextColor: Colors.white,
      );
      const theme2 = MCalDayThemeData(
        weekNumberTextColor: Colors.black,
        timeLegendBackgroundColor: Colors.black,
        timeLegendTickColor: Colors.black,
        hourGridlineColor: Colors.black,
        majorGridlineColor: Colors.black,
        minorGridlineColor: Colors.black,
        currentTimeIndicatorColor: Colors.black,
        specialTimeRegionColor: Colors.black,
        blockedTimeRegionColor: Colors.black,
        timeRegionBorderColor: Colors.black,
        timeRegionTextColor: Colors.black,
      );

      final result = theme1.lerp(theme2, 0.5);

      expect(result.weekNumberTextColor, isNotNull);
      expect(result.timeLegendBackgroundColor, isNotNull);
      expect(result.timeLegendTickColor, isNotNull);
      expect(result.hourGridlineColor, isNotNull);
      expect(result.majorGridlineColor, isNotNull);
      expect(result.minorGridlineColor, isNotNull);
      expect(result.currentTimeIndicatorColor, isNotNull);
      expect(result.specialTimeRegionColor, isNotNull);
      expect(result.blockedTimeRegionColor, isNotNull);
      expect(result.timeRegionBorderColor, isNotNull);
      expect(result.timeRegionTextColor, isNotNull);
    });

    test('lerp at t=0.25 and t=0.75 gives expected values', () {
      const theme1 = MCalDayThemeData(timeLegendWidth: 0.0);
      const theme2 = MCalDayThemeData(timeLegendWidth: 100.0);

      final atQuarter = theme1.lerp(theme2, 0.25);
      final atThreeQuarters = theme1.lerp(theme2, 0.75);

      expect(atQuarter.timeLegendWidth, 25.0);
      expect(atThreeQuarters.timeLegendWidth, 75.0);
    });
  });

  group('MCalDayThemeData equality', () {
    test('identical instances are equal', () {
      const theme = MCalDayThemeData(timeLegendWidth: 60.0);

      expect(theme == theme, isTrue);
    });

    test('same values are equal', () {
      const theme1 = MCalDayThemeData(
        timeLegendWidth: 60.0,
        showTimeLegendTicks: true,
      );
      const theme2 = MCalDayThemeData(
        timeLegendWidth: 60.0,
        showTimeLegendTicks: true,
      );

      expect(theme1, equals(theme2));
      expect(theme1.hashCode, theme2.hashCode);
    });

    test('different values are not equal', () {
      const theme1 = MCalDayThemeData(timeLegendWidth: 60.0);
      const theme2 = MCalDayThemeData(timeLegendWidth: 80.0);

      expect(theme1, isNot(equals(theme2)));
      expect(theme1.hashCode, isNot(theme2.hashCode));
    });

    test('empty themes are equal', () {
      const theme1 = MCalDayThemeData();
      const theme2 = MCalDayThemeData();

      expect(theme1, equals(theme2));
    });

    test('equality with non-MCalDayThemeData returns false', () {
      const theme = MCalDayThemeData();

      // ignore: unrelated_type_equality_checks
      expect(theme == 'string', isFalse);
      // ignore: unrelated_type_equality_checks
      expect(theme == 42, isFalse);
    });
  });

  group('MCalDayThemeData hashCode', () {
    test('hashCode is consistent', () {
      const theme = MCalDayThemeData(timeLegendWidth: 60.0);

      expect(theme.hashCode, theme.hashCode);
    });

    test('equal instances have same hashCode', () {
      const theme1 = MCalDayThemeData(showTimeLegendTicks: true);
      const theme2 = MCalDayThemeData(showTimeLegendTicks: true);

      expect(theme1.hashCode, theme2.hashCode);
    });
  });

  group('MCalDayThemeData edge cases', () {
    test('copyWith with all properties preserves original when no args', () {
      const original = MCalDayThemeData(
        dayHeaderDayOfWeekStyle: TextStyle(fontSize: 12),
        dayHeaderDateStyle: TextStyle(fontSize: 24),
        weekNumberTextColor: Colors.blue,
        timeLegendWidth: 72.0,
        showTimeLegendTicks: true,
        timeLegendTickColor: Colors.black,
        hourGridlineColor: Colors.red,
        currentTimeIndicatorColor: Colors.purple,
        allDaySectionMaxRows: 5,
        timedEventMinHeight: 24.0,
        timedEventPadding: EdgeInsets.all(4.0),
        resizeHandleSize: 10.0,
        minResizeDurationMinutes: 30,
      );

      final copied = original.copyWith();

      expect(copied, original);
    });

    test('lerp with identical themes returns same values', () {
      const theme = MCalDayThemeData(
        timeLegendWidth: 60.0,
        hourGridlineColor: Colors.blue,
      );

      final result = theme.lerp(theme, 0.5);

      expect(result.timeLegendWidth, 60.0);
      expect(result.hourGridlineColor?.toARGB32(), Colors.blue.toARGB32());
    });

    test('defaults factory produces const-like immutable values', () {
      final themeData = ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      );

      final theme1 = MCalDayThemeData.defaults(themeData);
      final theme2 = MCalDayThemeData.defaults(themeData);

      expect(theme1.timeLegendWidth, theme2.timeLegendWidth);
      expect(theme1.showTimeLegendTicks, theme2.showTimeLegendTicks);
    });

    test('equality includes all property types', () {
      const theme1 = MCalDayThemeData(
        dayHeaderDayOfWeekStyle: TextStyle(fontSize: 12),
        timeLegendWidth: 60.0,
        showTimeLegendTicks: true,
        allDaySectionMaxRows: 3,
        timedEventPadding: EdgeInsets.all(2.0),
        hourGridlineColor: Colors.blue,
      );
      const theme2 = MCalDayThemeData(
        dayHeaderDayOfWeekStyle: TextStyle(fontSize: 12),
        timeLegendWidth: 60.0,
        showTimeLegendTicks: true,
        allDaySectionMaxRows: 3,
        timedEventPadding: EdgeInsets.all(2.0),
        hourGridlineColor: Colors.blue,
      );

      expect(theme1, equals(theme2));
    });
  });
}
