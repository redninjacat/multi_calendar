# Task Tracking

## Spec: example-app-reorganization

### Task 16: Feature Disparities Analysis ✓ COMPLETED

**Status:** ✅ Complete  
**Assigned Role:** Technical Analyst specializing in API comparison and gap analysis  
**Requirements:** REQ-10  
**Started:** 2026-02-15  
**Completed:** 2026-02-15

**Description:**  
Create comprehensive `feature-disparities.md` with API comparison and gap analysis between MCalDayView and MCalMonthView.

**Deliverables:**
- ✅ Complete widget parameter comparison (68 DayView, 56 MonthView parameters)
- ✅ Features Day View has but Month View lacks (with severity ratings)
- ✅ Features Month View has but Day View lacks (with severity ratings)
- ✅ API inconsistencies (naming, callback signatures, return types)
- ✅ Theme property comparison (30 DayView, 40 MonthView theme properties)
- ✅ Specific gaps highlighted with severity ratings
- ✅ Recommendations for future alignment work (14 prioritized items)
- ✅ Summary statistics and conclusion

**Key Findings:**

HIGH Severity Gaps:
- Day View: Missing onEventDoubleTap, drag callbacks return void (should be bool)
- Month View: Missing keyboard CRUD callbacks (onCreateEventRequested, onDeleteEventRequested, onEditEventRequested) and keyboardShortcuts map

MEDIUM Severity Gaps:
- Day View: Builders don't follow builder-with-default pattern, missing swipe navigation, missing cell interactivity callback
- Month View: Missing per-button navigation callbacks

API Inconsistencies:
- Naming: showWeekNumber (Day) vs showWeekNumbers (Month)
- Types: dateFormat is DateFormat in Day View, String in Month View
- Return types: onEventDropped/onEventResized return void in Day View, bool in Month View

**Artifacts:**
- feature-disparities.md (594 lines)

**Statistics:**
- Lines of analysis: 594
- Parameters analyzed: 124 (68 + 56)
- Theme properties analyzed: 70 (30 + 40)
- High-priority recommendations: 4
- Medium-priority recommendations: 5
- Low-priority recommendations: 3

**Source Files Referenced:**
- lib/src/widgets/mcal_day_view.dart
- lib/src/widgets/mcal_month_view.dart
- lib/src/styles/mcal_day_theme_data.dart
- lib/src/styles/mcal_month_theme_data.dart
