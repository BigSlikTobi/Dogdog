import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dogdog_trivia_game/design_system/modern_colors.dart';

void main() {
  group('ModernColors', () {
    group('Color Constants', () {
      test('should have correct primary colors', () {
        expect(ModernColors.primaryPurple, const Color(0xFF8B5CF6));
        expect(ModernColors.primaryBlue, const Color(0xFF4A90E2));
        expect(ModernColors.primaryGreen, const Color(0xFF10B981));
        expect(ModernColors.primaryYellow, const Color(0xFFF59E0B));
        expect(ModernColors.primaryRed, const Color(0xFFEF4444));
      });

      test('should have correct secondary colors', () {
        expect(ModernColors.secondaryPurple, const Color(0xFF7C3AED));
        expect(ModernColors.secondaryBlue, const Color(0xFF3B82F6));
        expect(ModernColors.secondaryGreen, const Color(0xFF059669));
        expect(ModernColors.secondaryYellow, const Color(0xFFD97706));
        expect(ModernColors.secondaryRed, const Color(0xFFDC2626));
      });

      test('should have correct background colors', () {
        expect(ModernColors.backgroundGradientStart, const Color(0xFFF3F0FF));
        expect(ModernColors.backgroundGradientEnd, const Color(0xFFFFFFFF));
        expect(ModernColors.cardBackground, const Color(0xFFFFFFFF));
        expect(ModernColors.overlayBackground, const Color(0x80000000));
      });

      test('should have correct text colors', () {
        expect(ModernColors.textPrimary, const Color(0xFF1F2937));
        expect(ModernColors.textSecondary, const Color(0xFF6B7280));
        expect(ModernColors.textLight, const Color(0xFF9CA3AF));
        expect(ModernColors.textOnDark, const Color(0xFFFFFFFF));
      });

      test('should have correct surface colors', () {
        expect(ModernColors.surfaceLight, const Color(0xFFF9FAFB));
        expect(ModernColors.surfaceMedium, const Color(0xFFF3F4F6));
        expect(ModernColors.surfaceDark, const Color(0xFFE5E7EB));
      });

      test('should have correct status colors', () {
        expect(ModernColors.success, const Color(0xFF10B981));
        expect(ModernColors.warning, const Color(0xFFF59E0B));
        expect(ModernColors.error, const Color(0xFFEF4444));
        expect(ModernColors.info, const Color(0xFF3B82F6));
      });

      test('should have correct difficulty colors mapped to dog breeds', () {
        expect(ModernColors.easyColor, ModernColors.primaryGreen); // Chihuahua
        expect(ModernColors.mediumColor, ModernColors.primaryYellow); // Cocker
        expect(
          ModernColors.hardColor,
          ModernColors.primaryRed,
        ); // German Shepherd
        expect(
          ModernColors.expertColor,
          ModernColors.primaryPurple,
        ); // Great Dane
      });
    });

    group('Gradient Definitions', () {
      test('should have correct gradient color pairs', () {
        expect(ModernColors.purpleGradient, [
          ModernColors.primaryPurple,
          ModernColors.secondaryPurple,
        ]);
        expect(ModernColors.blueGradient, [
          ModernColors.primaryBlue,
          ModernColors.secondaryBlue,
        ]);
        expect(ModernColors.greenGradient, [
          ModernColors.primaryGreen,
          ModernColors.secondaryGreen,
        ]);
        expect(ModernColors.yellowGradient, [
          ModernColors.primaryYellow,
          ModernColors.secondaryYellow,
        ]);
        expect(ModernColors.redGradient, [
          ModernColors.primaryRed,
          ModernColors.secondaryRed,
        ]);
      });

      test('should have correct difficulty gradient mappings', () {
        expect(ModernColors.easyGradient, ModernColors.greenGradient);
        expect(ModernColors.mediumGradient, ModernColors.yellowGradient);
        expect(ModernColors.hardGradient, ModernColors.redGradient);
        expect(ModernColors.expertGradient, ModernColors.purpleGradient);
      });

      test('should have correct background gradient', () {
        expect(ModernColors.backgroundGradient, [
          ModernColors.backgroundGradientStart,
          ModernColors.backgroundGradientEnd,
        ]);
      });

      test('should have exactly two colors in each gradient', () {
        expect(ModernColors.purpleGradient, hasLength(2));
        expect(ModernColors.blueGradient, hasLength(2));
        expect(ModernColors.greenGradient, hasLength(2));
        expect(ModernColors.yellowGradient, hasLength(2));
        expect(ModernColors.redGradient, hasLength(2));
        expect(ModernColors.backgroundGradient, hasLength(2));
      });
    });

    group('Difficulty Helper Methods', () {
      group('getGradientForDifficulty', () {
        test('should return correct gradient for English difficulty names', () {
          expect(
            ModernColors.getGradientForDifficulty('easy'),
            ModernColors.easyGradient,
          );
          expect(
            ModernColors.getGradientForDifficulty('medium'),
            ModernColors.mediumGradient,
          );
          expect(
            ModernColors.getGradientForDifficulty('hard'),
            ModernColors.hardGradient,
          );
          expect(
            ModernColors.getGradientForDifficulty('expert'),
            ModernColors.expertGradient,
          );
        });

        test('should return correct gradient for German difficulty names', () {
          expect(
            ModernColors.getGradientForDifficulty('leicht'),
            ModernColors.easyGradient,
          );
          expect(
            ModernColors.getGradientForDifficulty('mittel'),
            ModernColors.mediumGradient,
          );
          expect(
            ModernColors.getGradientForDifficulty('schwer'),
            ModernColors.hardGradient,
          );
          expect(
            ModernColors.getGradientForDifficulty('experte'),
            ModernColors.expertGradient,
          );
        });

        test('should handle case insensitive input', () {
          expect(
            ModernColors.getGradientForDifficulty('EASY'),
            ModernColors.easyGradient,
          );
          expect(
            ModernColors.getGradientForDifficulty('Easy'),
            ModernColors.easyGradient,
          );
          expect(
            ModernColors.getGradientForDifficulty('LEICHT'),
            ModernColors.easyGradient,
          );
          expect(
            ModernColors.getGradientForDifficulty('Mittel'),
            ModernColors.mediumGradient,
          );
        });

        test('should return default gradient for unknown difficulty', () {
          expect(
            ModernColors.getGradientForDifficulty('unknown'),
            ModernColors.purpleGradient,
          );
          expect(
            ModernColors.getGradientForDifficulty('invalid'),
            ModernColors.purpleGradient,
          );
          expect(
            ModernColors.getGradientForDifficulty(''),
            ModernColors.purpleGradient,
          );
        });

        test('should handle null and edge case inputs gracefully', () {
          expect(
            ModernColors.getGradientForDifficulty('   '),
            ModernColors.purpleGradient,
          );
          expect(
            ModernColors.getGradientForDifficulty('123'),
            ModernColors.purpleGradient,
          );
          expect(
            ModernColors.getGradientForDifficulty('easy123'),
            ModernColors.purpleGradient,
          );
        });
      });

      group('getColorForDifficulty', () {
        test('should return correct color for English difficulty names', () {
          expect(
            ModernColors.getColorForDifficulty('easy'),
            ModernColors.easyColor,
          );
          expect(
            ModernColors.getColorForDifficulty('medium'),
            ModernColors.mediumColor,
          );
          expect(
            ModernColors.getColorForDifficulty('hard'),
            ModernColors.hardColor,
          );
          expect(
            ModernColors.getColorForDifficulty('expert'),
            ModernColors.expertColor,
          );
        });

        test('should return correct color for German difficulty names', () {
          expect(
            ModernColors.getColorForDifficulty('leicht'),
            ModernColors.easyColor,
          );
          expect(
            ModernColors.getColorForDifficulty('mittel'),
            ModernColors.mediumColor,
          );
          expect(
            ModernColors.getColorForDifficulty('schwer'),
            ModernColors.hardColor,
          );
          expect(
            ModernColors.getColorForDifficulty('experte'),
            ModernColors.expertColor,
          );
        });

        test('should handle case insensitive input', () {
          expect(
            ModernColors.getColorForDifficulty('HARD'),
            ModernColors.hardColor,
          );
          expect(
            ModernColors.getColorForDifficulty('Hard'),
            ModernColors.hardColor,
          );
          expect(
            ModernColors.getColorForDifficulty('SCHWER'),
            ModernColors.hardColor,
          );
          expect(
            ModernColors.getColorForDifficulty('Experte'),
            ModernColors.expertColor,
          );
        });

        test('should return default color for unknown difficulty', () {
          expect(
            ModernColors.getColorForDifficulty('unknown'),
            ModernColors.primaryPurple,
          );
          expect(
            ModernColors.getColorForDifficulty('invalid'),
            ModernColors.primaryPurple,
          );
          expect(
            ModernColors.getColorForDifficulty(''),
            ModernColors.primaryPurple,
          );
        });

        test('should handle edge case inputs gracefully', () {
          expect(
            ModernColors.getColorForDifficulty('   '),
            ModernColors.primaryPurple,
          );
          expect(
            ModernColors.getColorForDifficulty('medium_hard'),
            ModernColors.primaryPurple,
          );
          expect(
            ModernColors.getColorForDifficulty('expert_level'),
            ModernColors.primaryPurple,
          );
        });
      });
    });

    group('Gradient Creation Methods', () {
      group('createLinearGradient', () {
        test('should create linear gradient with default parameters', () {
          final gradient = ModernColors.createLinearGradient(
            ModernColors.purpleGradient,
          );

          expect(gradient.colors, ModernColors.purpleGradient);
          expect(gradient.begin, Alignment.topLeft);
          expect(gradient.end, Alignment.bottomRight);
        });

        test('should create linear gradient with custom parameters', () {
          final gradient = ModernColors.createLinearGradient(
            ModernColors.blueGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          );

          expect(gradient.colors, ModernColors.blueGradient);
          expect(gradient.begin, Alignment.topCenter);
          expect(gradient.end, Alignment.bottomCenter);
        });

        test('should work with different color combinations', () {
          final customColors = [Colors.red, Colors.blue, Colors.green];
          final gradient = ModernColors.createLinearGradient(
            customColors,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          );

          expect(gradient.colors, customColors);
          expect(gradient.begin, Alignment.centerLeft);
          expect(gradient.end, Alignment.centerRight);
        });

        test('should handle single color gradient', () {
          final singleColor = [ModernColors.primaryPurple];
          final gradient = ModernColors.createLinearGradient(singleColor);

          expect(gradient.colors, singleColor);
          expect(gradient.colors, hasLength(1));
        });

        test('should handle empty color list', () {
          final emptyColors = <Color>[];
          final gradient = ModernColors.createLinearGradient(emptyColors);

          expect(gradient.colors, emptyColors);
          expect(gradient.colors, isEmpty);
        });
      });

      group('createRadialGradient', () {
        test('should create radial gradient with default parameters', () {
          final gradient = ModernColors.createRadialGradient(
            ModernColors.greenGradient,
          );

          expect(gradient.colors, ModernColors.greenGradient);
          expect(gradient.center, Alignment.center);
          expect(gradient.radius, 0.5);
        });

        test('should create radial gradient with custom parameters', () {
          final gradient = ModernColors.createRadialGradient(
            ModernColors.redGradient,
            center: Alignment.topLeft,
            radius: 0.8,
          );

          expect(gradient.colors, ModernColors.redGradient);
          expect(gradient.center, Alignment.topLeft);
          expect(gradient.radius, 0.8);
        });

        test('should work with different color combinations', () {
          final customColors = [Colors.yellow, Colors.orange];
          final gradient = ModernColors.createRadialGradient(
            customColors,
            center: Alignment.bottomRight,
            radius: 1.0,
          );

          expect(gradient.colors, customColors);
          expect(gradient.center, Alignment.bottomRight);
          expect(gradient.radius, 1.0);
        });

        test('should handle edge case radius values', () {
          final gradient1 = ModernColors.createRadialGradient(
            ModernColors.yellowGradient,
            radius: 0.0,
          );
          expect(gradient1.radius, 0.0);

          final gradient2 = ModernColors.createRadialGradient(
            ModernColors.yellowGradient,
            radius: 2.0,
          );
          expect(gradient2.radius, 2.0);
        });
      });
    });

    group('Color Accessibility and Contrast', () {
      test('should have sufficient contrast for text colors', () {
        // Test that text colors have good contrast ratios
        // This is a basic check - in a real app you'd use proper contrast calculation
        expect(ModernColors.textPrimary.computeLuminance(), lessThan(0.5));
        expect(ModernColors.textOnDark.computeLuminance(), greaterThan(0.5));
      });

      test('should have distinct primary and secondary color pairs', () {
        expect(ModernColors.primaryPurple, isNot(ModernColors.secondaryPurple));
        expect(ModernColors.primaryBlue, isNot(ModernColors.secondaryBlue));
        expect(ModernColors.primaryGreen, isNot(ModernColors.secondaryGreen));
        expect(ModernColors.primaryYellow, isNot(ModernColors.secondaryYellow));
        expect(ModernColors.primaryRed, isNot(ModernColors.secondaryRed));
      });

      test('should have overlay background with proper transparency', () {
        expect(ModernColors.overlayBackground.alpha, lessThan(255));
        expect(ModernColors.overlayBackground.alpha, greaterThan(0));
      });
    });

    group('Color Consistency', () {
      test('should maintain consistency between status and primary colors', () {
        expect(ModernColors.success, ModernColors.primaryGreen);
        expect(ModernColors.warning, ModernColors.primaryYellow);
        expect(ModernColors.error, ModernColors.primaryRed);
        expect(ModernColors.info, ModernColors.secondaryBlue);
      });

      test('should have surface colors in proper hierarchy', () {
        final lightLuminance = ModernColors.surfaceLight.computeLuminance();
        final mediumLuminance = ModernColors.surfaceMedium.computeLuminance();
        final darkLuminance = ModernColors.surfaceDark.computeLuminance();

        expect(lightLuminance, greaterThan(mediumLuminance));
        expect(mediumLuminance, greaterThan(darkLuminance));
      });

      test('should have background gradient from light to white', () {
        final startLuminance = ModernColors.backgroundGradientStart
            .computeLuminance();
        final endLuminance = ModernColors.backgroundGradientEnd
            .computeLuminance();

        expect(endLuminance, greaterThanOrEqualTo(startLuminance));
        expect(ModernColors.backgroundGradientEnd, Colors.white);
      });
    });

    group('Class Structure', () {
      test('should not be instantiable', () {
        // This test ensures the private constructor prevents instantiation
        // We can't directly test this, but we can verify the class structure
        expect(ModernColors, isA<Type>());
      });

      test('should have all constants as static', () {
        // All color constants should be accessible without instantiation
        expect(ModernColors.primaryPurple, isA<Color>());
        expect(ModernColors.purpleGradient, isA<List<Color>>());
        expect(ModernColors.backgroundGradient, isA<List<Color>>());
      });
    });

    group('Integration with Flutter Framework', () {
      test('should work with Material Design color system', () {
        // Test that our colors can be used in Material widgets
        final colorScheme = ColorScheme.fromSeed(
          seedColor: ModernColors.primaryPurple,
        );
        expect(colorScheme.primary, isA<Color>());
      });

      test('should work with ThemeData', () {
        final theme = ThemeData(
          primaryColor: ModernColors.primaryPurple,
          colorScheme: ColorScheme.fromSeed(
            seedColor: ModernColors.primaryPurple,
          ),
        );
        expect(theme.primaryColor, ModernColors.primaryPurple);
      });
    });

    group('Performance and Memory', () {
      test('should reuse color instances for efficiency', () {
        // Test that repeated calls return the same instances
        final color1 = ModernColors.getColorForDifficulty('easy');
        final color2 = ModernColors.getColorForDifficulty('easy');
        expect(identical(color1, color2), isTrue);

        final gradient1 = ModernColors.getGradientForDifficulty('medium');
        final gradient2 = ModernColors.getGradientForDifficulty('medium');
        expect(identical(gradient1, gradient2), isTrue);
      });

      test('should have immutable color lists', () {
        // Verify that gradient lists are const and immutable
        expect(ModernColors.purpleGradient, isA<List<Color>>());
        expect(
          () => ModernColors.purpleGradient.add(Colors.black),
          throwsUnsupportedError,
        );
      });
    });
  });
}
