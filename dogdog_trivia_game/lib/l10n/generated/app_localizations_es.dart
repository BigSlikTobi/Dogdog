/// Generated file. Do not edit.
///
/// This file contains the localization delegates and supported locales
/// for the DogDog Trivia Game.

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Juego de Trivia DogDog';

  @override
  String get homeScreen_welcomeTitle => '¡Bienvenido a DogDog!';

  @override
  String get homeScreen_startButton => 'Comenzar Quiz';

  @override
  String get homeScreen_achievementsButton => 'Logros';

  @override
  String get homeScreen_infoCard_funQuestions_title => 'Preguntas Divertidas';

  @override
  String get homeScreen_infoCard_funQuestions_description =>
      'Aprende sobre diferentes razas de perros y sus características';

  @override
  String get homeScreen_infoCard_educational_title => 'Educativo';

  @override
  String get homeScreen_infoCard_educational_description =>
      'Diseñado para que los niños aprendan mientras se divierten';

  @override
  String get homeScreen_infoCard_progress_title => 'Seguimiento de Progreso';

  @override
  String get homeScreen_infoCard_progress_description =>
      'Sigue tu progreso y desbloquea logros';

  @override
  String get homeScreen_progress_title => 'Tu Progreso';

  @override
  String homeScreen_progress_currentRank(String rank) {
    return 'Rango Actual: $rank';
  }

  @override
  String homeScreen_progress_nextRank(String rank) {
    return 'Siguiente: $rank';
  }

  @override
  String get difficultyScreen_title => 'Elegir Dificultad';

  @override
  String get difficultyScreen_headerTitle => 'Elige tu nivel de dificultad';

  @override
  String get difficultyScreen_headerSubtitle =>
      'Cada dificultad ofrece diferentes desafíos y recompensas.';

  @override
  String get difficultyScreen_selectButton => 'Elegir esta categoría';

  @override
  String get difficulty_easy => 'Fácil';

  @override
  String get difficulty_medium => 'Medio';

  @override
  String get difficulty_hard => 'Difícil';

  @override
  String get difficulty_expert => 'Experto';

  @override
  String get difficulty_easy_description => 'Perfecto para principiantes';

  @override
  String get difficulty_medium_description => 'Para amantes de los perros';

  @override
  String get difficulty_hard_description => 'Para expertos en perros';

  @override
  String get difficulty_expert_description => 'Solo para profesionales';

  @override
  String difficulty_points_per_question(int points) {
    return '$points puntos por pregunta';
  }

  @override
  String gameScreen_level(int level) {
    return 'Nivel $level';
  }

  @override
  String get gameScreen_loading => 'Cargando preguntas...';

  @override
  String get gameScreen_score => 'Puntuación';

  @override
  String get gameScreen_lives => 'Vidas';

  @override
  String get gameScreen_timeRemaining => 'Tiempo Restante';

  @override
  String gameScreen_questionCounter(int current, int total) {
    return 'Pregunta $current de $total';
  }

  @override
  String get powerUp_fiftyFifty => 'Masticar 50/50';

  @override
  String get powerUp_hint => 'Pista';

  @override
  String get powerUp_extraTime => 'Tiempo Extra';

  @override
  String get powerUp_skip => 'Saltar';

  @override
  String get powerUp_secondChance => 'Segunda Oportunidad';

  @override
  String get powerUp_fiftyFifty_description =>
      'Elimina dos respuestas incorrectas';

  @override
  String get powerUp_hint_description =>
      'Muestra una pista para la respuesta correcta';

  @override
  String get powerUp_extraTime_description =>
      'Añade 10 segundos a la pregunta actual';

  @override
  String get powerUp_skip_description =>
      'Salta a la siguiente pregunta sin penalización';

  @override
  String get powerUp_secondChance_description => 'Restaura una vida perdida';

  @override
  String get rank_chihuahua => 'Chihuahua';

  @override
  String get rank_pug => 'Pug';

  @override
  String get rank_cockerSpaniel => 'Cocker Spaniel';

  @override
  String get rank_germanShepherd => 'Pastor Alemán';

  @override
  String get rank_greatDane => 'Gran Danés';

  @override
  String get rank_chihuahua_description =>
      'Pequeño comienzo - ¡Has respondido correctamente tus primeras 10 preguntas!';

  @override
  String get rank_pug_description =>
      'Buen progreso - ¡25 respuestas correctas alcanzadas!';

  @override
  String get rank_cockerSpaniel_description =>
      'Héroe de medio camino - ¡50 respuestas correctas dominadas!';

  @override
  String get rank_germanShepherd_description =>
      'Compañero leal - ¡75 respuestas correctas logradas!';

  @override
  String get rank_greatDane_description =>
      'Gran maestro - ¡100 respuestas correctas alcanzadas!';

  @override
  String get gameResult_win => 'Ganado';

  @override
  String get gameResult_lose => 'Perdido';

  @override
  String get gameResult_quit => 'Abandonado';

  @override
  String get feedback_correct => '¡Correcto!';

  @override
  String get feedback_incorrect => 'Incorrecto';

  @override
  String get feedback_timeUp => '¡Se acabó el tiempo!';

  @override
  String get common_ok => 'OK';

  @override
  String get common_cancel => 'Cancelar';

  @override
  String get common_retry => 'Reintentar';

  @override
  String get common_continue => 'Continuar';

  @override
  String get common_back => 'Atrás';

  @override
  String get accessibility_pauseGame => 'Pausar juego';

  @override
  String get accessibility_goBack => 'Volver a la pantalla de inicio';

  @override
  String get accessibility_appLogo => 'Logo de la app DogDog';

  @override
  String get achievementsScreen_title => 'Logros';

  @override
  String get achievementsScreen_tryAgain => 'Intentar de nuevo';

  @override
  String get achievementsScreen_close => 'Cerrar';

  @override
  String get gameOverScreen_title => 'Juego Terminado';

  @override
  String gameOverScreen_finalScore(int score) {
    return 'Puntuación Final: $score';
  }

  @override
  String gameOverScreen_correctAnswers(int correct, int total) {
    return '$correct de $total correctas';
  }

  @override
  String get gameOverScreen_playAgain => 'Jugar de Nuevo';

  @override
  String get gameOverScreen_backToHome => 'Volver al Inicio';

  @override
  String get resultScreen_funFact => 'Dato Curioso:';

  @override
  String get resultScreen_nextQuestion => 'Siguiente Pregunta';

  @override
  String get resultScreen_viewResults => 'Ver Resultados';

  @override
  String get errorScreen_title => 'Recuperación de Errores';

  @override
  String get errorScreen_servicesRestarted =>
      'Servicios reiniciados exitosamente';

  @override
  String errorScreen_restartFailed(String error) {
    return 'Falló el reinicio de servicios: $error';
  }

  @override
  String get errorScreen_cacheCleared => 'Caché limpiado exitosamente';

  @override
  String errorScreen_cacheClearFailed(String error) {
    return 'Falló la limpieza de caché: $error';
  }

  @override
  String get errorScreen_resetToDefaults =>
      'Restablecer a Valores Predeterminados';

  @override
  String get errorScreen_resetConfirmation =>
      'Esto restablecerá todas las configuraciones de la app a sus valores predeterminados. Tu progreso se conservará. ¿Continuar?';

  @override
  String get errorScreen_reset => 'Restablecer';

  @override
  String get errorScreen_settingsReset =>
      'Configuraciones restablecidas a valores predeterminados';

  @override
  String errorScreen_resetFailed(String error) {
    return 'Falló el restablecimiento de configuraciones: $error';
  }

  @override
  String errorScreen_loadingError(String error) {
    return 'Error cargando logros: $error';
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
  String get powerUp_extraTimeAdded => '¡Tiempo extra añadido!';

  @override
  String get powerUp_questionSkipped => '¡Pregunta saltada!';

  @override
  String get powerUp_lifeRestored => '¡Vida restaurada!';

  @override
  String get powerUp_use => 'Usar';

  @override
  String get achievementsScreen_pleaseRetryLater =>
      'Por favor, inténtalo de nuevo más tarde';

  @override
  String get achievementsScreen_yourStatistics => 'Tus Estadísticas';

  @override
  String get achievementsScreen_correctAnswers => 'Respuestas Correctas';

  @override
  String get achievementsScreen_accuracy => 'Precisión';

  @override
  String get achievementsScreen_gamesPlayed => 'Juegos Jugados';

  @override
  String get achievementsScreen_totalScore => 'Puntuación Total';

  @override
  String get achievementsScreen_currentRank => 'Rango Actual';

  @override
  String get achievementsScreen_nextRank => 'Siguiente Rango';

  @override
  String get achievementsScreen_allRanksAchieved =>
      '¡Todos los Rangos Alcanzados!';

  @override
  String get achievementsScreen_allRanksAchievedDescription =>
      'Has desbloqueado todos los rangos disponibles. ¡Excelente trabajo!';

  @override
  String get achievementsScreen_allAchievements => 'Todos los Logros';

  @override
  String achievementsScreen_correctAnswersRequired(int count) {
    return '$count respuestas correctas';
  }

  @override
  String achievementsScreen_moreAnswersToUnlock(int count) {
    return '$count respuestas correctas más para desbloquear';
  }

  @override
  String achievementsScreen_moreAnswersToNextRank(int count) {
    return '$count respuestas correctas más para el siguiente rango';
  }

  @override
  String get achievementsScreen_requiredAnswers => 'Respuestas requeridas:';

  @override
  String get achievementsScreen_yourAnswers => 'Tus respuestas:';

  @override
  String get achievementsScreen_unlocked => 'Desbloqueado:';

  @override
  String get checkpointCelebration_title => '¡Checkpoint Alcanzado!';

  @override
  String get checkpointCelebration_performance => 'Tu Rendimiento';

  @override
  String get checkpointCelebration_questionsAnswered => 'Preguntas';

  @override
  String get checkpointCelebration_correctAnswers => 'Correctas';

  @override
  String get checkpointCelebration_accuracy => 'Precisión';

  @override
  String get checkpointCelebration_pointsEarned => 'Puntos';

  @override
  String get checkpointCelebration_powerUpsEarned => 'Power-ups Obtenidos';

  @override
  String get checkpointCelebration_returnToMap => 'Volver al Mapa';

  @override
  String get checkpointCelebration_continue => 'Continuar';

  @override
  String get checkpointCelebration_pathCompleted => '¡Camino Completado!';

  @override
  String get checkpointCelebration_checkpointReached =>
      '¡Checkpoint Alcanzado!';

  @override
  String get checkpointCelebration_performanceSummary =>
      'Resumen de Rendimiento';

  @override
  String get checkpointCelebration_questions => 'Preguntas';

  @override
  String get checkpointCelebration_points => 'Puntos';

  @override
  String get checkpointCelebration_powerUpRewards => 'Recompensas de Power-Up';

  @override
  String get checkpointCelebration_noPowerUps =>
      'No se ganaron power-ups esta vez';

  @override
  String get checkpointCelebration_completePath => 'Completar Camino';

  @override
  String get checkpointCelebration_continueJourney => 'Continuar Viaje';

  @override
  String get powerUp_fiftyFifty_short => '50/50';

  @override
  String get powerUp_hint_short => 'Pista';

  @override
  String get powerUp_extraTime_short => 'Tiempo Extra';

  @override
  String get powerUp_skip_short => 'Saltar';

  @override
  String get powerUp_secondChance_short => '2ª Oportunidad';

  @override
  String get accessibility_checkpointCelebration =>
      'Celebración de logro de checkpoint';

  @override
  String get treasureMap_pathCompleted => '¡Camino Completado!';

  @override
  String get treasureMap_startAdventure => 'Comenzar Aventura';

  @override
  String get treasureMap_continueAdventure => 'Continuar Aventura';

  @override
  String get treasureMap_congratulations => '¡Felicidades!';

  @override
  String get treasureMap_completionMessage =>
      '¡Has completado este camino de aprendizaje! Todos los checkpoints han sido desbloqueados.';

  @override
  String get treasureMap_continueExploring => 'Continuar Explorando';

  @override
  String get pathSelection_current => 'Actual';

  @override
  String get pathSelection_start => 'Iniciar';

  @override
  String get pathType_dogTrivia_name => 'Quiz Canino';

  @override
  String get pathType_dogTrivia_description =>
      'Aprende sobre diferentes razas de perros, sus características y orígenes';

  @override
  String get pathType_puppyQuest_name => 'Aventura Cachorros';

  @override
  String get pathType_puppyQuest_description =>
      'Pon a prueba tus habilidades de identificación de razas con desafíos de imágenes cronometrados';

  @override
  String get pathType_dogBreeds_name => 'Razas de Perros';

  @override
  String get pathType_dogBreeds_description =>
      'Aprende sobre diferentes razas de perros, sus características y orígenes';

  @override
  String get pathType_dogTraining_name => 'Entrenamiento Canino';

  @override
  String get pathType_dogTraining_description =>
      'Domina las técnicas de entrenamiento canino, comandos y orientación conductual';

  @override
  String get pathType_healthCare_name => 'Salud y Cuidado';

  @override
  String get pathType_healthCare_description =>
      'Comprende la salud canina, nutrición y atención médica';

  @override
  String get pathType_dogBehavior_name => 'Comportamiento Canino';

  @override
  String get pathType_dogBehavior_description =>
      'Explora la psicología canina, instintos y patrones de comportamiento';

  @override
  String get pathType_dogHistory_name => 'Historia Canina';

  @override
  String get pathType_dogHistory_description =>
      'Descubre la historia de los perros, genética y evolución';

  @override
  String get pathType_breedAdventure_name => 'Aventura de Razas';

  @override
  String get pathType_breedAdventure_description =>
      'Pon a prueba tu conocimiento identificando razas de perros a partir de fotos';

  @override
  String get treasureMap_adventure => 'Aventura';

  @override
  String treasureMap_questionsTo(int current, int total, String checkpoint) {
    return '$current/$total preguntas hasta $checkpoint';
  }

  @override
  String get treasureMap_questions => 'questions';

  @override
  String get treasureMap_currentRank => 'Current Rank';

  @override
  String get treasureMap_allCompleted => 'All Completed!';

  @override
  String get treasureMap_pathCompletedStatus => '¡Camino Completado!';

  @override
  String treasureMap_progressQuestions(int current, int total) {
    return 'Progreso: $current/$total preguntas';
  }

  @override
  String treasureMap_checkpointsCompleted(int current, int total) {
    return '$current/$total checkpoints completados';
  }

  @override
  String get breedAdventure_title => 'Aventura de Razas Caninas';

  @override
  String get breedAdventure_description =>
      'Pon a prueba tu conocimiento identificando razas de perros a partir de fotos';

  @override
  String get breedAdventure_whichImageShows => '¿Qué imagen muestra un';

  @override
  String get breedAdventure_gameInitializing =>
      'Preparando tu aventura de razas...';

  @override
  String get breedAdventure_loadingImages => 'Cargando imágenes de razas...';

  @override
  String get breedAdventure_gamePaused => 'Juego Pausado';

  @override
  String get breedAdventure_pauseMessage =>
      'El juego está pausado. Toca Reanudar para continuar.';

  @override
  String get breedAdventure_resume => 'Reanudar';

  @override
  String get breedAdventure_exitGame => 'Salir del Juego';

  @override
  String get breedAdventure_adventureComplete => '¡Aventura Completada!';

  @override
  String get breedAdventure_finalScore => 'Puntuación Final';

  @override
  String get breedAdventure_correct => 'Correctas';

  @override
  String get breedAdventure_accuracy => 'Precisión';

  @override
  String get breedAdventure_phase => 'Fase';

  @override
  String get breedAdventure_playAgain => 'Jugar de Nuevo';

  @override
  String get breedAdventure_home => 'Inicio';

  @override
  String get breedAdventure_powerUps => 'Power-ups';

  @override
  String get breedAdventure_lives => 'Vidas';

  @override
  String get category_dogTraining => 'Entrenamiento Canino';

  @override
  String get category_dogBreeds => 'Razas de Perros';

  @override
  String get category_dogBehavior => 'Comportamiento Canino';

  @override
  String get category_dogTraining_description =>
      'Domina técnicas de entrenamiento canino, comandos y orientación conductual';

  @override
  String get category_dogBreeds_description =>
      'Aprende sobre diferentes razas de perros, sus características y orígenes';

  @override
  String get category_dogBehavior_description =>
      'Explora la psicología canina, instintos y patrones de comportamiento';

  @override
  String get difficulty_easyPlus => 'Fácil+';

  @override
  String get difficulty_easyPlus_description =>
      'Un poco más desafiante que fácil';

  @override
  String treasureMap_startCategoryAdventure(String category) {
    return 'Comenzar Aventura de $category';
  }

  @override
  String treasureMap_continueCategoryAdventure(String category) {
    return 'Continuar Aventura de $category';
  }

  @override
  String get breedAdventure_progress => 'Progreso';

  @override
  String get breedAdventure_timeRemaining => 'Tiempo Restante';

  @override
  String get breedAdventure_hintTitle => 'Pista de Raza';

  @override
  String get breedAdventure_powerUpEarned => '¡Power-up Obtenido!';

  @override
  String get breedAdventure_connectionProblem => 'Problema de Conexión';

  @override
  String get breedAdventure_connectionMessage =>
      'No se pueden cargar las imágenes. Por favor verifica tu conexión a internet e inténtalo de nuevo.';

  @override
  String get breedAdventure_imageLoadFailed => 'Fallo al Cargar Imagen';

  @override
  String get breedAdventure_imageLoadMessage =>
      'Las imágenes de razas no se pudieron cargar. Esto podría ser un problema temporal.';

  @override
  String get breedAdventure_phaseComplete => '¡Fase Completada!';

  @override
  String breedAdventure_phaseCompleteMessage(String phase) {
    return 'Has completado todas las razas en la fase $phase. ¡Excelente trabajo!';
  }

  @override
  String get breedAdventure_nextPhase => 'Siguiente Fase';

  @override
  String get breedAdventure_restartGame => 'Reiniciar Juego';

  @override
  String get breedAdventure_skip => 'Saltar';

  @override
  String get breedAdventure_sec => 'seg';

  @override
  String get breedAdventure_powerUpHint_celebration =>
      '¡Conocimiento de razas revelado! 🧠';

  @override
  String get breedAdventure_powerUpExtraTime_celebration =>
      '¡Tiempo extra concedido! ⏰';

  @override
  String get breedAdventure_powerUpSkip_celebration =>
      '¡Pregunta saltada exitosamente! ⏭️';

  @override
  String get breedAdventure_powerUpSecondChance_celebration =>
      '¡Vida restaurada! ❤️';

  @override
  String get breedAdventure_powerUpHint_description =>
      'Revela información útil sobre las características e historia de la raza.';

  @override
  String get breedAdventure_powerUpExtraTime_description =>
      'Añade 5 segundos extra al temporizador de la pregunta actual.';

  @override
  String get breedAdventure_powerUpSkip_description =>
      'Salta la pregunta actual sin perder una vida.';

  @override
  String get breedAdventure_powerUpSecondChance_description =>
      'Restaura una vida cuando das una respuesta incorrecta.';

  @override
  String get difficultyPhase_beginner => 'Principiante';

  @override
  String get difficultyPhase_intermediate => 'Intermedio';

  @override
  String get difficultyPhase_expert => 'Experto';

  @override
  String get treasureMap_chooseYourAdventure => 'Elige tu Aventura';

  @override
  String get treasureMap_selectCategoryFirst => 'Selecciona Categoría Primero';

  @override
  String get treasureMap_selectCategoryDialog_title => 'Seleccionar Categoría';

  @override
  String get treasureMap_selectCategoryDialog_message =>
      'Por favor selecciona una categoría arriba para comenzar tu aventura.';

  @override
  String get category_dogHealth => 'Salud Canina';

  @override
  String get category_dogHistory => 'Historia Canina';

  @override
  String get category_dogHealth_description =>
      'Comprende la salud canina, nutrición y cuidado médico';

  @override
  String get category_dogHistory_description =>
      'Descubre la historia de los perros, genética y evolución';

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
  String get breedAdventure_chooseCorrectImage => 'Elige la imagen correcta';

  @override
  String get breedAdventure_newHighScore => '¡Nuevo récord!';

  @override
  String get breedAdventure_loadingChallenge => 'Cargando desafío de raza...';

  @override
  String get breedAdventure_retry => 'Reintentar';

  @override
  String breedAdventure_completedAllBreedsMessage(String phaseName) {
    return 'Has completado todas las razas en la fase $phaseName. ¡Gran trabajo!';
  }

  @override
  String breedAdventure_recoveryModeActiveMessage(int consecutiveFailures) {
    return 'Modo de recuperación activo después de $consecutiveFailures fallos. Usando contenido de respaldo.';
  }

  @override
  String get breedAdventure_recoveryModeActiveOfflineMessage =>
      'Modo de recuperación activo. Usando contenido sin conexión cuando sea posible.';

  @override
  String get breedAdventure_tryAgain => 'Intentar de nuevo';

  @override
  String get breedAdventure_dataCorruptedMessage =>
      'Los datos del juego parecen estar corruptos. Por favor, reinicia el juego o vuelve a la pantalla de inicio.';

  @override
  String get breedAdventure_recoveryMode => 'Modo de recuperación';

  @override
  String get breedAdventure_loadingFailed => 'Fallo al cargar la imagen';

  @override
  String breedAdventure_loadingFailedMessage(int failedImageCount) {
    return 'Fallo al cargar $failedImageCount imágenes. Esto podría ser un problema temporal.';
  }

  @override
  String get breedAdventure_dataError => 'Error de datos';

  @override
  String get breedAdventure_somethingWentWrong => 'Algo salió mal';

  @override
  String get breedAdventure_goHome => 'Ir a inicio';
}
