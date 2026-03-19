import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multi_calendar/multi_calendar.dart';

void main() {
  group('MCalMonthViewThemeData constructor', () {
    test('default constructor creates instance with all null properties', () {
      const theme = MCalMonthViewThemeData();

      expect(theme.cellTextStyle, isNull);
      expect(theme.todayBackgroundColor, isNull);
      expect(theme.todayTextStyle, isNull);
      expect(theme.weekdayHeaderTextStyle, isNull);
      expect(theme.eventTileHeight, isNull);
      expect(theme.dateLabelPosition, isNull);
      expect(theme.overflowIndicatorHeight, isNull);
      expect(theme.dropTargetCellValidColor, isNull);
      expect(theme.dragSourceOpacity, isNull);
    });

    test('constructor accepts key properties', () {
      const cellStyle = TextStyle(fontSize: 14);

      const theme = MCalMonthViewThemeData(
        cellTextStyle: cellStyle,
        todayBackgroundColor: Colors.blue,
        eventTileHeight: 24.0,
        dateLabelPosition: DateLabelPosition.topCenter,
        overflowIndicatorHeight: 16.0,
        dropTargetCellValidColor: Colors.green,
        dragSourceOpacity: 0.5,
      );

      expect(theme.eventTileHeight, 24.0);
      expect(theme.dateLabelPosition, DateLabelPosition.topCenter);
      expect(theme.dragSourceOpacity, 0.5);
    });
  });

  group('MCalMonthViewThemeData.defaults', () {
    test('defaults factory creates non-null values from ThemeData', () {
      final themeData = ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      );

      final theme = MCalMonthViewThemeData.defaults(themeData);

      expect(theme.cellTextStyle, isNotNull);
      expect(theme.todayBackgroundColor, isNotNull);
      expect(theme.todayTextStyle, isNotNull);
      expect(theme.weekdayHeaderTextStyle, isNotNull);
      expect(theme.eventTileHeight, 20.0);
      expect(theme.dateLabelPosition, DateLabelPosition.topLeft);
      expect(theme.overflowIndicatorHeight, 14.0);
      expect(theme.dropTargetCellValidColor, isNotNull);
      expect(theme.dragSourceOpacity, 0.5);
    });

    test('defaults uses colorScheme from ThemeData', () {
      final themeData = ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
      );

      final theme = MCalMonthViewThemeData.defaults(themeData);

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

      final light = MCalMonthViewThemeData.defaults(lightTheme);
      final dark = MCalMonthViewThemeData.defaults(darkTheme);

      expect(light.todayBackgroundColor, isNot(dark.todayBackgroundColor));
    });
  });

  group('MCalMonthViewThemeData copyWith', () {
    test('copyWith with no arguments returns identical instance', () {
      const original = MCalMonthViewThemeData(
        eventTileHeight: 24.0,
        todayBackgroundColor: Colors.blue,
      );

      final copied = original.copyWith();

      expect(copied.eventTileHeight, 24.0);
      expect(copied.todayBackgroundColor, Colors.blue);
      expect(copied, original);
    });

    test('copyWith updates single property', () {
      const original = MCalMonthViewThemeData(eventTileHeight: 20.0);

      final updated = original.copyWith(eventTileHeight: 28.0);

      expect(updated.eventTileHeight, 28.0);
      expect(original.eventTileHeight, 20.0);
    });

    test('copyWith preserves unspecified properties', () {
      const original = MCalMonthViewThemeData(
        eventTileHeight: 20.0,
        todayBackgroundColor: Colors.blue,
      );

      final updated = original.copyWith(eventTileHeight: 24.0);

      expect(updated.eventTileHeight, 24.0);
      expect(updated.todayBackgroundColor, Colors.blue);
    });

    test('copyWith updates DateLabelPosition', () {
      const original = MCalMonthViewThemeData(
        dateLabelPosition: DateLabelPosition.topLeft,
      );

      final updated = original.copyWith(
        dateLabelPosition: DateLabelPosition.topCenter,
      );

      expect(updated.dateLabelPosition, DateLabelPosition.topCenter);
    });

    test('copyWith updates Color properties', () {
      const original = MCalMonthViewThemeData(todayBackgroundColor: Colors.blue);

      final updated = original.copyWith(todayBackgroundColor: Colors.red);

      expect(updated.todayBackgroundColor, Colors.red);
    });

    test('copyWith updates double properties', () {
      const original = MCalMonthViewThemeData(
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
      const original = MCalMonthViewThemeData(
        cellTextStyle: TextStyle(fontSize: 12),
      );
      const newStyle = TextStyle(fontSize: 16, color: Colors.red);

      final updated = original.copyWith(cellTextStyle: newStyle);

      expect(updated.cellTextStyle?.fontSize, 16);
      expect(updated.cellTextStyle?.color, Colors.red);
    });

    test('copyWith updates drop target properties', () {
      const original = MCalMonthViewThemeData(
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
      const original = MCalMonthViewThemeData(
        eventTileHeight: 20.0,
        eventTileVerticalSpacing: 1.0,
      );

      final updated = original.copyWith(
        eventTileHeight: 24.0,
        eventTileVerticalSpacing: 2.0,
      );

      expect(updated.eventTileHeight, 24.0);
      expect(updated.eventTileVerticalSpacing, 2.0);
    });

  });

  group('MCalMonthViewThemeData lerp', () {
    test('lerp with null other returns this', () {
      const theme = MCalMonthViewThemeData(eventTileHeight: 24.0);

      final result = theme.lerp(null, 0.5);

      expect(result, theme);
    });

    test('lerp at t=0.0 returns this theme', () {
      const theme1 = MCalMonthViewThemeData(
        eventTileHeight: 20.0,
        todayBackgroundColor: Colors.white,
      );
      const theme2 = MCalMonthViewThemeData(
        eventTileHeight: 28.0,
        todayBackgroundColor: Colors.black,
      );

      final result = theme1.lerp(theme2, 0.0);

      expect(result.eventTileHeight, 20.0);
      expect(result.todayBackgroundColor?.toARGB32(), Colors.white.toARGB32());
    });

    test('lerp at t=1.0 returns other theme', () {
      const theme1 = MCalMonthViewThemeData(
        eventTileHeight: 20.0,
        todayBackgroundColor: Colors.white,
      );
      const theme2 = MCalMonthViewThemeData(
        eventTileHeight: 28.0,
        todayBackgroundColor: Colors.black,
      );

      final result = theme1.lerp(theme2, 1.0);

      expect(result.eventTileHeight, 28.0);
      expect(result.todayBackgroundColor?.toARGB32(), Colors.black.toARGB32());
    });

    test('lerp at t=0.5 interpolates double values', () {
      const theme1 = MCalMonthViewThemeData(eventTileHeight: 20.0);
      const theme2 = MCalMonthViewThemeData(eventTileHeight: 28.0);

      final result = theme1.lerp(theme2, 0.5);

      expect(result.eventTileHeight, 24.0);
    });

    test('lerp interpolates Color values', () {
      const theme1 = MCalMonthViewThemeData(todayBackgroundColor: Colors.white);
      const theme2 = MCalMonthViewThemeData(todayBackgroundColor: Colors.black);

      final atHalf = theme1.lerp(theme2, 0.5);

      expect(atHalf.todayBackgroundColor, isNotNull);
      expect(atHalf.todayBackgroundColor, isNot(Colors.white));
      expect(atHalf.todayBackgroundColor, isNot(Colors.black));
    });

    test('lerp interpolates dateLabelPosition at t<0.5 uses this value', () {
      const theme1 = MCalMonthViewThemeData(
        dateLabelPosition: DateLabelPosition.topLeft,
      );
      const theme2 = MCalMonthViewThemeData(
        dateLabelPosition: DateLabelPosition.topCenter,
      );

      final result = theme1.lerp(theme2, 0.3);

      expect(result.dateLabelPosition, DateLabelPosition.topLeft);
    });

    test('lerp interpolates dateLabelPosition at t>=0.5 uses other value', () {
      const theme1 = MCalMonthViewThemeData(
        dateLabelPosition: DateLabelPosition.topLeft,
      );
      const theme2 = MCalMonthViewThemeData(
        dateLabelPosition: DateLabelPosition.topCenter,
      );

      final result = theme1.lerp(theme2, 0.5);

      expect(result.dateLabelPosition, DateLabelPosition.topCenter);
    });

    test('lerp interpolates TextStyle', () {
      const theme1 = MCalMonthViewThemeData(
        cellTextStyle: TextStyle(fontSize: 12, color: Colors.white),
      );
      const theme2 = MCalMonthViewThemeData(
        cellTextStyle: TextStyle(fontSize: 24, color: Colors.black),
      );

      final result = theme1.lerp(theme2, 0.5);

      expect(result.cellTextStyle?.fontSize, 18.0);
    });

    test('lerp handles null double values', () {
      const theme1 = MCalMonthViewThemeData(eventTileHeight: null);
      const theme2 = MCalMonthViewThemeData(eventTileHeight: 28.0);

      final result = theme1.lerp(theme2, 0.5);

      expect(result.eventTileHeight, 14.0);
    });

    test('lerp handles both null doubles', () {
      const theme1 = MCalMonthViewThemeData(eventTileHeight: null);
      const theme2 = MCalMonthViewThemeData(eventTileHeight: null);

      final result = theme1.lerp(theme2, 0.5);

      expect(result.eventTileHeight, isNull);
    });

    test('lerp interpolates drop target and drag properties', () {
      const theme1 = MCalMonthViewThemeData(
        dropTargetCellBorderRadius: 2.0,
        dragSourceOpacity: 0.3,
        draggedTileElevation: 4.0,
      );
      const theme2 = MCalMonthViewThemeData(
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

  group('MCalMonthViewThemeData equality', () {
    test('identical instances are equal', () {
      const theme = MCalMonthViewThemeData(eventTileHeight: 24.0);

      expect(theme == theme, isTrue);
    });

    test('same values are equal', () {
      const theme1 = MCalMonthViewThemeData(
        eventTileHeight: 24.0,
        dateLabelPosition: DateLabelPosition.topCenter,
      );
      const theme2 = MCalMonthViewThemeData(
        eventTileHeight: 24.0,
        dateLabelPosition: DateLabelPosition.topCenter,
      );

      expect(theme1, equals(theme2));
      expect(theme1.hashCode, theme2.hashCode);
    });

    test('different values are not equal', () {
      const theme1 = MCalMonthViewThemeData(eventTileHeight: 20.0);
      const theme2 = MCalMonthViewThemeData(eventTileHeight: 28.0);

      expect(theme1, isNot(equals(theme2)));
      expect(theme1.hashCode, isNot(theme2.hashCode));
    });

    test('empty themes are equal', () {
      const theme1 = MCalMonthViewThemeData();
      const theme2 = MCalMonthViewThemeData();

      expect(theme1, equals(theme2));
    });

    test('equality with non-MCalMonthViewThemeData returns false', () {
      const theme = MCalMonthViewThemeData();

      expect(theme == 'string', isFalse); // ignore: unrelated_type_equality_checks
      expect(theme == 42, isFalse); // ignore: unrelated_type_equality_checks
    });
  });

  group('MCalMonthViewThemeData hashCode', () {
    test('hashCode is consistent', () {
      const theme = MCalMonthViewThemeData(eventTileHeight: 24.0);

      expect(theme.hashCode, theme.hashCode);
    });

    test('equal instances have same hashCode', () {
      const theme1 = MCalMonthViewThemeData(dateLabelPosition: DateLabelPosition.topLeft);
      const theme2 = MCalMonthViewThemeData(dateLabelPosition: DateLabelPosition.topLeft);

      expect(theme1.hashCode, theme2.hashCode);
    });
  });

  group('MCalMonthViewThemeData edge cases', () {
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
        const original = MCalMonthViewThemeData(
          dateLabelPosition: DateLabelPosition.topLeft,
        );
        final updated = original.copyWith(dateLabelPosition: position);
        expect(updated.dateLabelPosition, position);
      }
    });

    test('lerp with identical themes returns same values', () {
      const theme = MCalMonthViewThemeData(
        eventTileHeight: 24.0,
        todayBackgroundColor: Colors.blue,
      );

      final result = theme.lerp(theme, 0.5);

      expect(result.eventTileHeight, 24.0);
      expect(result.todayBackgroundColor?.toARGB32(), Colors.blue.toARGB32());
    });

    test('defaults factory produces consistent values', () {
      final themeData = ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      );

      final theme1 = MCalMonthViewThemeData.defaults(themeData);
      final theme2 = MCalMonthViewThemeData.defaults(themeData);

      expect(theme1.eventTileHeight, theme2.eventTileHeight);
      expect(theme1.dateLabelPosition, theme2.dateLabelPosition);
    });

    test('copyWith updates all-day and hover properties', () {
      const original = MCalMonthViewThemeData(
        allDayEventBackgroundColor: Colors.blue,
        hoverCellBackgroundColor: Colors.grey,
      );

      final updated = original.copyWith(
        allDayEventBackgroundColor: Colors.red,
        hoverCellBackgroundColor: Colors.white,
      );

      expect(updated.allDayEventBackgroundColor, Colors.red);
      expect(updated.hoverCellBackgroundColor, Colors.white);
    });

    test('lerp interpolates all Color properties', () {
      const theme1 = MCalMonthViewThemeData(
        todayBackgroundColor: Colors.white,
        dropTargetCellValidColor: Colors.white,
      );
      const theme2 = MCalMonthViewThemeData(
        todayBackgroundColor: Colors.black,
        dropTargetCellValidColor: Colors.black,
      );

      final result = theme1.lerp(theme2, 0.5);

      expect(result.todayBackgroundColor, isNotNull);
      expect(result.dropTargetCellValidColor, isNotNull);
    });

    test('copyWith updates leading and trailing date properties', () {
      const original = MCalMonthViewThemeData(
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
      const theme1 = MCalMonthViewThemeData(eventTileHeight: 0.0);
      const theme2 = MCalMonthViewThemeData(eventTileHeight: 100.0);

      final atQuarter = theme1.lerp(theme2, 0.25);
      final atThreeQuarters = theme1.lerp(theme2, 0.75);

      expect(atQuarter.eventTileHeight, 25.0);
      expect(atThreeQuarters.eventTileHeight, 75.0);
    });

    test('copyWith updates drop target tile properties', () {
      const original = MCalMonthViewThemeData(
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

    test('new 5 cascade properties round-trip via copyWith', () {
      const original = MCalMonthViewThemeData(
        overlayScrimColor: Color(0x80000000),
        errorIconColor: Color(0xFFFF0000),
        defaultRegionColor: Color(0xFF909090),
      );
      final updated = original.copyWith(
        errorIconColor: const Color(0xFFCC0000),
        overflowIndicatorTextStyle: const TextStyle(fontSize: 10),
      );

      expect(updated.overlayScrimColor, const Color(0x80000000));
      expect(updated.errorIconColor, const Color(0xFFCC0000));
      expect(updated.defaultRegionColor, const Color(0xFF909090));
      expect(updated.overflowIndicatorTextStyle?.fontSize, 10);
      expect(original.errorIconColor, const Color(0xFFFF0000));
    });

    group('defaults() for new cascade properties', () {
      test('defaults provides non-null overlayScrimColor and errorIconColor', () {
        final themeData = ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        );
        final defaults = MCalMonthViewThemeData.defaults(themeData);

        expect(defaults.overlayScrimColor, isNotNull);
        expect(defaults.errorIconColor, isNotNull);
        expect(defaults.defaultRegionColor, isNotNull);
        expect(defaults.overflowIndicatorTextStyle, isNotNull);
      });

      test('defaults dropTargetCellValidColor and InvalidColor use M3 roles not Colors.*', () {
        final themeData = ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        );
        final defaults = MCalMonthViewThemeData.defaults(themeData);

        // Should be non-null
        expect(defaults.dropTargetCellValidColor, isNotNull);
        expect(defaults.dropTargetCellInvalidColor, isNotNull);
        // Should NOT be the old hardcoded Colors.green/red
        expect(defaults.dropTargetCellValidColor, isNot(Colors.green.withValues(alpha: 0.3)));
        expect(defaults.dropTargetCellInvalidColor, isNot(Colors.red.withValues(alpha: 0.3)));
      });
    });
  });
}
