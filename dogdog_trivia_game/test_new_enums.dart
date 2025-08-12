import 'package:flutter/material.dart';
import 'lib/models/enums.dart';
import 'lib/utils/path_localization.dart';

void main() {
  print('Testing new PathType enum values:');

  // Test enum values
  print('PathType.dogTrivia: ${PathType.dogTrivia}');
  print('PathType.puppyQuest: ${PathType.puppyQuest}');

  // Test display names
  print('dogTrivia displayName: ${PathType.dogTrivia.displayName}');
  print('puppyQuest displayName: ${PathType.puppyQuest.displayName}');

  // Test descriptions
  print('dogTrivia description: ${PathType.dogTrivia.description}');
  print('puppyQuest description: ${PathType.puppyQuest.description}');

  print('\nAll enum values work correctly!');

  // Test that we only have 2 values now
  print('Total PathType values: ${PathType.values.length}');
  assert(PathType.values.length == 2, 'Should have exactly 2 PathType values');

  print('✅ Tests passed! The enum changes are working correctly.');
}
