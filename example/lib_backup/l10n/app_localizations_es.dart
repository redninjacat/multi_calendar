// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Multi Calendario';

  @override
  String get toggleTheme => 'Cambiar tema';

  @override
  String get changeLanguage => 'Cambiar idioma';

  @override
  String get languageEnglish => 'Inglés';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageFrench => 'Francés';

  @override
  String get languageArabic => 'Árabe (RTL)';

  @override
  String get languageHebrew => 'Hebreo (RTL)';

  @override
  String get monthView => 'Vista Mensual';

  @override
  String get dayView => 'Vista Diaria';

  @override
  String get monthViewDescription =>
      'Diferentes estilos para la vista de calendario mensual';

  @override
  String get dayViewDescription =>
      'Vista diaria con arrastrar y soltar, eventos diarios y con horario';

  @override
  String get comingSoon => 'Próximamente...';

  @override
  String get styleDefault => 'Predeterminado';

  @override
  String get styleClassic => 'Clásico';

  @override
  String get styleModern => 'Moderno';

  @override
  String get styleColorful => 'Colorido';

  @override
  String get styleMinimal => 'Minimal';

  @override
  String get styleMinimalDescription =>
      'Bare bones, text-only design. Maximum whitespace, minimal gridlines, subtle colors. Clean and spacious.';

  @override
  String get styleFeaturesDemo => 'Características';

  @override
  String get styleFeaturesDemoDescription =>
      'Demostración completa: regiones horarias especiales (almuerzo, después de horas), ranuras bloqueadas, arrastrar y soltar, redimensionar, navegación por teclado, ajustar a tiempo. Intenta soltar eventos en zonas bloqueadas.';

  @override
  String get styleDefaultDescription =>
      'Vista diaria predeterminada. Arrastra eventos para mover, redimensiona desde los bordes. Doble toque en espacio vacío para crear. Muestra eventos diarios y con horario.';

  @override
  String get styleClassicDescription =>
      'Cuadrícula tradicional con bordes, esquinas cuadradas, colores uniformes. Horario comercial 8–18, líneas de 15 minutos.';

  @override
  String get styleModernDescription =>
      'Diseño limpio y redondeado con indicadores de eventos coloridos. Horario extendido 7–21, líneas principales de 30 minutos.';

  @override
  String get styleColorfulDescription =>
      'Degradados vibrantes y colores llamativos. Rango completo de 24 horas. Estética divertida y creativa.';

  @override
  String get styleStressTest => 'Prueba de Estrés';

  @override
  String get styleStressTestDescription =>
      'Demostración de rendimiento con 100–500 eventos. Activar modo estrés, seleccionar cantidad, ver FPS y métricas. Demuestra renderizado fluido con muchos eventos superpuestos.';

  @override
  String get styleRtlDemo => 'Demo RTL';

  @override
  String get styleRtlDemoDescription =>
      'Vista diaria en diseño de derecha a izquierda (árabe). Leyenda de tiempo a la derecha, flechas del navegador invertidas. Demuestra soporte RTL completo para árabe y otros idiomas.';

  @override
  String get styleThemeCustomization => 'Personalización de Tema';

  @override
  String get styleThemeCustomizationDescription =>
      'Personalizar propiedades del tema: altura de hora, líneas, ranuras de tiempo, fichas de eventos, asas de redimensionar. Presets para configuraciones comunes. Los cambios se aplican inmediatamente.';

  @override
  String get notes => 'Notas';

  @override
  String get allDay => 'Todo el día';

  @override
  String allDayRange(Object startDate, Object endDate) {
    return '$startDate - $endDate (Todo el día)';
  }

  @override
  String allDaySingle(Object date) {
    return '$date (Todo el día)';
  }

  @override
  String daysCount(Object count) {
    return '$count días';
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
    return 'Movido: $title a $time';
  }

  @override
  String eventResized(Object title, Object minutes) {
    return 'Redimensionado: $title a $minutes min';
  }

  @override
  String doubleTapCreate(Object time) {
    return 'Doble toque a las $time - Crear evento';
  }

  @override
  String eventId(Object id) {
    return 'ID del evento: $id';
  }

  @override
  String externalId(Object id) {
    return 'ID externo: $id';
  }

  @override
  String eventCreated(Object title) {
    return 'Creado: $title';
  }

  @override
  String eventUpdated(Object title) {
    return 'Actualizado: $title';
  }

  @override
  String eventDeleted(Object title) {
    return 'Eliminado: $title';
  }

  @override
  String get deleteEvent => 'Eliminar Evento';

  @override
  String deleteEventConfirm(Object title) {
    return '¿Eliminar \"$title\"?';
  }

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get edit => 'Editar';

  @override
  String get comparisonView => 'Comparación';

  @override
  String get comparisonViewDescription =>
      'Vistas mensual y diaria lado a lado con datos compartidos';

  @override
  String get comparisonUseMonthView =>
      'Resumen, planificación, eventos de varios días';

  @override
  String get comparisonUseDayView =>
      'Detalles de horario, franjas horarias, arrastrar y soltar';

  @override
  String comparisonDaySelected(Object date) {
    return 'Seleccionado $date';
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
