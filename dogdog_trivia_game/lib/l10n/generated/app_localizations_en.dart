/// Generated file. Do not edit.
///
/// This file contains the localization delegates and supported locales
/// for the DogDog Trivia Game.

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'DogDog Trivia Game';

  @override
  String get homeScreen_welcomeTitle => 'Welcome to DogDog!';

  @override
  String get homeScreen_startButton => 'Start Quiz';

  @override
  String get homeScreen_achievementsButton => 'Achievements';

  @override
  String get homeScreen_infoCard_funQuestions_title => 'Fun Questions';

  @override
  String get homeScreen_infoCard_funQuestions_description =>
      'Learn about different dog breeds and their characteristics';

  @override
  String get homeScreen_infoCard_educational_title => 'Educational';

  @override
  String get homeScreen_infoCard_educational_description =>
      'Designed for children to learn while having fun';

  @override
  String get homeScreen_infoCard_progress_title => 'Progress Tracking';

  @override
  String get homeScreen_infoCard_progress_description =>
      'Track your progress and unlock achievements';

  @override
  String get homeScreen_progress_title => 'Your Progress';

  @override
  String homeScreen_progress_currentRank(String rank) {
    return 'Current Rank: $rank';
  }

  @override
  String homeScreen_progress_nextRank(String rank) {
    return 'Next: $rank';
  }

  @override
  String get difficultyScreen_title => 'Choose Difficulty';

  @override
  String get difficultyScreen_headerTitle => 'Choose your difficulty level';

  @override
  String get difficultyScreen_headerSubtitle =>
      'Each difficulty offers different challenges and rewards.';

  @override
  String get difficultyScreen_selectButton => 'Choose this category';

  @override
  String get difficulty_easy => 'Easy';

  @override
  String get difficulty_medium => 'Medium';

  @override
  String get difficulty_hard => 'Hard';

  @override
  String get difficulty_expert => 'Expert';

  @override
  String get difficulty_easy_description => 'Perfect for beginners';

  @override
  String get difficulty_medium_description => 'For dog lovers';

  @override
  String get difficulty_hard_description => 'For dog experts';

  @override
  String get difficulty_expert_description => 'Only for professionals';

  @override
  String difficulty_points_per_question(int points) {
    return '$points points per question';
  }

  @override
  String gameScreen_level(int level) {
    return 'Level $level';
  }

  @override
  String get gameScreen_loading => 'Loading questions...';

  @override
  String get gameScreen_score => 'Score';

  @override
  String get gameScreen_lives => 'Lives';

  @override
  String get gameScreen_timeRemaining => 'Time Remaining';

  @override
  String gameScreen_questionCounter(int current, int total) {
    return 'Question $current of $total';
  }

  @override
  String get powerUp_fiftyFifty => 'Chew 50/50';

  @override
  String get powerUp_hint => 'Hint';

  @override
  String get powerUp_extraTime => 'Extra Time';

  @override
  String get powerUp_skip => 'Skip';

  @override
  String get powerUp_secondChance => 'Second Chance';

  @override
  String get powerUp_fiftyFifty_description => 'Removes two wrong answers';

  @override
  String get powerUp_hint_description => 'Shows a hint for the correct answer';

  @override
  String get powerUp_extraTime_description =>
      'Adds 10 seconds to the current question';

  @override
  String get powerUp_skip_description =>
      'Skips to the next question without penalty';

  @override
  String get powerUp_secondChance_description => 'Restores one lost life';

  @override
  String get rank_chihuahua => 'Chihuahua';

  @override
  String get rank_pug => 'Pug';

  @override
  String get rank_cockerSpaniel => 'Cocker Spaniel';

  @override
  String get rank_germanShepherd => 'German Shepherd';

  @override
  String get rank_greatDane => 'Great Dane';

  @override
  String get rank_chihuahua_description =>
      'Small beginning - You answered your first 10 questions correctly!';

  @override
  String get rank_pug_description =>
      'Good progress - 25 correct answers reached!';

  @override
  String get rank_cockerSpaniel_description =>
      'Halfway hero - 50 correct answers mastered!';

  @override
  String get rank_germanShepherd_description =>
      'Loyal companion - 75 correct answers achieved!';

  @override
  String get rank_greatDane_description =>
      'Grand master - 100 correct answers reached!';

  @override
  String get gameResult_win => 'Won';

  @override
  String get gameResult_lose => 'Lost';

  @override
  String get gameResult_quit => 'Quit';

  @override
  String get feedback_correct => 'Correct!';

  @override
  String get feedback_incorrect => 'Incorrect';

  @override
  String get feedback_timeUp => 'Time\'s up!';

  @override
  String get common_ok => 'OK';

  @override
  String get common_cancel => 'Cancel';

  @override
  String get common_retry => 'Retry';

  @override
  String get common_continue => 'Continue';

  @override
  String get common_back => 'Back';

  @override
  String get accessibility_pauseGame => 'Pause game';

  @override
  String get accessibility_goBack => 'Go back to home screen';

  @override
  String get accessibility_appLogo => 'DogDog app logo';

  @override
  String get achievementsScreen_title => 'Achievements';

  @override
  String get achievementsScreen_tryAgain => 'Try Again';

  @override
  String get achievementsScreen_close => 'Close';

  @override
  String get gameOverScreen_title => 'Game Over';

  @override
  String gameOverScreen_finalScore(int score) {
    return 'Final Score: $score';
  }

  @override
  String gameOverScreen_correctAnswers(int correct, int total) {
    return '$correct out of $total correct';
  }

  @override
  String get gameOverScreen_playAgain => 'Play Again';

  @override
  String get gameOverScreen_backToHome => 'Back to Home';

  @override
  String get resultScreen_funFact => 'Fun Fact:';

  @override
  String get resultScreen_nextQuestion => 'Next Question';

  @override
  String get resultScreen_viewResults => 'View Results';

  @override
  String get errorScreen_title => 'Error Recovery';

  @override
  String get errorScreen_servicesRestarted => 'Services restarted successfully';

  @override
  String errorScreen_restartFailed(String error) {
    return 'Failed to restart services: $error';
  }

  @override
  String get errorScreen_cacheCleared => 'Cache cleared successfully';

  @override
  String errorScreen_cacheClearFailed(String error) {
    return 'Failed to clear cache: $error';
  }

  @override
  String get errorScreen_resetToDefaults => 'Reset to Defaults';

  @override
  String get errorScreen_resetConfirmation =>
      'This will reset all app settings to their default values. Your progress will be preserved. Continue?';

  @override
  String get errorScreen_reset => 'Reset';

  @override
  String get errorScreen_settingsReset => 'Settings reset to defaults';

  @override
  String errorScreen_resetFailed(String error) {
    return 'Failed to reset settings: $error';
  }

  @override
  String errorScreen_loadingError(String error) {
    return 'Error loading achievements: $error';
  }

  @override
  String get powerUp_extraTimeAdded => 'Extra time added!';

  @override
  String get powerUp_questionSkipped => 'Question skipped!';

  @override
  String get powerUp_lifeRestored => 'Life restored!';

  @override
  String get powerUp_use => 'Use';

  @override
  String get achievementsScreen_pleaseRetryLater => 'Please try again later';

  @override
  String get achievementsScreen_yourStatistics => 'Your Statistics';

  @override
  String get achievementsScreen_correctAnswers => 'Correct Answers';

  @override
  String get achievementsScreen_accuracy => 'Accuracy';

  @override
  String get achievementsScreen_gamesPlayed => 'Games Played';

  @override
  String get achievementsScreen_totalScore => 'Total Score';

  @override
  String get achievementsScreen_currentRank => 'Current Rank';

  @override
  String get achievementsScreen_nextRank => 'Next Rank';

  @override
  String get achievementsScreen_allRanksAchieved => 'All Ranks Achieved!';

  @override
  String get achievementsScreen_allRanksAchievedDescription =>
      'You have unlocked all available ranks. Great job!';

  @override
  String get achievementsScreen_allAchievements => 'All Achievements';

  @override
  String achievementsScreen_correctAnswersRequired(int count) {
    return '$count correct answers';
  }

  @override
  String achievementsScreen_moreAnswersToUnlock(int count) {
    return '$count more correct answers to unlock';
  }

  @override
  String achievementsScreen_moreAnswersToNextRank(int count) {
    return '$count more correct answers to next rank';
  }

  @override
  String get achievementsScreen_requiredAnswers => 'Required answers:';

  @override
  String get achievementsScreen_yourAnswers => 'Your answers:';

  @override
  String get achievementsScreen_unlocked => 'Unlocked:';

  @override
  String get checkpointCelebration_title => 'Checkpoint Reached!';

  @override
  String get checkpointCelebration_performance => 'Your Performance';

  @override
  String get checkpointCelebration_questionsAnswered => 'Questions';

  @override
  String get checkpointCelebration_correctAnswers => 'Correct';

  @override
  String get checkpointCelebration_accuracy => 'Accuracy';

  @override
  String get checkpointCelebration_pointsEarned => 'Points';

  @override
  String get checkpointCelebration_powerUpsEarned => 'Power-ups Earned';

  @override
  String get checkpointCelebration_returnToMap => 'Return to Map';

  @override
  String get checkpointCelebration_continue => 'Continue';

  @override
  String get checkpointCelebration_pathCompleted => 'Path Completed!';

  @override
  String get checkpointCelebration_checkpointReached => 'Checkpoint Reached!';

  @override
  String get checkpointCelebration_performanceSummary => 'Performance Summary';

  @override
  String get checkpointCelebration_questions => 'Questions';

  @override
  String get checkpointCelebration_points => 'Points';

  @override
  String get checkpointCelebration_powerUpRewards => 'Power-Up Rewards';

  @override
  String get checkpointCelebration_noPowerUps =>
      'No power-ups earned this time';

  @override
  String get checkpointCelebration_completePath => 'Complete Path';

  @override
  String get checkpointCelebration_continueJourney => 'Continue Journey';

  @override
  String get powerUp_fiftyFifty_short => '50/50';

  @override
  String get powerUp_hint_short => 'Hint';

  @override
  String get powerUp_extraTime_short => 'Extra Time';

  @override
  String get powerUp_skip_short => 'Skip';

  @override
  String get powerUp_secondChance_short => '2nd Chance';

  @override
  String get accessibility_checkpointCelebration =>
      'Checkpoint achievement celebration';

  @override
  String get treasureMap_pathCompleted => 'Path Completed!';

  @override
  String get treasureMap_startAdventure => 'Start Adventure';

  @override
  String get treasureMap_continueAdventure => 'Continue Adventure';

  @override
  String get treasureMap_congratulations => 'Congratulations!';

  @override
  String get treasureMap_completionMessage =>
      'You have completed this learning path! All checkpoints have been unlocked.';

  @override
  String get treasureMap_continueExploring => 'Continue Exploring';

  @override
  String get pathSelection_current => 'Current';

  @override
  String get pathSelection_start => 'Start';

  @override
  String get pathType_dogBreeds_name => 'Dog Breeds';

  @override
  String get pathType_dogBreeds_description =>
      'Learn about different dog breeds, their characteristics, and origins';

  @override
  String get pathType_dogTraining_name => 'Dog Training';

  @override
  String get pathType_dogTraining_description =>
      'Master dog training techniques, commands, and behavioral guidance';

  @override
  String get pathType_healthCare_name => 'Health & Care';

  @override
  String get pathType_healthCare_description =>
      'Understand dog health, nutrition, and medical care';

  @override
  String get pathType_dogBehavior_name => 'Dog Behavior';

  @override
  String get pathType_dogBehavior_description =>
      'Explore dog psychology, instincts, and behavioral patterns';

  @override
  String get pathType_dogHistory_name => 'Dog History';

  @override
  String get pathType_dogHistory_description =>
      'Discover the history of dogs, genetics, and evolution';

  @override
  String get treasureMap_adventure => 'Adventure';

  @override
  String treasureMap_questionsTo(int current, int total, String checkpoint) {
    return '$current/$total questions to $checkpoint';
  }

  @override
  String get treasureMap_questions => 'questions';

  @override
  String get treasureMap_currentRank => 'Current Rank';

  @override
  String get treasureMap_allCompleted => 'All Completed!';

  @override
  String get treasureMap_pathCompletedStatus => 'Path Completed!';

  @override
  String treasureMap_progressQuestions(int current, int total) {
    return 'Progress: $current/$total questions';
  }

  @override
  String treasureMap_checkpointsCompleted(int current, int total) {
    return '$current/$total checkpoints completed';
  }

  @override
  String get breedAdventure_title => 'Dog Breeds Adventure';

  @override
  String get breedAdventure_description =>
      'Test your knowledge by identifying dog breeds from photos';

  @override
  String get breedAdventure_whichImageShows => 'Which image shows a';

  @override
  String get breedAdventure_gameInitializing =>
      'Preparing your breed adventure...';

  @override
  String get breedAdventure_loadingImages => 'Loading breed images...';

  @override
  String get breedAdventure_gamePaused => 'Game Paused';

  @override
  String get breedAdventure_pauseMessage =>
      'The game is paused. Tap Resume to continue.';

  @override
  String get breedAdventure_resume => 'Resume';

  @override
  String get breedAdventure_exitGame => 'Exit Game';

  @override
  String get breedAdventure_adventureComplete => 'Adventure Complete!';

  @override
  String get breedAdventure_finalScore => 'Final Score';

  @override
  String get breedAdventure_correct => 'Correct';

  @override
  String get breedAdventure_accuracy => 'Accuracy';

  @override
  String get breedAdventure_phase => 'Phase';

  @override
  String get breedAdventure_playAgain => 'Play Again';

  @override
  String get breedAdventure_home => 'Home';

  @override
  String get breedAdventure_powerUps => 'Power-ups';

  @override
  String get breedAdventure_lives => 'Lives';

  @override
  String get breedAdventure_progress => 'Progress';

  @override
  String get breedAdventure_timeRemaining => 'Time Remaining';

  @override
  String get breedAdventure_hintTitle => 'Breed Hint';

  @override
  String get breedAdventure_powerUpEarned => 'Power-up Earned!';

  @override
  String get breedAdventure_connectionProblem => 'Connection Problem';

  @override
  String get breedAdventure_connectionMessage =>
      'Unable to load images. Please check your internet connection and try again.';

  @override
  String get breedAdventure_imageLoadFailed => 'Image Load Failed';

  @override
  String get breedAdventure_imageLoadMessage =>
      'The breed images could not be loaded. This might be a temporary issue.';

  @override
  String get breedAdventure_phaseComplete => 'Phase Complete!';

  @override
  String breedAdventure_phaseCompleteMessage(String phase) {
    return 'You\'ve completed all breeds in the $phase phase. Great job!';
  }

  @override
  String get breedAdventure_nextPhase => 'Next Phase';

  @override
  String get breedAdventure_restartGame => 'Restart Game';

  @override
  String get breedAdventure_skip => 'Skip';

  @override
  String get breedAdventure_sec => 'sec';

  @override
  String get breedAdventure_powerUpHint_celebration =>
      'Breed knowledge revealed! 🧠';

  @override
  String get breedAdventure_powerUpExtraTime_celebration =>
      'Extra time granted! ⏰';

  @override
  String get breedAdventure_powerUpSkip_celebration =>
      'Question skipped successfully! ⏭️';

  @override
  String get breedAdventure_powerUpSecondChance_celebration =>
      'Life restored! ❤️';

  @override
  String get breedAdventure_powerUpHint_description =>
      'Reveals helpful information about the breed\'s characteristics and history.';

  @override
  String get breedAdventure_powerUpExtraTime_description =>
      'Adds 5 extra seconds to the current question timer.';

  @override
  String get breedAdventure_powerUpSkip_description =>
      'Skip the current question without losing a life.';

  @override
  String get breedAdventure_powerUpSecondChance_description =>
      'Restores one life when you make an incorrect answer.';

  @override
  String get difficultyPhase_beginner => 'Beginner';

  @override
  String get difficultyPhase_intermediate => 'Intermediate';

  @override
  String get difficultyPhase_expert => 'Expert';

  @override
  String get pathType_breedAdventure_name => 'Breed Adventure';

  @override
  String get pathType_breedAdventure_description =>
      'Identify dog breeds from photos in this exciting visual challenge';
}
