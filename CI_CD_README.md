# CI/CD Setup for DogDog Trivia Game

This document describes the Continuous Integration and Continuous Deployment (CI/CD) setup for the DogDog Trivia Game Flutter project.

## Overview

The CI/CD pipeline ensures code quality, runs comprehensive tests, and builds the application automatically for every pull request and push to the main branch.

## GitHub Actions Workflows

### 1. Main CI/CD Pipeline (`.github/workflows/ci-cd.yml`)

**Triggers:**
- Push to `main` or `develop` branches
- Pull requests to `main` branch

**Jobs:**

#### Test Job
- Runs on Ubuntu latest
- Installs Flutter and dependencies
- Performs code analysis (`flutter analyze`)
- Checks code formatting (`dart format`)
- Generates localization files
- Runs unit tests with coverage
- Uploads coverage to Codecov

#### Build Android Job
- Builds release APK
- Uploads APK as artifact
- Requires test job to pass first

#### Build iOS Job  
- Builds iOS app (no code signing for CI)
- Runs on macOS
- Uploads build artifacts
- Requires test job to pass first

#### Security Scan Job
- Runs dependency audit
- Performs security scanning with Semgrep
- Checks for vulnerabilities and secrets

### 2. Branch Protection (`.github/workflows/branch-protection.yml`)

Automatically sets up branch protection rules for the main branch:
- Requires status checks to pass (Test, Build Android, Security Scan)
- Requires at least 1 review for pull requests
- Dismisses stale reviews when new commits are pushed
- Prevents force pushes and branch deletion

## Pre-commit Hooks

The `.pre-commit-config.yaml` file sets up local pre-commit hooks that run:
- Trailing whitespace removal
- End of file fixing
- YAML validation
- Large file detection
- Merge conflict detection
- Flutter analysis
- Code formatting
- Tests

### Setting up pre-commit hooks locally:

```bash
# Install pre-commit
pip install pre-commit

# Install the hooks
pre-commit install

# Run hooks on all files (optional)
pre-commit run --all-files
```

## Test Helper

A test helper class (`test/helpers/test_helper.dart`) provides utilities for:
- Creating test widgets with proper localization setup
- Setting up provider dependencies
- Consistent test app configuration

### Usage:

```dart
// For basic widget tests
await tester.pumpWidget(
  TestHelper.createBasicTestApp(MyWidget()),
);

// For tests requiring ProgressService
await tester.pumpWidget(
  TestHelper.createTestAppWithProgressService(MyScreen()),
);

// For tests requiring custom providers
await tester.pumpWidget(
  TestHelper.createTestApp(
    MyWidget(),
    providers: [
      ChangeNotifierProvider(create: (_) => MyService()),
    ],
  ),
);
```

## Local Test Runner

Use the `scripts/run_tests.sh` script to run the complete test suite locally:

```bash
./scripts/run_tests.sh
```

This script will:
1. Check Flutter installation
2. Install dependencies
3. Generate localization files
4. Run code analysis
5. Check formatting
6. Run unit tests with coverage
7. Generate coverage report
8. Run integration tests

## Test Coverage

- Coverage reports are generated automatically during CI
- HTML coverage reports can be generated locally with `genhtml`
- Coverage is uploaded to Codecov for tracking over time

## Branch Protection Rules

The main branch is protected with the following rules:
- All status checks must pass before merging
- At least 1 review is required for pull requests
- Stale reviews are dismissed when new commits are pushed
- Force pushes are not allowed
- Direct pushes to main are not allowed (must use pull requests)

## Required Checks

Before any code can be merged to main, these checks must pass:
- ✅ Test job (unit tests, integration tests, analysis, formatting)
- ✅ Build Android APK job
- ✅ Security Scan job

## Fixing Common Test Issues

### Localization Errors
If you see `Null check operator used on a null value` related to `AppLocalizations.of()`:

```dart
// ❌ Wrong - Missing localization setup
await tester.pumpWidget(MaterialApp(home: MyWidget()));

// ✅ Correct - Using test helper
await tester.pumpWidget(TestHelper.createBasicTestApp(MyWidget()));
```

### Provider Errors
For widgets that require providers:

```dart
// ✅ Use TestHelper with providers
await tester.pumpWidget(
  TestHelper.createTestAppWithProgressService(MyWidget()),
);
```

### Widget Finding Issues
Make sure your widgets have proper test keys or semantic labels:

```dart
// In widget code
Semantics(
  label: 'My button',
  child: ElevatedButton(...),
)

// In tests
expect(find.bySemanticsLabel('My button'), findsOneWidget);
```

## Environment Setup

### Required Software:
- Flutter SDK (3.24.0 or later)
- Dart SDK (included with Flutter)
- Git
- For coverage reports: `lcov` package

### Optional Tools:
- pre-commit (for local hooks)
- genhtml (for HTML coverage reports)

## Getting Started

1. Clone the repository
2. Install Flutter dependencies: `flutter pub get`
3. Set up pre-commit hooks: `pre-commit install`
4. Run tests locally: `./scripts/run_tests.sh`
5. Create a feature branch and push your changes
6. Open a pull request to main branch
7. Ensure all CI checks pass before requesting review

## Troubleshooting

### CI Failing on Flutter Analysis
- Run `flutter analyze` locally to see issues
- Fix all analysis issues before pushing

### Tests Failing in CI but Passing Locally
- Ensure you're using the test helper for proper setup
- Check that all dependencies are properly declared
- Verify localization files are generated (`flutter gen-l10n`)

### Build Failures
- Check that all assets are properly declared in `pubspec.yaml`
- Ensure all imports are correct
- Verify platform-specific dependencies are handled properly
