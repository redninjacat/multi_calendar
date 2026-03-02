# AGENTS.md

## Cursor Cloud specific instructions

### Overview

This is **Multi Calendar** (`multi_calendar`), a Flutter UI package providing Day View, Multi-Day View, and Month View calendar widgets with RFC 5545 RRULE support. It is a pure Dart/Flutter library with no backend services, databases, or external dependencies.

### Project structure

- `/workspace/` — Main Flutter package (library)
- `/workspace/example/` — Demo Flutter app depending on the package via `path: ../`
- `/workspace/test/` — 1496 unit/widget/integration tests
- `/workspace/.spec-workflow/` — Spec-workflow documents (see below)

### Prerequisites

- **Flutter SDK** must be installed at `/opt/flutter` and on `PATH`. The project requires Dart SDK `^3.10.4`. Flutter 3.41.0 (Dart 3.11.0) is confirmed compatible.
- No Docker, databases, or external services needed.

### Common commands

| Task | Command | Notes |
|------|---------|-------|
| Install deps | `flutter pub get` | Run from `/workspace`; also resolves `example/` deps |
| Lint | `flutter analyze` | Expect only `info`-level issues (no errors/warnings) |
| Test | `flutter test` | Run from `/workspace`; 1496 tests |
| Build example (web) | `cd example && flutter build web` | Outputs to `example/build/web/` |
| Serve example | `python3 -m http.server 8080 --directory example/build/web` | Then open `http://localhost:8080` |
| Run example (dev) | `cd example && flutter run -d chrome` | Interactive dev mode in Chrome |

### Gotchas

- **Golden tests**: 3 golden image tests (`goldens/time_legend_*.png`) may fail with tiny pixel diffs (~0.2%) in cloud environments due to font rendering differences. These are not code bugs.
- **`flutter: generate: true`**: Both `pubspec.yaml` files enable l10n code generation. `flutter pub get` handles this automatically; no separate `flutter gen-l10n` step is needed.
- **No version pinning files**: There are no `.fvm`, `.tool-versions`, or `.flutter-version` files. The Dart SDK constraint `^3.10.4` in `pubspec.yaml` is the canonical version requirement.

---

## Spec-Workflow Integration

This project uses [spec-workflow-mcp](https://github.com/Pimzino/spec-workflow-mcp) for structured, spec-driven development. The MCP server runs locally and is **not available to cloud agents**. However, all spec-workflow data lives in committed files under `.spec-workflow/`, so cloud agents can and should interact with them directly via the filesystem.

### Directory layout

```
.spec-workflow/
├── steering/           # Project-level vision and standards (read before any feature work)
│   ├── product.md      # Product purpose, target users, key features, principles
│   ├── tech.md         # Technology stack, performance targets, architectural decisions
│   └── structure.md    # Directory organization, naming conventions, code size guidelines
├── templates/          # Document templates for creating new specs
│   ├── requirements-template.md
│   ├── design-template.md
│   ├── tasks-template.md
│   ├── product-template.md
│   ├── tech-template.md
│   └── structure-template.md
├── user-templates/     # Project-specific template overrides (currently empty)
├── specs/              # Active specs (created by MCP server when a spec is in progress)
├── approvals/          # Approval metadata (JSON files tracking review status)
└── archive/            # Completed specs, organized by feature name
    └── specs/
        └── <feature-name>/
            ├── requirements.md
            ├── design.md
            ├── tasks.md
            └── Implementation Logs/
```

### Before implementing a feature

1. **Read steering docs first.** The three files in `.spec-workflow/steering/` define project-wide standards that all implementations must follow:
   - `product.md` — What Multi Calendar is, who it's for, what's in/out of scope
   - `tech.md` — Dart/Flutter conventions, performance requirements (60fps, O(log n) lookups, <100ms startup), architectural decisions and rationale
   - `structure.md` — File naming (`snake_case.dart`), class naming (`MCal` prefix for public widgets/themes), import order, code size limits (500 lines/file, 50 lines/function), test structure

2. **Check for an existing spec.** Look in `.spec-workflow/specs/` (active) or `.spec-workflow/archive/specs/` for a spec matching the feature. If one exists, read its `requirements.md`, `design.md`, and `tasks.md` before writing any code.

3. **Check for related archived specs.** Past specs in `.spec-workflow/archive/specs/` provide context on how similar features were designed and implemented. The `Implementation Logs/` subdirectories contain per-task logs with code statistics.

### Spec document roles

Each spec contains three documents that serve distinct purposes:

- **`requirements.md`** — *What* to build. User stories with WHEN/THEN/SHALL acceptance criteria. Defines the success contract. Do not deviate from these without explicit instruction.
- **`design.md`** — *How* to build it. Architecture, component interfaces, data models, error handling, testing strategy. References steering docs for alignment. Includes code reuse analysis showing which existing files to leverage or extend.
- **`tasks.md`** — *Execution plan.* Ordered, numbered task list. Each task specifies:
  - Target file(s)
  - What to implement
  - `_Leverage:_` — existing code to build upon
  - `_Requirements:_` — which acceptance criteria this task satisfies
  - `_Prompt:_` — detailed implementation prompt with Role/Task/Restrictions/Success criteria
  - Checkbox status: `[ ]` pending, `[-]` in progress, `[x]` done

### Writing new spec documents (cloud agent workflow)

When asked to create a spec for a new feature, write the documents directly as files. Follow this process:

1. **Use the templates.** Copy structure from `.spec-workflow/templates/requirements-template.md`, `design-template.md`, and `tasks-template.md`. Check `.spec-workflow/user-templates/` first for project-specific overrides.
2. **Align with steering docs.** Reference `product.md` for scope validation, `tech.md` for technical constraints, and `structure.md` for naming/organization.
3. **Write files to `.spec-workflow/specs/<feature-name>/`.** Create `requirements.md` first, then `design.md`, then `tasks.md` — they build on each other sequentially.
4. **Cross-reference.** Design should cite specific requirements. Tasks should cite specific requirements and design sections. Tasks should identify existing code to leverage.
5. **Commit and push.** The local MCP dashboard will pick up the new files when the user runs it.

### Implementing tasks from a spec

When asked to implement a feature that has a spec:

1. Read all three spec documents (`requirements.md`, `design.md`, `tasks.md`).
2. Follow the task list in order — tasks are sequenced to manage dependencies.
3. For each task, follow the `_Prompt:_` field which contains detailed implementation guidance.
4. Respect `_Leverage:_` references — these point to existing code patterns to follow.
5. Validate against `_Requirements:_` acceptance criteria when done.
6. Update the task checkbox in `tasks.md`: mark `[-]` when starting, `[x]` when complete.

### Key conventions from steering docs

These are the most important standards from the steering documents that apply to all work:

- **`MCal` prefix** on all public widget and theme class names (e.g., `MCalDayView`, `MCalThemeData`)
- **Delegation pattern** — the package handles display only; storage/CRUD is the consuming app's responsibility
- **Builder callbacks** for all visual customization — never hardcode appearance
- **`Semantics` widgets** throughout for accessibility (VoiceOver/TalkBack)
- **RTL support** via `Directionality.of(context)` for Arabic and Hebrew
- **Dual localization** — package uses `MCalLocalizations.of(context)` (gen-l10n from `lib/l10n/`); example app uses separate `AppLocalizations.of(context)` (gen-l10n from `example/lib/l10n/`)
- **Code size limits** — max 500 lines/file, 50 lines/function, 4 levels of nesting
- **Performance targets** — 60fps rendering, <100ms startup, <50ms touch response, O(log n) event lookups
- **DST-safe date arithmetic** — see section below

### DST-safe date/time arithmetic

All date arithmetic MUST use the DST-safe utilities in `lib/src/utils/date_utils.dart` instead of `Duration`-based arithmetic. This is critical because `Duration(days: 1)` adds exactly 24 wall-clock hours, which lands on the wrong calendar day at DST boundaries.

**Required utilities** (from `date_utils.dart`):

| Utility | Use instead of | Why |
|---------|---------------|-----|
| `addDays(date, n)` | `date.add(Duration(days: n))` | Calendar-day shift preserving time-of-day across DST |
| `dateOnly(date)` | `DateTime(d.year, d.month, d.day)` | Consistent date-only extraction |
| `daysBetween(from, to)` | `to.difference(from).inDays` | UTC-based day count, not affected by DST |

**Rules:**
- NEVER use `date.add(Duration(days: n))` for shifting by calendar days — use `addDays(date, n)`
- NEVER use `a.difference(b).inDays` to count calendar days — use `daysBetween(a, b)`
- For computing end times of expanded recurring events/regions, use calendar-day constructor arithmetic: `DateTime(start.year, start.month, start.day + daySpan, start.hour + hourDelta, ...)` — the `DateTime` constructor handles overflow correctly
- Import as `import '../utils/date_utils.dart' as date_utils;` when in `lib/src/` subdirectories (the prefix avoids conflicts with `dart:core`)
