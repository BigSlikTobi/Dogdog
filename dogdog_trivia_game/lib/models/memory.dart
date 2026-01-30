import 'companion_enums.dart';

/// Model representing a memory/moment saved in the Memory Journal
class Memory {
  /// Unique identifier
  final String id;

  /// When this memory was created
  final DateTime timestamp;

  /// Title of the story/adventure
  final String storyTitle;

  /// Description of what happened
  final String description;

  /// Fun facts learned during this session
  final List<String> factsLearned;

  /// Path to screenshot (if captured)
  final String? screenshotPath;

  /// World area where this memory was created (stored as string)
  final String worldArea;
  
  /// Get the WorldArea enum from the stored string
  WorldArea get worldAreaEnum => WorldArea.values.firstWhere(
    (a) => a.name == worldArea,
    orElse: () => WorldArea.home,
  );

  /// Whether user marked this as a highlight
  final bool isHighlighted;

  /// Number of correct answers in this session
  final int correctAnswers;

  /// Bond gained during this session
  final double bondGained;

  const Memory({
    required this.id,
    required this.timestamp,
    required this.storyTitle,
    this.description = '',
    this.factsLearned = const [],
    this.screenshotPath,
    required this.worldArea,
    this.isHighlighted = false,
    this.correctAnswers = 0,
    this.bondGained = 0.0,
  });

  /// Creates a copy with updated fields
  Memory copyWith({
    String? id,
    DateTime? timestamp,
    String? storyTitle,
    String? description,
    List<String>? factsLearned,
    String? screenshotPath,
    String? worldArea,
    bool? isHighlighted,
    int? correctAnswers,
    double? bondGained,
  }) {
    return Memory(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      storyTitle: storyTitle ?? this.storyTitle,
      description: description ?? this.description,
      factsLearned: factsLearned ?? this.factsLearned,
      screenshotPath: screenshotPath ?? this.screenshotPath,
      worldArea: worldArea ?? this.worldArea,
      isHighlighted: isHighlighted ?? this.isHighlighted,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      bondGained: bondGained ?? this.bondGained,
    );
  }

  /// Toggle highlight status
  Memory toggleHighlight() => copyWith(isHighlighted: !isHighlighted);

  /// Creates from JSON
  factory Memory.fromJson(Map<String, dynamic> json) {
    return Memory(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      storyTitle: json['storyTitle'] as String,
      description: json['description'] as String? ?? '',
      factsLearned:
          (json['factsLearned'] as List<dynamic>?)?.cast<String>() ?? [],
      screenshotPath: json['screenshotPath'] as String?,
      worldArea: json['worldArea'] as String,
      isHighlighted: json['isHighlighted'] as bool? ?? false,
      correctAnswers: json['correctAnswers'] as int? ?? 0,
      bondGained: (json['bondGained'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'storyTitle': storyTitle,
      'description': description,
      'factsLearned': factsLearned,
      'screenshotPath': screenshotPath,
      'worldArea': worldArea,
      'isHighlighted': isHighlighted,
      'correctAnswers': correctAnswers,
      'bondGained': bondGained,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Memory && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Memory(title: $storyTitle, facts: ${factsLearned.length}, bond: +${(bondGained * 100).toStringAsFixed(1)}%)';
  }
}
