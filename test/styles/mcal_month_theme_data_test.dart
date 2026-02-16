import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multi_calendar/multi_calendar.dart';

void main() {
  group('MCalMonthThemeData constructor', () {
    test('default constructor creates instance with all null properties', () {
      const theme = MCalMonthThemeData();

      expect(theme.cellBackgroundColor, isNull);
      expect(theme.cellBorderColor, isNull);
      expect(theme.cellTextStyle, isNull);
      expect(theme.todayBackgroundColor, isNull);
      expect(theme.todayTextStyle, isNull);
      expect(theme.weekdayHeaderTextStyle, isNull);
      expect(theme.eventTileHeight, isNull);
      expect(theme.dateLabelPosition, isNull);
      expect(theme.overflowIndicatorHeight, isNull);
      expect(theme.navigatorTextStyle, isNull);
      expect(theme.allDayEventBackgroundColor, isNull);
      expect(theme.dropTargetCellValidColor, isNull);
      expect(theme.dragSourceOpacity, isNull);
    });

    test('constructor accepts key properties', () {
      const cellStyle = TextStyle(fontSize: 14);

      const theme = MCalMonthThemeData(
        cellBackgroundColor: Colors.white,
        cellBorderColor: Colors.grey,
        cellTextStyle: cellStyle,
        todayBackgroundColor: Colors.blue,
        eventTileHeight: 24.0,
        dateLabelPosition: DateLabelPosition.topCenter,
        overflowIndicatorHeight: 16.0,
        navigatorTextStyle: cellStyle,
        dropTargetCellValidColor: Colors.green,
        dragSourceOpacity: 0.5,
      );

      expect(theme.cellBackgroundColor, Colors.white);
      expect(theme.eventTileHeight, 24.0);
      expect(theme.dateLabelPosition, DateLabelPosition.topCenter);
      expect(theme.dragSourceOpacity, 0.5);
    });
  });

  group('MCalMonthThemeData.defaults', () {
    test('defaults factory creates non-null values from ThemeData', () {
      final themeData = ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      );

      final theme = MCalMonthThemeData.defaults(themeData);

      expect(theme.cellBackgroundColor, isNotNull);
      expect(theme.cellBorderColor, isNotNull);
      expect(theme.cellTextStyle, isNotNull);
      expect(theme.todayBackgroundColor, isNotNull);
      expect(theme.todayTextStyle, isNotNull);
      expect(theme.weekdayHeaderTextStyle, isNotNull);
      expect(theme.eventTileHeight, 20.0);
      expect(theme.dateLabelPosition, DateLabelPosition.topLeft);
      expect(theme.overflowIndicatorHeight, 14.0);
      expect(theme.navigatorTextStyle, isNotNull);
      expect(theme.allDayEventBackgroundColor, isNotNull);
      expect(theme.dropTargetCellValidColor, isNotNull);
      expect(theme.dragSourceOpacity, 0.5);
    });

    test('defaults uses colorScheme from ThemeData', () {
      final themeData = ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
      );

      final theme = MCalMonthThemeData.defaults(themeData);

      expect(theme.cellBackgroundColor, themeData.colorScheme.surface);
      expect(theme.todayBackgroundColor, isNotNull);
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

      final light = MCalMonthThemeData.defaults(lightTheme);
      final dark = MCalMonthThemeData.defaults(darkTheme);

      expect(light.cellBackgroundColor, isNot(dark.cellBackgroundColor));
      expect(light.todayBackgroundColor, isNot(dark.todayBackgroundColor));
    });
  });

  group('MCalMonthThemeData copyWith', () {
    test('copyWith with no arguments returns identical instance', () {
      const original = MCalMonthThemeData(
        eventTileHeight: 24.0,
        cellBackgroundColor: Colors.white,
      );

      final copied = original.copyWith();

      expect(copied.eventTileHeight, 24.0);
      expect(copied.cellBackgroundColor, Colors.white);
      expect(copied, original);
    });

    test('copyWith updates single property', () {
      const original = MCalMonthThemeData(eventTileHeight: 20.0);

      final updated = original.copyWith(eventTileHeight: 28.0);

      expect(updated.eventTileHeight, 28.0);
      expect(original.eventTileHeight, 20.0);
    });

    test('copyWith preserves unspecified properties', () {
      const original = MCalMonthThemeData(
        eventTileHeight: 20.0,
        cellBackgroundColor: Colors.white,
        todayBackgroundColor: Colors.blue,
      );

      final updated = original.copyWith(eventTileHeight: 24.0);

      expect(updated.eventTileHeight, 24.0);
      expect(updated.cellBackgroundColor, Colors.white);
      expect(updated.todayBackgroundColor, Colors.blue);
    });

    test('copyWith updates DateLabelPosition', () {
      const original = MCalMonthThemeData(
        dateLabelPosition: DateLabelPosition.topLeft,
      );

      final updated = original.copyWith(
        dateLabelPosition: DateLabelPosition.topCenter,
      );

      expect(updated.dateLabelPosition, DateLabelPosition.topCenter);
    });

    test('copyWith updates Color properties', () {
      const original = MCalMonthThemeData(cellBackgroundColor: Colors.blue);

      final updated = original.copyWith(cellBackgroundColor: Colors.red);

      expect(updated.cellBackgroundColor, Colors.red);
    });

    test('copyWith updates double properties', () {
      const original = MCalMonthThemeData(
        eventTileHeight: 20.0,
        overflowIndicatorHeight: 14.0,
        dragSourceOpacity: 0.5,
      );

      final updated = original.copyWith(
        eventTileHeight: 28.0,
        overflowIndicatorHeight: 18.0,
        dragSourceOpacity: 0.8,
      );

      expect(updated.eventTileHeight, 28.0);
      expect(updated.overflowIndicatorHeight, 18.0);
      expect(updated.dragSourceOpacity, 0.8);
    });

    test('copyWith updates TextStyle properties', () {
      const original = MCalMonthThemeData(
        cellTextStyle: TextStyle(fontSize: 12),
      );
      const newStyle = TextStyle(fontSize: 16, color: Colors.red);

      final updated = original.copyWith(cellTextStyle: newStyle);

      expect(updated.cellTextStyle?.fontSize, 16);
      expect(updated.cellTextStyle?.color, Colors.red);
    });

    test('copyWith updates drop target properties', () {
      const original = MCalMonthThemeData(
        dropTargetCellValidColor: Colors.green,
        dropTargetCellInvalidColor: Colors.red,
        dropTargetCellBorderRadius: 4.0,
      );

      final updated = original.copyWith(
        dropTargetCellValidColor: Colors.blue,
        dropTargetCellInvalidColor: Colors.orange,
        dropTargetCellBorderRadius: 8.0,
      );

      expect(updated.dropTargetCellValidColor, Colors.blue);
      expect(updated.dropTargetCellInvalidColor, Colors.orange);
      expect(updated.dropTargetCellBorderRadius, 8.0);
    });

    test('copyWith updates event tile properties', () {
      const original = MCalMonthThemeData(
        eventTileHeight: 20.0,
        eventTileHorizontalSpacing: 1.0,
        eventTileVerticalSpacing: 1.0,
        eventTileCornerRadius: 3.0,
      );

      final updated = original.copyWith(
        eventTileHeight: 24.0,
        eventTileHorizontalSpacing: 2.0,
        eventTileVerticalSpacing: 2.0,
        eventTileCornerRadius: 6.0,
      );

      expect(updated.eventTileHeight, 24.0);
      expect(updated.eventTileHorizontalSpacing, 2.0);
      expect(updated.eventTileVerticalSpacing, 2.0);
      expect(updated.eventTileCornerRadius, 6.0);
    });

    test('copyWith updates all-day event properties', () {
      const original = MCalMonthThemeData(
        allDayEventBackgroundColor: Colors.blue,
        allDayEventTextStyle: TextStyle(fontSize: 12),
        allDayEventBorderColor: Colors.grey,
        allDayEventBorderWidth: 1.0,
      );

      final updated = original.copyWith(
        allDayEventBackgroundColor: Colors.red,
        allDayEventTextStyle: TextStyle(fontSize: 14),
        allDayEventBorderColor: Colors.black,
        allDayEventBorderWidth: 2.0,
      );

      expect(updated.allDayEventBackgroundColor, Colors.red);
      expect(updated.allDayEventTextStyle?.fontSize, 14);
      expect(updated.allDayEventBorderColor, Colors.black);
      expect(updated.allDayEventBorderWidth, 2.0);
    });
  });

  group('MCalMonthThemeData lerp', () {
    test('lerp with null other returns this', () {
      const theme = MCalMonthThemeData(eventTileHeight: 24.0);

      final result = theme.lerp(null, 0.5);

      expect(result, theme);
    });

    test('lerp at t=0.0 returns this theme', () {
      const theme1 = MCalMonthThemeData(
        eventTileHeight: 20.0,
        cellBackgroundColor: Colors.white,
      );
      const theme2 = MCalMonthThemeData(
        eventTileHeight: 28.0,
        cellBackgroundColor: Colors.black,
      );

      final result = theme1.lerp(theme2, 0.0);

      expect(result.eventTileHeight, 20.0);
      expect(result.cellBackgroundColor?.toARGB32(), Colors.white.toARGB32());
    });

    test('lerp at t=1.0 returns other theme', () {
      const theme1 = MCalMonthThemeData(
        eventTileHeight: 20.0,
        cellBackgroundColor: Colors.white,
      );
      const theme2 = MCalMonthThemeData(
        eventTileHeight: 28.0,
        cellBackgroundColor: Colors.black,
      );

      final result = theme1.lerp(theme2, 1.0);

      expect(result.eventTileHeight, 28.0);
      expect(result.cellBackgroundColor?.toARGB32(), Colors.black.toARGB32());
    });

    test('lerp at t=0.5 interpolates double values', () {
      const theme1 = MCalMonthThemeData(eventTileHeight: 20.0);
      const theme2 = MCalMonthThemeData(eventTileHeight: 28.0);

      final result = theme1.lerp(theme2, 0.5);

      expect(result.eventTileHeight, 24.0);
    });

    test('lerp interpolates Color values', () {
      const theme1 = MCalMonthThemeData(cellBackgroundColor: Colors.white);
      const theme2 = MCalMonthThemeData(cellBackgroundColor: Colors.black);

      final atHalf = theme1.lerp(theme2, 0.5);

      expect(atHalf.cellBackgroundColor, isNotNull);
      expect(atHalf.cellBackgroundColor, isNot(Colors.white));
      expect(atHalf.cellBackgroundColor, isNot(Colors.black));
    });

    test('lerp interpolates dateLabelPosition at t<0.5 uses this value', () {
      const theme1 = MCalMonthThemeData(
        dateLabelPosition: DateLabelPosition.topLeft,
      );
      const theme2 = MCalMonthThemeData(
        dateLabelPosition: DateLabelPosition.topCenter,
      );

      final result = theme1.lerp(theme2, 0.3);

      expect(result.dateLabelPosition, DateLabelPosition.topLeft);
    });

    test('lerp interpolates dateLabelPosition at t>=0.5 uses other value', () {
      const theme1 = MCalMonthThemeData(
        dateLabelPosition: DateLabelPosition.topLeft,
      );
      const theme2 = MCalMonthThemeData(
        dateLabelPosition: DateLabelPosition.topCenter,
      );

      final result = theme1.lerp(theme2, 0.5);

      expect(result.dateLabelPosition, DateLabelPosition.topCenter);
    });

    test('lerp interpolates TextStyle', () {
      const theme1 = MCalMonthThemeData(
        cellTextStyle: TextStyle(fontSize: 12, color: Colors.white),
      );
      const theme2 = MCalMonthThemeData(
        cellTextStyle: TextStyle(fontSize: 24, color: Colors.black),
      );

      final result = theme1.lerp(theme2, 0.5);

      expect(result.cellTextStyle?.fontSize, 18.0);
    });

    test('lerp handles null double values', () {
      const theme1 = MCalMonthThemeData(eventTileHeight: null);
      const theme2 = MCalMonthThemeData(eventTileHeight: 28.0);

      final result = theme1.lerp(theme2, 0.5);

      expect(result.eventTileHeight, 14.0);
    });

    test('lerp handles both null doubles', () {
      const theme1 = MCalMonthThemeData(eventTileHeight: null);
      const theme2 = MCalMonthThemeData(eventTileHeight: null);

      final result = theme1.lerp(theme2, 0.5);

      expect(result.eventTileHeight, isNull);
    });

    test('lerp interpolates drop target and drag properties', () {
      const theme1 = MCalMonthThemeData(
        dropTargetCellBorderRadius: 2.0,
        dragSourceOpacity: 0.3,
        draggedTileElevation: 4.0,
      );
      const theme2 = MCalMonthThemeData(
        dropTargetCellBorderRadius: 8.0,
        dragSourceOpacity: 0.9,
        draggedTileElevation: 12.0,
      );

      final result = theme1.lerp(theme2, 0.5);

      expect(result.dropTargetCellBorderRadius, closeTo(5.0, 0.001));
      expect(result.dragSourceOpacity, closeTo(0.6, 0.001));
      expect(result.draggedTileElevation, closeTo(8.0, 0.001));
    });
  });

  group('MCalMonthThemeData equality', () {
    test('identical instances are equal', () {
      const theme = MCalMonthThemeData(eventTileHeight: 24.0);

      expect(theme == theme, isTrue);
    });

    test('same values are equal', () {
      const theme1 = MCalMonthThemeData(
        eventTileHeight: 24.0,
        dateLabelPosition: DateLabelPosition.topCenter,
      );
      const theme2 = MCalMonthThemeData(
        eventTileHeight: 24.0,
        dateLabelPosition: DateLabelPosition.topCenter,
      );

      expect(theme1, equals(theme2));
      expect(theme1.hashCode, theme2.hashCode);
    });

    test('different values are not equal', () {
      const theme1 = MCalMonthThemeData(eventTileHeight: 20.0);
      const theme2 = MCalMonthThemeData(eventTileHeight: 28.0);

      expect(theme1, isNot(equals(theme2)));
      expect(theme1.hashCode, isNot(theme2.hashCode));
    });

    test('empty themes are equal', () {
      const theme1 = MCalMonthThemeData();
      const theme2 = MCalMonthThemeData();

      expect(theme1, equals(theme2));
    });

    test('equality with non-MCalMonthThemeData returns false', () {
      const theme = MCalMonthThemeData();

      expect(theme == 'string', isFalse); // ignore: unrelated_type_equality_checks
      expect(theme == 42, isFalse); // ignore: unrelated_type_equality_checks
    });
  });

  group('MCalMonthThemeData hashCode', () {
    test('hashCode is consistent', () {
      const theme = MCalMonthThemeData(eventTileHeight: 24.0);

      expect(theme.hashCode, theme.hashCode);
    });

    test('equal instances have same hashCode', () {
      const theme1 = MCalMonthThemeData(dateLabelPosition: DateLabelPosition.topLeft);
      const theme2 = MCalMonthThemeData(dateLabelPosition: DateLabelPosition.topLeft);

      expect(theme1.hashCode, theme2.hashCode);
    });
  });

  group('MCalMonthThemeData edge cases', () {
    test('copyWith with all DateLabelPosition values', () {
      const positions = [
        DateLabelPosition.topLeft,
        DateLabelPosition.topCenter,
        DateLabelPosition.topRight,
        DateLabelPosition.bottomLeft,
        DateLabelPosition.bottomCenter,
        DateLabelPosition.bottomRight,
      ];

      for (final position in positions) {
        const original = MCalMonthThemeData(
          dateLabelPosition: DateLabelPosition.topLeft,
        );
        final updated = original.copyWith(dateLabelPosition: position);
        expect(updated.dateLabelPosition, position);
      }
    });

    test('lerp with identical themes returns same values', () {
      const theme = MCalMonthThemeData(
        eventTileHeight: 24.0,
        cellBackgroundColor: Colors.blue,
      );

      final result = theme.lerp(theme, 0.5);

      expect(result.eventTileHeight, 24.0);
      expect(result.cellBackgroundColor?.toARGB32(), Colors.blue.toARGB32());
    });

    test('defaults factory produces consistent values', () {
      final themeData = ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      );

      final theme1 = MCalMonthThemeData.defaults(themeData);
      final theme2 = MCalMonthThemeData.defaults(themeData);

      expect(theme1.eventTileHeight, theme2.eventTileHeight);
      expect(theme1.dateLabelPosition, theme2.dateLabelPosition);
    });

    test('copyWith updates multi-day and hover properties', () {
      const original = MCalMonthThemeData(
        multiDayEventBackgroundColor: Colors.blue,
        hoverCellBackgroundColor: Colors.grey,
        hoverEventBackgroundColor: Colors.orange,
      );

      final updated = original.copyWith(
        multiDayEventBackgroundColor: Colors.red,
        hoverCellBackgroundColor: Colors.white,
        hoverEventBackgroundColor: Colors.purple,
      );

      expect(updated.multiDayEventBackgroundColor, Colors.red);
      expect(updated.hoverCellBackgroundColor, Colors.white);
      expect(updated.hoverEventBackgroundColor, Colors.purple);
    });

    test('lerp interpolates all Color properties', () {
      const theme1 = MCalMonthThemeData(
        cellBackgroundColor: Colors.white,
        todayBackgroundColor: Colors.white,
        dropTargetCellValidColor: Colors.white,
      );
      const theme2 = MCalMonthThemeData(
        cellBackgroundColor: Colors.black,
        todayBackgroundColor: Colors.black,
        dropTargetCellValidColor: Colors.black,
      );

      final result = theme1.lerp(theme2, 0.5);

      expect(result.cellBackgroundColor, isNotNull);
      expect(result.todayBackgroundColor, isNotNull);
      expect(result.dropTargetCellValidColor, isNotNull);
    });

    test('copyWith updates leading and trailing date properties', () {
      const original = MCalMonthThemeData(
        leadingDatesTextStyle: TextStyle(fontSize: 10),
        trailingDatesTextStyle: TextStyle(fontSize: 10),
        leadingDatesBackgroundColor: Colors.white,
        trailingDatesBackgroundColor: Colors.white,
      );

      final updated = original.copyWith(
        leadingDatesTextStyle: TextStyle(fontSize: 12),
        trailingDatesTextStyle: TextStyle(fontSize: 12),
        leadingDatesBackgroundColor: Colors.grey,
        trailingDatesBackgroundColor: Colors.grey,
      );

      expect(updated.leadingDatesTextStyle?.fontSize, 12);
      expect(updated.trailingDatesTextStyle?.fontSize, 12);
      expect(updated.leadingDatesBackgroundColor, Colors.grey);
      expect(updated.trailingDatesBackgroundColor, Colors.grey);
    });

    test('lerp at t=0.25 and t=0.75 gives expected double values', () {
      const theme1 = MCalMonthThemeData(eventTileHeight: 0.0);
      const theme2 = MCalMonthThemeData(eventTileHeight: 100.0);

      final atQuarter = theme1.lerp(theme2, 0.25);
      final atThreeQuarters = theme1.lerp(theme2, 0.75);

      expect(atQuarter.eventTileHeight, 25.0);
      expect(atThreeQuarters.eventTileHeight, 75.0);
    });

    test('copyWith updates drop target tile properties', () {
      const original = MCalMonthThemeData(
        dropTargetTileBackgroundColor: Colors.blue,
        dropTargetTileInvalidBackgroundColor: Colors.red,
        dropTargetTileCornerRadius: 4.0,
        dropTargetTileBorderColor: Colors.grey,
        dropTargetTileBorderWidth: 1.0,
      );

      final updated = original.copyWith(
        dropTargetTileBackgroundColor: Colors.green,
        dropTargetTileInvalidBackgroundColor: Colors.orange,
        dropTargetTileCornerRadius: 8.0,
        dropTargetTileBorderColor: Colors.black,
        dropTargetTileBorderWidth: 2.0,
      );

      expect(updated.dropTargetTileBackgroundColor, Colors.green);
      expect(updated.dropTargetTileInvalidBackgroundColor, Colors.orange);
      expect(updated.dropTargetTileCornerRadius, 8.0);
      expect(updated.dropTargetTileBorderColor, Colors.black);
      expect(updated.dropTargetTileBorderWidth, 2.0);
    });
  });
}
