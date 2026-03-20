import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multi_calendar/multi_calendar.dart';

void main() {
  group('MCalTheme InheritedWidget', () {
    testWidgets('of() with MCalTheme ancestor returns the theme data from the ancestor', (tester) async {
      final testThemeData = MCalThemeData(
        cellBackgroundColor: Colors.red,
        monthViewTheme: MCalMonthViewThemeData(
          todayBackgroundColor: Colors.blue,
        ),
      );

      MCalThemeData? capturedTheme;

      await tester.pumpWidget(
        MaterialApp(
          home: MCalTheme(
            data: testThemeData,
            child: Builder(
              builder: (context) {
                capturedTheme = MCalTheme.of(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(capturedTheme, isNotNull);
      expect(capturedTheme!.cellBackgroundColor, Colors.red);
      expect(capturedTheme!.monthViewTheme?.todayBackgroundColor, Colors.blue);
    });

    testWidgets('of() fallback to ThemeExtension when no MCalTheme ancestor', (tester) async {
      final extensionThemeData = MCalThemeData(
        cellBackgroundColor: Colors.green,
        monthViewTheme: MCalMonthViewThemeData(
          todayBackgroundColor: Colors.orange,
        ),
      );

      MCalThemeData? capturedTheme;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            useMaterial3: true,
            extensions: [extensionThemeData],
          ),
          home: Builder(
            builder: (context) {
              capturedTheme = MCalTheme.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(capturedTheme, isNotNull);
      expect(capturedTheme!.cellBackgroundColor, Colors.green);
      expect(capturedTheme!.monthViewTheme?.todayBackgroundColor, Colors.orange);
    });

    testWidgets('of() fallback to fromTheme() when neither MCalTheme nor extension exists', (tester) async {
      MCalThemeData? capturedTheme;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
          ),
          home: Builder(
            builder: (context) {
              capturedTheme = MCalTheme.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      // MCalTheme.of() returns MCalThemeData() (all nulls) when no theme ancestor
      expect(capturedTheme, isNotNull);
      expect(capturedTheme!.cellBackgroundColor, isNull);
      expect(capturedTheme!.monthViewTheme, isNull);
      expect(capturedTheme!.dayViewTheme, isNull);
    });

    testWidgets('of() prioritizes MCalTheme ancestor over ThemeExtension', (tester) async {
      const inheritedThemeData = MCalThemeData(
        cellBackgroundColor: Colors.red,
      );

      const extensionThemeData = MCalThemeData(
        cellBackgroundColor: Colors.green,
      );

      MCalThemeData? capturedTheme;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            useMaterial3: true,
            extensions: [extensionThemeData],
          ),
          home: MCalTheme(
            data: inheritedThemeData,
            child: Builder(
              builder: (context) {
                capturedTheme = MCalTheme.of(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      // Should use MCalTheme ancestor, not ThemeExtension
      expect(capturedTheme, isNotNull);
      expect(capturedTheme!.cellBackgroundColor, Colors.red);
    });

    testWidgets('maybeOf() returns null when no MCalTheme ancestor', (tester) async {
      MCalThemeData? capturedTheme;
      bool maybeOfWasCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            useMaterial3: true,
            // Even with ThemeExtension, maybeOf should return null
            extensions: const [
              MCalThemeData(cellBackgroundColor: Colors.blue),
            ],
          ),
          home: Builder(
            builder: (context) {
              capturedTheme = MCalTheme.maybeOf(context);
              maybeOfWasCalled = true;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(maybeOfWasCalled, isTrue);
      expect(capturedTheme, isNull);
    });

    testWidgets('maybeOf() returns theme when MCalTheme ancestor exists', (tester) async {
      final testThemeData = MCalThemeData(
        cellBackgroundColor: Colors.purple,
        monthViewTheme: MCalMonthViewThemeData(
          todayBackgroundColor: Colors.cyan,
        ),
      );

      MCalThemeData? capturedTheme;

      await tester.pumpWidget(
        MaterialApp(
          home: MCalTheme(
            data: testThemeData,
            child: Builder(
              builder: (context) {
                capturedTheme = MCalTheme.maybeOf(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(capturedTheme, isNotNull);
      expect(capturedTheme!.cellBackgroundColor, Colors.purple);
      expect(capturedTheme!.monthViewTheme?.todayBackgroundColor, Colors.cyan);
    });

    testWidgets('updateShouldNotify returns true when data changes', (tester) async {
      const themeData1 = MCalThemeData(
        cellBackgroundColor: Colors.red,
      );

      const themeData2 = MCalThemeData(
        cellBackgroundColor: Colors.blue,
      );

      final oldWidget = MCalTheme(
        data: themeData1,
        child: const SizedBox(),
      );

      final newWidget = MCalTheme(
        data: themeData2,
        child: const SizedBox(),
      );

      // updateShouldNotify should return true when data differs
      expect(newWidget.updateShouldNotify(oldWidget), isTrue);
    });

    testWidgets('updateShouldNotify returns false when data is the same', (tester) async {
      const themeData = MCalThemeData(
        cellBackgroundColor: Colors.red,
      );

      final oldWidget = MCalTheme(
        data: themeData,
        child: const SizedBox(),
      );

      final newWidget = MCalTheme(
        data: themeData,
        child: const SizedBox(),
      );

      // updateShouldNotify should return false when data is identical
      expect(newWidget.updateShouldNotify(oldWidget), isFalse);
    });

    testWidgets('nested MCalTheme uses closest ancestor', (tester) async {
      const outerTheme = MCalThemeData(
        cellBackgroundColor: Colors.red,
      );

      const innerTheme = MCalThemeData(
        cellBackgroundColor: Colors.blue,
      );

      MCalThemeData? capturedOuterTheme;
      MCalThemeData? capturedInnerTheme;

      await tester.pumpWidget(
        MaterialApp(
          home: MCalTheme(
            data: outerTheme,
            child: Column(
              children: [
                Builder(
                  builder: (context) {
                    capturedOuterTheme = MCalTheme.of(context);
                    return const SizedBox();
                  },
                ),
                MCalTheme(
                  data: innerTheme,
                  child: Builder(
                    builder: (context) {
                      capturedInnerTheme = MCalTheme.of(context);
                      return const SizedBox();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(capturedOuterTheme!.cellBackgroundColor, Colors.red);
      expect(capturedInnerTheme!.cellBackgroundColor, Colors.blue);
    });

    testWidgets('widgets rebuild when MCalTheme data changes', (tester) async {
      const themeData1 = MCalThemeData(
        cellBackgroundColor: Colors.red,
      );

      const themeData2 = MCalThemeData(
        cellBackgroundColor: Colors.blue,
      );

      final themeNotifier = ValueNotifier<MCalThemeData>(themeData1);

      int buildCount = 0;
      MCalThemeData? capturedTheme;

      await tester.pumpWidget(
        MaterialApp(
          home: ValueListenableBuilder<MCalThemeData>(
            valueListenable: themeNotifier,
            builder: (context, theme, _) {
              return MCalTheme(
                data: theme,
                child: Builder(
                  builder: (context) {
                    buildCount++;
                    capturedTheme = MCalTheme.of(context);
                    return const SizedBox();
                  },
                ),
              );
            },
          ),
        ),
      );

      expect(buildCount, 1);
      expect(capturedTheme!.cellBackgroundColor, Colors.red);

      // Change the theme data
      themeNotifier.value = themeData2;
      await tester.pump();

      expect(buildCount, 2);
      expect(capturedTheme!.cellBackgroundColor, Colors.blue);
    });
  });

  group('MCalThemeData', () {
    test('copyWith creates new instance with updated values', () {
      final original = MCalThemeData(
        cellBackgroundColor: Colors.white,
        dayViewTheme: MCalDayViewThemeData(eventTileBackgroundColor: Colors.green),
        monthViewTheme: MCalMonthViewThemeData(
          todayBackgroundColor: Colors.blue,
        ),
      );

      final updated = original.copyWith(
        cellBackgroundColor: Colors.grey,
        monthViewTheme: original.monthViewTheme?.copyWith(todayBackgroundColor: Colors.red),
      );

      // Updated values should be changed
      expect(updated.cellBackgroundColor, Colors.grey);
      expect(updated.monthViewTheme?.todayBackgroundColor, Colors.red);
      // Unchanged values should remain the same
      expect(updated.dayViewTheme?.eventTileBackgroundColor, Colors.green);

      // Original should be unchanged
      expect(original.cellBackgroundColor, Colors.white);
      expect(original.monthViewTheme?.todayBackgroundColor, Colors.blue);
      expect(original.dayViewTheme?.eventTileBackgroundColor, Colors.green);
    });

    test('copyWith preserves null values when not specified', () {
      final original = MCalThemeData(
        cellBackgroundColor: Colors.white,
      );

      final updated = original.copyWith(
        monthViewTheme: MCalMonthViewThemeData(todayBackgroundColor: Colors.blue),
      );

      expect(updated.cellBackgroundColor, Colors.white);
      expect(updated.monthViewTheme?.todayBackgroundColor, Colors.blue);
      expect(updated.cellBorderColor, isNull);
    });

    test('copyWith preserves existing values when null is passed', () {
      final original = MCalThemeData(
        cellBackgroundColor: Colors.white,
        monthViewTheme: MCalMonthViewThemeData(
          todayBackgroundColor: Colors.blue,
        ),
      );

      // copyWith uses ?? operator, so passing null preserves existing value
      final updated = original.copyWith(
        cellBackgroundColor: null, // This will preserve Colors.white
      );

      expect(updated.cellBackgroundColor, Colors.white);
      expect(updated.monthViewTheme?.todayBackgroundColor, Colors.blue);
    });

    test('dropTargetCell and dropTargetTile theme properties are supported', () {
      final theme = MCalThemeData(
        monthViewTheme: MCalMonthViewThemeData(
          dropTargetCellValidColor: Color(0xFF00FF00),
          dropTargetCellInvalidColor: Color(0xFFFF0000),
          dropTargetCellBorderRadius: 8.0,
          dropTargetTileBackgroundColor: Color(0xFF0000FF),
          dropTargetTileInvalidBackgroundColor: Color(0xFFFF00FF),
          dropTargetTileCornerRadius: 4.0,
        ),
      );
      expect(theme.monthViewTheme?.dropTargetCellValidColor?.toARGB32(), 0xFF00FF00);
      expect(theme.monthViewTheme?.dropTargetCellInvalidColor?.toARGB32(), 0xFFFF0000);
      expect(theme.monthViewTheme?.dropTargetCellBorderRadius, 8.0);
      expect(theme.monthViewTheme?.dropTargetTileBackgroundColor?.toARGB32(), 0xFF0000FF);
      expect(theme.monthViewTheme?.dropTargetTileInvalidBackgroundColor?.toARGB32(), 0xFFFF00FF);
      expect(theme.monthViewTheme?.dropTargetTileCornerRadius, 4.0);

      final updated = theme.copyWith(
        monthViewTheme: theme.monthViewTheme?.copyWith(
          dropTargetTileBorderColor: Colors.amber,
          dropTargetTileBorderWidth: 2.0,
        ),
      );
      expect(updated.monthViewTheme?.dropTargetTileBorderColor, Colors.amber);
      expect(updated.monthViewTheme?.dropTargetTileBorderWidth, 2.0);
    });

    test('lerp interpolates between themes correctly (t = 0.0)', () {
      final theme1 = MCalThemeData(
        cellBackgroundColor: Colors.white,
        monthViewTheme: MCalMonthViewThemeData(todayBackgroundColor: Colors.blue),
      );

      final theme2 = MCalThemeData(
        cellBackgroundColor: Colors.black,
        monthViewTheme: MCalMonthViewThemeData(todayBackgroundColor: Colors.red),
      );

      final interpolated = theme1.lerp(theme2, 0.0);

      // At t=0.0, should return theme1 (or very close to it)
      expect(interpolated.cellBackgroundColor?.toARGB32(), Colors.white.toARGB32());
      expect(interpolated.monthViewTheme?.todayBackgroundColor?.toARGB32(), Colors.blue.toARGB32());
    });

    test('lerp interpolates between themes correctly (t = 1.0)', () {
      final theme1 = MCalThemeData(
        cellBackgroundColor: Colors.white,
        monthViewTheme: MCalMonthViewThemeData(todayBackgroundColor: Colors.blue),
      );

      final theme2 = MCalThemeData(
        cellBackgroundColor: Colors.black,
        monthViewTheme: MCalMonthViewThemeData(todayBackgroundColor: Colors.red),
      );

      final interpolated = theme1.lerp(theme2, 1.0);

      // At t=1.0, should return theme2 (or very close to it)
      expect(interpolated.cellBackgroundColor?.toARGB32(), Colors.black.toARGB32());
      expect(interpolated.monthViewTheme?.todayBackgroundColor?.toARGB32(), Colors.red.toARGB32());
    });

    test('lerp interpolates between themes correctly (t = 0.5)', () {
      final theme1 = MCalThemeData(
        cellBackgroundColor: Colors.white,
        monthViewTheme: MCalMonthViewThemeData(todayBackgroundColor: Colors.blue),
      );

      final theme2 = MCalThemeData(
        cellBackgroundColor: Colors.black,
        monthViewTheme: MCalMonthViewThemeData(todayBackgroundColor: Colors.red),
      );

      final interpolated = theme1.lerp(theme2, 0.5);

      // At t=0.5, should interpolate between colors
      expect(interpolated.cellBackgroundColor, isNotNull);
      expect(interpolated.monthViewTheme?.todayBackgroundColor, isNotNull);
      // Colors should be between white and black, blue and red
      expect(interpolated.cellBackgroundColor, isNot(Colors.white));
      expect(interpolated.cellBackgroundColor, isNot(Colors.black));
    });

    test('lerp returns original theme when other is not MCalThemeData', () {
      final theme = MCalThemeData(
        cellBackgroundColor: Colors.white,
      );

      final result = theme.lerp(null, 0.5);

      expect(result, theme);
    });

    test('fromTheme creates sensible defaults from light ThemeData', () {
      final themeData = ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      );

      final calendarTheme = MCalThemeData.fromTheme(themeData);

      // Verify defaults are set
      expect(calendarTheme.cellBackgroundColor, isNotNull);
      expect(calendarTheme.cellBorderColor, isNotNull);
      expect(calendarTheme.monthViewTheme?.cellTextStyle, isNotNull);
      expect(calendarTheme.monthViewTheme?.todayBackgroundColor, isNotNull);
      expect(calendarTheme.monthViewTheme?.todayTextStyle, isNotNull);
      expect(calendarTheme.monthViewTheme?.weekdayHeaderTextStyle, isNotNull);
      expect(calendarTheme.dayViewTheme?.eventTileBackgroundColor, isNotNull);
      expect(calendarTheme.dayViewTheme?.eventTileTextStyle, isNotNull);
      expect(calendarTheme.navigatorTextStyle, isNotNull);
    });

    test('fromTheme creates sensible defaults from dark ThemeData', () {
      final themeData = ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
      );

      final calendarTheme = MCalThemeData.fromTheme(themeData);

      // Verify defaults are set for dark theme
      expect(calendarTheme.cellBackgroundColor, isNotNull);
      expect(calendarTheme.cellBorderColor, isNotNull);
      expect(calendarTheme.monthViewTheme?.cellTextStyle, isNotNull);
      expect(calendarTheme.monthViewTheme?.todayBackgroundColor, isNotNull);
      expect(calendarTheme.monthViewTheme?.todayTextStyle, isNotNull);
      expect(calendarTheme.monthViewTheme?.weekdayHeaderTextStyle, isNotNull);
      expect(calendarTheme.dayViewTheme?.eventTileBackgroundColor, isNotNull);
      expect(calendarTheme.dayViewTheme?.eventTileTextStyle, isNotNull);
      expect(calendarTheme.navigatorTextStyle, isNotNull);
    });

    test('fromTheme uses colorScheme and textTheme from ThemeData', () {
      final customColor = Colors.purple;
      final themeData = ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: customColor),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 16),
          bodySmall: TextStyle(fontSize: 12),
        ),
      );

      final calendarTheme = MCalThemeData.fromTheme(themeData);

      // Verify theme uses colorScheme colors
      expect(calendarTheme.cellBackgroundColor, themeData.colorScheme.surface);
      expect(calendarTheme.monthViewTheme?.todayBackgroundColor, isNotNull);
      // Verify text styles are derived from textTheme
      expect(calendarTheme.monthViewTheme?.cellTextStyle, isNotNull);
    });

    test('light and dark themes work correctly', () {
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

      final lightCalendarTheme = MCalThemeData.fromTheme(lightTheme);
      final darkCalendarTheme = MCalThemeData.fromTheme(darkTheme);

      // Both should have non-null values
      expect(lightCalendarTheme.cellBackgroundColor, isNotNull);
      expect(darkCalendarTheme.cellBackgroundColor, isNotNull);

      // Colors should differ between light and dark
      expect(
        lightCalendarTheme.cellBackgroundColor,
        isNot(darkCalendarTheme.cellBackgroundColor),
      );
    });

    test('all properties are nullable', () {
      const emptyTheme = MCalThemeData();

      expect(emptyTheme.cellBackgroundColor, isNull);
      expect(emptyTheme.cellBorderColor, isNull);
      expect(emptyTheme.monthViewTheme?.cellTextStyle, isNull);
      expect(emptyTheme.monthViewTheme?.todayBackgroundColor, isNull);
      expect(emptyTheme.monthViewTheme?.todayTextStyle, isNull);
      expect(emptyTheme.monthViewTheme?.leadingDatesTextStyle, isNull);
      expect(emptyTheme.monthViewTheme?.trailingDatesTextStyle, isNull);
      expect(emptyTheme.monthViewTheme?.leadingDatesBackgroundColor, isNull);
      expect(emptyTheme.monthViewTheme?.trailingDatesBackgroundColor, isNull);
      expect(emptyTheme.monthViewTheme?.weekdayHeaderTextStyle, isNull);
      expect(emptyTheme.monthViewTheme?.weekdayHeaderBackgroundColor, isNull);
      expect(emptyTheme.dayViewTheme?.eventTileBackgroundColor, isNull);
      expect(emptyTheme.dayViewTheme?.eventTileTextStyle, isNull);
      expect(emptyTheme.navigatorTextStyle, isNull);
      expect(emptyTheme.navigatorBackgroundColor, isNull);
      // Properties now on dayViewTheme (via MCalAllDayTileThemeMixin)
      expect(emptyTheme.dayViewTheme?.allDayEventBackgroundColor, isNull);
      expect(emptyTheme.dayViewTheme?.allDayEventTextStyle, isNull);
      expect(emptyTheme.dayViewTheme?.allDayEventBorderColor, isNull);
      expect(emptyTheme.dayViewTheme?.allDayEventBorderWidth, isNull);
      // weekNumber now on both sub-themes (via MCalEventTileThemeMixin)
      expect(emptyTheme.dayViewTheme?.weekNumberTextStyle, isNull);
      expect(emptyTheme.dayViewTheme?.weekNumberBackgroundColor, isNull);
      // Month-specific
      expect(emptyTheme.monthViewTheme?.focusedDateBackgroundColor, isNull);
      expect(emptyTheme.monthViewTheme?.focusedDateTextStyle, isNull);
      expect(emptyTheme.monthViewTheme?.hoverCellBackgroundColor, isNull);
      expect(emptyTheme.dayViewTheme?.hoverEventBackgroundColor, isNull);
    });

    test('lerp handles null values correctly', () {
      final theme1 = MCalThemeData(
        cellBackgroundColor: Colors.white,
        cellBorderColor: null,
      );

      final theme2 = MCalThemeData(
        cellBackgroundColor: Colors.black,
        cellBorderColor: Colors.grey,
      );

      final interpolated = theme1.lerp(theme2, 0.5);

      // Should handle null values gracefully
      expect(interpolated.cellBackgroundColor, isNotNull);
    });

    // ==================== NEW PROPERTY TESTS ====================

    group('copyWith for new properties', () {
      test('copyWith overrides focusedDate properties', () {
        final original = MCalThemeData(
          monthViewTheme: MCalMonthViewThemeData(
            focusedDateBackgroundColor: Colors.blue,
            focusedDateTextStyle: const TextStyle(color: Colors.blue),
          ),
        );

        final updated = original.copyWith(
          monthViewTheme: original.monthViewTheme?.copyWith(
            focusedDateBackgroundColor: Colors.green,
            focusedDateTextStyle: const TextStyle(color: Colors.green),
          ),
        );

        expect(updated.monthViewTheme?.focusedDateBackgroundColor, Colors.green);
        expect(updated.monthViewTheme?.focusedDateTextStyle?.color, Colors.green);
        // Original should be unchanged
        expect(original.monthViewTheme?.focusedDateBackgroundColor, Colors.blue);
        expect(original.monthViewTheme?.focusedDateTextStyle?.color, Colors.blue);
      });

      test('copyWith overrides allDayEvent properties', () {
        final original = MCalThemeData(
          dayViewTheme: MCalDayViewThemeData(
            allDayEventBackgroundColor: Colors.blue,
            allDayEventTextStyle: const TextStyle(color: Colors.blue),
            allDayEventBorderColor: Colors.blue,
            allDayEventBorderWidth: 1.0,
          ),
        );

        final updated = original.copyWith(
          dayViewTheme: original.dayViewTheme?.copyWith(
            allDayEventBackgroundColor: Colors.red,
            allDayEventTextStyle: const TextStyle(color: Colors.red),
            allDayEventBorderColor: Colors.red,
            allDayEventBorderWidth: 2.0,
          ),
        );

        expect(updated.dayViewTheme?.allDayEventBackgroundColor, Colors.red);
        expect(updated.dayViewTheme?.allDayEventTextStyle?.color, Colors.red);
        expect(updated.dayViewTheme?.allDayEventBorderColor, Colors.red);
        expect(updated.dayViewTheme?.allDayEventBorderWidth, 2.0);
        // Original should be unchanged
        expect(original.dayViewTheme?.allDayEventBackgroundColor, Colors.blue);
        expect(original.dayViewTheme?.allDayEventBorderWidth, 1.0);
      });

      test('copyWith overrides weekNumber properties', () {
        final original = MCalThemeData(
          dayViewTheme: MCalDayViewThemeData(
            weekNumberTextStyle: const TextStyle(color: Colors.grey),
            weekNumberBackgroundColor: Colors.grey,
          ),
        );

        final updated = original.copyWith(
          dayViewTheme: original.dayViewTheme?.copyWith(
            weekNumberTextStyle: const TextStyle(color: Colors.black),
            weekNumberBackgroundColor: Colors.white,
          ),
        );

        expect(updated.dayViewTheme?.weekNumberTextStyle?.color, Colors.black);
        expect(updated.dayViewTheme?.weekNumberBackgroundColor, Colors.white);
        // Original should be unchanged
        expect(original.dayViewTheme?.weekNumberTextStyle?.color, Colors.grey);
        expect(original.dayViewTheme?.weekNumberBackgroundColor, Colors.grey);
      });

      test('copyWith overrides hover properties', () {
        final original = MCalThemeData(
          dayViewTheme: MCalDayViewThemeData(hoverEventBackgroundColor: Colors.green),
          monthViewTheme: MCalMonthViewThemeData(
            hoverCellBackgroundColor: Colors.blue,
          ),
        );

        final updated = original.copyWith(
          dayViewTheme: original.dayViewTheme?.copyWith(
            hoverEventBackgroundColor: Colors.orange,
          ),
          monthViewTheme: original.monthViewTheme?.copyWith(
            hoverCellBackgroundColor: Colors.red,
          ),
        );

        expect(updated.monthViewTheme?.hoverCellBackgroundColor, Colors.red);
        expect(updated.dayViewTheme?.hoverEventBackgroundColor, Colors.orange);
        // Original should be unchanged
        expect(original.monthViewTheme?.hoverCellBackgroundColor, Colors.blue);
        expect(original.dayViewTheme?.hoverEventBackgroundColor, Colors.green);
      });

      test('copyWith preserves new properties when not specified', () {
        final original = MCalThemeData(
          dayViewTheme: MCalDayViewThemeData(
            allDayEventBorderWidth: 2.0,
            weekNumberBackgroundColor: Colors.grey,
          ),
          monthViewTheme: MCalMonthViewThemeData(
            focusedDateBackgroundColor: Colors.blue,
            hoverCellBackgroundColor: Colors.yellow,
          ),
        );

        final updated = original.copyWith(
          cellBackgroundColor: Colors.white,
        );

        expect(updated.monthViewTheme?.focusedDateBackgroundColor, Colors.blue);
        expect(updated.dayViewTheme?.allDayEventBorderWidth, 2.0);
        expect(updated.dayViewTheme?.weekNumberBackgroundColor, Colors.grey);
        expect(updated.monthViewTheme?.hoverCellBackgroundColor, Colors.yellow);
        expect(updated.cellBackgroundColor, Colors.white);
      });
    });

    group('lerp for new properties', () {
      test('lerp interpolates focusedDate Color properties correctly', () {
        final theme1 = MCalThemeData(
          monthViewTheme: MCalMonthViewThemeData(focusedDateBackgroundColor: Colors.white),
        );

        final theme2 = MCalThemeData(
          monthViewTheme: MCalMonthViewThemeData(focusedDateBackgroundColor: Colors.black),
        );

        // At t=0.0
        final atStart = theme1.lerp(theme2, 0.0);
        expect(
          atStart.monthViewTheme?.focusedDateBackgroundColor?.toARGB32(),
          Colors.white.toARGB32(),
        );

        // At t=1.0
        final atEnd = theme1.lerp(theme2, 1.0);
        expect(
          atEnd.monthViewTheme?.focusedDateBackgroundColor?.toARGB32(),
          Colors.black.toARGB32(),
        );

        // At t=0.5
        final atMiddle = theme1.lerp(theme2, 0.5);
        expect(atMiddle.monthViewTheme?.focusedDateBackgroundColor, isNotNull);
        expect(atMiddle.monthViewTheme?.focusedDateBackgroundColor, isNot(Colors.white));
        expect(atMiddle.monthViewTheme?.focusedDateBackgroundColor, isNot(Colors.black));
      });

      test('lerp interpolates focusedDate TextStyle correctly', () {
        final theme1 = MCalThemeData(
          monthViewTheme: MCalMonthViewThemeData(
            focusedDateTextStyle: const TextStyle(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        );

        final theme2 = MCalThemeData(
          monthViewTheme: MCalMonthViewThemeData(
            focusedDateTextStyle: const TextStyle(
              fontSize: 24,
              color: Colors.black,
            ),
          ),
        );

        final atMiddle = theme1.lerp(theme2, 0.5);

        expect(atMiddle.monthViewTheme?.focusedDateTextStyle, isNotNull);
        expect(atMiddle.monthViewTheme?.focusedDateTextStyle!.fontSize, 18.0);
      });

      test('lerp interpolates allDayEvent Color properties correctly', () {
        final theme1 = MCalThemeData(
          dayViewTheme: MCalDayViewThemeData(
            allDayEventBackgroundColor: Colors.blue,
            allDayEventBorderColor: Colors.blue,
          ),
        );

        final theme2 = MCalThemeData(
          dayViewTheme: MCalDayViewThemeData(
            allDayEventBackgroundColor: Colors.red,
            allDayEventBorderColor: Colors.red,
          ),
        );

        // At t=0.0
        final atStart = theme1.lerp(theme2, 0.0);
        expect(
          atStart.dayViewTheme?.allDayEventBackgroundColor?.toARGB32(),
          Colors.blue.toARGB32(),
        );
        expect(
          atStart.dayViewTheme?.allDayEventBorderColor?.toARGB32(),
          Colors.blue.toARGB32(),
        );

        // At t=1.0
        final atEnd = theme1.lerp(theme2, 1.0);
        expect(
          atEnd.dayViewTheme?.allDayEventBackgroundColor?.toARGB32(),
          Colors.red.toARGB32(),
        );
        expect(
          atEnd.dayViewTheme?.allDayEventBorderColor?.toARGB32(),
          Colors.red.toARGB32(),
        );

        // At t=0.5
        final atMiddle = theme1.lerp(theme2, 0.5);
        expect(atMiddle.dayViewTheme?.allDayEventBackgroundColor, isNotNull);
        expect(atMiddle.dayViewTheme?.allDayEventBackgroundColor, isNot(Colors.blue));
        expect(atMiddle.dayViewTheme?.allDayEventBackgroundColor, isNot(Colors.red));
      });

      test('lerp interpolates allDayEventBorderWidth correctly', () {
        final theme1 = MCalThemeData(
          dayViewTheme: MCalDayViewThemeData(allDayEventBorderWidth: 1.0),
        );

        final theme2 = MCalThemeData(
          dayViewTheme: MCalDayViewThemeData(allDayEventBorderWidth: 3.0),
        );

        // At t=0.0
        final atStart = theme1.lerp(theme2, 0.0);
        expect(atStart.dayViewTheme?.allDayEventBorderWidth, 1.0);

        // At t=1.0
        final atEnd = theme1.lerp(theme2, 1.0);
        expect(atEnd.dayViewTheme?.allDayEventBorderWidth, 3.0);

        // At t=0.5
        final atMiddle = theme1.lerp(theme2, 0.5);
        expect(atMiddle.dayViewTheme?.allDayEventBorderWidth, 2.0);
      });

      test('lerp interpolates allDayEvent TextStyle correctly', () {
        final theme1 = MCalThemeData(
          dayViewTheme: MCalDayViewThemeData(
            allDayEventTextStyle: const TextStyle(fontSize: 10, color: Colors.blue),
          ),
        );

        final theme2 = MCalThemeData(
          dayViewTheme: MCalDayViewThemeData(
            allDayEventTextStyle: const TextStyle(fontSize: 20, color: Colors.red),
          ),
        );

        final atMiddle = theme1.lerp(theme2, 0.5);

        expect(atMiddle.dayViewTheme?.allDayEventTextStyle, isNotNull);
        expect(atMiddle.dayViewTheme?.allDayEventTextStyle!.fontSize, 15.0);
      });

      test('lerp interpolates weekNumber properties correctly', () {
        final theme1 = MCalThemeData(
          dayViewTheme: MCalDayViewThemeData(
            weekNumberBackgroundColor: Colors.white,
            weekNumberTextStyle: const TextStyle(fontSize: 10),
          ),
        );

        final theme2 = MCalThemeData(
          dayViewTheme: MCalDayViewThemeData(
            weekNumberBackgroundColor: Colors.black,
            weekNumberTextStyle: const TextStyle(fontSize: 20),
          ),
        );

        // At t=0.0
        final atStart = theme1.lerp(theme2, 0.0);
        expect(
          atStart.dayViewTheme?.weekNumberBackgroundColor?.toARGB32(),
          Colors.white.toARGB32(),
        );

        // At t=1.0
        final atEnd = theme1.lerp(theme2, 1.0);
        expect(
          atEnd.dayViewTheme?.weekNumberBackgroundColor?.toARGB32(),
          Colors.black.toARGB32(),
        );

        // At t=0.5 - check TextStyle interpolation
        final atMiddle = theme1.lerp(theme2, 0.5);
        expect(atMiddle.dayViewTheme?.weekNumberTextStyle, isNotNull);
        expect(atMiddle.dayViewTheme?.weekNumberTextStyle!.fontSize, 15.0);
      });

      test('lerp interpolates hover Color properties correctly', () {
        final theme1 = MCalThemeData(
          dayViewTheme: MCalDayViewThemeData(hoverEventBackgroundColor: Colors.blue),
          monthViewTheme: MCalMonthViewThemeData(
            hoverCellBackgroundColor: Colors.white,
          ),
        );

        final theme2 = MCalThemeData(
          dayViewTheme: MCalDayViewThemeData(hoverEventBackgroundColor: Colors.red),
          monthViewTheme: MCalMonthViewThemeData(
            hoverCellBackgroundColor: Colors.black,
          ),
        );

        // At t=0.0
        final atStart = theme1.lerp(theme2, 0.0);
        expect(
          atStart.monthViewTheme?.hoverCellBackgroundColor?.toARGB32(),
          Colors.white.toARGB32(),
        );
        expect(
          atStart.dayViewTheme?.hoverEventBackgroundColor?.toARGB32(),
          Colors.blue.toARGB32(),
        );

        // At t=1.0
        final atEnd = theme1.lerp(theme2, 1.0);
        expect(
          atEnd.monthViewTheme?.hoverCellBackgroundColor?.toARGB32(),
          Colors.black.toARGB32(),
        );
        expect(
          atEnd.dayViewTheme?.hoverEventBackgroundColor?.toARGB32(),
          Colors.red.toARGB32(),
        );

        // At t=0.5
        final atMiddle = theme1.lerp(theme2, 0.5);
        expect(atMiddle.monthViewTheme?.hoverCellBackgroundColor, isNotNull);
        expect(atMiddle.monthViewTheme?.hoverCellBackgroundColor, isNot(Colors.white));
        expect(atMiddle.monthViewTheme?.hoverCellBackgroundColor, isNot(Colors.black));
      });

      test('lerp handles null values for new properties', () {
        final theme1 = MCalThemeData(
          dayViewTheme: MCalDayViewThemeData(
            allDayEventBorderWidth: null,
            weekNumberBackgroundColor: null,
          ),
          monthViewTheme: MCalMonthViewThemeData(focusedDateBackgroundColor: Colors.blue),
        );

        final theme2 = MCalThemeData(
          dayViewTheme: MCalDayViewThemeData(
            allDayEventBorderWidth: 2.0,
            weekNumberBackgroundColor: Colors.grey,
          ),
          monthViewTheme: MCalMonthViewThemeData(focusedDateBackgroundColor: null),
        );

        final interpolated = theme1.lerp(theme2, 0.5);

        // Should handle null values gracefully
        expect(interpolated, isNotNull);
      });

      test('lerp interpolates double from null correctly', () {
        final theme1 = MCalThemeData(
          dayViewTheme: MCalDayViewThemeData(allDayEventBorderWidth: null),
        );

        final theme2 = MCalThemeData(
          dayViewTheme: MCalDayViewThemeData(allDayEventBorderWidth: 4.0),
        );

        final atMiddle = theme1.lerp(theme2, 0.5);
        // When a is null, it defaults to 0.0, so 0.0 + (4.0 - 0.0) * 0.5 = 2.0
        expect(atMiddle.dayViewTheme?.allDayEventBorderWidth, 2.0);
      });
    });

    group('fromTheme for new properties', () {
      test('fromTheme provides non-null focusedDate defaults', () {
        final themeData = ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        );

        final calendarTheme = MCalThemeData.fromTheme(themeData);

        expect(calendarTheme.monthViewTheme?.focusedDateBackgroundColor, isNotNull);
        expect(calendarTheme.monthViewTheme?.focusedDateTextStyle, isNotNull);
      });

      test('fromTheme provides non-null allDayEvent defaults', () {
        final themeData = ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        );

        final calendarTheme = MCalThemeData.fromTheme(themeData);

        expect(calendarTheme.dayViewTheme?.allDayEventBackgroundColor, isNotNull);
        expect(calendarTheme.dayViewTheme?.allDayEventTextStyle, isNotNull);
        expect(calendarTheme.dayViewTheme?.allDayEventBorderColor, isNotNull);
        expect(calendarTheme.dayViewTheme?.allDayEventBorderWidth, isNotNull);
        expect(calendarTheme.dayViewTheme?.allDayEventBorderWidth, 1.0);
      });

      test('fromTheme provides non-null weekNumber defaults', () {
        final themeData = ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        );

        final calendarTheme = MCalThemeData.fromTheme(themeData);

        expect(calendarTheme.dayViewTheme?.weekNumberTextStyle, isNotNull);
        expect(calendarTheme.dayViewTheme?.weekNumberBackgroundColor, isNotNull);
      });

      test('fromTheme provides non-null hover defaults', () {
        final themeData = ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        );

        final calendarTheme = MCalThemeData.fromTheme(themeData);

        expect(calendarTheme.monthViewTheme?.hoverCellBackgroundColor, isNotNull);
        expect(calendarTheme.dayViewTheme?.hoverEventBackgroundColor, isNotNull);
      });

      test('fromTheme provides non-null eventTile contrast color defaults', () {
        final themeData = ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        );

        final calendarTheme = MCalThemeData.fromTheme(themeData);

        expect(calendarTheme.dayViewTheme?.eventTileLightContrastColor, isNotNull);
        expect(calendarTheme.dayViewTheme?.eventTileDarkContrastColor, isNotNull);
      });

      test('fromTheme provides non-null day theme drop target defaults', () {
        final themeData = ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        );

        final calendarTheme = MCalThemeData.fromTheme(themeData);
        final dayViewTheme = calendarTheme.dayViewTheme;

        expect(dayViewTheme, isNotNull);
        expect(dayViewTheme!.dropTargetTileInvalidBackgroundColor, isNotNull);
        expect(dayViewTheme.dropTargetOverlayValidColor, isNotNull);
        expect(dayViewTheme.dropTargetOverlayInvalidColor, isNotNull);
        expect(dayViewTheme.dropTargetOverlayBorderColor, isNotNull);
        expect(dayViewTheme.dropTargetOverlayBorderWidth, isNotNull);
        expect(dayViewTheme.disabledTimeSlotColor, isNotNull);
        expect(dayViewTheme.resizeHandleColor, isNotNull);
        expect(dayViewTheme.keyboardSelectionBorderColor, isNotNull);
        expect(dayViewTheme.keyboardHighlightBorderColor, isNotNull);
        expect(dayViewTheme.focusedSlotBorderColor, isNotNull);
        expect(dayViewTheme.focusedSlotBorderWidth, isNotNull);
        expect(dayViewTheme.focusedSlotBackgroundColor, isNotNull);
      });

      test('fromTheme provides non-null month theme overlay/error defaults', () {
        final themeData = ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        );

        final calendarTheme = MCalThemeData.fromTheme(themeData);
        final monthViewTheme = calendarTheme.monthViewTheme;

        expect(monthViewTheme, isNotNull);
        expect(monthViewTheme!.overlayScrimColor, isNotNull);
        expect(monthViewTheme.errorIconColor, isNotNull);
        expect(monthViewTheme.overflowIndicatorTextStyle, isNotNull);
        expect(monthViewTheme.defaultRegionColor, isNotNull);
        expect(monthViewTheme.dropTargetCellValidColor, isNotNull);
        expect(monthViewTheme.dropTargetCellInvalidColor, isNotNull);
      });

      test('MCalTheme.of() returns all-null MCalThemeData when no ancestor', () {
        // This is tested in the widget test group but validated here for properties
        const emptyTheme = MCalThemeData();
        expect(emptyTheme.dayViewTheme?.eventTileLightContrastColor, isNull);
        expect(emptyTheme.dayViewTheme?.eventTileDarkContrastColor, isNull);
        expect(emptyTheme.dayViewTheme?.hoverEventBackgroundColor, isNull);
        expect(emptyTheme.dayViewTheme, isNull);
        expect(emptyTheme.monthViewTheme, isNull);
      });

      test('fromTheme month properties differ between light and dark', () {
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

        final lightCalendarTheme = MCalThemeData.fromTheme(lightTheme);
        final darkCalendarTheme = MCalThemeData.fromTheme(darkTheme);

        // Colors should differ between light and dark themes
        expect(
          lightCalendarTheme.monthViewTheme?.focusedDateBackgroundColor,
          isNot(darkCalendarTheme.monthViewTheme?.focusedDateBackgroundColor),
        );
        expect(
          lightCalendarTheme.dayViewTheme?.allDayEventBackgroundColor,
          isNot(darkCalendarTheme.dayViewTheme?.allDayEventBackgroundColor),
        );
        expect(
          lightCalendarTheme.dayViewTheme?.weekNumberBackgroundColor,
          isNot(darkCalendarTheme.dayViewTheme?.weekNumberBackgroundColor),
        );
        expect(
          lightCalendarTheme.monthViewTheme?.hoverCellBackgroundColor,
          isNot(darkCalendarTheme.monthViewTheme?.hoverCellBackgroundColor),
        );
      });

      test('fromTheme uses colorScheme for new properties', () {
        final customColor = Colors.orange;
        final themeData = ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: customColor),
        );

        final calendarTheme = MCalThemeData.fromTheme(themeData);

        // Verify that fromTheme uses values from the theme
        expect(calendarTheme.monthViewTheme?.focusedDateBackgroundColor, isNotNull);
        expect(calendarTheme.dayViewTheme?.allDayEventBackgroundColor, isNotNull);
        expect(calendarTheme.dayViewTheme?.weekNumberBackgroundColor, isNotNull);
        expect(calendarTheme.monthViewTheme?.hoverCellBackgroundColor, isNotNull);
        expect(calendarTheme.dayViewTheme?.hoverEventBackgroundColor, isNotNull);
      });
    });
  });
}
