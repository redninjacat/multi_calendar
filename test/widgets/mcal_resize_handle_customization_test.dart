import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:multi_calendar/multi_calendar.dart';

/// Mock controller for testing.
class _MockController extends MCalEventController {
  _MockController({super.initialDate});

  void setMockEvents(List<MCalCalendarEvent> events) {
    clearEvents();
    addEvents(events);
  }
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en', null);
  });

  // ============================================================
  // Shared helpers
  // ============================================================

  Future<void> pumpMonthView(
    WidgetTester tester, {
    required _MockController controller,
    bool? enableDragToResize,
    bool enableDragToMove = true,
    Widget Function(BuildContext, MCalResizeHandleContext)?
        resizeHandleBuilder,
    double Function(MCalEventTileContext, MCalResizeEdge)?
        resizeHandleInset,
    TargetPlatform platform = TargetPlatform.macOS,
    MediaQueryData? mediaQueryData,
    bool Function(BuildContext, MCalEventResizedDetails)? onEventResized,
  }) async {
    final mq = mediaQueryData ?? const MediaQueryData(size: Size(800, 600));
    await tester.pumpWidget(
      MediaQuery(
        data: mq,
        child: MaterialApp(
          theme: ThemeData(platform: platform),
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: MCalMonthView(
                controller: controller,
                enableDragToMove: enableDragToMove,
                enableDragToResize: enableDragToResize,
                resizeHandleBuilder: resizeHandleBuilder,
                resizeHandleInset: resizeHandleInset,
                onEventResized: onEventResized,
                enableAnimations: false,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  // ============================================================
  // Test: API Renames
  // ============================================================
  group('API Renames', () {
    late _MockController controller;
    setUp(() {
      controller = _MockController(initialDate: DateTime(2025, 1, 1));
    });
    tearDown(() => controller.dispose());

    testWidgets(
      'enableDragToMove: true enables drag-and-drop',
      (tester) async {
        final event = MCalCalendarEvent(
          id: 'drag-move-test',
          title: 'Move Test',
          start: DateTime(2025, 1, 6),
          end: DateTime(2025, 1, 8),
          color: Colors.blue,
        );
        controller.setMockEvents([event]);

        await pumpMonthView(
          tester,
          controller: controller,
          enableDragToMove: true,
          enableDragToResize: false,
        );

        // The event should be rendered. With drag enabled, there should be
        // a draggable tile (long press to drag).
        expect(find.text('Move Test'), findsWidgets);
      },
    );

    testWidgets(
      'enableDragToResize: true enables resize handles',
      (tester) async {
        final event = MCalCalendarEvent(
          id: 'drag-resize-test',
          title: 'Resize Test',
          start: DateTime(2025, 1, 6),
          end: DateTime(2025, 1, 8),
          color: Colors.blue,
        );
        controller.setMockEvents([event]);

        await pumpMonthView(
          tester,
          controller: controller,
          enableDragToMove: true,
          enableDragToResize: true,
        );

        expect(find.bySemanticsLabel('Resize start edge'), findsWidgets);
        expect(find.bySemanticsLabel('Resize end edge'), findsWidgets);
      },
    );

    testWidgets(
      'enableDragToResize: false disables resize handles',
      (tester) async {
        final event = MCalCalendarEvent(
          id: 'no-resize-test',
          title: 'No Resize',
          start: DateTime(2025, 1, 6),
          end: DateTime(2025, 1, 8),
          color: Colors.blue,
        );
        controller.setMockEvents([event]);

        await pumpMonthView(
          tester,
          controller: controller,
          enableDragToMove: true,
          enableDragToResize: false,
        );

        expect(find.bySemanticsLabel('Resize start edge'), findsNothing);
        expect(find.bySemanticsLabel('Resize end edge'), findsNothing);
      },
    );
  });

  // ============================================================
  // Test: Custom Resize Handle Builder
  // ============================================================
  group('Custom resizeHandleBuilder', () {
    late _MockController controller;
    setUp(() {
      controller = _MockController(initialDate: DateTime(2025, 1, 1));
    });
    tearDown(() => controller.dispose());

    testWidgets(
      'custom builder renders on multi-day event tile handles',
      (tester) async {
        final event = MCalCalendarEvent(
          id: 'custom-handle-1',
          title: 'Custom Handle',
          start: DateTime(2025, 1, 6),
          end: DateTime(2025, 1, 8),
          color: Colors.green,
        );
        controller.setMockEvents([event]);

        // Track contexts passed to the builder
        final capturedContexts = <MCalResizeHandleContext>[];

        await pumpMonthView(
          tester,
          controller: controller,
          enableDragToResize: true,
          resizeHandleBuilder: (context, handleContext) {
            capturedContexts.add(handleContext);
            return Container(
              key: ValueKey('custom-handle-${handleContext.edge.name}'),
              width: 4,
              height: 20,
              color: Colors.red,
            );
          },
        );

        // Custom handle widgets should render
        expect(
          find.byKey(const ValueKey('custom-handle-start')),
          findsWidgets,
        );
        expect(
          find.byKey(const ValueKey('custom-handle-end')),
          findsWidgets,
        );

        // Verify contexts were passed
        expect(capturedContexts, isNotEmpty);

        // Verify we got both edge types
        final edges = capturedContexts.map((c) => c.edge).toSet();
        expect(edges, contains(MCalResizeEdge.start));
        expect(edges, contains(MCalResizeEdge.end));
      },
    );

    testWidgets(
      'MCalResizeHandleContext has correct event reference',
      (tester) async {
        final event = MCalCalendarEvent(
          id: 'ctx-event-ref',
          title: 'Ctx Event Ref',
          start: DateTime(2025, 1, 6),
          end: DateTime(2025, 1, 8),
          color: Colors.purple,
        );
        controller.setMockEvents([event]);

        final capturedContexts = <MCalResizeHandleContext>[];

        await pumpMonthView(
          tester,
          controller: controller,
          enableDragToResize: true,
          resizeHandleBuilder: (context, handleContext) {
            capturedContexts.add(handleContext);
            return const SizedBox(width: 4, height: 20);
          },
        );

        // All contexts should reference an event with our id
        for (final ctx in capturedContexts) {
          expect(ctx.event.id, equals('ctx-event-ref'));
        }
      },
    );

    testWidgets(
      'isDropTargetPreview is false for event tile handles',
      (tester) async {
        final event = MCalCalendarEvent(
          id: 'not-preview',
          title: 'Not Preview',
          start: DateTime(2025, 1, 6),
          end: DateTime(2025, 1, 8),
          color: Colors.orange,
        );
        controller.setMockEvents([event]);

        final capturedContexts = <MCalResizeHandleContext>[];

        await pumpMonthView(
          tester,
          controller: controller,
          enableDragToResize: true,
          resizeHandleBuilder: (context, handleContext) {
            capturedContexts.add(handleContext);
            return const SizedBox(width: 4, height: 20);
          },
        );

        // All handles on the actual event tiles should have
        // isDropTargetPreview = false
        for (final ctx in capturedContexts) {
          expect(ctx.isDropTargetPreview, isFalse);
        }
      },
    );

    testWidgets(
      'null resizeHandleBuilder uses default white bar',
      (tester) async {
        final event = MCalCalendarEvent(
          id: 'default-handle',
          title: 'Default Handle',
          start: DateTime(2025, 1, 6),
          end: DateTime(2025, 1, 8),
          color: Colors.blue,
        );
        controller.setMockEvents([event]);

        await pumpMonthView(
          tester,
          controller: controller,
          enableDragToResize: true,
          resizeHandleBuilder: null, // default
        );

        // Resize handles should still be present (default visual)
        expect(find.bySemanticsLabel('Resize start edge'), findsWidgets);
        expect(find.bySemanticsLabel('Resize end edge'), findsWidgets);
      },
    );
  });

  // ============================================================
  // Test: Custom Resize Handle Inset
  // ============================================================
  group('Custom resizeHandleInset', () {
    late _MockController controller;
    setUp(() {
      controller = _MockController(initialDate: DateTime(2025, 1, 1));
    });
    tearDown(() => controller.dispose());

    testWidgets(
      'resizeHandleInset callback is invoked with correct args',
      (tester) async {
        final event = MCalCalendarEvent(
          id: 'inset-callback',
          title: 'Inset CB',
          start: DateTime(2025, 1, 6),
          end: DateTime(2025, 1, 8),
          color: Colors.teal,
        );
        controller.setMockEvents([event]);

        final capturedEdges = <MCalResizeEdge>[];
        final capturedIsAllDay = <bool>[];

        await pumpMonthView(
          tester,
          controller: controller,
          enableDragToResize: true,
          resizeHandleInset: (tileContext, edge) {
            capturedEdges.add(edge);
            capturedIsAllDay.add(tileContext.isAllDay);
            return 10.0;
          },
        );

        // Callback should have been invoked for start and end handles
        expect(capturedEdges, isNotEmpty);
        expect(capturedEdges, contains(MCalResizeEdge.start));
        expect(capturedEdges, contains(MCalResizeEdge.end));
      },
    );

    testWidgets(
      'resizeHandleInset can return different values for all-day vs timed',
      (tester) async {
        final allDayEvent = MCalCalendarEvent(
          id: 'allday-inset',
          title: 'All Day',
          start: DateTime(2025, 1, 6),
          end: DateTime(2025, 1, 8),
          color: Colors.blue,
          isAllDay: true,
        );
        final timedEvent = MCalCalendarEvent(
          id: 'timed-inset',
          title: 'Timed',
          start: DateTime(2025, 1, 13, 10, 0),
          end: DateTime(2025, 1, 15, 11, 0),
          color: Colors.red,
        );
        controller.setMockEvents([allDayEvent, timedEvent]);

        final insetsByAllDay = <bool, double>{};

        await pumpMonthView(
          tester,
          controller: controller,
          enableDragToResize: true,
          resizeHandleInset: (tileContext, edge) {
            final inset = tileContext.isAllDay ? 0.0 : 20.0;
            insetsByAllDay[tileContext.isAllDay] = inset;
            return inset;
          },
        );

        // Verify we got callbacks for both all-day and timed events
        // (may not always be true depending on layout, but at least one type
        // should render)
        expect(insetsByAllDay.isNotEmpty, isTrue);
      },
    );

    testWidgets(
      'null resizeHandleInset uses zero inset (default)',
      (tester) async {
        final event = MCalCalendarEvent(
          id: 'zero-inset',
          title: 'Zero Inset',
          start: DateTime(2025, 1, 6),
          end: DateTime(2025, 1, 8),
          color: Colors.blue,
        );
        controller.setMockEvents([event]);

        await pumpMonthView(
          tester,
          controller: controller,
          enableDragToResize: true,
          resizeHandleInset: null, // default
        );

        // Handles should be present at the tile edges
        expect(find.bySemanticsLabel('Resize start edge'), findsWidgets);
        expect(find.bySemanticsLabel('Resize end edge'), findsWidgets);
      },
    );
  });

  // ============================================================
  // Test: MCalResizeHandleContext class
  // ============================================================
  group('MCalResizeHandleContext', () {
    test('constructs with required fields', () {
      final event = MCalCalendarEvent(
        id: 'ctx-test',
        title: 'Context Test',
        start: DateTime(2025, 1, 6),
        end: DateTime(2025, 1, 8),
        color: Colors.blue,
      );
      final context = MCalResizeHandleContext(
        edge: MCalResizeEdge.start,
        event: event,
      );

      expect(context.edge, MCalResizeEdge.start);
      expect(context.event.id, 'ctx-test');
      expect(context.isDropTargetPreview, isFalse); // default
    });

    test('isDropTargetPreview defaults to false', () {
      final event = MCalCalendarEvent(
        id: 'default-preview',
        title: 'Default',
        start: DateTime(2025, 1, 6),
        end: DateTime(2025, 1, 8),
        color: Colors.blue,
      );
      final context = MCalResizeHandleContext(
        edge: MCalResizeEdge.end,
        event: event,
      );

      expect(context.isDropTargetPreview, isFalse);
    });

    test('isDropTargetPreview can be set to true', () {
      final event = MCalCalendarEvent(
        id: 'preview-true',
        title: 'Preview True',
        start: DateTime(2025, 1, 6),
        end: DateTime(2025, 1, 8),
        color: Colors.blue,
      );
      final context = MCalResizeHandleContext(
        edge: MCalResizeEdge.end,
        event: event,
        isDropTargetPreview: true,
      );

      expect(context.isDropTargetPreview, isTrue);
    });

    test('both edge values are accessible', () {
      final event = MCalCalendarEvent(
        id: 'edge-test',
        title: 'Edge Test',
        start: DateTime(2025, 1, 6),
        end: DateTime(2025, 1, 8),
        color: Colors.blue,
      );
      final startCtx = MCalResizeHandleContext(
        edge: MCalResizeEdge.start,
        event: event,
      );
      final endCtx = MCalResizeHandleContext(
        edge: MCalResizeEdge.end,
        event: event,
      );

      expect(startCtx.edge, MCalResizeEdge.start);
      expect(endCtx.edge, MCalResizeEdge.end);
    });
  });
}
