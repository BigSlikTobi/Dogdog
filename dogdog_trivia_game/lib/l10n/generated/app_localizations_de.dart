/// Generated file. Do not edit.
///
/// This file contains the localization delegates and supported locales
/// for the DogDog Trivia Game.

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'DogDog Trivia Spiel';

  @override
  String get homeScreen_welcomeTitle => 'Willkommen bei DogDog!';

  @override
  String get homeScreen_startButton => 'Quiz starten';

  @override
  String get homeScreen_achievementsButton => 'Erfolge';

  @override
  String get homeScreen_infoCard_funQuestions_title => 'Lustige Fragen';

  @override
  String get homeScreen_infoCard_funQuestions_description =>
      'Lerne verschiedene Hunderassen und ihre Eigenschaften kennen';

  @override
  String get homeScreen_infoCard_educational_title => 'Lehrreich';

  @override
  String get homeScreen_infoCard_educational_description =>
      'Für Kinder entwickelt, um beim Spielen zu lernen';

  @override
  String get homeScreen_infoCard_progress_title => 'Fortschrittsverfolgung';

  @override
  String get homeScreen_infoCard_progress_description =>
      'Verfolge deinen Fortschritt und schalte Erfolge frei';

  @override
  String get homeScreen_progress_title => 'Dein Fortschritt';

  @override
  String homeScreen_progress_currentRank(String rank) {
    return 'Aktueller Rang: $rank';
  }

  @override
  String homeScreen_progress_nextRank(String rank) {
    return 'Nächster: $rank';
  }

  @override
  String get difficultyScreen_title => 'Schwierigkeit wählen';

  @override
  String get difficultyScreen_headerTitle => 'Wähle deinen Schwierigkeitsgrad';

  @override
  String get difficultyScreen_headerSubtitle =>
      'Jeder Schwierigkeitsgrad bietet verschiedene Herausforderungen und Belohnungen.';

  @override
  String get difficultyScreen_selectButton => 'Diese Kategorie wählen';

  @override
  String get difficulty_easy => 'Leicht';

  @override
  String get difficulty_medium => 'Mittel';

  @override
  String get difficulty_hard => 'Schwer';

  @override
  String get difficulty_expert => 'Experte';

  @override
  String get difficulty_easy_description => 'Perfekt für Anfänger';

  @override
  String get difficulty_medium_description => 'Für Hundeliebhaber';

  @override
  String get difficulty_hard_description => 'Für Hundeexperten';

  @override
  String get difficulty_expert_description => 'Nur für Profis';

  @override
  String difficulty_points_per_question(int points) {
    return '$points Punkte pro Frage';
  }

  @override
  String gameScreen_level(int level) {
    return 'Level $level';
  }

  @override
  String get gameScreen_loading => 'Lade Fragen...';

  @override
  String get gameScreen_score => 'Punkte';

  @override
  String get gameScreen_lives => 'Leben';

  @override
  String get gameScreen_timeRemaining => 'Verbleibende Zeit';

  @override
  String gameScreen_questionCounter(int current, int total) {
    return 'Frage $current von $total';
  }

  @override
  String get powerUp_fiftyFifty => 'Kau 50/50';

  @override
  String get powerUp_hint => 'Hinweis';

  @override
  String get powerUp_extraTime => 'Extra Zeit';

  @override
  String get powerUp_skip => 'Überspringen';

  @override
  String get powerUp_secondChance => 'Zweite Chance';

  @override
  String get powerUp_fiftyFifty_description =>
      'Entfernt zwei falsche Antworten';

  @override
  String get powerUp_hint_description =>
      'Zeigt einen Hinweis für die richtige Antwort';

  @override
  String get powerUp_extraTime_description =>
      'Fügt 10 Sekunden zur aktuellen Frage hinzu';

  @override
  String get powerUp_skip_description =>
      'Springt zur nächsten Frage ohne Strafe';

  @override
  String get powerUp_secondChance_description =>
      'Stellt ein verlorenes Leben wieder her';

  @override
  String get rank_chihuahua => 'Chihuahua';

  @override
  String get rank_pug => 'Mops';

  @override
  String get rank_cockerSpaniel => 'Cocker Spaniel';

  @override
  String get rank_germanShepherd => 'Deutscher Schäferhund';

  @override
  String get rank_greatDane => 'Deutsche Dogge';

  @override
  String get rank_chihuahua_description =>
      'Kleiner Anfang - Du hast deine ersten 10 Fragen richtig beantwortet!';

  @override
  String get rank_pug_description =>
      'Guter Fortschritt - 25 richtige Antworten erreicht!';

  @override
  String get rank_cockerSpaniel_description =>
      'Halbzeit-Held - 50 richtige Antworten gemeistert!';

  @override
  String get rank_germanShepherd_description =>
      'Treuer Begleiter - 75 richtige Antworten erreicht!';

  @override
  String get rank_greatDane_description =>
      'Großmeister - 100 richtige Antworten erreicht!';

  @override
  String get gameResult_win => 'Gewonnen';

  @override
  String get gameResult_lose => 'Verloren';

  @override
  String get gameResult_quit => 'Beendet';

  @override
  String get feedback_correct => 'Richtig!';

  @override
  String get feedback_incorrect => 'Falsch';

  @override
  String get feedback_timeUp => 'Zeit ist um!';

  @override
  String get common_ok => 'OK';

  @override
  String get common_cancel => 'Abbrechen';

  @override
  String get common_retry => 'Wiederholen';

  @override
  String get common_continue => 'Weiter';

  @override
  String get common_back => 'Zurück';

  @override
  String get accessibility_pauseGame => 'Spiel pausieren';

  @override
  String get accessibility_goBack => 'Zurück zum Startbildschirm';

  @override
  String get accessibility_appLogo => 'DogDog App-Logo';

  @override
  String get achievementsScreen_title => 'Erfolge';

  @override
  String get achievementsScreen_tryAgain => 'Erneut versuchen';

  @override
  String get achievementsScreen_close => 'Schließen';

  @override
  String get gameOverScreen_title => 'Spiel beendet';

  @override
  String gameOverScreen_finalScore(int score) {
    return 'Endpunktzahl: $score';
  }

  @override
  String gameOverScreen_correctAnswers(int correct, int total) {
    return '$correct von $total richtig';
  }

  @override
  String get gameOverScreen_playAgain => 'Nochmal spielen';

  @override
  String get gameOverScreen_backToHome => 'Zurück zum Start';

  @override
  String get resultScreen_funFact => 'Wissenswertes:';

  @override
  String get resultScreen_nextQuestion => 'Nächste Frage';

  @override
  String get resultScreen_viewResults => 'Ergebnisse anzeigen';

  @override
  String get errorScreen_title => 'Fehlerwiederherstellung';

  @override
  String get errorScreen_servicesRestarted =>
      'Dienste erfolgreich neu gestartet';

  @override
  String errorScreen_restartFailed(String error) {
    return 'Neustart der Dienste fehlgeschlagen: $error';
  }

  @override
  String get errorScreen_cacheCleared => 'Cache erfolgreich geleert';

  @override
  String errorScreen_cacheClearFailed(String error) {
    return 'Cache-Leerung fehlgeschlagen: $error';
  }

  @override
  String get errorScreen_resetToDefaults => 'Auf Standard zurücksetzen';

  @override
  String get errorScreen_resetConfirmation =>
      'Dies setzt alle App-Einstellungen auf ihre Standardwerte zurück. Dein Fortschritt bleibt erhalten. Fortfahren?';

  @override
  String get errorScreen_reset => 'Zurücksetzen';

  @override
  String get errorScreen_settingsReset =>
      'Einstellungen auf Standard zurückgesetzt';

  @override
  String errorScreen_resetFailed(String error) {
    return 'Zurücksetzen der Einstellungen fehlgeschlagen: $error';
  }

  @override
  String errorScreen_loadingError(String error) {
    return 'Fehler beim Laden der Erfolge: $error';
  }

  @override
  String get errorCriticalTitle => 'Critical Error';

  @override
  String get errorCriticalMessage =>
      'A critical error has occurred that prevents the game from functioning properly. Please restart the app.';

  @override
  String get errorLocalizationTitle => 'Language Issue';

  @override
  String get errorLocalizationMessage =>
      'Some content may not be available in your selected language. Would you like to continue in English?';

  @override
  String get errorNoQuestionsTitle => 'No Questions Available';

  @override
  String errorNoQuestionsForCategoryMessage(String category) {
    return 'No questions are available for $category. Please try a different category.';
  }

  @override
  String errorFewQuestionsMessage(int count) {
    return 'Only $count questions are available for this category. The game may be shorter than usual.';
  }

  @override
  String get errorLoadingTitle => 'Loading Issue';

  @override
  String get errorGenericMessage =>
      'An unexpected error occurred. Please try again.';

  @override
  String get errorActionRetry => 'Try Again';

  @override
  String get errorActionSwitchCategory => 'Choose Different Category';

  @override
  String errorActionContinueAnyway(int count) {
    return 'Continue with $count Questions';
  }

  @override
  String get errorActionUseDefaultLanguage => 'Use English Instead';

  @override
  String get errorActionGoHome => 'Return to Main Menu';

  @override
  String get powerUp_extraTimeAdded => 'Extra Zeit hinzugefügt!';

  @override
  String get powerUp_questionSkipped => 'Frage übersprungen!';

  @override
  String get powerUp_lifeRestored => 'Ein Leben wiederhergestellt!';

  @override
  String get powerUp_use => 'Verwenden';

  @override
  String get achievementsScreen_pleaseRetryLater =>
      'Bitte versuche es später erneut';

  @override
  String get achievementsScreen_yourStatistics => 'Deine Statistiken';

  @override
  String get achievementsScreen_correctAnswers => 'Richtige Antworten';

  @override
  String get achievementsScreen_accuracy => 'Genauigkeit';

  @override
  String get achievementsScreen_gamesPlayed => 'Gespielte Spiele';

  @override
  String get achievementsScreen_totalScore => 'Rekord';

  @override
  String get achievementsScreen_currentRank => 'Aktueller Rang';

  @override
  String get achievementsScreen_nextRank => 'Nächster Rang';

  @override
  String get achievementsScreen_allRanksAchieved => 'Alle Ränge erreicht!';

  @override
  String get achievementsScreen_allRanksAchievedDescription =>
      'Du hast alle verfügbaren Ränge freigeschaltet. Großartige Arbeit!';

  @override
  String get achievementsScreen_allAchievements => 'Alle Erfolge';

  @override
  String achievementsScreen_correctAnswersRequired(int count) {
    return '$count richtige Antworten';
  }

  @override
  String achievementsScreen_moreAnswersToUnlock(int count) {
    return '$count weitere richtige Antworten zum Freischalten';
  }

  @override
  String achievementsScreen_moreAnswersToNextRank(int count) {
    return '$count weitere richtige Antworten zum nächsten Rang';
  }

  @override
  String get achievementsScreen_requiredAnswers => 'Erforderliche Antworten:';

  @override
  String get achievementsScreen_yourAnswers => 'Deine Antworten:';

  @override
  String get achievementsScreen_unlocked => 'Freigeschaltet:';

  @override
  String get checkpointCelebration_title => 'Checkpoint erreicht!';

  @override
  String get checkpointCelebration_performance => 'Deine Leistung';

  @override
  String get checkpointCelebration_questionsAnswered => 'Fragen';

  @override
  String get checkpointCelebration_correctAnswers => 'Richtig';

  @override
  String get checkpointCelebration_accuracy => 'Genauigkeit';

  @override
  String get checkpointCelebration_pointsEarned => 'Punkte';

  @override
  String get checkpointCelebration_powerUpsEarned => 'Verdiente Power-Ups';

  @override
  String get checkpointCelebration_returnToMap => 'Zur Karte zurück';

  @override
  String get checkpointCelebration_continue => 'Weiter';

  @override
  String get checkpointCelebration_pathCompleted => 'Pfad abgeschlossen!';

  @override
  String get checkpointCelebration_checkpointReached => 'Checkpoint erreicht!';

  @override
  String get checkpointCelebration_performanceSummary => 'Leistungsübersicht';

  @override
  String get checkpointCelebration_questions => 'Fragen';

  @override
  String get checkpointCelebration_points => 'Punkte';

  @override
  String get checkpointCelebration_powerUpRewards => 'Power-Up Belohnungen';

  @override
  String get checkpointCelebration_noPowerUps =>
      'Diesmal keine Power-Ups verdient';

  @override
  String get checkpointCelebration_completePath => 'Pfad Abschließen';

  @override
  String get checkpointCelebration_continueJourney => 'Reise Fortsetzen';

  @override
  String get powerUp_fiftyFifty_short => '50/50';

  @override
  String get powerUp_hint_short => 'Hinweis';

  @override
  String get powerUp_extraTime_short => 'Extra Zeit';

  @override
  String get powerUp_skip_short => 'Überspringen';

  @override
  String get powerUp_secondChance_short => '2. Chance';

  @override
  String get accessibility_checkpointCelebration => 'Checkpoint-Erfolg Feier';

  @override
  String get treasureMap_pathCompleted => 'Pfad Abgeschlossen!';

  @override
  String get treasureMap_startAdventure => 'Abenteuer Starten';

  @override
  String get treasureMap_continueAdventure => 'Abenteuer Fortsetzen';

  @override
  String get treasureMap_congratulations => 'Herzlichen Glückwunsch!';

  @override
  String get treasureMap_completionMessage =>
      'Du hast diesen Lernpfad abgeschlossen! Alle Checkpoints wurden freigeschaltet.';

  @override
  String get treasureMap_continueExploring => 'Weiter Erkunden';

  @override
  String get pathSelection_current => 'Aktuell';

  @override
  String get pathSelection_start => 'Starten';

  @override
  String get pathType_dogTrivia_name => 'Hunde Quiz';

  @override
  String get pathType_dogTrivia_description =>
      'Lerne verschiedene Hunderassen, ihre Eigenschaften und Ursprünge kennen';

  @override
  String get pathType_puppyQuest_name => 'Welpen raten';

  @override
  String get pathType_puppyQuest_description =>
      'Teste deine Rassenerkennung mit zeitlich begrenzten Bildherausforderungen';

  @override
  String get pathType_dogBreeds_name => 'Hunderassen';

  @override
  String get pathType_dogBreeds_description =>
      'Lerne verschiedene Hunderassen, ihre Eigenschaften und Ursprünge kennen';

  @override
  String get pathType_dogTraining_name => 'Hundetraining';

  @override
  String get pathType_dogTraining_description =>
      'Meistere Hundetraining-Techniken, Kommandos und Verhaltensführung';

  @override
  String get pathType_healthCare_name => 'Gesundheit & Pflege';

  @override
  String get pathType_healthCare_description =>
      'Verstehe Hundegesundheit, Ernährung und medizinische Versorgung';

  @override
  String get pathType_dogBehavior_name => 'Hundeverhalten';

  @override
  String get pathType_dogBehavior_description =>
      'Erkunde Hundepsychologie, Instinkte und Verhaltensmuster';

  @override
  String get pathType_dogHistory_name => 'Hundegeschichte';

  @override
  String get pathType_dogHistory_description =>
      'Entdecke die Geschichte der Hunde, Genetik und Evolution';

  @override
  String get pathType_breedAdventure_name => 'Rassen-Abenteuer';

  @override
  String get pathType_breedAdventure_description =>
      'Teste dein Wissen durch Identifizierung von Hunderassen anhand von Fotos';

  @override
  String get treasureMap_adventure => 'Abenteuer';

  @override
  String treasureMap_questionsTo(int current, int total, String checkpoint) {
    return '$current/$total Fragen bis $checkpoint';
  }

  @override
  String get treasureMap_questions => 'questions';

  @override
  String get treasureMap_currentRank => 'Current Rank';

  @override
  String get treasureMap_allCompleted => 'All Completed!';

  @override
  String get treasureMap_pathCompletedStatus => 'Pfad Abgeschlossen!';

  @override
  String treasureMap_progressQuestions(int current, int total) {
    return 'Fortschritt: $current/$total Fragen';
  }

  @override
  String treasureMap_checkpointsCompleted(int current, int total) {
    return '$current/$total Checkpoints abgeschlossen';
  }

  @override
  String get breedAdventure_title => 'Hunderassen-Abenteuer';

  @override
  String get breedAdventure_description =>
      'Teste dein Wissen, indem du Hunderassen anhand von Fotos identifizierst';

  @override
  String get breedAdventure_whichImageShows => 'Welches Bild zeigt einen';

  @override
  String get breedAdventure_gameInitializing =>
      'Bereite dein Hunderassen-Abenteuer vor...';

  @override
  String get breedAdventure_loadingImages => 'Lade Hunderassen-Bilder...';

  @override
  String get breedAdventure_gamePaused => 'Spiel Pausiert';

  @override
  String get breedAdventure_pauseMessage =>
      'Das Spiel ist pausiert. Tippe auf Fortsetzen, um weiterzumachen.';

  @override
  String get breedAdventure_resume => 'Fortsetzen';

  @override
  String get breedAdventure_exitGame => 'Spiel Beenden';

  @override
  String get breedAdventure_adventureComplete => 'Abenteuer Abgeschlossen!';

  @override
  String get breedAdventure_finalScore => 'Punkte';

  @override
  String get breedAdventure_correct => 'Richtig';

  @override
  String get breedAdventure_accuracy => 'Genauigkeit';

  @override
  String get breedAdventure_phase => 'Phase';

  @override
  String get breedAdventure_playAgain => 'Nochmal Spielen';

  @override
  String get breedAdventure_home => 'Start';

  @override
  String get breedAdventure_powerUps => 'Power-Ups';

  @override
  String get breedAdventure_lives => 'Leben';

  @override
  String get category_dogTraining => 'Hundetraining';

  @override
  String get category_dogBreeds => 'Hunderassen';

  @override
  String get category_dogBehavior => 'Hundeverhalten';

  @override
  String get category_dogTraining_description =>
      'Meistere Hundetrainingstechniken, Kommandos und Verhaltensführung';

  @override
  String get category_dogBreeds_description =>
      'Lerne verschiedene Hunderassen, ihre Eigenschaften und Ursprünge kennen';

  @override
  String get category_dogBehavior_description =>
      'Erkunde Hundepsychologie, Instinkte und Verhaltensmuster';

  @override
  String get difficulty_easyPlus => 'Leicht+';

  @override
  String get difficulty_easyPlus_description =>
      'Etwas herausfordernder als leicht';

  @override
  String treasureMap_startCategoryAdventure(String category) {
    return '$category Abenteuer Starten';
  }

  @override
  String treasureMap_continueCategoryAdventure(String category) {
    return '$category Abenteuer Fortsetzen';
  }

  @override
  String get breedAdventure_progress => 'Fortschritt';

  @override
  String get breedAdventure_timeRemaining => 'Verbleibende Zeit';

  @override
  String get breedAdventure_hintTitle => 'Rassen-Hinweis';

  @override
  String get breedAdventure_powerUpEarned => 'Power-Up Verdient!';

  @override
  String get breedAdventure_connectionProblem => 'Verbindungsproblem';

  @override
  String get breedAdventure_connectionMessage =>
      'Bilder können nicht geladen werden. Bitte überprüfe deine Internetverbindung und versuche es erneut.';

  @override
  String get breedAdventure_imageLoadFailed => 'Bild-Laden Fehlgeschlagen';

  @override
  String get breedAdventure_imageLoadMessage =>
      'Die Hunderassen-Bilder konnten nicht geladen werden. Dies könnte ein vorübergehendes Problem sein.';

  @override
  String get breedAdventure_phaseComplete => 'Phase Abgeschlossen!';

  @override
  String breedAdventure_phaseCompleteMessage(String phase) {
    return 'Du hast alle Rassen in der $phase-Phase abgeschlossen. Großartige Arbeit!';
  }

  @override
  String get breedAdventure_nextPhase => 'Nächste Phase';

  @override
  String get breedAdventure_restartGame => 'Spiel Neustarten';

  @override
  String get breedAdventure_skip => 'Überspringen';

  @override
  String get breedAdventure_sec => 'Sek';

  @override
  String get breedAdventure_powerUpHint_celebration =>
      'Rassen-Wissen enthüllt! 🧠';

  @override
  String get breedAdventure_powerUpExtraTime_celebration =>
      'Extra Zeit gewährt! ⏰';

  @override
  String get breedAdventure_powerUpSkip_celebration =>
      'Frage erfolgreich übersprungen! ⏭️';

  @override
  String get breedAdventure_powerUpSecondChance_celebration =>
      'Leben wiederhergestellt! ❤️';

  @override
  String get breedAdventure_powerUpHint_description =>
      'Enthüllt hilfreiche Informationen über die Eigenschaften und Geschichte der Rasse.';

  @override
  String get breedAdventure_powerUpExtraTime_description =>
      'Fügt 5 zusätzliche Sekunden zum aktuellen Fragen-Timer hinzu.';

  @override
  String get breedAdventure_powerUpSkip_description =>
      'Überspringe die aktuelle Frage ohne ein Leben zu verlieren.';

  @override
  String get breedAdventure_powerUpSecondChance_description =>
      'Stellt ein Leben wieder her, wenn du eine falsche Antwort gibst.';

  @override
  String get difficultyPhase_beginner => 'Anfänger';

  @override
  String get difficultyPhase_intermediate => 'Fortgeschritten';

  @override
  String get difficultyPhase_expert => 'Experte';

  @override
  String get treasureMap_chooseYourAdventure => 'Wähle dein Abenteuer';

  @override
  String get treasureMap_selectCategoryFirst => 'Zuerst Kategorie wählen';

  @override
  String get treasureMap_selectCategoryDialog_title => 'Kategorie wählen';

  @override
  String get treasureMap_selectCategoryDialog_message =>
      'Bitte wähle oben eine Kategorie aus, um dein Abenteuer zu starten.';

  @override
  String get category_dogHealth => 'Hundegesundheit';

  @override
  String get category_dogHistory => 'Hundegeschichte';

  @override
  String get category_dogHealth_description =>
      'Verstehe Hundegesundheit, Ernährung und medizinische Versorgung';

  @override
  String get category_dogHistory_description =>
      'Entdecke die Geschichte der Hunde, Genetik und Evolution';

  @override
  String get categorySelection_title => 'Choose Your Adventure';

  @override
  String get categorySelection_hint =>
      'Select a category to start your quiz adventure';

  @override
  String get categorySelection_description =>
      'Select a category to start your learning adventure with fun questions about dogs';

  @override
  String categorySelection_selectedHint(String category) {
    return 'Currently selected: $category. Tap to confirm or choose a different category';
  }

  @override
  String categorySelection_selectHint(String category) {
    return 'Tap to select $category category';
  }

  @override
  String categorySelection_announceSelection(String category) {
    return 'Selected $category category';
  }

  @override
  String get breedAdventure_chooseCorrectImage => 'Wähle das richtige Bild';

  @override
  String get breedAdventure_newHighScore => 'Neuer Highscore!';

  @override
  String get breedAdventure_loadingChallenge =>
      'Lade Rassen-Herausforderung...';

  @override
  String get breedAdventure_retry => 'Wiederholen';

  @override
  String breedAdventure_completedAllBreedsMessage(String phaseName) {
    return 'Du hast alle Rassen in der $phaseName-Phase abgeschlossen. Großartige Arbeit!';
  }

  @override
  String breedAdventure_recoveryModeActiveMessage(int consecutiveFailures) {
    return 'Wiederherstellungsmodus nach $consecutiveFailures Fehlern aktiv. Fallback-Inhalt wird verwendet.';
  }

  @override
  String get breedAdventure_recoveryModeActiveOfflineMessage =>
      'Wiederherstellungsmodus aktiv. Offline-Inhalt wird wo möglich verwendet.';

  @override
  String get breedAdventure_tryAgain => 'Erneut versuchen';

  @override
  String get breedAdventure_dataCorruptedMessage =>
      'Spieldaten scheinen beschädigt zu sein. Bitte starte das Spiel neu oder kehre zum Startbildschirm zurück.';

  @override
  String get breedAdventure_recoveryMode => 'Wiederherstellungsmodus';

  @override
  String get breedAdventure_loadingFailed => 'Bild-Laden fehlgeschlagen';

  @override
  String breedAdventure_loadingFailedMessage(int failedImageCount) {
    return 'Fehler beim Laden von $failedImageCount Bildern. Dies könnte ein vorübergehendes Problem sein.';
  }

  @override
  String get breedAdventure_dataError => 'Datenfehler';

  @override
  String get breedAdventure_somethingWentWrong => 'Etwas ist schiefgegangen';

  @override
  String get breedAdventure_goHome => 'Zum Startbildschirm';
}
