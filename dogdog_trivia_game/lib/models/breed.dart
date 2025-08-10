/// Model representing a dog breed with image URL and difficulty level
class Breed {
  final String name;
  final String imageUrl;
  final int difficulty;

  const Breed({
    required this.name,
    required this.imageUrl,
    required this.difficulty,
  });

  /// Creates a Breed instance from JSON data
  factory Breed.fromJson(Map<String, dynamic> json) {
    return Breed(
      name: json['breed'] as String,
      imageUrl: json['url'] as String,
      difficulty: int.parse(json['difficulty'] as String),
    );
  }

  /// Converts the Breed instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'breed': name,
      'url': imageUrl,
      'difficulty': difficulty.toString(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Breed &&
        other.name == name &&
        other.imageUrl == imageUrl &&
        other.difficulty == difficulty;
  }

  @override
  int get hashCode => Object.hash(name, imageUrl, difficulty);

  @override
  String toString() {
    return 'Breed(name: $name, imageUrl: $imageUrl, difficulty: $difficulty)';
  }
}
