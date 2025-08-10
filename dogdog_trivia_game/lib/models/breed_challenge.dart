import 'difficulty_phase.dart';

/// Model representing a single breed identification challenge with two image options
class BreedChallenge {
  final String correctBreedName;
  final String correctImageUrl;
  final String incorrectImageUrl;
  final int correctImageIndex; // 0 or 1 to randomize position
  final DifficultyPhase phase;

  const BreedChallenge({
    required this.correctBreedName,
    required this.correctImageUrl,
    required this.incorrectImageUrl,
    required this.correctImageIndex,
    required this.phase,
  });

  /// Returns the image URL for the given index (0 or 1)
  String getImageUrl(int index) {
    if (index == correctImageIndex) {
      return correctImageUrl;
    } else {
      return incorrectImageUrl;
    }
  }

  /// Returns true if the selected image index is correct
  bool isCorrectSelection(int selectedIndex) {
    return selectedIndex == correctImageIndex;
  }

  /// Returns the list of image URLs in order [index0, index1]
  List<String> get imageUrls {
    return [getImageUrl(0), getImageUrl(1)];
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BreedChallenge &&
        other.correctBreedName == correctBreedName &&
        other.correctImageUrl == correctImageUrl &&
        other.incorrectImageUrl == incorrectImageUrl &&
        other.correctImageIndex == correctImageIndex &&
        other.phase == phase;
  }

  @override
  int get hashCode => Object.hash(
    correctBreedName,
    correctImageUrl,
    incorrectImageUrl,
    correctImageIndex,
    phase,
  );

  @override
  String toString() {
    return 'BreedChallenge(correctBreedName: $correctBreedName, '
        'correctImageIndex: $correctImageIndex, phase: $phase)';
  }
}
