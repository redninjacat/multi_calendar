import 'package:flutter/material.dart';

// ============================================================================
// Layout Direction InheritedWidget
// ============================================================================

/// InheritedWidget that propagates the calendar's resolved *layout* direction
/// independently from the ambient [Directionality] (which carries the *text*
/// direction).
///
/// ## Design rationale
///
/// [MCalMonthView] and [MCalDayView] wrap their content in two layers:
///
/// ```
/// Directionality(textDirection)          ← drives all Text widget rendering
///   └─ MCalLayoutDirectionality(isLayoutRTL)  ← drives all visual layout logic
///        └─ calendar content
/// ```
///
/// This separation allows, for example, right-to-left Hebrew text (RTL
/// `textDirection`) inside a left-to-right calendar grid (LTR
/// `layoutDirection`).
///
/// ## Usage
///
/// Internal calendar widgets read layout direction via [MCalLayoutDirectionality.of]:
///
/// ```dart
/// final isLayoutRTL = MCalLayoutDirectionality.of(context);
/// ```
///
/// The owning view places this widget just inside the outer [Directionality]:
///
/// ```dart
/// Directionality(
///   textDirection: resolvedTextDirection,
///   child: MCalLayoutDirectionality(
///     isLayoutRTL: resolvedLayoutDirection == TextDirection.rtl,
///     child: ...,
///   ),
/// )
/// ```
class MCalLayoutDirectionality extends InheritedWidget {
  const MCalLayoutDirectionality({
    super.key,
    required this.isLayoutRTL,
    required super.child,
  });

  /// Whether the current layout direction is right-to-left.
  final bool isLayoutRTL;

  /// Returns `true` if the nearest [MCalLayoutDirectionality] ancestor is RTL.
  ///
  /// Falls back to the ambient [Directionality] if no [MCalLayoutDirectionality]
  /// ancestor is present (e.g. in unit tests or standalone widget usage).
  static bool of(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<MCalLayoutDirectionality>()
            ?.isLayoutRTL ??
        (Directionality.maybeOf(context) == TextDirection.rtl);
  }

  @override
  bool updateShouldNotify(MCalLayoutDirectionality oldWidget) =>
      isLayoutRTL != oldWidget.isLayoutRTL;
}
