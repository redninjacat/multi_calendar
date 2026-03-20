import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:multi_calendar/multi_calendar.dart';
import 'package:multi_calendar/src/widgets/month_subwidgets/day_cell_widget.dart';

BoxDecoration _focusedCellDecoration(WidgetTester tester) {
  final focused = find.byWidgetPredicate(
    (w) => w is DayCellWidget && w.isFocused,
  );
  expect(focused, findsOneWidget);
  final decorated = find.descendant(
    of: focused,
    matching: find.byWidgetPredicate(
      (w) {
        if (w is! Container) return false;
        final d = w.decoration;
        if (d is! BoxDecoration) return false;
        return d.border != null;
      },
    ),
  );
  expect(decorated, findsWidgets);
  final container = tester.widget<Container>(decorated.first);
  return container.decoration! as BoxDecoration;
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en', null);
  });

  group('DayCellWidget focused-cell theme', () {
    final displayMonth = DateTime(2024, 6, 1);
    final focusedDay = DateTime(2024, 6, 20);

    late MCalEventController controller;

    setUp(() {
      controller = MCalEventController(initialDate: displayMonth);
      controller.setFocusedDateTime(focusedDay, isAllDay: true);
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('default theme uses master focused-cell colors and border',
        (tester) async {
      final flutterTheme = ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      );
      final monthDefs = MCalMonthViewThemeData.defaults(flutterTheme);

      await tester.pumpWidget(
        MaterialApp(
          theme: flutterTheme,
          home: Scaffold(
            body: SizedBox(
              height: 600,
              child: MCalMonthView(controller: controller),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final deco = _focusedCellDecoration(tester);
      expect(deco.color, monthDefs.focusedCellBackgroundColor);
      expect(deco.color, isNotNull);
      expect(deco.color!.a > 0, isTrue,
          reason: 'R6.1 focused cell background must not be transparent');
      final border = deco.border! as Border;
      expect(border.top.color, monthDefs.focusedCellBorderColor);
      expect(border.top.width, monthDefs.focusedCellBorderWidth);
    });

    testWidgets('consumer focusedCellBackgroundColor overrides default',
        (tester) async {
      const overrideBg = Color(0xFFFF69B4);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          ),
          home: Scaffold(
            body: SizedBox(
              height: 600,
              child: MCalTheme(
                data: const MCalThemeData(
                  monthViewTheme: MCalMonthViewThemeData(
                    focusedCellBackgroundColor: overrideBg,
                  ),
                ),
                child: MCalMonthView(controller: controller),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final deco = _focusedCellDecoration(tester);
      expect(deco.color, overrideBg);
    });

    testWidgets('focusedCellDecoration overrides individual focused-cell fields',
        (tester) async {
      const ignoredBg = Color(0xFF00FF00);
      const decorationColor = Color(0xFF673AB7);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          ),
          home: Scaffold(
            body: SizedBox(
              height: 600,
              child: MCalTheme(
                data: MCalThemeData(
                  monthViewTheme: MCalMonthViewThemeData(
                    focusedCellBackgroundColor: ignoredBg,
                    focusedCellDecoration: BoxDecoration(
                      color: decorationColor,
                      border: Border.all(color: Colors.orange, width: 4),
                    ),
                  ),
                ),
                child: MCalMonthView(controller: controller),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final deco = _focusedCellDecoration(tester);
      expect(deco.color, decorationColor);
      final border = deco.border! as Border;
      expect(border.top.color, Colors.orange);
      expect(border.top.width, 4.0);
    });

    testWidgets(
        'non-interactive focused cell dims focusedCellDecoration fill to α=0.6',
        (tester) async {
      const fill = Color(0xFFFF0000);
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          ),
          home: Scaffold(
            body: SizedBox(
              height: 600,
              child: MCalTheme(
                data: MCalThemeData(
                  monthViewTheme: MCalMonthViewThemeData(
                    focusedCellDecoration: BoxDecoration(
                      color: fill,
                      border: Border.all(color: Colors.orange, width: 2),
                    ),
                  ),
                ),
                child: MCalMonthView(
                  controller: controller,
                  cellInteractivityCallback: (context, details) {
                    final d = details.date;
                    return !(d.year == 2024 && d.month == 6 && d.day == 20);
                  },
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final deco = _focusedCellDecoration(tester);
      expect(deco.color, fill.withValues(alpha: 0.6));
      final border = deco.border! as Border;
      expect(border.top.color, Colors.orange);
      expect(border.top.width, 2.0);
    });

    testWidgets('consumer focusedCellBorderColor and width apply when decoration null',
        (tester) async {
      const borderColor = Color(0xFF009688);
      const borderWidth = 5.0;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          ),
          home: Scaffold(
            body: SizedBox(
              height: 600,
              child: MCalTheme(
                data: const MCalThemeData(
                  monthViewTheme: MCalMonthViewThemeData(
                    focusedCellBorderColor: borderColor,
                    focusedCellBorderWidth: borderWidth,
                  ),
                ),
                child: MCalMonthView(controller: controller),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final deco = _focusedCellDecoration(tester);
      final border = deco.border! as Border;
      expect(border.top.color, borderColor);
      expect(border.top.width, borderWidth);
    });
  });
}
