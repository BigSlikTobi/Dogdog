import 'package:flutter/foundation.dart';
import '../services/question_service.dart';
import '../services/error_service.dart';
import '../models/enums.dart';

/// Service for handling comprehensive error recovery and user guidance
/// Implements Task 10: Add comprehensive error recovery and user guidance
class CategoryErrorRecoveryService {
  static const int _minQuestionsRequired = 10;
  static const int _minQuestionsPreferred = 20;

  /// Analyzes the current category's question availability and error state
  Future<CategoryErrorAnalysis> analyzeCategoryError({
    required QuestionCategory category,
    String? locale = 'en',
  }) async {
    final questionService = QuestionService();
    final errorService = ErrorService();

    try {
      // Check if question service is initialized
      if (!questionService.isInitialized) {
        return CategoryErrorAnalysis(
          category: category,
          errorType: CategoryErrorType.criticalFailure,
          availableQuestions: 0,
          canContinue: false,
          recommendedAction: RecoveryAction.restartApp,
          userMessage:
              'The question service failed to initialize. Please restart the app.',
        );
      }

      // Get available questions for this category
      final availableQuestions = _getAvailableQuestionsCount(
        questionService,
        category,
        locale!,
      );

      // Check for localization issues
      final hasLocalizationIssues = _checkLocalizationIssues(
        questionService,
        category,
        locale,
      );

      // Analyze error severity and provide recommendations
      return _analyzeAndProvideRecommendations(
        category: category,
        availableQuestions: availableQuestions,
        hasLocalizationIssues: hasLocalizationIssues,
        locale: locale,
      );
    } catch (e) {
      errorService.recordError(
        ErrorType.gameLogic,
        'Failed to analyze category error for ${category.name}: $e',
        severity: ErrorSeverity.high,
        originalError: e,
      );

      return CategoryErrorAnalysis(
        category: category,
        errorType: CategoryErrorType.criticalFailure,
        availableQuestions: 0,
        canContinue: false,
        recommendedAction: RecoveryAction.goHome,
        userMessage:
            'Unable to analyze category status. Please return to main menu.',
      );
    }
  }

  /// Gets the count of available questions for a category
  int _getAvailableQuestionsCount(
    QuestionService questionService,
    QuestionCategory category,
    String locale,
  ) {
    try {
      if (questionService.useLocalizedQuestions) {
        final localizedQuestions = questionService
            .getLocalizedQuestionsForCategory(
              category: category,
              count: 100, // Request more than we need to get accurate count
              locale: locale,
              excludeIds: {},
            );
        return localizedQuestions.length;
      } else {
        // For legacy questions, estimate based on total available
        final allQuestions = questionService.getQuestionsForCategory(
          category: category,
          count: 100,
          locale: locale,
          excludeIds: {},
        );
        return allQuestions.length;
      }
    } catch (e) {
      debugPrint('Error counting questions for category ${category.name}: $e');
      return 0;
    }
  }

  /// Checks for localization-specific issues
  bool _checkLocalizationIssues(
    QuestionService questionService,
    QuestionCategory category,
    String locale,
  ) {
    if (!questionService.useLocalizedQuestions) {
      return false; // No localization in legacy mode
    }

    try {
      // Try to get questions in the requested locale
      final localizedQuestions = questionService
          .getLocalizedQuestionsForCategory(
            category: category,
            count: 5,
            locale: locale,
            excludeIds: {},
          );

      // Check if we got questions in the correct locale
      for (final question in localizedQuestions.take(3)) {
        final questionText = question.getText(locale);
        if (questionText.trim().isEmpty) {
          return true; // Found localization issues
        }
      }

      return false;
    } catch (e) {
      debugPrint('Error checking localization for ${category.name}: $e');
      return true; // Assume localization issues if check fails
    }
  }

  /// Analyzes the situation and provides recommendations
  CategoryErrorAnalysis _analyzeAndProvideRecommendations({
    required QuestionCategory category,
    required int availableQuestions,
    required bool hasLocalizationIssues,
    required String locale,
  }) {
    // Critical failure: No questions available
    if (availableQuestions == 0) {
      return CategoryErrorAnalysis(
        category: category,
        errorType: CategoryErrorType.noQuestions,
        availableQuestions: 0,
        canContinue: false,
        recommendedAction: RecoveryAction.switchCategory,
        userMessage:
            'No questions are available for this category. Please try a different category.',
        alternativeActions: [
          RecoveryAction.useBackupMode,
          RecoveryAction.goHome,
        ],
      );
    }

    // Localization issues
    if (hasLocalizationIssues) {
      return CategoryErrorAnalysis(
        category: category,
        errorType: CategoryErrorType.localizationError,
        availableQuestions: availableQuestions,
        canContinue: true,
        recommendedAction: RecoveryAction.useDefaultLanguage,
        userMessage:
            'Some content may not be available in your language. Would you like to continue in English?',
        alternativeActions: [
          RecoveryAction.continueAnyway,
          RecoveryAction.switchCategory,
        ],
      );
    }

    // Insufficient questions (but some available)
    if (availableQuestions < _minQuestionsRequired) {
      return CategoryErrorAnalysis(
        category: category,
        errorType: CategoryErrorType.insufficientQuestions,
        availableQuestions: availableQuestions,
        canContinue: true,
        recommendedAction: RecoveryAction.continueAnyway,
        userMessage:
            'Only $availableQuestions questions are available for this category. The game may be shorter than usual.',
        alternativeActions: [
          RecoveryAction.switchCategory,
          RecoveryAction.useBackupMode,
        ],
      );
    }

    // Limited questions (playable but not ideal)
    if (availableQuestions < _minQuestionsPreferred) {
      return CategoryErrorAnalysis(
        category: category,
        errorType: CategoryErrorType.limitedQuestions,
        availableQuestions: availableQuestions,
        canContinue: true,
        recommendedAction: RecoveryAction.continueAnyway,
        userMessage:
            'This category has limited questions ($availableQuestions available). You can still play, but variety may be reduced.',
        alternativeActions: [RecoveryAction.switchCategory],
      );
    }

    // All good
    return CategoryErrorAnalysis(
      category: category,
      errorType: CategoryErrorType.none,
      availableQuestions: availableQuestions,
      canContinue: true,
      recommendedAction: RecoveryAction.continueNormally,
      userMessage:
          'Category is ready with $availableQuestions questions available.',
    );
  }

  /// Attempts to recover from a category error
  Future<CategoryRecoveryResult> attemptRecovery({
    required CategoryErrorAnalysis analysis,
    required RecoveryAction action,
    String? fallbackLocale = 'en',
  }) async {
    final questionService = QuestionService();
    final errorService = ErrorService();

    try {
      switch (action) {
        case RecoveryAction.retry:
          await questionService.attemptRecovery();
          final newAnalysis = await analyzeCategoryError(
            category: analysis.category,
            locale: fallbackLocale,
          );
          return CategoryRecoveryResult(
            success: newAnalysis.canContinue,
            newAnalysis: newAnalysis,
            message: newAnalysis.canContinue
                ? 'Recovery successful! Questions are now available.'
                : 'Recovery failed. Please try a different approach.',
          );

        case RecoveryAction.useDefaultLanguage:
          final newAnalysis = await analyzeCategoryError(
            category: analysis.category,
            locale: 'en', // Force English
          );
          return CategoryRecoveryResult(
            success: newAnalysis.canContinue,
            newAnalysis: newAnalysis,
            message: newAnalysis.canContinue
                ? 'Switched to English. Questions are now available.'
                : 'Even English content is unavailable for this category.',
          );

        case RecoveryAction.useBackupMode:
          // In backup mode, we try to get any available questions regardless of locale/category
          try {
            questionService.reset();
            await questionService.initialize();
            return CategoryRecoveryResult(
              success: true,
              newAnalysis: analysis.copyWith(
                errorType: CategoryErrorType.none,
                canContinue: true,
                userMessage: 'Using backup question set. Content may be mixed.',
              ),
              message: 'Backup mode activated. Limited content available.',
            );
          } catch (e) {
            return CategoryRecoveryResult(
              success: false,
              newAnalysis: analysis,
              message: 'Backup mode failed to initialize.',
            );
          }

        case RecoveryAction.continueAnyway:
          return CategoryRecoveryResult(
            success: true,
            newAnalysis: analysis.copyWith(canContinue: true),
            message: 'Continuing with limited content.',
          );

        default:
          return CategoryRecoveryResult(
            success: false,
            newAnalysis: analysis,
            message: 'No automatic recovery available for this action.',
          );
      }
    } catch (e) {
      errorService.recordError(
        ErrorType.gameLogic,
        'Recovery attempt failed for action $action: $e',
        severity: ErrorSeverity.high,
        originalError: e,
      );

      return CategoryRecoveryResult(
        success: false,
        newAnalysis: analysis,
        message: 'Recovery failed due to an error: ${e.toString()}',
      );
    }
  }
}

/// Analysis result for category error state
class CategoryErrorAnalysis {
  final QuestionCategory category;
  final CategoryErrorType errorType;
  final int availableQuestions;
  final bool canContinue;
  final RecoveryAction recommendedAction;
  final String userMessage;
  final List<RecoveryAction> alternativeActions;

  const CategoryErrorAnalysis({
    required this.category,
    required this.errorType,
    required this.availableQuestions,
    required this.canContinue,
    required this.recommendedAction,
    required this.userMessage,
    this.alternativeActions = const [],
  });

  CategoryErrorAnalysis copyWith({
    QuestionCategory? category,
    CategoryErrorType? errorType,
    int? availableQuestions,
    bool? canContinue,
    RecoveryAction? recommendedAction,
    String? userMessage,
    List<RecoveryAction>? alternativeActions,
  }) {
    return CategoryErrorAnalysis(
      category: category ?? this.category,
      errorType: errorType ?? this.errorType,
      availableQuestions: availableQuestions ?? this.availableQuestions,
      canContinue: canContinue ?? this.canContinue,
      recommendedAction: recommendedAction ?? this.recommendedAction,
      userMessage: userMessage ?? this.userMessage,
      alternativeActions: alternativeActions ?? this.alternativeActions,
    );
  }
}

/// Result of attempting recovery
class CategoryRecoveryResult {
  final bool success;
  final CategoryErrorAnalysis newAnalysis;
  final String message;

  const CategoryRecoveryResult({
    required this.success,
    required this.newAnalysis,
    required this.message,
  });
}

/// Types of category-specific errors
enum CategoryErrorType {
  none,
  noQuestions,
  insufficientQuestions,
  limitedQuestions,
  localizationError,
  criticalFailure,
}

/// Available recovery actions
enum RecoveryAction {
  continueNormally,
  retry,
  switchCategory,
  useDefaultLanguage,
  useBackupMode,
  continueAnyway,
  goHome,
  restartApp,
}
