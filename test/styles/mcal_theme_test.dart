import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multi_calendar/multi_calendar.dart';

void main() {
  group('MCalTheme InheritedWidget', () {
    testWidgets('of() with MCalTheme ancestor returns the theme data from the ancestor', (tester) async {
      final testThemeData = MCalThemeData(
        cellBackgroundColor: Colors.red,
        monthTheme: MCalMonthThemeData(
          cellBackgroundColor: Colors.red,
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
      expect(capturedTheme!.monthTheme?.todayBackgroundColor, Colors.blue);
    });

    testWidgets('of() fallback to ThemeExtension when no MCalTheme ancestor', (tester) async {
      final extensionThemeData = MCalThemeData(
        cellBackgroundColor: Colors.green,
        monthTheme: MCalMonthThemeData(
          cellBackgroundColor: Colors.green,
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
      expect(capturedTheme!.monthTheme?.todayBackgroundColor, Colors.orange);
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

      // fromTheme() should provide non-null defaults
      expect(capturedTheme, isNotNull);
      expect(capturedTheme!.cellBackgroundColor, isNotNull);
      expect(capturedTheme!.monthTheme?.todayBackgroundColor, isNotNull);
      expect(capturedTheme!.monthTheme?.cellTextStyle, isNotNull);
      expect(capturedTheme!.eventTileBackgroundColor, isNotNull);
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
        monthTheme: MCalMonthThemeData(
          cellBackgroundColor: Colors.purple,
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
      expect(capturedTheme!.monthTheme?.todayBackgroundColor, Colors.cyan);
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
        eventTileBackgroundColor: Colors.green,
        monthTheme: MCalMonthThemeData(
          cellBackgroundColor: Colors.white,
          todayBackgroundColor: Colors.blue,
        ),
      );

      final updated = original.copyWith(
        cellBackgroundColor: Colors.grey,
        monthTheme: original.monthTheme?.copyWith(todayBackgroundColor: Colors.red),
      );

      // Updated values should be changed
      expect(updated.cellBackgroundColor, Colors.grey);
      expect(updated.monthTheme?.todayBackgroundColor, Colors.red);
      // Unchanged values should remain the same
      expect(updated.eventTileBackgroundColor, Colors.green);

      // Original should be unchanged
      expect(original.cellBackgroundColor, Colors.white);
      expect(original.monthTheme?.todayBackgroundColor, Colors.blue);
      expect(original.eventTileBackgroundColor, Colors.green);
    });

    test('copyWith preserves null values when not specified', () {
      final original = MCalThemeData(
        cellBackgroundColor: Colors.white,
      );

      final updated = original.copyWith(
        monthTheme: MCalMonthThemeData(todayBackgroundColor: Colors.blue),
      );

      expect(updated.cellBackgroundColor, Colors.white);
      expect(updated.monthTheme?.todayBackgroundColor, Colors.blue);
      expect(updated.cellBorderColor, isNull);
    });

    test('copyWith preserves existing values when null is passed', () {
      final original = MCalThemeData(
        cellBackgroundColor: Colors.white,
        monthTheme: MCalMonthThemeData(
          cellBackgroundColor: Colors.white,
          todayBackgroundColor: Colors.blue,
        ),
      );

      // copyWith uses ?? operator, so passing null preserves existing value
      final updated = original.copyWith(
        cellBackgroundColor: null, // This will preserve Colors.white
      );

      expect(updated.cellBackgroundColor, Colors.white);
      expect(updated.monthTheme?.todayBackgroundColor, Colors.blue);
    });

    test('dropTargetCell and dropTargetTile theme properties are supported', () {
      final theme = MCalThemeData(
        monthTheme: MCalMonthThemeData(
          dropTargetCellValidColor: Color(0xFF00FF00),
          dropTargetCellInvalidColor: Color(0xFFFF0000),
          dropTargetCellBorderRadius: 8.0,
          dropTargetTileBackgroundColor: Color(0xFF0000FF),
          dropTargetTileInvalidBackgroundColor: Color(0xFFFF00FF),
          dropTargetTileCornerRadius: 4.0,
        ),
      );
      expect(theme.monthTheme?.dropTargetCellValidColor?.toARGB32(), 0xFF00FF00);
      expect(theme.monthTheme?.dropTargetCellInvalidColor?.toARGB32(), 0xFFFF0000);
      expect(theme.monthTheme?.dropTargetCellBorderRadius, 8.0);
      expect(theme.monthTheme?.dropTargetTileBackgroundColor?.toARGB32(), 0xFF0000FF);
      expect(theme.monthTheme?.dropTargetTileInvalidBackgroundColor?.toARGB32(), 0xFFFF00FF);
      expect(theme.monthTheme?.dropTargetTileCornerRadius, 4.0);

      final updated = theme.copyWith(
        monthTheme: theme.monthTheme?.copyWith(
          dropTargetTileBorderColor: Colors.amber,
          dropTargetTileBorderWidth: 2.0,
        ),
      );
      expect(updated.monthTheme?.dropTargetTileBorderColor, Colors.amber);
      expect(updated.monthTheme?.dropTargetTileBorderWidth, 2.0);
    });

    test('lerp interpolates between themes correctly (t = 0.0)', () {
      final theme1 = MCalThemeData(
        cellBackgroundColor: Colors.white,
        monthTheme: MCalMonthThemeData(todayBackgroundColor: Colors.blue),
      );

      final theme2 = MCalThemeData(
        cellBackgroundColor: Colors.black,
        monthTheme: MCalMonthThemeData(todayBackgroundColor: Colors.red),
      );

      final interpolated = theme1.lerp(theme2, 0.0);

      // At t=0.0, should return theme1 (or very close to it)
      expect(interpolated.cellBackgroundColor?.toARGB32(), Colors.white.toARGB32());
      expect(interpolated.monthTheme?.todayBackgroundColor?.toARGB32(), Colors.blue.toARGB32());
    });

    test('lerp interpolates between themes correctly (t = 1.0)', () {
      final theme1 = MCalThemeData(
        cellBackgroundColor: Colors.white,
        monthTheme: MCalMonthThemeData(todayBackgroundColor: Colors.blue),
      );

      final theme2 = MCalThemeData(
        cellBackgroundColor: Colors.black,
        monthTheme: MCalMonthThemeData(todayBackgroundColor: Colors.red),
      );

      final interpolated = theme1.lerp(theme2, 1.0);

      // At t=1.0, should return theme2 (or very close to it)
      expect(interpolated.cellBackgroundColor?.toARGB32(), Colors.black.toARGB32());
      expect(interpolated.monthTheme?.todayBackgroundColor?.toARGB32(), Colors.red.toARGB32());
    });

    test('lerp interpolates between themes correctly (t = 0.5)', () {
      final theme1 = MCalThemeData(
        cellBackgroundColor: Colors.white,
        monthTheme: MCalMonthThemeData(todayBackgroundColor: Colors.blue),
      );

      final theme2 = MCalThemeData(
        cellBackgroundColor: Colors.black,
        monthTheme: MCalMonthThemeData(todayBackgroundColor: Colors.red),
      );

      final interpolated = theme1.lerp(theme2, 0.5);

      // At t=0.5, should interpolate between colors
      expect(interpolated.cellBackgroundColor, isNotNull);
      expect(interpolated.monthTheme?.todayBackgroundColor, isNotNull);
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
      expect(calendarTheme.monthTheme?.cellTextStyle, isNotNull);
      expect(calendarTheme.monthTheme?.todayBackgroundColor, isNotNull);
      expect(calendarTheme.monthTheme?.todayTextStyle, isNotNull);
      expect(calendarTheme.monthTheme?.weekdayHeaderTextStyle, isNotNull);
      expect(calendarTheme.eventTileBackgroundColor, isNotNull);
      expect(calendarTheme.eventTileTextStyle, isNotNull);
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
      expect(calendarTheme.monthTheme?.cellTextStyle, isNotNull);
      expect(calendarTheme.monthTheme?.todayBackgroundColor, isNotNull);
      expect(calendarTheme.monthTheme?.todayTextStyle, isNotNull);
      expect(calendarTheme.monthTheme?.weekdayHeaderTextStyle, isNotNull);
      expect(calendarTheme.eventTileBackgroundColor, isNotNull);
      expect(calendarTheme.eventTileTextStyle, isNotNull);
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
      expect(calendarTheme.monthTheme?.todayBackgroundColor, isNotNull);
      // Verify text styles are derived from textTheme
      expect(calendarTheme.monthTheme?.cellTextStyle, isNotNull);
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
      expect(emptyTheme.monthTheme?.cellTextStyle, isNull);
      expect(emptyTheme.monthTheme?.todayBackgroundColor, isNull);
      expect(emptyTheme.monthTheme?.todayTextStyle, isNull);
      expect(emptyTheme.monthTheme?.leadingDatesTextStyle, isNull);
      expect(emptyTheme.monthTheme?.trailingDatesTextStyle, isNull);
      expect(emptyTheme.monthTheme?.leadingDatesBackgroundColor, isNull);
      expect(emptyTheme.monthTheme?.trailingDatesBackgroundColor, isNull);
      expect(emptyTheme.monthTheme?.weekdayHeaderTextStyle, isNull);
      expect(emptyTheme.monthTheme?.weekdayHeaderBackgroundColor, isNull);
      expect(emptyTheme.eventTileBackgroundColor, isNull);
      expect(emptyTheme.eventTileTextStyle, isNull);
      expect(emptyTheme.navigatorTextStyle, isNull);
      expect(emptyTheme.navigatorBackgroundColor, isNull);
      // New properties - shared
      expect(emptyTheme.allDayEventBackgroundColor, isNull);
      expect(emptyTheme.allDayEventTextStyle, isNull);
      expect(emptyTheme.allDayEventBorderColor, isNull);
      expect(emptyTheme.allDayEventBorderWidth, isNull);
      expect(emptyTheme.weekNumberTextStyle, isNull);
      expect(emptyTheme.weekNumberBackgroundColor, isNull);
      // Month-specific
      expect(emptyTheme.monthTheme?.focusedDateBackgroundColor, isNull);
      expect(emptyTheme.monthTheme?.focusedDateTextStyle, isNull);
      expect(emptyTheme.monthTheme?.hoverCellBackgroundColor, isNull);
      expect(emptyTheme.monthTheme?.hoverEventBackgroundColor, isNull);
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
          monthTheme: MCalMonthThemeData(
            focusedDateBackgroundColor: Colors.blue,
            focusedDateTextStyle: const TextStyle(color: Colors.blue),
          ),
        );

        final updated = original.copyWith(
          monthTheme: original.monthTheme?.copyWith(
            focusedDateBackgroundColor: Colors.green,
            focusedDateTextStyle: const TextStyle(color: Colors.green),
          ),
        );

        expect(updated.monthTheme?.focusedDateBackgroundColor, Colors.green);
        expect(updated.monthTheme?.focusedDateTextStyle?.color, Colors.green);
        // Original should be unchanged
        expect(original.monthTheme?.focusedDateBackgroundColor, Colors.blue);
        expect(original.monthTheme?.focusedDateTextStyle?.color, Colors.blue);
      });

      test('copyWith overrides allDayEvent properties', () {
        final original = MCalThemeData(
          allDayEventBackgroundColor: Colors.blue,
          allDayEventTextStyle: const TextStyle(color: Colors.blue),
          allDayEventBorderColor: Colors.blue,
          allDayEventBorderWidth: 1.0,
        );

        final updated = original.copyWith(
          allDayEventBackgroundColor: Colors.red,
          allDayEventTextStyle: const TextStyle(color: Colors.red),
          allDayEventBorderColor: Colors.red,
          allDayEventBorderWidth: 2.0,
        );

        expect(updated.allDayEventBackgroundColor, Colors.red);
        expect(updated.allDayEventTextStyle?.color, Colors.red);
        expect(updated.allDayEventBorderColor, Colors.red);
        expect(updated.allDayEventBorderWidth, 2.0);
        // Original should be unchanged
        expect(original.allDayEventBackgroundColor, Colors.blue);
        expect(original.allDayEventBorderWidth, 1.0);
      });

      test('copyWith overrides weekNumber properties', () {
        final original = MCalThemeData(
          weekNumberTextStyle: const TextStyle(color: Colors.grey),
          weekNumberBackgroundColor: Colors.grey,
        );

        final updated = original.copyWith(
          weekNumberTextStyle: const TextStyle(color: Colors.black),
          weekNumberBackgroundColor: Colors.white,
        );

        expect(updated.weekNumberTextStyle?.color, Colors.black);
        expect(updated.weekNumberBackgroundColor, Colors.white);
        // Original should be unchanged
        expect(original.weekNumberTextStyle?.color, Colors.grey);
        expect(original.weekNumberBackgroundColor, Colors.grey);
      });

      test('copyWith overrides hover properties', () {
        final original = MCalThemeData(
          monthTheme: MCalMonthThemeData(
            hoverCellBackgroundColor: Colors.blue,
            hoverEventBackgroundColor: Colors.green,
          ),
        );

        final updated = original.copyWith(
          monthTheme: original.monthTheme?.copyWith(
            hoverCellBackgroundColor: Colors.red,
            hoverEventBackgroundColor: Colors.orange,
          ),
        );

        expect(updated.monthTheme?.hoverCellBackgroundColor, Colors.red);
        expect(updated.monthTheme?.hoverEventBackgroundColor, Colors.orange);
        // Original should be unchanged
        expect(original.monthTheme?.hoverCellBackgroundColor, Colors.blue);
        expect(original.monthTheme?.hoverEventBackgroundColor, Colors.green);
      });

      test('copyWith preserves new properties when not specified', () {
        final original = MCalThemeData(
          allDayEventBorderWidth: 2.0,
          weekNumberBackgroundColor: Colors.grey,
          monthTheme: MCalMonthThemeData(
            focusedDateBackgroundColor: Colors.blue,
            hoverCellBackgroundColor: Colors.yellow,
          ),
        );

        final updated = original.copyWith(
          cellBackgroundColor: Colors.white,
        );

        expect(updated.monthTheme?.focusedDateBackgroundColor, Colors.blue);
        expect(updated.allDayEventBorderWidth, 2.0);
        expect(updated.weekNumberBackgroundColor, Colors.grey);
        expect(updated.monthTheme?.hoverCellBackgroundColor, Colors.yellow);
        expect(updated.cellBackgroundColor, Colors.white);
      });
    });

    group('lerp for new properties', () {
      test('lerp interpolates focusedDate Color properties correctly', () {
        final theme1 = MCalThemeData(
          monthTheme: MCalMonthThemeData(focusedDateBackgroundColor: Colors.white),
        );

        final theme2 = MCalThemeData(
          monthTheme: MCalMonthThemeData(focusedDateBackgroundColor: Colors.black),
        );

        // At t=0.0
        final atStart = theme1.lerp(theme2, 0.0);
        expect(
          atStart.monthTheme?.focusedDateBackgroundColor?.toARGB32(),
          Colors.white.toARGB32(),
        );

        // At t=1.0
        final atEnd = theme1.lerp(theme2, 1.0);
        expect(
          atEnd.monthTheme?.focusedDateBackgroundColor?.toARGB32(),
          Colors.black.toARGB32(),
        );

        // At t=0.5
        final atMiddle = theme1.lerp(theme2, 0.5);
        expect(atMiddle.monthTheme?.focusedDateBackgroundColor, isNotNull);
        expect(atMiddle.monthTheme?.focusedDateBackgroundColor, isNot(Colors.white));
        expect(atMiddle.monthTheme?.focusedDateBackgroundColor, isNot(Colors.black));
      });

      test('lerp interpolates focusedDate TextStyle correctly', () {
        final theme1 = MCalThemeData(
          monthTheme: MCalMonthThemeData(
            focusedDateTextStyle: const TextStyle(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        );

        final theme2 = MCalThemeData(
          monthTheme: MCalMonthThemeData(
            focusedDateTextStyle: const TextStyle(
              fontSize: 24,
              color: Colors.black,
            ),
          ),
        );

        final atMiddle = theme1.lerp(theme2, 0.5);

        expect(atMiddle.monthTheme?.focusedDateTextStyle, isNotNull);
        expect(atMiddle.monthTheme?.focusedDateTextStyle!.fontSize, 18.0);
      });

      test('lerp interpolates allDayEvent Color properties correctly', () {
        final theme1 = MCalThemeData(
          allDayEventBackgroundColor: Colors.blue,
          allDayEventBorderColor: Colors.blue,
        );

        final theme2 = MCalThemeData(
          allDayEventBackgroundColor: Colors.red,
          allDayEventBorderColor: Colors.red,
        );

        // At t=0.0
        final atStart = theme1.lerp(theme2, 0.0);
        expect(
          atStart.allDayEventBackgroundColor?.toARGB32(),
          Colors.blue.toARGB32(),
        );
        expect(
          atStart.allDayEventBorderColor?.toARGB32(),
          Colors.blue.toARGB32(),
        );

        // At t=1.0
        final atEnd = theme1.lerp(theme2, 1.0);
        expect(
          atEnd.allDayEventBackgroundColor?.toARGB32(),
          Colors.red.toARGB32(),
        );
        expect(
          atEnd.allDayEventBorderColor?.toARGB32(),
          Colors.red.toARGB32(),
        );

        // At t=0.5
        final atMiddle = theme1.lerp(theme2, 0.5);
        expect(atMiddle.allDayEventBackgroundColor, isNotNull);
        expect(atMiddle.allDayEventBackgroundColor, isNot(Colors.blue));
        expect(atMiddle.allDayEventBackgroundColor, isNot(Colors.red));
      });

      test('lerp interpolates allDayEventBorderWidth correctly', () {
        final theme1 = MCalThemeData(
          allDayEventBorderWidth: 1.0,
        );

        final theme2 = MCalThemeData(
          allDayEventBorderWidth: 3.0,
        );

        // At t=0.0
        final atStart = theme1.lerp(theme2, 0.0);
        expect(atStart.allDayEventBorderWidth, 1.0);

        // At t=1.0
        final atEnd = theme1.lerp(theme2, 1.0);
        expect(atEnd.allDayEventBorderWidth, 3.0);

        // At t=0.5
        final atMiddle = theme1.lerp(theme2, 0.5);
        expect(atMiddle.allDayEventBorderWidth, 2.0);
      });

      test('lerp interpolates allDayEvent TextStyle correctly', () {
        final theme1 = MCalThemeData(
          allDayEventTextStyle: const TextStyle(
            fontSize: 10,
            color: Colors.blue,
          ),
        );

        final theme2 = MCalThemeData(
          allDayEventTextStyle: const TextStyle(
            fontSize: 20,
            color: Colors.red,
          ),
        );

        final atMiddle = theme1.lerp(theme2, 0.5);

        expect(atMiddle.allDayEventTextStyle, isNotNull);
        expect(atMiddle.allDayEventTextStyle!.fontSize, 15.0);
      });

      test('lerp interpolates weekNumber properties correctly', () {
        final theme1 = MCalThemeData(
          weekNumberBackgroundColor: Colors.white,
          weekNumberTextStyle: const TextStyle(fontSize: 10),
        );

        final theme2 = MCalThemeData(
          weekNumberBackgroundColor: Colors.black,
          weekNumberTextStyle: const TextStyle(fontSize: 20),
        );

        // At t=0.0
        final atStart = theme1.lerp(theme2, 0.0);
        expect(
          atStart.weekNumberBackgroundColor?.toARGB32(),
          Colors.white.toARGB32(),
        );

        // At t=1.0
        final atEnd = theme1.lerp(theme2, 1.0);
        expect(
          atEnd.weekNumberBackgroundColor?.toARGB32(),
          Colors.black.toARGB32(),
        );

        // At t=0.5 - check TextStyle interpolation
        final atMiddle = theme1.lerp(theme2, 0.5);
        expect(atMiddle.weekNumberTextStyle, isNotNull);
        expect(atMiddle.weekNumberTextStyle!.fontSize, 15.0);
      });

      test('lerp interpolates hover Color properties correctly', () {
        final theme1 = MCalThemeData(
          monthTheme: MCalMonthThemeData(
            hoverCellBackgroundColor: Colors.white,
            hoverEventBackgroundColor: Colors.blue,
          ),
        );

        final theme2 = MCalThemeData(
          monthTheme: MCalMonthThemeData(
            hoverCellBackgroundColor: Colors.black,
            hoverEventBackgroundColor: Colors.red,
          ),
        );

        // At t=0.0
        final atStart = theme1.lerp(theme2, 0.0);
        expect(
          atStart.monthTheme?.hoverCellBackgroundColor?.toARGB32(),
          Colors.white.toARGB32(),
        );
        expect(
          atStart.monthTheme?.hoverEventBackgroundColor?.toARGB32(),
          Colors.blue.toARGB32(),
        );

        // At t=1.0
        final atEnd = theme1.lerp(theme2, 1.0);
        expect(
          atEnd.monthTheme?.hoverCellBackgroundColor?.toARGB32(),
          Colors.black.toARGB32(),
        );
        expect(
          atEnd.monthTheme?.hoverEventBackgroundColor?.toARGB32(),
          Colors.red.toARGB32(),
        );

        // At t=0.5
        final atMiddle = theme1.lerp(theme2, 0.5);
        expect(atMiddle.monthTheme?.hoverCellBackgroundColor, isNotNull);
        expect(atMiddle.monthTheme?.hoverCellBackgroundColor, isNot(Colors.white));
        expect(atMiddle.monthTheme?.hoverCellBackgroundColor, isNot(Colors.black));
      });

      test('lerp handles null values for new properties', () {
        final theme1 = MCalThemeData(
          allDayEventBorderWidth: null,
          weekNumberBackgroundColor: null,
          monthTheme: MCalMonthThemeData(focusedDateBackgroundColor: Colors.blue),
        );

        final theme2 = MCalThemeData(
          allDayEventBorderWidth: 2.0,
          weekNumberBackgroundColor: Colors.grey,
          monthTheme: MCalMonthThemeData(focusedDateBackgroundColor: null),
        );

        final interpolated = theme1.lerp(theme2, 0.5);

        // Should handle null values gracefully
        expect(interpolated, isNotNull);
      });

      test('lerp interpolates double from null correctly', () {
        final theme1 = MCalThemeData(
          allDayEventBorderWidth: null,
        );

        final theme2 = MCalThemeData(
          allDayEventBorderWidth: 4.0,
        );

        final atMiddle = theme1.lerp(theme2, 0.5);
        // When a is null, it defaults to 0.0, so 0.0 + (4.0 - 0.0) * 0.5 = 2.0
        expect(atMiddle.allDayEventBorderWidth, 2.0);
      });
    });

    group('fromTheme for new properties', () {
      test('fromTheme provides non-null focusedDate defaults', () {
        final themeData = ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        );

        final calendarTheme = MCalThemeData.fromTheme(themeData);

        expect(calendarTheme.monthTheme?.focusedDateBackgroundColor, isNotNull);
        expect(calendarTheme.monthTheme?.focusedDateTextStyle, isNotNull);
      });

      test('fromTheme provides non-null allDayEvent defaults', () {
        final themeData = ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        );

        final calendarTheme = MCalThemeData.fromTheme(themeData);

        expect(calendarTheme.allDayEventBackgroundColor, isNotNull);
        expect(calendarTheme.allDayEventTextStyle, isNotNull);
        expect(calendarTheme.allDayEventBorderColor, isNotNull);
        expect(calendarTheme.allDayEventBorderWidth, isNotNull);
        expect(calendarTheme.allDayEventBorderWidth, 1.0);
      });

      test('fromTheme provides non-null weekNumber defaults', () {
        final themeData = ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        );

        final calendarTheme = MCalThemeData.fromTheme(themeData);

        expect(calendarTheme.weekNumberTextStyle, isNotNull);
        expect(calendarTheme.weekNumberBackgroundColor, isNotNull);
      });

      test('fromTheme provides non-null hover defaults', () {
        final themeData = ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        );

        final calendarTheme = MCalThemeData.fromTheme(themeData);

        expect(calendarTheme.monthTheme?.hoverCellBackgroundColor, isNotNull);
        expect(calendarTheme.monthTheme?.hoverEventBackgroundColor, isNotNull);
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
          lightCalendarTheme.monthTheme?.focusedDateBackgroundColor,
          isNot(darkCalendarTheme.monthTheme?.focusedDateBackgroundColor),
        );
        expect(
          lightCalendarTheme.allDayEventBackgroundColor,
          isNot(darkCalendarTheme.allDayEventBackgroundColor),
        );
        expect(
          lightCalendarTheme.weekNumberBackgroundColor,
          isNot(darkCalendarTheme.weekNumberBackgroundColor),
        );
        expect(
          lightCalendarTheme.monthTheme?.hoverCellBackgroundColor,
          isNot(darkCalendarTheme.monthTheme?.hoverCellBackgroundColor),
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
        expect(calendarTheme.monthTheme?.focusedDateBackgroundColor, isNotNull);
        expect(calendarTheme.allDayEventBackgroundColor, isNotNull);
        expect(calendarTheme.weekNumberBackgroundColor, isNotNull);
        expect(calendarTheme.monthTheme?.hoverCellBackgroundColor, isNotNull);
        expect(calendarTheme.monthTheme?.hoverEventBackgroundColor, isNotNull);
      });
    });
  });
}
