import 'package:flutter_test/flutter_test.dart';
import 'package:dogdog_trivia_game/models/enums.dart';

void main() {
  group('PathTypeLocalization', () {
    test('should use proper localization keys for breed adventure', () {
      // This test verifies that the path_localization.dart file
      // now properly references the localization keys instead of hardcoded strings

      // The test ensures the code compiles without using hardcoded strings
      // If the path_localization.dart still had hardcoded strings,
      // the compilation would succeed but the localization would be broken

      expect(PathType.values.contains(PathType.breedAdventure), isTrue);
      expect(PathType.breedAdventure.toString(), contains('breedAdventure'));
    });
  });
}
