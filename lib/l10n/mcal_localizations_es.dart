// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'mcal_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class MCalLocalizationsEs extends MCalLocalizations {
  MCalLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get daySunday => 'Domingo';

  @override
  String get dayMonday => 'Lunes';

  @override
  String get dayTuesday => 'Martes';

  @override
  String get dayWednesday => 'Miércoles';

  @override
  String get dayThursday => 'Jueves';

  @override
  String get dayFriday => 'Viernes';

  @override
  String get daySaturday => 'Sábado';

  @override
  String get daySundayShort => 'Dom';

  @override
  String get dayMondayShort => 'Lun';

  @override
  String get dayTuesdayShort => 'Mar';

  @override
  String get dayWednesdayShort => 'Mié';

  @override
  String get dayThursdayShort => 'Jue';

  @override
  String get dayFridayShort => 'Vie';

  @override
  String get daySaturdayShort => 'Sáb';

  @override
  String get monthJanuary => 'Enero';

  @override
  String get monthFebruary => 'Febrero';

  @override
  String get monthMarch => 'Marzo';

  @override
  String get monthApril => 'Abril';

  @override
  String get monthMay => 'Mayo';

  @override
  String get monthJune => 'Junio';

  @override
  String get monthJuly => 'Julio';

  @override
  String get monthAugust => 'Agosto';

  @override
  String get monthSeptember => 'Septiembre';

  @override
  String get monthOctober => 'Octubre';

  @override
  String get monthNovember => 'Noviembre';

  @override
  String get monthDecember => 'Diciembre';

  @override
  String get today => 'Hoy';

  @override
  String get week => 'Semana';

  @override
  String get month => 'Mes';

  @override
  String get day => 'Día';

  @override
  String get year => 'Año';

  @override
  String get previousDay => 'Día anterior';

  @override
  String get nextDay => 'Día siguiente';

  @override
  String get previousMonth => 'Mes anterior';

  @override
  String get nextMonth => 'Mes siguiente';

  @override
  String currentTime(Object time) {
    return 'Hora actual: $time';
  }

  @override
  String get focused => 'enfocado';

  @override
  String get selected => 'seleccionado';

  @override
  String get event => 'evento';

  @override
  String get events => 'eventos';

  @override
  String get doubleTapToSelect => 'Toca dos veces para seleccionar';

  @override
  String get calendar => 'Calendario';

  @override
  String get dropTargetPrefix => 'Zona de soltar';

  @override
  String get dropTargetDateRangeTo => 'a';

  @override
  String get dropTargetValid => 'válido';

  @override
  String get dropTargetInvalid => 'no válido';

  @override
  String multiDaySpanLabel(Object days, Object position) {
    return 'evento de $days días, día $position de $days';
  }

  @override
  String scheduleFor(Object date) {
    return 'Horario para $date';
  }

  @override
  String get timeGrid => 'Cuadrícula de tiempo';

  @override
  String get doubleTapToCreateEvent => 'Toca dos veces para crear evento';

  @override
  String get allDay => 'Todo el día';

  @override
  String get announcementResizeCancelled => 'Redimensión cancelada';

  @override
  String announcementMoveCancelled(Object title) {
    return 'Movimiento cancelado para $title';
  }

  @override
  String get announcementEventSelectionCancelled =>
      'Selección de evento cancelada';

  @override
  String announcementEventsHighlighted(Object count, Object title) {
    return '$count eventos. $title resaltado. Tab para recorrer, Enter para confirmar.';
  }

  @override
  String announcementEventSelected(Object title) {
    return 'Seleccionado $title. Flechas para mover, Enter para confirmar, Escape para cancelar.';
  }

  @override
  String announcementEventCycled(Object title, Object index, Object total) {
    return '$title. $index de $total.';
  }

  @override
  String announcementMovingEvent(Object title, Object date) {
    return 'Moviendo $title a $date';
  }

  @override
  String get announcementResizeModeEntered =>
      'Modo redimensión. Ajustando borde final. Flechas para redimensionar, S para inicio, E para final, M para modo mover, Enter para confirmar.';

  @override
  String get announcementResizingStartEdge => 'Redimensionando borde inicial';

  @override
  String get announcementResizingEndEdge => 'Redimensionando borde final';

  @override
  String get announcementMoveMode => 'Modo mover';

  @override
  String get announcementMoveInvalidTarget =>
      'Movimiento cancelado. Destino no válido.';

  @override
  String announcementEventMoved(Object title, Object date) {
    return 'Movido $title a $date';
  }

  @override
  String announcementResizingProgress(
    Object title,
    Object edge,
    Object date,
    Object days,
  ) {
    return 'Redimensionando $title $edge a $date, $days días';
  }

  @override
  String get announcementResizeInvalid =>
      'Redimensión cancelada. Redimensión no válida.';

  @override
  String announcementEventResized(Object title, Object start, Object end) {
    return 'Redimensionado $title de $start a $end';
  }
}
