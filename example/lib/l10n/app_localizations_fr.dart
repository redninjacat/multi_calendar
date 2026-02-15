// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Multi Calendrier';

  @override
  String get toggleTheme => 'Changer le thème';

  @override
  String get changeLanguage => 'Changer la langue';

  @override
  String get languageEnglish => 'Anglais';

  @override
  String get languageSpanish => 'Espagnol';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageArabic => 'Arabe (RTL)';

  @override
  String get monthView => 'Vue Mensuelle';

  @override
  String get dayView => 'Vue Journalière';

  @override
  String get monthViewDescription =>
      'Différents styles pour la vue calendrier mensuel';

  @override
  String get dayViewDescription =>
      'Vue journalière avec glisser-déposer, événements à horaire et toute la journée';

  @override
  String get comingSoon => 'Bientôt disponible...';

  @override
  String get styleDefault => 'Par défaut';

  @override
  String get styleClassic => 'Classique';

  @override
  String get styleModern => 'Moderne';

  @override
  String get styleColorful => 'Coloré';

  @override
  String get styleMinimal => 'Minimal';

  @override
  String get styleMinimalDescription =>
      'Bare bones, text-only design. Maximum whitespace, minimal gridlines, subtle colors. Clean and spacious.';

  @override
  String get styleFeaturesDemo => 'Features Demo';

  @override
  String get styleFeaturesDemoDescription =>
      'Comprehensive showcase: special time regions (lunch, after-hours), blocked slots, drag-drop, resize, keyboard nav, snap-to-time. Try dropping events into blocked zones.';

  @override
  String get styleDefaultDescription =>
      'Vue journalière par défaut. Glissez les événements pour les déplacer, redimensionnez depuis les bords. Double toucher l\'espace vide pour créer. Affiche les événements diurnes et horaires.';

  @override
  String get styleClassicDescription =>
      'Grille traditionnelle avec bordures, coins carrés, couleurs uniformes. Heures de bureau 8–18, lignes de 15 minutes.';

  @override
  String get styleModernDescription =>
      'Design épuré et arrondi avec indicateurs d\'événements colorés. Heures étendues 7–21, lignes principales de 30 minutes.';

  @override
  String get styleColorfulDescription =>
      'Dégradés vibrants et couleurs vives. Plage complète de 24 heures. Esthétique ludique et créative.';

  @override
  String get styleStressTest => 'Test de Stress';

  @override
  String get styleStressTestDescription =>
      'Démonstration de performance avec 100–500 événements. Activer le mode stress, sélectionner le nombre, voir FPS et métriques. Démontre un rendu fluide avec de nombreux événements qui se chevauchent.';

  @override
  String get styleRtlDemo => 'Démo RTL';

  @override
  String get styleRtlDemoDescription =>
      'Vue journalière en mise en page de droite à gauche (arabe). Légende horaire à droite, flèches de navigation inversées. Démontre le support RTL complet pour l\'arabe et autres langues.';

  @override
  String get styleThemeCustomization => 'Personnalisation du Thème';

  @override
  String get styleThemeCustomizationDescription =>
      'Personnaliser les propriétés du thème : hauteur des heures, lignes, créneaux horaires, tuiles d\'événements, poignées de redimensionnement. Présets pour configurations courantes. Les changements s\'appliquent immédiatement.';

  @override
  String get notes => 'Notes';

  @override
  String get allDay => 'Toute la journée';

  @override
  String allDayRange(Object startDate, Object endDate) {
    return '$startDate - $endDate (Toute la journée)';
  }

  @override
  String allDaySingle(Object date) {
    return '$date (Toute la journée)';
  }

  @override
  String daysCount(Object count) {
    return '$count jours';
  }

  @override
  String hoursMinutes(Object hours, Object minutes) {
    return '$hours h $minutes min';
  }

  @override
  String hoursOnly(Object hours) {
    return '$hours h';
  }

  @override
  String minutesOnly(Object minutes) {
    return '$minutes min';
  }

  @override
  String eventMoved(Object title, Object time) {
    return 'Déplacé : $title à $time';
  }

  @override
  String eventResized(Object title, Object minutes) {
    return 'Redimensionné : $title à $minutes min';
  }

  @override
  String doubleTapCreate(Object time) {
    return 'Double toucher à $time - Créer un événement';
  }

  @override
  String eventId(Object id) {
    return 'ID de l\'événement : $id';
  }

  @override
  String externalId(Object id) {
    return 'ID externe : $id';
  }

  @override
  String eventCreated(Object title) {
    return 'Créé : $title';
  }

  @override
  String eventUpdated(Object title) {
    return 'Mis à jour : $title';
  }

  @override
  String eventDeleted(Object title) {
    return 'Supprimé : $title';
  }

  @override
  String get deleteEvent => 'Supprimer l\'événement';

  @override
  String deleteEventConfirm(Object title) {
    return 'Supprimer « $title » ?';
  }

  @override
  String get cancel => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get edit => 'Modifier';

  @override
  String get comparisonView => 'Comparaison';

  @override
  String get comparisonViewDescription =>
      'Vues mensuelle et journalière côte à côte avec données partagées';

  @override
  String get comparisonUseMonthView =>
      'Vue d\'ensemble, planification, événements multi-jours';

  @override
  String get comparisonUseDayView =>
      'Détails d\'horaire, créneaux, glisser-déposer';

  @override
  String comparisonDaySelected(Object date) {
    return 'Sélectionné $date';
  }

  @override
  String get styleAccessibility => 'Accessibility';

  @override
  String get styleAccessibilityDescription =>
      'Demonstrate accessibility features: keyboard shortcuts, screen reader support, high contrast mode. WCAG 2.1 AA compliant.';

  @override
  String get accessibilityKeyboardShortcuts => 'Keyboard Shortcuts';

  @override
  String get accessibilityShortcutCreate => 'Create event';

  @override
  String get accessibilityShortcutEdit => 'Edit event';

  @override
  String get accessibilityShortcutDelete => 'Delete event';

  @override
  String get accessibilityScreenReaderGuide => 'Screen Reader Guide';

  @override
  String get accessibilityScreenReaderInstructions =>
      'Enable VoiceOver (iOS/macOS) or TalkBack (Android) to hear semantic labels. Events announce title, time range, and duration. Navigator buttons announce Previous day, Today, Next day. Time slots announce hour. Resize handles announce Resize start edge or Resize end edge.';

  @override
  String get accessibilityChecklist => 'Accessibility Checklist';

  @override
  String get accessibilityChecklistItem1 =>
      'Semantic labels on all interactive elements';

  @override
  String get accessibilityChecklistItem2 =>
      'Keyboard navigation (Tab, Arrow keys, Enter, Escape)';

  @override
  String get accessibilityChecklistItem3 =>
      'Keyboard shortcuts (Cmd/Ctrl+N, E, D)';

  @override
  String get accessibilityChecklistItem4 => 'High contrast mode support';

  @override
  String get accessibilityChecklistItem5 =>
      'Screen reader announcements for actions';

  @override
  String get accessibilityChecklistItem6 => 'Focus indicators visible';

  @override
  String get accessibilityHighContrast => 'High Contrast Mode';

  @override
  String get accessibilityHighContrastDescription =>
      'Toggle to see high-contrast styling for low vision users.';

  @override
  String get accessibilityKeyboardNavFlow => 'Keyboard Navigation Flow';

  @override
  String get accessibilityKeyboardNavStep1 => 'Tab or click to focus Day View';

  @override
  String get accessibilityKeyboardNavStep2 =>
      'Tab to move between events chronologically';

  @override
  String get accessibilityKeyboardNavStep3 =>
      'Enter to activate (open event details)';

  @override
  String get accessibilityKeyboardNavStep4 =>
      'Cmd/Ctrl+N to create, E to edit, D to delete focused event';
}
