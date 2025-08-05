import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../models/question.dart';
import '../models/enums.dart';

/// Service class responsible for managing question pools and providing
/// questions with adaptive difficulty selection
class QuestionService {
  static final QuestionService _instance = QuestionService._internal();
  factory QuestionService() => _instance;
  QuestionService._internal();

  final Map<Difficulty, List<Question>> _questionPools = {};
  final Random _random = Random();
  bool _isInitialized = false;

  /// Initializes the question service by loading questions from JSON data
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _loadQuestionsFromAssets();
      _isInitialized = true;
    } catch (e) {
      throw Exception('Failed to initialize QuestionService: $e');
    }
  }

  /// Loads questions from local JSON assets
  Future<void> _loadQuestionsFromAssets() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/data/questions.json',
      );
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      for (final entry in jsonData.entries) {
        final difficultyName = entry.key;
        final questionsJson = entry.value as List;

        final difficulty = Difficulty.values.firstWhere(
          (d) => d.name == difficultyName,
          orElse: () => Difficulty.easy,
        );

        final questions = questionsJson
            .map((q) => Question.fromJson(q as Map<String, dynamic>))
            .toList();

        _questionPools[difficulty] = questions;
      }
    } catch (e) {
      // Fallback to sample data if asset loading fails
      _loadSampleQuestions();
    }
  }

  /// Loads sample questions as fallback data
  void _loadSampleQuestions() {
    _questionPools[Difficulty.easy] = _getEasyQuestions();
    _questionPools[Difficulty.medium] = _getMediumQuestions();
    _questionPools[Difficulty.hard] = _getHardQuestions();
    _questionPools[Difficulty.expert] = _getExpertQuestions();
  }

  /// Resets the service for testing purposes
  void reset() {
    _questionPools.clear();
    _isInitialized = false;
  }

  /// Returns a list of questions with adaptive difficulty selection
  ///
  /// [count] - Number of questions to return
  /// [playerLevel] - Current player level (1-5)
  /// [streakCount] - Current correct answer streak
  /// [recentMistakes] - Number of recent mistakes
  List<Question> getQuestionsWithAdaptiveDifficulty({
    required int count,
    required int playerLevel,
    required int streakCount,
    required int recentMistakes,
  }) {
    if (!_isInitialized) {
      throw StateError(
        'QuestionService not initialized. Call initialize() first.',
      );
    }

    final List<Question> selectedQuestions = [];
    final Set<String> usedQuestionIds = {};

    for (int i = 0; i < count; i++) {
      final difficulty = _calculateAdaptiveDifficulty(
        playerLevel: playerLevel,
        streakCount: streakCount,
        recentMistakes: recentMistakes,
        questionIndex: i,
      );

      final question = _getRandomQuestionByDifficulty(
        difficulty,
        excludeIds: usedQuestionIds,
      );

      if (question != null) {
        selectedQuestions.add(question);
        usedQuestionIds.add(question.id);
      }
    }

    return selectedQuestions;
  }

  /// Calculates the appropriate difficulty based on player performance
  Difficulty _calculateAdaptiveDifficulty({
    required int playerLevel,
    required int streakCount,
    required int recentMistakes,
    required int questionIndex,
  }) {
    // Base difficulty distribution based on level
    final Map<Difficulty, double> baseProbabilities =
        _getBaseDifficultyDistribution(playerLevel);

    // Adjust probabilities based on streak
    if (streakCount >= 5) {
      // Increase difficulty for high streaks
      baseProbabilities[Difficulty.easy] =
          (baseProbabilities[Difficulty.easy]! * 0.5).clamp(0.1, 1.0);
      baseProbabilities[Difficulty.medium] =
          (baseProbabilities[Difficulty.medium]! * 1.2).clamp(0.0, 1.0);
      baseProbabilities[Difficulty.hard] =
          (baseProbabilities[Difficulty.hard]! * 1.3).clamp(0.0, 1.0);
      baseProbabilities[Difficulty.expert] =
          (baseProbabilities[Difficulty.expert]! * 1.5).clamp(0.0, 1.0);
    } else if (streakCount >= 3) {
      // Slightly increase difficulty for moderate streaks
      baseProbabilities[Difficulty.easy] =
          (baseProbabilities[Difficulty.easy]! * 0.8).clamp(0.1, 1.0);
      baseProbabilities[Difficulty.medium] =
          (baseProbabilities[Difficulty.medium]! * 1.1).clamp(0.0, 1.0);
      baseProbabilities[Difficulty.hard] =
          (baseProbabilities[Difficulty.hard]! * 1.1).clamp(0.0, 1.0);
    }

    // Adjust probabilities based on recent mistakes
    if (recentMistakes >= 3) {
      // Decrease difficulty for many mistakes
      baseProbabilities[Difficulty.easy] =
          (baseProbabilities[Difficulty.easy]! * 1.5).clamp(0.0, 1.0);
      baseProbabilities[Difficulty.medium] =
          (baseProbabilities[Difficulty.medium]! * 0.7).clamp(0.0, 1.0);
      baseProbabilities[Difficulty.hard] =
          (baseProbabilities[Difficulty.hard]! * 0.5).clamp(0.0, 1.0);
      baseProbabilities[Difficulty.expert] =
          (baseProbabilities[Difficulty.expert]! * 0.3).clamp(0.0, 1.0);
    } else if (recentMistakes >= 2) {
      // Slightly decrease difficulty for some mistakes
      baseProbabilities[Difficulty.easy] =
          (baseProbabilities[Difficulty.easy]! * 1.2).clamp(0.0, 1.0);
      baseProbabilities[Difficulty.medium] =
          (baseProbabilities[Difficulty.medium]! * 0.9).clamp(0.0, 1.0);
      baseProbabilities[Difficulty.hard] =
          (baseProbabilities[Difficulty.hard]! * 0.8).clamp(0.0, 1.0);
    }

    // Normalize probabilities
    final totalProbability = baseProbabilities.values.reduce((a, b) => a + b);
    baseProbabilities.updateAll((key, value) => value / totalProbability);

    // Select difficulty based on weighted random selection
    return _selectDifficultyByProbability(baseProbabilities);
  }

  /// Returns base difficulty distribution for a given player level
  Map<Difficulty, double> _getBaseDifficultyDistribution(int playerLevel) {
    switch (playerLevel) {
      case 1:
        return {
          Difficulty.easy: 0.8,
          Difficulty.medium: 0.15,
          Difficulty.hard: 0.05,
          Difficulty.expert: 0.0,
        };
      case 2:
        return {
          Difficulty.easy: 0.6,
          Difficulty.medium: 0.3,
          Difficulty.hard: 0.1,
          Difficulty.expert: 0.0,
        };
      case 3:
        return {
          Difficulty.easy: 0.4,
          Difficulty.medium: 0.4,
          Difficulty.hard: 0.15,
          Difficulty.expert: 0.05,
        };
      case 4:
        return {
          Difficulty.easy: 0.3,
          Difficulty.medium: 0.35,
          Difficulty.hard: 0.25,
          Difficulty.expert: 0.1,
        };
      case 5:
      default:
        return {
          Difficulty.easy: 0.2,
          Difficulty.medium: 0.3,
          Difficulty.hard: 0.35,
          Difficulty.expert: 0.15,
        };
    }
  }

  /// Selects a difficulty based on weighted probabilities
  Difficulty _selectDifficultyByProbability(
    Map<Difficulty, double> probabilities,
  ) {
    final randomValue = _random.nextDouble();
    double cumulativeProbability = 0.0;

    for (final entry in probabilities.entries) {
      cumulativeProbability += entry.value;
      if (randomValue <= cumulativeProbability) {
        return entry.key;
      }
    }

    // Fallback to easy if something goes wrong
    return Difficulty.easy;
  }

  /// Gets a random question of the specified difficulty
  Question? _getRandomQuestionByDifficulty(
    Difficulty difficulty, {
    Set<String>? excludeIds,
  }) {
    final questions = _questionPools[difficulty];
    if (questions == null || questions.isEmpty) {
      return null;
    }

    final availableQuestions = excludeIds != null
        ? questions.where((q) => !excludeIds.contains(q.id)).toList()
        : questions;

    if (availableQuestions.isEmpty) {
      return null;
    }

    final randomIndex = _random.nextInt(availableQuestions.length);
    return availableQuestions[randomIndex];
  }

  /// Gets all questions for a specific difficulty level
  List<Question> getQuestionsByDifficulty(Difficulty difficulty) {
    if (!_isInitialized) {
      throw StateError(
        'QuestionService not initialized. Call initialize() first.',
      );
    }
    return List.from(_questionPools[difficulty] ?? []);
  }

  /// Gets the total number of questions available
  int get totalQuestionCount {
    if (!_isInitialized) return 0;
    return _questionPools.values.fold(
      0,
      (sum, questions) => sum + questions.length,
    );
  }

  /// Gets the number of questions for a specific difficulty
  int getQuestionCountByDifficulty(Difficulty difficulty) {
    if (!_isInitialized) return 0;
    return _questionPools[difficulty]?.length ?? 0;
  }

  /// Checks if the service is initialized
  bool get isInitialized => _isInitialized;

  /// Sample easy questions about dogs
  List<Question> _getEasyQuestions() {
    return [
      Question(
        id: 'easy_001',
        text: 'Welche Farbe haben die meisten Golden Retriever?',
        answers: ['Golden/Gelb', 'Schwarz', 'Weiß', 'Braun'],
        correctAnswerIndex: 0,
        funFact:
            'Golden Retriever haben ihr goldenes Fell, das ihnen ihren Namen gibt. Sie wurden ursprünglich für die Jagd gezüchtet.',
        difficulty: Difficulty.easy,
        category: 'Hunderassen',
        hint: 'Der Name verrät schon die Antwort!',
      ),
      Question(
        id: 'easy_002',
        text: 'Wie viele Beine hat ein Hund?',
        answers: ['3', '4', '5', '6'],
        correctAnswerIndex: 1,
        funFact:
            'Hunde sind Vierbeiner, genau wie die meisten Säugetiere. Ihre vier Beine helfen ihnen beim Laufen und Springen.',
        difficulty: Difficulty.easy,
        category: 'Anatomie',
        hint: 'Zähle die Pfoten!',
      ),
      Question(
        id: 'easy_003',
        text: 'Was machen Hunde, wenn sie glücklich sind?',
        answers: ['Bellen', 'Wedeln mit dem Schwanz', 'Schlafen', 'Fressen'],
        correctAnswerIndex: 1,
        funFact:
            'Schwanzwedeln ist ein Zeichen für Freude und Aufregung bei Hunden. Je schneller sie wedeln, desto glücklicher sind sie!',
        difficulty: Difficulty.easy,
        category: 'Verhalten',
        hint: 'Schau dir den Schwanz an!',
      ),
      Question(
        id: 'easy_004',
        text: 'Welches Geräusch machen Hunde?',
        answers: ['Miau', 'Wuff', 'Muh', 'Quak'],
        correctAnswerIndex: 1,
        funFact:
            'Hunde bellen "Wuff" oder "Wau". Verschiedene Hunderassen haben unterschiedliche Bellgeräusche.',
        difficulty: Difficulty.easy,
        category: 'Verhalten',
        hint: 'Das klassische Hundegeräusch!',
      ),
      Question(
        id: 'easy_005',
        text: 'Was brauchen Hunde jeden Tag?',
        answers: ['Fernsehen', 'Spaziergang', 'Computerspiele', 'Hausaufgaben'],
        correctAnswerIndex: 1,
        funFact:
            'Hunde brauchen täglich Bewegung und frische Luft. Spaziergänge halten sie gesund und glücklich.',
        difficulty: Difficulty.easy,
        category: 'Pflege',
        hint: 'Bewegung ist wichtig!',
      ),
      Question(
        id: 'easy_006',
        text: 'Welcher Hund ist sehr klein?',
        answers: ['Deutsche Dogge', 'Chihuahua', 'Bernhardiner', 'Schäferhund'],
        correctAnswerIndex: 1,
        funFact:
            'Chihuahuas sind die kleinste Hunderasse der Welt. Sie wiegen oft nur 1-3 Kilogramm!',
        difficulty: Difficulty.easy,
        category: 'Hunderassen',
        hint: 'Der kleinste Hund der Welt!',
      ),
      Question(
        id: 'easy_007',
        text: 'Was essen Hunde gerne?',
        answers: ['Schokolade', 'Hundefutter', 'Gras', 'Steine'],
        correctAnswerIndex: 1,
        funFact:
            'Hundefutter ist speziell für Hunde gemacht und enthält alle Nährstoffe, die sie brauchen. Schokolade ist giftig für Hunde!',
        difficulty: Difficulty.easy,
        category: 'Ernährung',
        hint: 'Was ist speziell für Hunde gemacht?',
      ),
      Question(
        id: 'easy_008',
        text: 'Wo schlafen Hunde gerne?',
        answers: ['Im Hundebett', 'Auf dem Baum', 'Im Wasser', 'In der Luft'],
        correctAnswerIndex: 0,
        funFact:
            'Hunde lieben gemütliche, warme Plätze zum Schlafen. Ein eigenes Hundebett gibt ihnen Sicherheit und Komfort.',
        difficulty: Difficulty.easy,
        category: 'Verhalten',
        hint: 'Ein gemütlicher Platz nur für sie!',
      ),
    ];
  }

  /// Sample medium questions about dogs
  List<Question> _getMediumQuestions() {
    return [
      Question(
        id: 'medium_001',
        text:
            'Welche Hunderasse wurde ursprünglich für die Rettung in den Alpen gezüchtet?',
        answers: ['Dalmatiner', 'Bernhardiner', 'Pudel', 'Beagle'],
        correctAnswerIndex: 1,
        funFact:
            'Bernhardiner wurden von Mönchen in den Schweizer Alpen für Rettungsmissionen eingesetzt. Sie können Menschen unter Schneelawinen aufspüren.',
        difficulty: Difficulty.medium,
        category: 'Hunderassen',
        hint: 'Diese Hunde sind nach einem Heiligen benannt!',
      ),
      Question(
        id: 'medium_002',
        text: 'Wie viele Zähne hat ein erwachsener Hund normalerweise?',
        answers: ['32', '42', '28', '36'],
        correctAnswerIndex: 1,
        funFact:
            'Erwachsene Hunde haben 42 Zähne - 20 im Oberkiefer und 22 im Unterkiefer. Welpen haben nur 28 Milchzähne.',
        difficulty: Difficulty.medium,
        category: 'Anatomie',
        hint: 'Mehr als Menschen, aber weniger als 50!',
      ),
      Question(
        id: 'medium_003',
        text: 'Welche Hunderasse ist bekannt für ihre schwarz-weißen Flecken?',
        answers: ['Border Collie', 'Dalmatiner', 'Husky', 'Cocker Spaniel'],
        correctAnswerIndex: 1,
        funFact:
            'Dalmatiner werden weiß geboren und entwickeln ihre charakteristischen schwarzen Flecken erst nach einigen Wochen.',
        difficulty: Difficulty.medium,
        category: 'Hunderassen',
        hint: 'Diese Hunde sind oft bei der Feuerwehr zu sehen!',
      ),
      Question(
        id: 'medium_004',
        text: 'Wie lange ist die durchschnittliche Schwangerschaft bei Hunden?',
        answers: ['6 Wochen', '9 Monate', '9 Wochen', '4 Monate'],
        correctAnswerIndex: 2,
        funFact:
            'Hündinnen sind etwa 63 Tage (9 Wochen) trächtig. Ein Wurf kann 1-12 Welpen haben, je nach Rasse.',
        difficulty: Difficulty.medium,
        category: 'Fortpflanzung',
        hint: 'Kürzer als bei Menschen!',
      ),
      Question(
        id: 'medium_005',
        text: 'Welcher Sinn ist bei Hunden am besten entwickelt?',
        answers: ['Sehen', 'Hören', 'Riechen', 'Schmecken'],
        correctAnswerIndex: 2,
        funFact:
            'Hunde haben etwa 300 Millionen Riechzellen, Menschen nur 6 Millionen. Sie können Gerüche 10.000 bis 100.000 Mal besser wahrnehmen als wir.',
        difficulty: Difficulty.medium,
        category: 'Sinne',
        hint: 'Mit diesem Sinn können sie Drogen und Sprengstoff finden!',
      ),
      Question(
        id: 'medium_006',
        text: 'Welche Hunderasse gilt als die intelligenteste?',
        answers: ['Golden Retriever', 'Border Collie', 'Pudel', 'Labrador'],
        correctAnswerIndex: 1,
        funFact:
            'Border Collies gelten als die intelligenteste Hunderasse. Sie können über 1000 Wörter lernen und komplexe Aufgaben lösen.',
        difficulty: Difficulty.medium,
        category: 'Hunderassen',
        hint: 'Diese Hunde hüten gerne Schafe!',
      ),
      Question(
        id: 'medium_007',
        text: 'Warum hecheln Hunde?',
        answers: ['Zum Spielen', 'Zur Kühlung', 'Aus Langeweile', 'Zum Bellen'],
        correctAnswerIndex: 1,
        funFact:
            'Hunde haben keine Schweißdrüsen wie Menschen. Sie hecheln, um ihre Körpertemperatur zu regulieren und sich abzukühlen.',
        difficulty: Difficulty.medium,
        category: 'Physiologie',
        hint: 'Es hilft ihnen bei heißem Wetter!',
      ),
      Question(
        id: 'medium_008',
        text:
            'Welche Hunderasse wurde ursprünglich für die Jagd auf Dachse gezüchtet?',
        answers: ['Dackel', 'Terrier', 'Spaniel', 'Pointer'],
        correctAnswerIndex: 0,
        funFact:
            'Dackel wurden speziell für die Dachsjagd gezüchtet. Ihre kurzen Beine und langen Körper halfen ihnen, in Dachsbaue zu kriechen.',
        difficulty: Difficulty.medium,
        category: 'Hunderassen',
        hint: 'Ihr Name verrät ihre ursprüngliche Beute!',
      ),
    ];
  }

  /// Sample hard questions about dogs
  List<Question> _getHardQuestions() {
    return [
      Question(
        id: 'hard_001',
        text: 'Welche Hunderasse hat eine blaue Zunge?',
        answers: ['Chow Chow', 'Shar Pei', 'Beide', 'Keine'],
        correctAnswerIndex: 2,
        funFact:
            'Sowohl Chow Chows als auch Shar Peis haben charakteristische blau-schwarze Zungen. Dies ist ein genetisches Merkmal dieser Rassen.',
        difficulty: Difficulty.hard,
        category: 'Hunderassen',
        hint: 'Es sind tatsächlich zwei Rassen!',
      ),
      Question(
        id: 'hard_002',
        text: 'Wie viele Schweißdrüsen haben Hunde an ihren Pfoten?',
        answers: [
          'Keine',
          'Nur zwischen den Zehen',
          'Überall an den Pfoten',
          'Nur an den Ballen',
        ],
        correctAnswerIndex: 1,
        funFact:
            'Hunde haben Schweißdrüsen nur zwischen ihren Zehen. Deshalb können sie bei Stress feuchte Pfotenabdrücke hinterlassen.',
        difficulty: Difficulty.hard,
        category: 'Anatomie',
        hint: 'Nur an einer sehr spezifischen Stelle!',
      ),
      Question(
        id: 'hard_003',
        text: 'Welche Hunderasse wurde nach einer italienischen Stadt benannt?',
        answers: ['Bologneser', 'Neapolitanischer Mastiff', 'Beide', 'Keine'],
        correctAnswerIndex: 2,
        funFact:
            'Der Bologneser ist nach Bologna benannt, der Neapolitanische Mastiff nach Neapel. Beide Städte haben Hunderassen, die ihren Namen tragen.',
        difficulty: Difficulty.hard,
        category: 'Hunderassen',
        hint: 'Italien hat mehrere Städte mit Hunderassen!',
      ),
      Question(
        id: 'hard_004',
        text: 'Was ist die normale Körpertemperatur eines Hundes?',
        answers: ['36-37°C', '38-39°C', '40-41°C', '35-36°C'],
        correctAnswerIndex: 1,
        funFact:
            'Die normale Körpertemperatur von Hunden liegt zwischen 38-39°C, etwa 1-2 Grad höher als bei Menschen.',
        difficulty: Difficulty.hard,
        category: 'Physiologie',
        hint: 'Etwas höher als bei Menschen!',
      ),
      Question(
        id: 'hard_005',
        text: 'Welche Hunderasse kann nicht schwimmen?',
        answers: ['Bulldogge', 'Mops', 'Beide', 'Alle Hunde können schwimmen'],
        correctAnswerIndex: 2,
        funFact:
            'Bulldoggen und Möpse haben aufgrund ihrer flachen Gesichter und schweren Köpfe Schwierigkeiten beim Schwimmen und können ertrinken.',
        difficulty: Difficulty.hard,
        category: 'Hunderassen',
        hint: 'Rassen mit flachen Gesichtern haben Probleme!',
      ),
      Question(
        id: 'hard_006',
        text: 'Wie heißt die Wissenschaft, die sich mit Hunden beschäftigt?',
        answers: ['Kynologie', 'Canologie', 'Hundologie', 'Caninologie'],
        correctAnswerIndex: 0,
        funFact:
            'Kynologie ist die Wissenschaft von der Zucht, Dressur und den Krankheiten der Hunde. Der Begriff kommt vom griechischen Wort "kyon" für Hund.',
        difficulty: Difficulty.hard,
        category: 'Wissenschaft',
        hint: 'Ein griechisches Wort!',
      ),
      Question(
        id: 'hard_007',
        text: 'Welche Hunderasse wurde ursprünglich zur Löwenjagd eingesetzt?',
        answers: [
          'Rhodesian Ridgeback',
          'Afghanischer Windhund',
          'Irischer Wolfshund',
          'Barsoi',
        ],
        correctAnswerIndex: 0,
        funFact:
            'Der Rhodesian Ridgeback wurde in Afrika zur Löwenjagd gezüchtet. Der charakteristische Haarkamm auf dem Rücken wächst gegen die Fellrichtung.',
        difficulty: Difficulty.hard,
        category: 'Hunderassen',
        hint: 'Diese Rasse kommt aus Afrika!',
      ),
      Question(
        id: 'hard_008',
        text: 'Wie viele Geschmacksknospen haben Hunde ungefähr?',
        answers: ['1.700', '9.000', '10.000', '15.000'],
        correctAnswerIndex: 0,
        funFact:
            'Hunde haben nur etwa 1.700 Geschmacksknospen, Menschen haben etwa 9.000. Dafür ist ihr Geruchssinn viel besser entwickelt.',
        difficulty: Difficulty.hard,
        category: 'Sinne',
        hint: 'Viel weniger als Menschen!',
      ),
    ];
  }

  /// Sample expert questions about dogs
  List<Question> _getExpertQuestions() {
    return [
      Question(
        id: 'expert_001',
        text: 'Welche Hunderasse hat die längste Lebenserwartung?',
        answers: [
          'Chihuahua',
          'Jack Russell Terrier',
          'Toy Pudel',
          'Alle etwa gleich',
        ],
        correctAnswerIndex: 0,
        funFact:
            'Chihuahuas haben oft eine Lebenserwartung von 14-16 Jahren, manchmal sogar bis zu 20 Jahre. Kleinere Hunderassen leben generell länger.',
        difficulty: Difficulty.expert,
        category: 'Hunderassen',
        hint: 'Die kleinste Rasse lebt am längsten!',
      ),
      Question(
        id: 'expert_002',
        text:
            'Welches Gen ist für die Fellfarbe Merle bei Hunden verantwortlich?',
        answers: ['MITF-Gen', 'MLPH-Gen', 'PMEL-Gen', 'MC1R-Gen'],
        correctAnswerIndex: 2,
        funFact:
            'Das PMEL-Gen (Premelanosome protein) ist für das Merle-Muster verantwortlich, das gefleckte oder marmorierte Fellfarben erzeugt.',
        difficulty: Difficulty.expert,
        category: 'Genetik',
        hint: 'Es beginnt mit P!',
      ),
      Question(
        id: 'expert_003',
        text: 'Welche Hunderasse wurde zur Jagd auf Wölfe in Irland gezüchtet?',
        answers: [
          'Irish Setter',
          'Irish Terrier',
          'Irish Wolfhound',
          'Kerry Blue Terrier',
        ],
        correctAnswerIndex: 2,
        funFact:
            'Der Irish Wolfhound ist die größte Hunderasse und wurde speziell zur Wolfsjagd in Irland gezüchtet. Sie können über 80 cm groß werden.',
        difficulty: Difficulty.expert,
        category: 'Hunderassen',
        hint: 'Der Name verrät die Beute!',
      ),
      Question(
        id: 'expert_004',
        text:
            'Wie nennt man die Krankheit, bei der Hunde keine Tränen produzieren können?',
        answers: [
          'Keratokonjunktivitis sicca',
          'Entropium',
          'Ektropium',
          'Glaukom',
        ],
        correctAnswerIndex: 0,
        funFact:
            'Keratokonjunktivitis sicca, auch "trockenes Auge" genannt, ist eine Krankheit, bei der die Tränenproduktion gestört ist.',
        difficulty: Difficulty.expert,
        category: 'Veterinärmedizin',
        hint: 'Ein sehr langer medizinischer Begriff!',
      ),
      Question(
        id: 'expert_005',
        text: 'Welche Hunderasse hat natürlich kupierte Ohren?',
        answers: [
          'Keine - alle werden operiert',
          'Boston Terrier',
          'Französische Bulldogge',
          'Beide B und C',
        ],
        correctAnswerIndex: 3,
        funFact:
            'Boston Terrier und Französische Bulldoggen haben natürlich aufrechte, kurze Ohren. Viele andere Rassen werden operativ kupiert.',
        difficulty: Difficulty.expert,
        category: 'Hunderassen',
        hint: 'Zwei Rassen haben es natürlich!',
      ),
      Question(
        id: 'expert_006',
        text:
            'Welcher Neurotransmitter ist hauptsächlich für das Bindungsverhalten zwischen Hund und Mensch verantwortlich?',
        answers: ['Dopamin', 'Serotonin', 'Oxytocin', 'Adrenalin'],
        correctAnswerIndex: 2,
        funFact:
            'Oxytocin, auch "Kuschelhormon" genannt, wird sowohl bei Hunden als auch bei Menschen ausgeschüttet, wenn sie miteinander interagieren.',
        difficulty: Difficulty.expert,
        category: 'Neurobiologie',
        hint: 'Das "Liebeshormon"!',
      ),
      Question(
        id: 'expert_007',
        text:
            'Welche Hunderasse wurde ursprünglich zur Jagd auf Löwen in Afrika eingesetzt?',
        answers: ['Basenji', 'Rhodesian Ridgeback', 'Pharaonenhund', 'Azawakh'],
        correctAnswerIndex: 1,
        funFact:
            'Der Rhodesian Ridgeback wurde von europäischen Siedlern in Afrika zur Löwenjagd entwickelt. Der Ridgeback (Haarkamm) ist sein Markenzeichen.',
        difficulty: Difficulty.expert,
        category: 'Hunderassen',
        hint: 'Hat einen charakteristischen Haarkamm!',
      ),
      Question(
        id: 'expert_008',
        text: 'Wie viele Chromosomenpaare haben Hunde?',
        answers: ['38', '39', '40', '42'],
        correctAnswerIndex: 1,
        funFact:
            'Hunde haben 39 Chromosomenpaare (78 Chromosomen insgesamt), während Menschen 23 Paare (46 Chromosomen) haben.',
        difficulty: Difficulty.expert,
        category: 'Genetik',
        hint: 'Mehr als Menschen!',
      ),
    ];
  }
}
