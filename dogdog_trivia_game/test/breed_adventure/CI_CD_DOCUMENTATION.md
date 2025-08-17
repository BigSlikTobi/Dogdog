# Breed Adventure CI/CD Integration

This document describes the CI/CD setup for the Dog Breeds Adventure feature.

## Overview

The Breed Adventure CI/CD pipeline is designed to run automatically when changes are made to breed adventure specific files, ensuring code quality and test coverage without affecting the broader application pipeline.

## Workflow Triggers

The pipeline runs on:

### Push Events
- Branches: `main`, `develop`, `tests/dog_breed_adventure-CICD`
- Specific file paths:
  - `dogdog_trivia_game/lib/models/breed_adventure/**`
  - `dogdog_trivia_game/lib/controllers/breed_adventure/**`
  - `dogdog_trivia_game/lib/services/breed_adventure/**`
  - `dogdog_trivia_game/lib/widgets/breed_adventure/**`
  - `dogdog_trivia_game/lib/screens/dog_breeds_adventure_screen.dart`
  - `dogdog_trivia_game/test/breed_adventure/**`
  - Shared dependencies and configuration files

### Pull Request Events
- Target branches: `main`, `develop`
- Same file path triggers as push events

### Manual Trigger
- `workflow_dispatch` allows manual execution for testing

## Pipeline Stages

### 1. 📚 Code Checkout
- Uses `actions/checkout@v4`
- Retrieves latest code from repository

### 2. 🚀 Flutter Setup
- Uses `subosito/flutter-action@v2`
- Flutter version: `3.32.8` (stable channel)
- Enables caching for faster builds

### 3. 📦 Dependencies
- Runs `flutter pub get`
- Installs all project dependencies

### 4. 🔍 Environment Verification
- Runs `flutter doctor -v`
- Ensures Flutter environment is properly configured

### 5. 🧹 Code Formatting
- Checks formatting for breed adventure files only
- Uses `dart format --set-exit-if-changed`
- Fails pipeline if formatting issues are found

### 6. 🔍 Static Analysis
- Analyzes breed adventure specific directories
- Reports issues but doesn't fail the pipeline (info level)
- Covers: models, controllers, services, widgets, screens, tests

### 7. 🌐 Localization Generation
- Generates localization files using `flutter gen-l10n`
- Required for proper test execution

### 8. 📊 Test Structure Verification
- Counts unit and integration test files
- Provides feedback on test coverage structure
- Warns if test count is unexpectedly low

### 9. 🧪 Unit Tests
- Runs `test/breed_adventure/unit/` tests
- Generates coverage report
- Uses expanded reporter for detailed output

### 10. 🔗 Integration Tests
- Runs `test/breed_adventure/integration/` tests
- Continues coverage collection
- Tests complete feature workflows

### 11. 📈 Coverage Analysis
- Analyzes coverage specifically for breed adventure files
- Calculates per-file coverage percentages
- Enforces coverage threshold (90%)
- Provides detailed coverage breakdown

### 12. 📤 Artifact Upload
- Uploads coverage reports as GitHub artifacts
- Retains artifacts for 7 days
- Accessible for download and review

### 13. 📊 Codecov Integration
- Uploads coverage to Codecov service
- Tagged as `breed-adventure` for filtering
- Provides external coverage tracking

### 14. 🚦 Quality Gate
- Separate job that checks main test results
- Prevents deployment if tests fail
- Provides clear pass/fail status

## Coverage Requirements

### Threshold
- **Minimum Coverage**: 90%
- **Scope**: Breed adventure specific files
- **Enforcement**: Pipeline fails if threshold not met

### Tracked Files
The following breed adventure files are tracked for coverage:
- `lib/models/breed_adventure/*.dart`
- `lib/controllers/breed_adventure/*.dart`
- `lib/services/breed_adventure/*.dart`
- `lib/widgets/breed_adventure/*.dart`
- `lib/screens/dog_breeds_adventure_screen.dart`

### Current Coverage Status
Based on latest test run:
- **Models**: 100% (breed_challenge, difficulty_phase)
- **Services**: 97.3% (timer), 39.2% (breed_service), 0% (localization)
- **Controllers**: 7.4% (main controller), 3.4% (power-up controller)
- **Widgets**: 85.8% (score_progress), 0-11.5% (others)

## Local Testing

### Prerequisites
```bash
cd dogdog_trivia_game
flutter pub get
```

### Run CI/CD Simulation
```bash
# From project root
./scripts/test_breed_adventure_cicd.sh
```

### Manual Test Commands
```bash
# Code formatting
dart format --set-exit-if-changed lib/models/breed_adventure/ lib/controllers/breed_adventure/ lib/services/breed_adventure/ lib/widgets/breed_adventure/ lib/screens/dog_breeds_adventure_screen.dart test/breed_adventure/

# Static analysis
flutter analyze lib/models/breed_adventure/ lib/controllers/breed_adventure/ lib/services/breed_adventure/ lib/widgets/breed_adventure/ lib/screens/dog_breeds_adventure_screen.dart test/breed_adventure/

# Run tests with coverage
flutter test test/breed_adventure/ --coverage

# Check coverage
grep -E "SF:.*breed_adventure" coverage/lcov.info
```

## Environment Variables

### CI/CD Configuration
- `FLUTTER_VERSION`: `3.32.8`
- `COVERAGE_THRESHOLD`: `90`

### Runtime Settings
- **Timeout**: 15 minutes per job
- **Runner**: `ubuntu-latest`
- **Parallel Execution**: Unit and integration tests run sequentially

## Failure Scenarios

### Common Failure Points
1. **Code Formatting**: Files not properly formatted
2. **Test Failures**: Unit or integration tests failing
3. **Coverage Below Threshold**: < 90% coverage
4. **Missing Dependencies**: Flutter setup issues

### Recovery Actions
1. **Formatting Issues**: Run `dart format` locally
2. **Test Failures**: Check test output in job logs
3. **Coverage Issues**: Add tests for uncovered code
4. **Environment Issues**: Check Flutter doctor output

## Monitoring and Alerts

### GitHub Integration
- Status checks appear on pull requests
- Branch protection can be configured to require passing tests
- Artifacts available for download after each run

### Codecov Integration
- Coverage trends tracked over time
- Pull request coverage diffs
- Team notifications for coverage changes

## Future Enhancements

### Planned Improvements
1. **Performance Testing**: Add performance benchmarks
2. **Visual Regression**: Screenshot comparisons
3. **Device Testing**: Multiple Flutter versions
4. **Security Scanning**: Dependency vulnerability checks

### Configuration Options
1. **Dynamic Thresholds**: Adjust coverage requirements by file type
2. **Conditional Execution**: Skip tests for documentation-only changes
3. **Parallel Testing**: Split test execution for faster feedback

## Troubleshooting

### Pipeline Not Triggering
- Check file paths in commit
- Verify branch names match configuration
- Ensure GitHub Actions are enabled

### Coverage Issues
- Verify test files are executable
- Check for missing test imports
- Ensure coverage collection is enabled

### Test Failures
- Run tests locally first
- Check for missing dependencies
- Verify asset files are available

## Security Considerations

### Sensitive Data
- No secrets required for basic testing
- Coverage reports contain code structure information
- Artifacts are accessible to repository collaborators

### Access Control
- Workflow runs with standard GitHub token permissions
- No external service authentication required
- Codecov integration uses public uploads

## Performance Metrics

### Typical Execution Times
- **Setup**: ~30 seconds
- **Dependencies**: ~15 seconds
- **Tests**: ~2-5 minutes
- **Coverage**: ~10 seconds
- **Total**: ~3-6 minutes

### Resource Usage
- **Memory**: Standard GitHub runner limits
- **CPU**: Single-threaded test execution
- **Storage**: Coverage artifacts ~5-10MB

This CI/CD setup ensures that the Dog Breeds Adventure feature maintains high quality and test coverage while providing fast feedback to developers.
