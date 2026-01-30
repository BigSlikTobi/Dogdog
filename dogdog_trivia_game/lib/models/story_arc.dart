import 'package:uuid/uuid.dart';
import 'companion_enums.dart';

/// A story arc represents a mini-narrative journey in a world area
/// 
/// Each story has questions woven into the narrative,
/// making learning feel like an adventure rather than a test.
class StoryArc {
  /// Unique identifier
  final String id;

  /// Title of the story
  final String title;

  /// Story description/hook
  final String description;

  /// The world area where this story takes place
  final WorldArea area;

  /// The companion mood at the start
  final CompanionMood startingMood;

  /// Narration segments (intro, transitions, conclusion)
  final List<StorySegment> segments;

  /// Questions embedded in the story
  final List<StoryQuestion> questions;

  /// Minimum growth stage required
  final GrowthStage requiredStage;

  /// Fun facts revealed during/after the story
  final List<String> funFacts;

  /// Bond bonus for completing the story
  final double bondReward;

  /// Estimated duration in minutes
  final int estimatedMinutes;

  const StoryArc({
    required this.id,
    required this.title,
    required this.description,
    required this.area,
    required this.startingMood,
    required this.segments,
    required this.questions,
    required this.requiredStage,
    required this.funFacts,
    this.bondReward = 0.05,
    this.estimatedMinutes = 3,
  });

  /// Total number of scenes in the story
  int get totalScenes => segments.length + questions.length;

  /// Whether this story is available for a given stage
  bool isAvailableFor(GrowthStage stage) {
    return stage.index >= requiredStage.index;
  }

  /// JSON serialization
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'area': area.name,
    'startingMood': startingMood.name,
    'segments': segments.map((s) => s.toJson()).toList(),
    'questions': questions.map((q) => q.toJson()).toList(),
    'requiredStage': requiredStage.name,
    'funFacts': funFacts,
    'bondReward': bondReward,
    'estimatedMinutes': estimatedMinutes,
  };

  factory StoryArc.fromJson(Map<String, dynamic> json) {
    return StoryArc(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      area: WorldArea.values.firstWhere((a) => a.name == json['area']),
      startingMood: CompanionMood.values.firstWhere(
        (m) => m.name == json['startingMood'],
      ),
      segments: (json['segments'] as List)
          .map((s) => StorySegment.fromJson(s as Map<String, dynamic>))
          .toList(),
      questions: (json['questions'] as List)
          .map((q) => StoryQuestion.fromJson(q as Map<String, dynamic>))
          .toList(),
      requiredStage: GrowthStage.values.firstWhere(
        (s) => s.name == json['requiredStage'],
      ),
      funFacts: List<String>.from(json['funFacts'] as List),
      bondReward: (json['bondReward'] as num).toDouble(),
      estimatedMinutes: json['estimatedMinutes'] as int,
    );
  }
}

/// A narrative segment (intro, transition, or conclusion)
class StorySegment {
  /// Unique identifier
  final String id;

  /// Type of segment
  final SegmentType type;

  /// The narration text
  final String narration;

  /// Companion reaction/mood during this segment
  final CompanionMood? companionMood;

  /// Optional voice-over audio path
  final String? audioPath;

  /// Background scene description/asset
  final String? scenePath;

  /// Animation to play on companion
  final String? companionAnimation;

  const StorySegment({
    required this.id,
    required this.type,
    required this.narration,
    this.companionMood,
    this.audioPath,
    this.scenePath,
    this.companionAnimation,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'narration': narration,
    if (companionMood != null) 'companionMood': companionMood!.name,
    if (audioPath != null) 'audioPath': audioPath,
    if (scenePath != null) 'scenePath': scenePath,
    if (companionAnimation != null) 'companionAnimation': companionAnimation,
  };

  factory StorySegment.fromJson(Map<String, dynamic> json) {
    return StorySegment(
      id: json['id'] as String,
      type: SegmentType.values.firstWhere((t) => t.name == json['type']),
      narration: json['narration'] as String,
      companionMood: json['companionMood'] != null
          ? CompanionMood.values.firstWhere(
              (m) => m.name == json['companionMood'],
            )
          : null,
      audioPath: json['audioPath'] as String?,
      scenePath: json['scenePath'] as String?,
      companionAnimation: json['companionAnimation'] as String?,
    );
  }
}

/// Types of story segments
enum SegmentType {
  intro,
  transition,
  discovery,
  celebration,
  conclusion,
}

/// A question embedded within a story
class StoryQuestion {
  /// Unique identifier
  final String id;

  /// Context narration before the question
  final String context;

  /// The question text
  final String question;

  /// Answer options
  final List<String> options;

  /// Index of the correct answer
  final int correctIndex;

  /// Companion reaction when correct
  final String correctReaction;

  /// Companion reaction when incorrect
  final String incorrectReaction;

  /// Fun fact to reveal after question
  final String? funFact;

  /// Bond points for correct answer
  final double bondPoints;

  const StoryQuestion({
    required this.id,
    required this.context,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.correctReaction,
    required this.incorrectReaction,
    this.funFact,
    this.bondPoints = 0.02,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'context': context,
    'question': question,
    'options': options,
    'correctIndex': correctIndex,
    'correctReaction': correctReaction,
    'incorrectReaction': incorrectReaction,
    if (funFact != null) 'funFact': funFact,
    'bondPoints': bondPoints,
  };

  factory StoryQuestion.fromJson(Map<String, dynamic> json) {
    return StoryQuestion(
      id: json['id'] as String,
      context: json['context'] as String,
      question: json['question'] as String,
      options: List<String>.from(json['options'] as List),
      correctIndex: json['correctIndex'] as int,
      correctReaction: json['correctReaction'] as String,
      incorrectReaction: json['incorrectReaction'] as String,
      funFact: json['funFact'] as String?,
      bondPoints: (json['bondPoints'] as num?)?.toDouble() ?? 0.02,
    );
  }
}

/// Tracks progress through a story arc
class StoryProgress {
  /// The story being played
  final String storyId;

  /// Current scene index
  final int currentSceneIndex;

  /// Total scenes
  final int totalScenes;

  /// Questions answered correctly
  final int correctAnswers;

  /// Total questions answered
  final int totalAnswered;

  /// Bond points accumulated
  final double bondAccumulated;

  /// Facts learned during story
  final List<String> factsLearned;

  /// Whether story is complete
  final bool isComplete;

  /// Start time
  final DateTime startedAt;

  /// Completion time
  final DateTime? completedAt;

  const StoryProgress({
    required this.storyId,
    this.currentSceneIndex = 0,
    required this.totalScenes,
    this.correctAnswers = 0,
    this.totalAnswered = 0,
    this.bondAccumulated = 0.0,
    this.factsLearned = const [],
    this.isComplete = false,
    required this.startedAt,
    this.completedAt,
  });

  StoryProgress copyWith({
    String? storyId,
    int? currentSceneIndex,
    int? totalScenes,
    int? correctAnswers,
    int? totalAnswered,
    double? bondAccumulated,
    List<String>? factsLearned,
    bool? isComplete,
    DateTime? startedAt,
    DateTime? completedAt,
  }) {
    return StoryProgress(
      storyId: storyId ?? this.storyId,
      currentSceneIndex: currentSceneIndex ?? this.currentSceneIndex,
      totalScenes: totalScenes ?? this.totalScenes,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      totalAnswered: totalAnswered ?? this.totalAnswered,
      bondAccumulated: bondAccumulated ?? this.bondAccumulated,
      factsLearned: factsLearned ?? this.factsLearned,
      isComplete: isComplete ?? this.isComplete,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  double get accuracy => 
      totalAnswered > 0 ? correctAnswers / totalAnswered : 0.0;

  double get progress => 
      totalScenes > 0 ? currentSceneIndex / totalScenes : 0.0;

  Map<String, dynamic> toJson() => {
    'storyId': storyId,
    'currentSceneIndex': currentSceneIndex,
    'totalScenes': totalScenes,
    'correctAnswers': correctAnswers,
    'totalAnswered': totalAnswered,
    'bondAccumulated': bondAccumulated,
    'factsLearned': factsLearned,
    'isComplete': isComplete,
    'startedAt': startedAt.toIso8601String(),
    if (completedAt != null) 'completedAt': completedAt!.toIso8601String(),
  };

  factory StoryProgress.fromJson(Map<String, dynamic> json) {
    return StoryProgress(
      storyId: json['storyId'] as String,
      currentSceneIndex: json['currentSceneIndex'] as int,
      totalScenes: json['totalScenes'] as int,
      correctAnswers: json['correctAnswers'] as int,
      totalAnswered: json['totalAnswered'] as int,
      bondAccumulated: (json['bondAccumulated'] as num).toDouble(),
      factsLearned: List<String>.from(json['factsLearned'] as List),
      isComplete: json['isComplete'] as bool,
      startedAt: DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }

  factory StoryProgress.start(StoryArc story) {
    return StoryProgress(
      storyId: story.id,
      totalScenes: story.totalScenes,
      startedAt: DateTime.now(),
    );
  }
}
