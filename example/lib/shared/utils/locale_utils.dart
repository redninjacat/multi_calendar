import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Returns the first day of the week for [locale] in the [DateTime.weekday]
/// convention used by [MCalEventController.firstDayOfWeek]
/// (1 = Monday, …, 7 = Sunday).
///
/// CLDR locale data is loaded asynchronously via the `intl` package. The load
/// is a no-op if the data was already initialised for that locale.
///
/// [DateSymbols.FIRSTDAYOFWEEK] uses a 0-based index **starting from Monday**
/// (Java / ISO convention):
///   0 = Monday, 1 = Tuesday, …, 5 = Saturday, 6 = Sunday.
///
/// This is converted to the [DateTime.weekday] range (1–7) that
/// [MCalEventController] expects.
///
/// Examples:
/// - `en` → 7 ([DateTime.sunday])
/// - `fr` → 1 ([DateTime.monday])
/// - `ar` → 6 ([DateTime.saturday])
/// - `he` → 7 ([DateTime.sunday])
Future<int> firstDayOfWeekForLocale(Locale locale) async {
  final tag = locale.languageCode;
  await initializeDateFormatting(tag, null);

  final symbols = dateTimeSymbolMap()[tag];

  // FIRSTDAYOFWEEK: 0 = Monday, 1 = Tuesday, …, 5 = Saturday, 6 = Sunday.
  // Default to 6 (Sunday) when locale data is unavailable.
  final fdow = symbols?.FIRSTDAYOFWEEK ?? 6;

  // Convert to DateTime.weekday convention (1=Mon … 7=Sun):
  //   intl 6 (Sunday) → DateTime.sunday (7)
  //   intl 0–5        → fdow + 1  (Mon→1, Tue→2, …, Sat→6)
  return fdow == 6 ? DateTime.sunday : fdow + 1;
}
