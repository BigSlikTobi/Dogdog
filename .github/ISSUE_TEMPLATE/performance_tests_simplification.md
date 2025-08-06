---
name: Simplify performance tests to avoid animation timing issues
about: Performance tests are failing due to animation timing and localization conflicts
title: '[BUG] Performance tests failing with animation timing and localization errors'
labels: 'bug, testing, performance'
assignees: 'BigSlikTobi'

---

**Describe the bug**
Performance tests in `test/utils/performance_test.dart` and `test/utils/comprehensive_performance_test.dart` are failing due to:
1. Animation timing issues causing `pumpAndSettle` timeouts
2. Null check operators failing on localization context
3. Widget overflow errors during responsive layout testing

**To Reproduce**
Steps to reproduce the behavior:
1. Run `flutter test test/utils/performance_test.dart`
2. Run `flutter test test/utils/comprehensive_performance_test.dart`
3. Observe multiple failures:
   - `pumpAndSettle timed out` errors
   - `Null check operator used on a null value` in AppLocalizations
   - `RenderFlex overflowed by 232 pixels` layout errors

**Expected behavior**
Performance tests should:
1. Complete without timing out on animations
2. Have proper localization context setup
3. Handle responsive layout changes without overflow errors
4. Provide meaningful performance metrics

**Screenshots**
Example error output:
```
══╡ EXCEPTION CAUGHT BY FLUTTER TEST FRAMEWORK ╞════════
The following assertion was thrown running a test:
pumpAndSettle timed out

══╡ EXCEPTION CAUGHT BY WIDGETS LIBRARY ╞═══════════════
Null check operator used on a null value
AppLocalizations.of (package:dogdog_trivia_game/l10n/generated/app_localizations.dart:77:73)
_HomeScreenState._buildWelcomeText (package:dogdog_trivia_game/screens/home_screen.dart:240:28)
```

**Device information:**
- Environment: Test suite (all platforms affected)  
- Flutter SDK: 3.32.0
- Test Framework: Flutter Test
- Tests affected: ~23 failing out of ~53 total performance tests

**Additional context**
The performance tests are trying to test complex UI scenarios including:
- Responsive layout changes with MediaQuery
- Animation performance during screen transitions
- Cross-platform widget performance
- Text rendering at different scales

These tests are currently too complex and brittle for reliable CI/CD execution.

**Logs**
```
00:04 +37 -21: performance_test.dart: should maintain 60 FPS during responsive layout changes
00:05 +53 -22: comprehensive_performance_test.dart: Platform-specific widget performance [E]
pumpAndSettle timed out
00:05 +53 -23: comprehensive_performance_test.dart: Text rendering performance with different scales [E]
RenderFlex overflowed by 232 pixels on the bottom
```

**Proposed Solutions**
1. Simplify performance tests to focus on core metrics only
2. Add proper localization setup using existing test helpers
3. Replace complex animation tests with unit tests for performance-critical code
4. Consider mocking heavy UI components for performance testing
5. Add timeout handling and skip tests that require complex UI setup
6. Focus on business logic performance rather than UI animation performance
