/// Generated file. Do not edit.
///
/// This file contains the localization delegates and supported locales
/// for the DogDog Trivia Game.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('de'),
    Locale('es'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'DogDog Trivia Game'**
  String get appTitle;

  /// Main welcome title on the home screen
  ///
  /// In en, this message translates to:
  /// **'Welcome to DogDog!'**
  String get homeScreen_welcomeTitle;

  /// Main button to start the quiz
  ///
  /// In en, this message translates to:
  /// **'Start Quiz'**
  String get homeScreen_startButton;

  /// Button to view achievements
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get homeScreen_achievementsButton;

  /// Title for fun questions info card
  ///
  /// In en, this message translates to:
  /// **'Fun Questions'**
  String get homeScreen_infoCard_funQuestions_title;

  /// Description for fun questions info card
  ///
  /// In en, this message translates to:
  /// **'Learn about different dog breeds and their characteristics'**
  String get homeScreen_infoCard_funQuestions_description;

  /// Title for educational info card
  ///
  /// In en, this message translates to:
  /// **'Educational'**
  String get homeScreen_infoCard_educational_title;

  /// Description for educational info card
  ///
  /// In en, this message translates to:
  /// **'Designed for children to learn while having fun'**
  String get homeScreen_infoCard_educational_description;

  /// Title for progress tracking info card
  ///
  /// In en, this message translates to:
  /// **'Progress Tracking'**
  String get homeScreen_infoCard_progress_title;

  /// Description for progress tracking info card
  ///
  /// In en, this message translates to:
  /// **'Track your progress and unlock achievements'**
  String get homeScreen_infoCard_progress_description;

  /// Title for progress section
  ///
  /// In en, this message translates to:
  /// **'Your Progress'**
  String get homeScreen_progress_title;

  /// Shows current player rank
  ///
  /// In en, this message translates to:
  /// **'Current Rank: {rank}'**
  String homeScreen_progress_currentRank(String rank);

  /// Shows next rank to achieve
  ///
  /// In en, this message translates to:
  /// **'Next: {rank}'**
  String homeScreen_progress_nextRank(String rank);

  /// Title for difficulty selection screen
  ///
  /// In en, this message translates to:
  /// **'Choose Difficulty'**
  String get difficultyScreen_title;

  /// Header text for difficulty selection
  ///
  /// In en, this message translates to:
  /// **'Choose your difficulty level'**
  String get difficultyScreen_headerTitle;

  /// Subtitle explaining difficulty differences
  ///
  /// In en, this message translates to:
  /// **'Each difficulty offers different challenges and rewards.'**
  String get difficultyScreen_headerSubtitle;

  /// Button text to select a difficulty
  ///
  /// In en, this message translates to:
  /// **'Choose this category'**
  String get difficultyScreen_selectButton;

  /// Easy difficulty level name
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get difficulty_easy;

  /// Medium difficulty level name
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get difficulty_medium;

  /// Hard difficulty level name
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get difficulty_hard;

  /// Expert difficulty level name
  ///
  /// In en, this message translates to:
  /// **'Expert'**
  String get difficulty_expert;

  /// Description for easy difficulty
  ///
  /// In en, this message translates to:
  /// **'Perfect for beginners'**
  String get difficulty_easy_description;

  /// Description for medium difficulty
  ///
  /// In en, this message translates to:
  /// **'For dog lovers'**
  String get difficulty_medium_description;

  /// Description for hard difficulty
  ///
  /// In en, this message translates to:
  /// **'For dog experts'**
  String get difficulty_hard_description;

  /// Description for expert difficulty
  ///
  /// In en, this message translates to:
  /// **'Only for professionals'**
  String get difficulty_expert_description;

  /// Points awarded per correct answer
  ///
  /// In en, this message translates to:
  /// **'{points} points per question'**
  String difficulty_points_per_question(int points);

  /// Current level display
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String gameScreen_level(int level);

  /// Loading message for game screen
  ///
  /// In en, this message translates to:
  /// **'Loading questions...'**
  String get gameScreen_loading;

  /// Score label
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get gameScreen_score;

  /// Lives label
  ///
  /// In en, this message translates to:
  /// **'Lives'**
  String get gameScreen_lives;

  /// Timer label
  ///
  /// In en, this message translates to:
  /// **'Time Remaining'**
  String get gameScreen_timeRemaining;

  /// Shows current question number out of total
  ///
  /// In en, this message translates to:
  /// **'Question {current} of {total}'**
  String gameScreen_questionCounter(int current, int total);

  /// 50/50 power-up name
  ///
  /// In en, this message translates to:
  /// **'Chew 50/50'**
  String get powerUp_fiftyFifty;

  /// Hint power-up name
  ///
  /// In en, this message translates to:
  /// **'Hint'**
  String get powerUp_hint;

  /// Extra time power-up name
  ///
  /// In en, this message translates to:
  /// **'Extra Time'**
  String get powerUp_extraTime;

  /// Skip power-up name
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get powerUp_skip;

  /// Second chance power-up name
  ///
  /// In en, this message translates to:
  /// **'Second Chance'**
  String get powerUp_secondChance;

  /// 50/50 power-up description
  ///
  /// In en, this message translates to:
  /// **'Removes two wrong answers'**
  String get powerUp_fiftyFifty_description;

  /// Hint power-up description
  ///
  /// In en, this message translates to:
  /// **'Shows a hint for the correct answer'**
  String get powerUp_hint_description;

  /// Extra time power-up description
  ///
  /// In en, this message translates to:
  /// **'Adds 10 seconds to the current question'**
  String get powerUp_extraTime_description;

  /// Skip power-up description
  ///
  /// In en, this message translates to:
  /// **'Skips to the next question without penalty'**
  String get powerUp_skip_description;

  /// Second chance power-up description
  ///
  /// In en, this message translates to:
  /// **'Restores one lost life'**
  String get powerUp_secondChance_description;

  /// Chihuahua rank name
  ///
  /// In en, this message translates to:
  /// **'Chihuahua'**
  String get rank_chihuahua;

  /// Pug rank name
  ///
  /// In en, this message translates to:
  /// **'Pug'**
  String get rank_pug;

  /// Cocker Spaniel rank name
  ///
  /// In en, this message translates to:
  /// **'Cocker Spaniel'**
  String get rank_cockerSpaniel;

  /// German Shepherd rank name
  ///
  /// In en, this message translates to:
  /// **'German Shepherd'**
  String get rank_germanShepherd;

  /// Great Dane rank name
  ///
  /// In en, this message translates to:
  /// **'Great Dane'**
  String get rank_greatDane;

  /// Chihuahua rank description
  ///
  /// In en, this message translates to:
  /// **'Small beginning - You answered your first 10 questions correctly!'**
  String get rank_chihuahua_description;

  /// Pug rank description
  ///
  /// In en, this message translates to:
  /// **'Good progress - 25 correct answers reached!'**
  String get rank_pug_description;

  /// Cocker Spaniel rank description
  ///
  /// In en, this message translates to:
  /// **'Halfway hero - 50 correct answers mastered!'**
  String get rank_cockerSpaniel_description;

  /// German Shepherd rank description
  ///
  /// In en, this message translates to:
  /// **'Loyal companion - 75 correct answers achieved!'**
  String get rank_germanShepherd_description;

  /// Great Dane rank description
  ///
  /// In en, this message translates to:
  /// **'Grand master - 100 correct answers reached!'**
  String get rank_greatDane_description;

  /// Game result: win
  ///
  /// In en, this message translates to:
  /// **'Won'**
  String get gameResult_win;

  /// Game result: lose
  ///
  /// In en, this message translates to:
  /// **'Lost'**
  String get gameResult_lose;

  /// Game result: quit
  ///
  /// In en, this message translates to:
  /// **'Quit'**
  String get gameResult_quit;

  /// Positive feedback for correct answer
  ///
  /// In en, this message translates to:
  /// **'Correct!'**
  String get feedback_correct;

  /// Negative feedback for incorrect answer
  ///
  /// In en, this message translates to:
  /// **'Incorrect'**
  String get feedback_incorrect;

  /// Message when time runs out
  ///
  /// In en, this message translates to:
  /// **'Time\'s up!'**
  String get feedback_timeUp;

  /// OK button text
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get common_ok;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get common_cancel;

  /// Retry button text
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get common_retry;

  /// Continue button text
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get common_continue;

  /// Back button text
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get common_back;

  /// Accessibility label for pause button
  ///
  /// In en, this message translates to:
  /// **'Pause game'**
  String get accessibility_pauseGame;

  /// Accessibility label for back button
  ///
  /// In en, this message translates to:
  /// **'Go back to home screen'**
  String get accessibility_goBack;

  /// Accessibility label for app logo
  ///
  /// In en, this message translates to:
  /// **'DogDog app logo'**
  String get accessibility_appLogo;

  /// Title for achievements screen
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievementsScreen_title;

  /// Button text to retry loading achievements
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get achievementsScreen_tryAgain;

  /// Button text to close achievement dialog
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get achievementsScreen_close;

  /// Title for game over screen
  ///
  /// In en, this message translates to:
  /// **'Game Over'**
  String get gameOverScreen_title;

  /// Shows the final score achieved
  ///
  /// In en, this message translates to:
  /// **'Final Score: {score}'**
  String gameOverScreen_finalScore(int score);

  /// Shows correct answers out of total
  ///
  /// In en, this message translates to:
  /// **'{correct} out of {total} correct'**
  String gameOverScreen_correctAnswers(int correct, int total);

  /// Button to start a new game
  ///
  /// In en, this message translates to:
  /// **'Play Again'**
  String get gameOverScreen_playAgain;

  /// Button to return to home screen
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get gameOverScreen_backToHome;

  /// Label for fun fact section
  ///
  /// In en, this message translates to:
  /// **'Fun Fact:'**
  String get resultScreen_funFact;

  /// Button to proceed to next question
  ///
  /// In en, this message translates to:
  /// **'Next Question'**
  String get resultScreen_nextQuestion;

  /// Button to view final results
  ///
  /// In en, this message translates to:
  /// **'View Results'**
  String get resultScreen_viewResults;

  /// Title for error recovery screen
  ///
  /// In en, this message translates to:
  /// **'Error Recovery'**
  String get errorScreen_title;

  /// Success message for service restart
  ///
  /// In en, this message translates to:
  /// **'Services restarted successfully'**
  String get errorScreen_servicesRestarted;

  /// Error message for failed service restart
  ///
  /// In en, this message translates to:
  /// **'Failed to restart services: {error}'**
  String errorScreen_restartFailed(String error);

  /// Success message for cache clearing
  ///
  /// In en, this message translates to:
  /// **'Cache cleared successfully'**
  String get errorScreen_cacheCleared;

  /// Error message for failed cache clearing
  ///
  /// In en, this message translates to:
  /// **'Failed to clear cache: {error}'**
  String errorScreen_cacheClearFailed(String error);

  /// Title for reset confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Reset to Defaults'**
  String get errorScreen_resetToDefaults;

  /// Confirmation message for resetting settings
  ///
  /// In en, this message translates to:
  /// **'This will reset all app settings to their default values. Your progress will be preserved. Continue?'**
  String get errorScreen_resetConfirmation;

  /// Button to confirm reset
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get errorScreen_reset;

  /// Success message for settings reset
  ///
  /// In en, this message translates to:
  /// **'Settings reset to defaults'**
  String get errorScreen_settingsReset;

  /// Error message for failed settings reset
  ///
  /// In en, this message translates to:
  /// **'Failed to reset settings: {error}'**
  String errorScreen_resetFailed(String error);

  /// Error message for loading failures
  ///
  /// In en, this message translates to:
  /// **'Error loading achievements: {error}'**
  String errorScreen_loadingError(String error);

  /// Notification when extra time power-up is used
  ///
  /// In en, this message translates to:
  /// **'Extra time added!'**
  String get powerUp_extraTimeAdded;

  /// Notification when skip power-up is used
  ///
  /// In en, this message translates to:
  /// **'Question skipped!'**
  String get powerUp_questionSkipped;

  /// Notification when second chance power-up is used
  ///
  /// In en, this message translates to:
  /// **'Life restored!'**
  String get powerUp_lifeRestored;

  /// Button text to use a power-up
  ///
  /// In en, this message translates to:
  /// **'Use'**
  String get powerUp_use;

  /// Message shown when achievements fail to load
  ///
  /// In en, this message translates to:
  /// **'Please try again later'**
  String get achievementsScreen_pleaseRetryLater;

  /// Title for the statistics section
  ///
  /// In en, this message translates to:
  /// **'Your Statistics'**
  String get achievementsScreen_yourStatistics;

  /// Label for correct answers statistic
  ///
  /// In en, this message translates to:
  /// **'Correct Answers'**
  String get achievementsScreen_correctAnswers;

  /// Label for accuracy statistic
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get achievementsScreen_accuracy;

  /// Label for games played statistic
  ///
  /// In en, this message translates to:
  /// **'Games Played'**
  String get achievementsScreen_gamesPlayed;

  /// Label for total score statistic
  ///
  /// In en, this message translates to:
  /// **'Total Score'**
  String get achievementsScreen_totalScore;

  /// Title for current rank section
  ///
  /// In en, this message translates to:
  /// **'Current Rank'**
  String get achievementsScreen_currentRank;

  /// Title for next rank section
  ///
  /// In en, this message translates to:
  /// **'Next Rank'**
  String get achievementsScreen_nextRank;

  /// Title when all ranks are unlocked
  ///
  /// In en, this message translates to:
  /// **'All Ranks Achieved!'**
  String get achievementsScreen_allRanksAchieved;

  /// Description when all ranks are unlocked
  ///
  /// In en, this message translates to:
  /// **'You have unlocked all available ranks. Great job!'**
  String get achievementsScreen_allRanksAchievedDescription;

  /// Title for all achievements section
  ///
  /// In en, this message translates to:
  /// **'All Achievements'**
  String get achievementsScreen_allAchievements;

  /// Shows number of correct answers required for achievement
  ///
  /// In en, this message translates to:
  /// **'{count} correct answers'**
  String achievementsScreen_correctAnswersRequired(int count);

  /// Shows how many more answers needed to unlock rank
  ///
  /// In en, this message translates to:
  /// **'{count} more correct answers to unlock'**
  String achievementsScreen_moreAnswersToUnlock(int count);

  /// Shows how many more answers needed for next rank
  ///
  /// In en, this message translates to:
  /// **'{count} more correct answers to next rank'**
  String achievementsScreen_moreAnswersToNextRank(int count);

  /// Label for required answers in achievement dialog
  ///
  /// In en, this message translates to:
  /// **'Required answers:'**
  String get achievementsScreen_requiredAnswers;

  /// Label for user's answers in achievement dialog
  ///
  /// In en, this message translates to:
  /// **'Your answers:'**
  String get achievementsScreen_yourAnswers;

  /// Label for unlock date in achievement dialog
  ///
  /// In en, this message translates to:
  /// **'Unlocked:'**
  String get achievementsScreen_unlocked;

  /// Main title for checkpoint celebration screen
  ///
  /// In en, this message translates to:
  /// **'Checkpoint Reached!'**
  String get checkpointCelebration_title;

  /// Section title for performance statistics
  ///
  /// In en, this message translates to:
  /// **'Your Performance'**
  String get checkpointCelebration_performance;

  /// Label for questions answered stat
  ///
  /// In en, this message translates to:
  /// **'Questions'**
  String get checkpointCelebration_questionsAnswered;

  /// Label for correct answers stat
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get checkpointCelebration_correctAnswers;

  /// Label for accuracy statistic
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get checkpointCelebration_accuracy;

  /// Label for points earned stat
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get checkpointCelebration_pointsEarned;

  /// Section title for earned power-ups
  ///
  /// In en, this message translates to:
  /// **'Power-ups Earned'**
  String get checkpointCelebration_powerUpsEarned;

  /// Button text to return to treasure map
  ///
  /// In en, this message translates to:
  /// **'Return to Map'**
  String get checkpointCelebration_returnToMap;

  /// Button text to continue to next questions
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get checkpointCelebration_continue;

  /// Title when entire path is completed
  ///
  /// In en, this message translates to:
  /// **'Path Completed!'**
  String get checkpointCelebration_pathCompleted;

  /// Title when checkpoint is reached
  ///
  /// In en, this message translates to:
  /// **'Checkpoint Reached!'**
  String get checkpointCelebration_checkpointReached;

  /// Section title for performance statistics
  ///
  /// In en, this message translates to:
  /// **'Performance Summary'**
  String get checkpointCelebration_performanceSummary;

  /// Label for questions answered statistic
  ///
  /// In en, this message translates to:
  /// **'Questions'**
  String get checkpointCelebration_questions;

  /// Label for points earned statistic
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get checkpointCelebration_points;

  /// Section title for earned power-ups
  ///
  /// In en, this message translates to:
  /// **'Power-Up Rewards'**
  String get checkpointCelebration_powerUpRewards;

  /// Message when no power-ups were earned
  ///
  /// In en, this message translates to:
  /// **'No power-ups earned this time'**
  String get checkpointCelebration_noPowerUps;

  /// Button text when path is completed
  ///
  /// In en, this message translates to:
  /// **'Complete Path'**
  String get checkpointCelebration_completePath;

  /// Button text to continue the journey
  ///
  /// In en, this message translates to:
  /// **'Continue Journey'**
  String get checkpointCelebration_continueJourney;

  /// Short name for 50/50 power-up
  ///
  /// In en, this message translates to:
  /// **'50/50'**
  String get powerUp_fiftyFifty_short;

  /// Short name for hint power-up
  ///
  /// In en, this message translates to:
  /// **'Hint'**
  String get powerUp_hint_short;

  /// Short name for extra time power-up
  ///
  /// In en, this message translates to:
  /// **'Extra Time'**
  String get powerUp_extraTime_short;

  /// Short name for skip power-up
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get powerUp_skip_short;

  /// Short name for second chance power-up
  ///
  /// In en, this message translates to:
  /// **'2nd Chance'**
  String get powerUp_secondChance_short;

  /// Accessibility label for checkpoint celebration animation
  ///
  /// In en, this message translates to:
  /// **'Checkpoint achievement celebration'**
  String get accessibility_checkpointCelebration;

  /// Text when the learning path is completed
  ///
  /// In en, this message translates to:
  /// **'Path Completed!'**
  String get treasureMap_pathCompleted;

  /// Button text to start the adventure
  ///
  /// In en, this message translates to:
  /// **'Start Adventure'**
  String get treasureMap_startAdventure;

  /// Button text to continue the adventure
  ///
  /// In en, this message translates to:
  /// **'Continue Adventure'**
  String get treasureMap_continueAdventure;

  /// Congratulations title in completion dialog
  ///
  /// In en, this message translates to:
  /// **'Congratulations!'**
  String get treasureMap_congratulations;

  /// Message shown when path is completed
  ///
  /// In en, this message translates to:
  /// **'You have completed this learning path! All checkpoints have been unlocked.'**
  String get treasureMap_completionMessage;

  /// Button text to continue exploring after completion
  ///
  /// In en, this message translates to:
  /// **'Continue Exploring'**
  String get treasureMap_continueExploring;

  /// Label for current path selection
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get pathSelection_current;

  /// Button text to start a path
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get pathSelection_start;

  /// Display name for dog breeds path
  ///
  /// In en, this message translates to:
  /// **'Dog Breeds'**
  String get pathType_dogBreeds_name;

  /// Description for dog breeds path
  ///
  /// In en, this message translates to:
  /// **'Learn about different dog breeds, their characteristics, and origins'**
  String get pathType_dogBreeds_description;

  /// Display name for dog training path
  ///
  /// In en, this message translates to:
  /// **'Dog Training'**
  String get pathType_dogTraining_name;

  /// Description for dog training path
  ///
  /// In en, this message translates to:
  /// **'Master dog training techniques, commands, and behavioral guidance'**
  String get pathType_dogTraining_description;

  /// Display name for health care path
  ///
  /// In en, this message translates to:
  /// **'Health & Care'**
  String get pathType_healthCare_name;

  /// Description for health care path
  ///
  /// In en, this message translates to:
  /// **'Understand dog health, nutrition, and medical care'**
  String get pathType_healthCare_description;

  /// Display name for dog behavior path
  ///
  /// In en, this message translates to:
  /// **'Dog Behavior'**
  String get pathType_dogBehavior_name;

  /// Description for dog behavior path
  ///
  /// In en, this message translates to:
  /// **'Explore dog psychology, instincts, and behavioral patterns'**
  String get pathType_dogBehavior_description;

  /// Display name for dog history path
  ///
  /// In en, this message translates to:
  /// **'Dog History'**
  String get pathType_dogHistory_name;

  /// Description for dog history path
  ///
  /// In en, this message translates to:
  /// **'Discover the history of dogs, genetics, and evolution'**
  String get pathType_dogHistory_description;

  /// Suffix for path title in treasure map
  ///
  /// In en, this message translates to:
  /// **'Adventure'**
  String get treasureMap_adventure;

  /// Format for questions remaining to checkpoint
  ///
  /// In en, this message translates to:
  /// **'{current}/{total} questions to {checkpoint}'**
  String treasureMap_questionsTo(int current, int total, String checkpoint);

  /// Label for questions
  ///
  /// In en, this message translates to:
  /// **'questions'**
  String get treasureMap_questions;

  /// Label for current rank
  ///
  /// In en, this message translates to:
  /// **'Current Rank'**
  String get treasureMap_currentRank;

  /// Message when all checkpoints are completed
  ///
  /// In en, this message translates to:
  /// **'All Completed!'**
  String get treasureMap_allCompleted;

  /// Status text when path is completed
  ///
  /// In en, this message translates to:
  /// **'Path Completed!'**
  String get treasureMap_pathCompletedStatus;

  /// Progress text showing total questions answered
  ///
  /// In en, this message translates to:
  /// **'Progress: {current}/{total} questions'**
  String treasureMap_progressQuestions(int current, int total);

  /// Text showing checkpoints completed
  ///
  /// In en, this message translates to:
  /// **'{current}/{total} checkpoints completed'**
  String treasureMap_checkpointsCompleted(int current, int total);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
