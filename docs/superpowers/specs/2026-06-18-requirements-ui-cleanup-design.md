# Requirements-Driven Flutter UI Cleanup Design

## Context

This design applies three new requirement documents to the Flutter app in `D:\Study\SU26\PRM393\App\Flutter_UI`:

1. `D:\Study\SU26\PRM393\Quan_ly_tieu_de_va_thong_bao_trong_Flutter.docx`
2. `D:\Study\SU26\PRM393\Tach_UI_thanh_cac_widget_nho_trong_Flutter.docx`
3. `D:\Study\SU26\PRM393\Tieu_chi_cham_code_ung_dung_mobile.docx`

The repo already has a workable structure with `models`, `providers`, `services`, `screens`, and `widgets`, and the current baseline passes:

- `flutter test`
- `flutter analyze`

The main gaps against the new requirements are:

- user-facing strings are still scattered as hardcoded literals across screens
- route names are still repeated as raw string literals
- several screens still have large, UI-heavy `build()` methods
- some screen copy is inconsistent in wording and language

## Goal

Bring the current Flutter app into alignment with the new requirements by centralizing reusable strings and route names, reducing large screen-level UI blocks into smaller widgets, and preserving existing behavior with focused regression tests.

## Non-Goals

- no full feature-folder migration
- no state-management rewrite
- no backend contract changes
- no visual redesign beyond wording/structure cleanup needed to satisfy the requirements

## Requirements Mapping

### 1. Centralized titles, labels, and messages

Add a constants layer under `lib/core/constants/`:

- `app_strings.dart`
- `app_routes.dart`

`AppStrings` will hold reusable:

- app title text
- screen titles
- common button labels
- form labels and hints
- success/error/empty-state messages
- dialog titles and action text

`AppRoutes` will replace repeated route literals such as:

- `/`
- `/login`
- `/register`
- `/home`

Dynamic text that depends on runtime values will stay dynamic, but its static base text should come from `AppStrings` where practical.

### 2. Smaller, clearer UI widgets

Refactor the most UI-heavy screens first:

- `lib/screens/login_screen.dart`
- `lib/screens/register_screen.dart`
- `lib/screens/menu_screen.dart`
- `lib/screens/checkout_screen.dart`
- `lib/screens/reservation_screen.dart`

The intent is not to move all screens into new folders immediately, but to split large `build()` methods into smaller private or shared widgets with clear responsibilities, such as:

- header sections
- form sections
- summary cards
- action rows
- product tiles / search bars / category filters

Selection rule: extract sections that are visually meaningful, repeated, or large enough to reduce screen complexity. Do not split every tiny `Text` or `SizedBox`.

### 3. Cleaner code against the grading rubric

The cleanup should improve the rubric dimensions most directly touched by the requirement docs:

- project structure clarity
- readability and naming
- widget decomposition
- code reuse through constants
- navigation consistency
- basic maintainability

The existing `providers` and `services` separation already satisfies part of the “logic away from UI” guidance, so this work will preserve that structure rather than rewrite it.

## Design Decisions

### Decision A: Use constants instead of full localization

Use `AppStrings` now, not Flutter localization.

Reason:

- the requirement document explicitly recommends a constants file as the right starting point for a student project
- this is the smallest complete change that satisfies the requirement
- it avoids a larger i18n migration that is outside the user’s requested scope

### Decision B: Use `AppRoutes` only for named routes already supported

Replace existing named-route string literals with `AppRoutes` constants, while leaving direct `MaterialPageRoute` navigation intact where screens require object arguments or where converting it would cause unnecessary routing churn.

Reason:

- satisfies the route-centralization requirement
- avoids turning this task into a full navigation architecture rewrite

### Decision C: Extract widgets in place first

Refactor large screens by introducing smaller widgets in the current screen file first, or move them into `lib/widgets/` only if reuse becomes clear during extraction.

Reason:

- keeps the diff focused
- reduces risk
- aligns with the requirement to split UI into meaningful smaller widgets without over-engineering

## Planned File Changes

### New files

- `lib/core/constants/app_strings.dart`
- `lib/core/constants/app_routes.dart`

### Primary modified files

- `lib/main.dart`
- `lib/screens/login_screen.dart`
- `lib/screens/register_screen.dart`
- `lib/screens/menu_screen.dart`
- `lib/screens/checkout_screen.dart`
- `lib/screens/reservation_screen.dart`
- `lib/screens/home_screen.dart`
- `lib/screens/more_screen.dart`
- `lib/screens/cart_screen.dart`
- `lib/screens/notifications_screen.dart`
- `lib/screens/profile_screen.dart`
- `lib/screens/reservation_history_screen.dart`
- `lib/screens/store_location_screen.dart`
- `lib/screens/chat_screen.dart`

Additional screen/widget files may be touched where hardcoded titles, labels, snackbar text, dialog text, or empty/error copy still violate the requirement documents.

### Test updates

- `test/widget_test.dart`

If the current single test file becomes too broad, add a focused new test file for constants- or screen-level behavior instead of bloating one file further.

## Data Flow / Behavior Impact

This work should not change core app flows:

- login
- registration
- menu browsing
- cart add/update flow
- checkout submission
- reservation lookup and booking

Allowed behavior adjustments:

- standardized button/label/message wording
- centralized route usage
- smaller internal widget composition

Any user-visible behavior change beyond wording/structure cleanup is out of scope unless it is required to keep the refactor correct.

## Error Handling

Existing provider/service error handling remains the source of truth.

This task may standardize:

- empty-state copy
- retry labels
- dialog titles
- snackbar messages

It should not change backend error semantics unless a touched screen requires a small fix to keep the UI accurate after extraction.

## Testing Strategy

Follow TDD for any changed behavior:

1. add or update a test that proves the intended requirement-aligned outcome
2. run the failing test
3. implement the minimal change
4. rerun the test
5. run broader verification once the set is complete

Required final verification:

- `flutter test`
- `flutter analyze`

## Risks and Mitigations

### Risk: over-refactoring

Mitigation:

- keep extractions local and purposeful
- do not reorganize the whole project
- avoid changing provider/service contracts unless required

### Risk: missed hardcoded strings

Mitigation:

- sweep screens/widgets for app bars, buttons, hints, snackbars, dialogs, empty-state text, and route literals
- verify affected files after constants are introduced

### Risk: regressions from widget extraction

Mitigation:

- preserve existing state ownership in parent screens
- pass only required values/callbacks into extracted widgets
- keep validation focused with tests and analyzer

## Success Criteria

This work is successful when:

1. reusable app copy and named routes are centralized instead of scattered literals
2. the largest targeted screens have meaningfully smaller, clearer UI composition
3. the app still passes `flutter test` and `flutter analyze`
4. the resulting code more clearly matches the three requirement documents without a broad rewrite
