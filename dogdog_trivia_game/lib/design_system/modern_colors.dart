import 'package:flutter/material.dart';

/// Modern color system for the DogDog trivia game redesign.
/// Provides consistent color palette with gradients and accessibility-compliant colors.
class ModernColors {
  // Private constructor to prevent instantiation
  ModernColors._();

  // Primary Colors
  static const Color primaryPurple = Color(0xFF8B5CF6);
  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color primaryGreen = Color(0xFF10B981);
  static const Color primaryYellow = Color(0xFFF59E0B);
  static const Color primaryRed = Color(0xFFEF4444);
  static const Color primaryOrange = Color(0xFFFF6B35);
  static const Color primaryPink = Color(0xFFEC4899);

  // Secondary Colors
  static const Color secondaryPurple = Color(0xFF7C3AED);
  static const Color secondaryBlue = Color(0xFF3B82F6);
  static const Color secondaryGreen = Color(0xFF059669);
  static const Color secondaryYellow = Color(0xFFD97706);
  static const Color secondaryRed = Color(0xFFDC2626);
  static const Color secondaryOrange = Color(0xFFE55100);
  static const Color secondaryPink = Color(0xFFDB2777);

  // Gradient Colors
  static const List<Color> purpleGradient = [primaryPurple, secondaryPurple];
  static const List<Color> blueGradient = [primaryBlue, secondaryBlue];
  static const List<Color> greenGradient = [primaryGreen, secondaryGreen];
  static const List<Color> yellowGradient = [primaryYellow, secondaryYellow];
  static const List<Color> redGradient = [primaryRed, secondaryRed];
  static const List<Color> orangeGradient = [primaryOrange, secondaryOrange];

  // Background Colors
  static const Color backgroundGradientStart = Color(0xFFF3F0FF);
  static const Color backgroundGradientEnd = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color overlayBackground = Color(0x80000000);

  // Text Colors
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textLight = Color(0xFF9CA3AF);
  static const Color textOnDark = Color(0xFFFFFFFF);

  // Surface Colors
  static const Color surfaceLight = Color(0xFFF9FAFB);
  static const Color surfaceMedium = Color(0xFFF3F4F6);
  static const Color surfaceDark = Color(0xFFE5E7EB);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Difficulty Level Colors (mapped to dog breeds)
  static const Color easyColor = primaryGreen; // Chihuahua
  static const Color mediumColor = primaryYellow; // Cocker
  static const Color hardColor = primaryRed; // German Shepherd
  static const Color expertColor = primaryPurple; // Great Dane

  // Gradient definitions for difficulty levels
  static const List<Color> easyGradient = greenGradient;
  static const List<Color> mediumGradient = yellowGradient;
  static const List<Color> hardGradient = redGradient;
  static const List<Color> expertGradient = purpleGradient;

  // Background gradient for the app
  static const List<Color> backgroundGradient = [
    backgroundGradientStart,
    backgroundGradientEnd,
  ];

  // Helper method to get gradient colors by difficulty
  static List<Color> getGradientForDifficulty(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
      case 'leicht':
        return easyGradient;
      case 'medium':
      case 'mittel':
        return mediumGradient;
      case 'hard':
      case 'schwer':
        return hardGradient;
      case 'expert':
      case 'experte':
        return expertGradient;
      default:
        return purpleGradient;
    }
  }

  // Helper method to get primary color by difficulty
  static Color getColorForDifficulty(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
      case 'leicht':
        return easyColor;
      case 'medium':
      case 'mittel':
        return mediumColor;
      case 'hard':
      case 'schwer':
        return hardColor;
      case 'expert':
      case 'experte':
        return expertColor;
      default:
        return primaryPurple;
    }
  }

  // Helper method to create linear gradient
  static LinearGradient createLinearGradient(
    List<Color> colors, {
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    return LinearGradient(colors: colors, begin: begin, end: end);
  }

  // Helper method to create radial gradient
  static RadialGradient createRadialGradient(
    List<Color> colors, {
    AlignmentGeometry center = Alignment.center,
    double radius = 0.5,
  }) {
    return RadialGradient(colors: colors, center: center, radius: radius);
  }
}
