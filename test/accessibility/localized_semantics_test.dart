import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:multi_calendar/multi_calendar.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en', null);
    await initializeDateFormatting('en_US', null);
    await initializeDateFormatting('es', null);
    await initializeDateFormatting('fr', null);
    await initializeDateFormatting('ar', null);
    await initializeDateFormatting('he', null);
  });

  group('Day View - English semantics', () {
    testWidgets('Time grid has English semantics label', (tester) async {
      final controller = MCalEventController(
        initialDate: DateTime(2026, 2, 14),
      );

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en', 'US'),
          localizationsDelegates: MCalLocalizations.localizationsDelegates,
          supportedLocales: MCalLocalizations.supportedLocales,
          home: Scaffold(
            body: SizedBox(
              height: 600,
              child: MCalDayView(controller: controller),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Time grid'), findsOneWidget);

      controller.dispose();
    });

    testWidgets('Previous day button has English semantics', (tester) async {
      final controller = MCalEventController(
        initialDate: DateTime(2026, 2, 14),
      );

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en', 'US'),
          localizationsDelegates: MCalLocalizations.localizationsDelegates,
          supportedLocales: MCalLocalizations.supportedLocales,
          home: Scaffold(
            body: SizedBox(
              height: 600,
              child: MCalDayView(
                controller: controller,
                showNavigator: true,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Previous day'), findsWidgets);

      controller.dispose();
    });

    testWidgets('Next day button has English semantics', (tester) async {
      final controller = MCalEventController(
        initialDate: DateTime(2026, 2, 14),
      );

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en', 'US'),
          localizationsDelegates: MCalLocalizations.localizationsDelegates,
          supportedLocales: MCalLocalizations.supportedLocales,
          home: Scaffold(
            body: SizedBox(
              height: 600,
              child: MCalDayView(
                controller: controller,
                showNavigator: true,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Next day'), findsWidgets);

      controller.dispose();
    });
  });

  group('Day View - Spanish semantics', () {
    testWidgets('Time grid has Spanish semantics label', (tester) async {
      final controller = MCalEventController(
        initialDate: DateTime(2026, 2, 14),
      );

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('es'),
          home: Scaffold(
            body: SizedBox(
              height: 600,
              child: MCalDayView(
                controller: controller,
                locale: const Locale('es'),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Cuadrícula de tiempo'), findsOneWidget);

      controller.dispose();
    });

    testWidgets('Previous day has Spanish semantics', (tester) async {
      final controller = MCalEventController(
        initialDate: DateTime(2026, 2, 14),
      );

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('es'),
          home: Scaffold(
            body: SizedBox(
              height: 600,
              child: MCalDayView(
                controller: controller,
                locale: const Locale('es'),
                showNavigator: true,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Día anterior'), findsWidgets);

      controller.dispose();
    });

    testWidgets('Next day has Spanish semantics', (tester) async {
      final controller = MCalEventController(
        initialDate: DateTime(2026, 2, 14),
      );

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('es'),
          home: Scaffold(
            body: SizedBox(
              height: 600,
              child: MCalDayView(
                controller: controller,
                locale: const Locale('es'),
                showNavigator: true,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Día siguiente'), findsWidgets);

      controller.dispose();
    });
  });

  group('Day View - French semantics', () {
    testWidgets('Time grid has French semantics label', (tester) async {
      final controller = MCalEventController(
        initialDate: DateTime(2026, 2, 14),
      );

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('fr'),
          home: Scaffold(
            body: SizedBox(
              height: 600,
              child: MCalDayView(
                controller: controller,
                locale: const Locale('fr'),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Grille horaire'), findsOneWidget);

      controller.dispose();
    });

    testWidgets('Navigation buttons have French semantics', (tester) async {
      final controller = MCalEventController(
        initialDate: DateTime(2026, 2, 14),
      );

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('fr'),
          home: Scaffold(
            body: SizedBox(
              height: 600,
              child: MCalDayView(
                controller: controller,
                locale: const Locale('fr'),
                showNavigator: true,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Jour précédent'), findsWidgets);
      expect(find.bySemanticsLabel('Jour suivant'), findsWidgets);

      controller.dispose();
    });
  });

  group('Day View - Arabic semantics (RTL)', () {
    testWidgets('Time grid has Arabic semantics label', (tester) async {
      final controller = MCalEventController(
        initialDate: DateTime(2026, 2, 14),
      );

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ar'),
          home: Scaffold(
            body: Directionality(
              textDirection: TextDirection.rtl,
              child: SizedBox(
                height: 600,
                child: MCalDayView(
                  controller: controller,
                  locale: const Locale('ar'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('شبكة الوقت'), findsOneWidget);

      controller.dispose();
    });

    testWidgets('Day View renders with Arabic semantics', (tester) async {
      final controller = MCalEventController(
        initialDate: DateTime(2026, 2, 14),
      );

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ar'),
          home: Scaffold(
            body: Directionality(
              textDirection: TextDirection.rtl,
              child: SizedBox(
                height: 600,
                child: MCalDayView(
                  controller: controller,
                  locale: const Locale('ar'),
                  showNavigator: true,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(MCalDayView), findsOneWidget);
      expect(find.bySemanticsLabel('اليوم السابق'), findsWidgets);
      expect(find.bySemanticsLabel('اليوم التالي'), findsWidgets);

      controller.dispose();
    });
  });

  group('Day View - Hebrew semantics (RTL)', () {
    testWidgets('Time grid has Hebrew semantics label', (tester) async {
      final controller = MCalEventController(
        initialDate: DateTime(2026, 2, 14),
      );

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('he'),
          home: Scaffold(
            body: Directionality(
              textDirection: TextDirection.rtl,
              child: SizedBox(
                height: 600,
                child: MCalDayView(
                  controller: controller,
                  locale: const Locale('he'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('רשת זמן'), findsOneWidget);

      controller.dispose();
    });

    testWidgets('Day View renders with Hebrew semantics', (tester) async {
      final controller = MCalEventController(
        initialDate: DateTime(2026, 2, 14),
      );

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('he'),
          home: Scaffold(
            body: Directionality(
              textDirection: TextDirection.rtl,
              child: SizedBox(
                height: 600,
                child: MCalDayView(
                  controller: controller,
                  locale: const Locale('he'),
                  showNavigator: true,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(MCalDayView), findsOneWidget);
      expect(find.bySemanticsLabel('יום קודם'), findsWidgets);
      expect(find.bySemanticsLabel('יום הבא'), findsWidgets);

      controller.dispose();
    });
  });

  group('Today button semantics', () {
    testWidgets('Today button has English semantics', (tester) async {
      final controller = MCalEventController(
        initialDate: DateTime(2026, 2, 14),
      );

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en', 'US'),
          localizationsDelegates: MCalLocalizations.localizationsDelegates,
          supportedLocales: MCalLocalizations.supportedLocales,
          home: Scaffold(
            body: SizedBox(
              height: 600,
              child: MCalDayView(
                controller: controller,
                showNavigator: true,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Today'), findsWidgets);

      controller.dispose();
    });

    testWidgets('Today button has Spanish semantics', (tester) async {
      final controller = MCalEventController(
        initialDate: DateTime(2026, 2, 14),
      );

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('es'),
          home: Scaffold(
            body: SizedBox(
              height: 600,
              child: MCalDayView(
                controller: controller,
                locale: const Locale('es'),
                showNavigator: true,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Hoy'), findsWidgets);

      controller.dispose();
    });
  });

  group('MCalLocalizations accessibility strings', () {
    testWidgets('timeGrid has correct strings for all languages',
        (tester) async {
      const testCases = [
        (Locale('en'), 'Time grid'),
        (Locale('es'), 'Cuadrícula de tiempo'),
        (Locale('fr'), 'Grille horaire'),
        (Locale('ar'), 'شبكة الوقت'),
        (Locale('he'), 'רשת זמן'),
      ];

      for (final (locale, expected) in testCases) {
        await tester.pumpWidget(
          MaterialApp(
            locale: locale,
            localizationsDelegates: MCalLocalizations.localizationsDelegates,
            supportedLocales: MCalLocalizations.supportedLocales,
            home: Builder(
              builder: (context) {
                final l10n = MCalLocalizations.of(context);
                return Text(l10n.timeGrid);
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text(expected), findsOneWidget);
      }
    });

    testWidgets('today has correct strings for all languages', (tester) async {
      const testCases = [
        (Locale('en'), 'Today'),
        (Locale('es'), 'Hoy'),
        (Locale('fr'), 'Aujourd\'hui'),
      ];

      for (final (locale, expected) in testCases) {
        await tester.pumpWidget(
          MaterialApp(
            locale: locale,
            localizationsDelegates: MCalLocalizations.localizationsDelegates,
            supportedLocales: MCalLocalizations.supportedLocales,
            home: Builder(
              builder: (context) {
                final l10n = MCalLocalizations.of(context);
                return Text(l10n.today);
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text(expected), findsOneWidget);
      }
    });

    testWidgets('doubleTapToCreateEvent is not empty', (tester) async {
      const testCases = [Locale('en'), Locale('es')];

      for (final locale in testCases) {
        await tester.pumpWidget(
          MaterialApp(
            locale: locale,
            localizationsDelegates: MCalLocalizations.localizationsDelegates,
            supportedLocales: MCalLocalizations.supportedLocales,
            home: Builder(
              builder: (context) {
                final l10n = MCalLocalizations.of(context);
                return Text(l10n.doubleTapToCreateEvent);
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        final textWidget = tester.widget<Text>(find.byType(Text));
        expect(textWidget.data, isNotEmpty);
      }
    });

    testWidgets('scheduleFor has parameter substitution', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: MCalLocalizations.localizationsDelegates,
          supportedLocales: MCalLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              final l10n = MCalLocalizations.of(context);
              return Text(l10n.scheduleFor('Feb 15'));
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('Feb 15'), findsOneWidget);
    });

    testWidgets('currentTime has parameter substitution', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: MCalLocalizations.localizationsDelegates,
          supportedLocales: MCalLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              final l10n = MCalLocalizations.of(context);
              return Text(l10n.currentTime('2:30 PM'));
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('2:30 PM'), findsOneWidget);
    });
  });

  group('Semantics tree structure', () {
    testWidgets('Day View has semantic labels in tree', (tester) async {
      final controller = MCalEventController(
        initialDate: DateTime(2026, 2, 14),
      );

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en', 'US'),
          localizationsDelegates: MCalLocalizations.localizationsDelegates,
          supportedLocales: MCalLocalizations.supportedLocales,
          home: Scaffold(
            body: SizedBox(
              height: 600,
              child: MCalDayView(controller: controller),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final semantics = tester.getSemantics(find.byType(MCalDayView));
      expect(semantics, isNotNull);

      controller.dispose();
    });

    testWidgets('Semantic labels change with locale', (tester) async {
      final controller = MCalEventController(
        initialDate: DateTime(2026, 2, 14),
      );

      // English
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en', 'US'),
          home: Scaffold(
            body: SizedBox(
              height: 600,
              child: MCalDayView(
                controller: controller,
                locale: const Locale('en', 'US'),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Time grid'), findsOneWidget);

      // Spanish
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('es'),
          home: Scaffold(
            body: SizedBox(
              height: 600,
              child: MCalDayView(
                controller: controller,
                locale: const Locale('es'),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Cuadrícula de tiempo'), findsOneWidget);

      controller.dispose();
    });
  });
}
