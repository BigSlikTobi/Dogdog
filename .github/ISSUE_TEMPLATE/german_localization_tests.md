---
name: Fix German localization in test setup for model tests
about: Model tests are failing because they expect German translations but get English
title: '[BUG] Model tests failing due to German localization setup'
labels: 'bug, testing, localization'
assignees: 'BigSlikTobi'

---

**Describe the bug**
Model tests in `test/models/enums_test.dart` and `test/models/achievement_test.dart` are failing because they expect German translations but the test environment is providing English translations. Tests are expecting values like "Leicht" but receiving "Easy".

**To Reproduce**
Steps to reproduce the behavior:
1. Run `flutter test test/models/`
2. Observe test failures in enum display name tests
3. See assertion errors like:
   ```
   Expected: 'Leicht'
   Actual: 'Easy'
   ```

**Expected behavior**
Model tests should either:
1. Be updated to expect English translations consistently, OR
2. Have proper German locale setup in the test environment

**Screenshots**
Test output showing localization failures:
```
Expected: 'Leicht'
Actual: 'Easy'
Which: is different.
Expected: Leicht
Actual: Easy
^
Differ at offset 0
```

**Device information:**
- Environment: Test suite (all platforms affected)
- Flutter SDK: 3.32.0
- Test Framework: Flutter Test

**Additional context**
The issue affects approximately 7-10 test cases across:
- `test/models/enums_test.dart`: Difficulty enum display names
- `test/models/enums_test.dart`: PowerUpType display names  
- `test/models/enums_test.dart`: Rank descriptions
- `test/models/enums_test.dart`: GameResult display names
- `test/models/achievement_test.dart`: Achievement titles from ranks

**Logs**
Example test failure:
```
00:00 +54 -1: /test/models/enums_test.dart: Difficulty should have correct display names in German [E]
Test failed. Expected: 'Leicht' Actual: 'Easy'
```

**Proposed Solutions**
1. Update test helper to force German locale: `TestHelper.createTestApp(locale: Locale('de'))`
2. Or update test expectations to match English translations consistently
3. Consider making tests locale-agnostic by testing enum values instead of display strings
