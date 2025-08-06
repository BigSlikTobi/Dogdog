import 'package:flutter/material.dart';

/// Modern shadow system for the DogDog trivia game redesign.
/// Provides consistent elevation and shadow definitions for depth and hierarchy.
class ModernShadows {
  // Private constructor to prevent instantiation
  ModernShadows._();

  // Shadow colors
  static const Color _shadowColor = Color(0x1A000000); // 10% black
  static const Color _shadowColorLight = Color(0x0D000000); // 5% black
  static const Color _shadowColorMedium = Color(0x26000000); // 15% black
  static const Color _shadowColorDark = Color(0x33000000); // 20% black

  // Elevation levels (Material Design inspired)
  static const double elevation0 = 0.0;
  static const double elevation1 = 1.0;
  static const double elevation2 = 2.0;
  static const double elevation3 = 3.0;
  static const double elevation4 = 4.0;
  static const double elevation6 = 6.0;
  static const double elevation8 = 8.0;
  static const double elevation12 = 12.0;
  static const double elevation16 = 16.0;
  static const double elevation24 = 24.0;

  // Shadow definitions for different elevation levels

  // No shadow
  static const List<BoxShadow> none = [];

  // Subtle shadow for cards and containers
  static const List<BoxShadow> subtle = [
    BoxShadow(
      color: _shadowColorLight,
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
  ];

  // Small shadow for buttons and interactive elements
  static const List<BoxShadow> small = [
    BoxShadow(
      color: _shadowColor,
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: 0,
    ),
  ];

  // Medium shadow for cards and elevated surfaces
  static const List<BoxShadow> medium = [
    BoxShadow(
      color: _shadowColor,
      offset: Offset(0, 4),
      blurRadius: 8,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: _shadowColorLight,
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: 0,
    ),
  ];

  // Large shadow for modals and floating elements
  static const List<BoxShadow> large = [
    BoxShadow(
      color: _shadowColorMedium,
      offset: Offset(0, 8),
      blurRadius: 16,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: _shadowColorLight,
      offset: Offset(0, 4),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  // Extra large shadow for overlays and popups
  static const List<BoxShadow> extraLarge = [
    BoxShadow(
      color: _shadowColorDark,
      offset: Offset(0, 12),
      blurRadius: 24,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: _shadowColorMedium,
      offset: Offset(0, 6),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];

  // Component-specific shadows
  static const List<BoxShadow> card = medium;
  static const List<BoxShadow> button = small;
  static const List<BoxShadow> floatingButton = large;
  static const List<BoxShadow> modal = extraLarge;
  static const List<BoxShadow> tooltip = small;
  static const List<BoxShadow> dropdown = medium;

  // Interactive state shadows
  static const List<BoxShadow> buttonPressed = [
    BoxShadow(
      color: _shadowColorLight,
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> buttonHover = [
    BoxShadow(
      color: _shadowColorMedium,
      offset: Offset(0, 4),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> cardHover = [
    BoxShadow(
      color: _shadowColorMedium,
      offset: Offset(0, 6),
      blurRadius: 16,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: _shadowColorLight,
      offset: Offset(0, 3),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  // Colored shadows for special effects
  static List<BoxShadow> colored(Color color, {double opacity = 0.3}) {
    return [
      BoxShadow(
        color: color.withValues(alpha: opacity),
        offset: const Offset(0, 4),
        blurRadius: 12,
        spreadRadius: 0,
      ),
    ];
  }

  // Glow effect shadows
  static List<BoxShadow> glow(
    Color color, {
    double opacity = 0.4,
    double blur = 8,
  }) {
    return [
      BoxShadow(
        color: color.withValues(alpha: opacity),
        offset: const Offset(0, 0),
        blurRadius: blur,
        spreadRadius: 2,
      ),
    ];
  }

  // Inner shadow effect (using inset property where supported)
  static const List<BoxShadow> inner = [
    BoxShadow(
      color: _shadowColorLight,
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: -2,
    ),
  ];

  // Helper methods for dynamic shadows
  static List<BoxShadow> custom({
    required Color color,
    required Offset offset,
    required double blurRadius,
    double spreadRadius = 0,
    double opacity = 1.0,
  }) {
    return [
      BoxShadow(
        color: color.withValues(alpha: opacity),
        offset: offset,
        blurRadius: blurRadius,
        spreadRadius: spreadRadius,
      ),
    ];
  }

  // Get shadow by elevation level
  static List<BoxShadow> byElevation(double elevation) {
    if (elevation <= 0) return none;
    if (elevation <= 1) return subtle;
    if (elevation <= 2) return small;
    if (elevation <= 4) return medium;
    if (elevation <= 8) return large;
    return extraLarge;
  }

  // Animated shadow transition helper
  static List<BoxShadow> lerp(List<BoxShadow> a, List<BoxShadow> b, double t) {
    if (a.isEmpty && b.isEmpty) return [];
    if (a.isEmpty) return b.map((shadow) => shadow.scale(t)).toList();
    if (b.isEmpty) return a.map((shadow) => shadow.scale(1 - t)).toList();

    final result = <BoxShadow>[];
    final maxLength = a.length > b.length ? a.length : b.length;

    for (int i = 0; i < maxLength; i++) {
      final shadowA = i < a.length ? a[i] : a.last;
      final shadowB = i < b.length ? b[i] : b.last;
      result.add(BoxShadow.lerp(shadowA, shadowB, t)!);
    }

    return result;
  }

  // Material Design elevation to shadow mapping
  static List<BoxShadow> materialElevation(double elevation) {
    switch (elevation.round()) {
      case 0:
        return none;
      case 1:
        return const [
          BoxShadow(
            color: Color(0x1F000000),
            offset: Offset(0, 2),
            blurRadius: 1,
            spreadRadius: -1,
          ),
          BoxShadow(
            color: Color(0x24000000),
            offset: Offset(0, 1),
            blurRadius: 1,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Color(0x1F000000),
            offset: Offset(0, 1),
            blurRadius: 3,
            spreadRadius: 0,
          ),
        ];
      case 2:
        return const [
          BoxShadow(
            color: Color(0x1F000000),
            offset: Offset(0, 3),
            blurRadius: 1,
            spreadRadius: -2,
          ),
          BoxShadow(
            color: Color(0x24000000),
            offset: Offset(0, 2),
            blurRadius: 2,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Color(0x1F000000),
            offset: Offset(0, 1),
            blurRadius: 5,
            spreadRadius: 0,
          ),
        ];
      case 3:
        return const [
          BoxShadow(
            color: Color(0x1F000000),
            offset: Offset(0, 3),
            blurRadius: 3,
            spreadRadius: -2,
          ),
          BoxShadow(
            color: Color(0x24000000),
            offset: Offset(0, 3),
            blurRadius: 4,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Color(0x1F000000),
            offset: Offset(0, 1),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ];
      case 4:
        return const [
          BoxShadow(
            color: Color(0x1F000000),
            offset: Offset(0, 2),
            blurRadius: 4,
            spreadRadius: -1,
          ),
          BoxShadow(
            color: Color(0x24000000),
            offset: Offset(0, 4),
            blurRadius: 5,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Color(0x1F000000),
            offset: Offset(0, 1),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ];
      default:
        return medium;
    }
  }
}
