import 'dart:ui';

/// Formats a month and year for display based on locale.
String formatMonthYear(DateTime date, Locale locale) {
  final months = locale.languageCode == 'es'
      ? [
          'Enero',
          'Febrero',
          'Marzo',
          'Abril',
          'Mayo',
          'Junio',
          'Julio',
          'Agosto',
          'Septiembre',
          'Octubre',
          'Noviembre',
          'Diciembre'
        ]
      : [
          'January',
          'February',
          'March',
          'April',
          'May',
          'June',
          'July',
          'August',
          'September',
          'October',
          'November',
          'December'
        ];
  return '${months[date.month - 1]} ${date.year}';
}
