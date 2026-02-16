// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'mcal_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class MCalLocalizationsFr extends MCalLocalizations {
  MCalLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get daySunday => 'Dimanche';

  @override
  String get dayMonday => 'Lundi';

  @override
  String get dayTuesday => 'Mardi';

  @override
  String get dayWednesday => 'Mercredi';

  @override
  String get dayThursday => 'Jeudi';

  @override
  String get dayFriday => 'Vendredi';

  @override
  String get daySaturday => 'Samedi';

  @override
  String get daySundayShort => 'Dim';

  @override
  String get dayMondayShort => 'Lun';

  @override
  String get dayTuesdayShort => 'Mar';

  @override
  String get dayWednesdayShort => 'Mer';

  @override
  String get dayThursdayShort => 'Jeu';

  @override
  String get dayFridayShort => 'Ven';

  @override
  String get daySaturdayShort => 'Sam';

  @override
  String get monthJanuary => 'Janvier';

  @override
  String get monthFebruary => 'Février';

  @override
  String get monthMarch => 'Mars';

  @override
  String get monthApril => 'Avril';

  @override
  String get monthMay => 'Mai';

  @override
  String get monthJune => 'Juin';

  @override
  String get monthJuly => 'Juillet';

  @override
  String get monthAugust => 'Août';

  @override
  String get monthSeptember => 'Septembre';

  @override
  String get monthOctober => 'Octobre';

  @override
  String get monthNovember => 'Novembre';

  @override
  String get monthDecember => 'Décembre';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get week => 'Semaine';

  @override
  String get month => 'Mois';

  @override
  String get day => 'Jour';

  @override
  String get year => 'Année';

  @override
  String get previousDay => 'Jour précédent';

  @override
  String get nextDay => 'Jour suivant';

  @override
  String get previousMonth => 'mois précédent';

  @override
  String get nextMonth => 'mois suivant';

  @override
  String currentTime(Object time) {
    return 'Heure actuelle : $time';
  }

  @override
  String get focused => 'focalisé';

  @override
  String get selected => 'sélectionné';

  @override
  String get event => 'événement';

  @override
  String get events => 'événements';

  @override
  String get doubleTapToSelect => 'Appuyez deux fois pour sélectionner';

  @override
  String get calendar => 'Calendrier';

  @override
  String get dropTargetPrefix => 'Cible de dépôt';

  @override
  String get dropTargetDateRangeTo => 'à';

  @override
  String get dropTargetValid => 'valide';

  @override
  String get dropTargetInvalid => 'invalide';

  @override
  String multiDaySpanLabel(Object days, Object position) {
    return 'événement de $days jours, jour $position sur $days';
  }

  @override
  String scheduleFor(Object date) {
    return 'Programme pour $date';
  }

  @override
  String get timeGrid => 'Grille horaire';

  @override
  String get doubleTapToCreateEvent =>
      'Appuyez deux fois pour créer un événement';

  @override
  String get allDay => 'Toute la journée';

  @override
  String get announcementResizeCancelled => 'Redimensionnement annulé';

  @override
  String announcementMoveCancelled(Object title) {
    return 'Déplacement annulé pour $title';
  }

  @override
  String get announcementEventSelectionCancelled =>
      'Sélection d\'événement annulée';

  @override
  String announcementEventsHighlighted(Object count, Object title) {
    return '$count événements. $title mis en surbrillance. Tab pour parcourir, Entrée pour confirmer.';
  }

  @override
  String announcementEventSelected(Object title) {
    return 'Sélectionné $title. Touches fléchées pour déplacer, Entrée pour confirmer, Échap pour annuler.';
  }

  @override
  String announcementEventCycled(Object title, Object index, Object total) {
    return '$title. $index sur $total.';
  }

  @override
  String announcementMovingEvent(Object title, Object date) {
    return 'Déplacement de $title vers $date';
  }

  @override
  String get announcementResizeModeEntered =>
      'Mode redimensionnement. Ajustement du bord final. Touches fléchées pour redimensionner, S pour début, E pour fin, M pour mode déplacement, Entrée pour confirmer.';

  @override
  String get announcementResizingStartEdge =>
      'Redimensionnement du bord de début';

  @override
  String get announcementResizingEndEdge => 'Redimensionnement du bord de fin';

  @override
  String get announcementMoveMode => 'Mode déplacement';

  @override
  String get announcementMoveInvalidTarget =>
      'Déplacement annulé. Cible invalide.';

  @override
  String announcementEventMoved(Object title, Object date) {
    return 'Déplacé $title vers $date';
  }

  @override
  String announcementResizingProgress(
    Object title,
    Object edge,
    Object date,
    Object days,
  ) {
    return 'Redimensionnement de $title $edge vers $date, $days jours';
  }

  @override
  String get announcementResizeInvalid =>
      'Redimensionnement annulé. Redimensionnement invalide.';

  @override
  String announcementEventResized(Object title, Object start, Object end) {
    return 'Redimensionné $title de $start à $end';
  }
}
