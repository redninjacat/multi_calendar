# AGENTS.md

## Cursor Cloud specific instructions

### Overview

This is **Multi Calendar** (`multi_calendar`), a Flutter UI package providing Day View, Multi-Day View, and Month View calendar widgets with RFC 5545 RRULE support. It is a pure Dart/Flutter library with no backend services, databases, or external dependencies.

### Project structure

- `/workspace/` — Main Flutter package (library)
- `/workspace/example/` — Demo Flutter app depending on the package via `path: ../`
- `/workspace/test/` — 1496 unit/widget/integration tests

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
