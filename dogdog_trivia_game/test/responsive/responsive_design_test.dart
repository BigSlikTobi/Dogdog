import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dogdog_trivia_game/utils/responsive.dart';
import 'package:dogdog_trivia_game/widgets/modern_card.dart';
import 'package:dogdog_trivia_game/widgets/gradient_button.dart';
import 'package:dogdog_trivia_game/widgets/dog_breed_card.dart';

void main() {
  group('Responsive Design Tests', () {
    testWidgets('ResponsiveUtils correctly identifies screen types', (
      WidgetTester tester,
    ) async {
      // Test mobile screen
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.getScreenType(context), ScreenType.mobile);
              expect(ResponsiveUtils.isMobile(context), isTrue);
              expect(ResponsiveUtils.isTablet(context), isFalse);
              expect(ResponsiveUtils.isDesktop(context), isFalse);
              return const SizedBox();
            },
          ),
        ),
      );

      // Test tablet screen
      tester.view.physicalSize = const Size(800, 1200);
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.getScreenType(context), ScreenType.tablet);
              expect(ResponsiveUtils.isMobile(context), isFalse);
              expect(ResponsiveUtils.isTablet(context), isTrue);
              expect(ResponsiveUtils.isDesktop(context), isFalse);
              return const SizedBox();
            },
          ),
        ),
      );

      // Test desktop screen
      tester.view.physicalSize = const Size(1400, 1000);
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(
                ResponsiveUtils.getScreenType(context),
                ScreenType.desktop,
              );
              expect(ResponsiveUtils.isMobile(context), isFalse);
              expect(ResponsiveUtils.isTablet(context), isFalse);
              expect(ResponsiveUtils.isDesktop(context), isTrue);
              return const SizedBox();
            },
          ),
        ),
      );

      // Reset
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('Responsive padding scales correctly', (
      WidgetTester tester,
    ) async {
      late EdgeInsets mobilePadding;
      late EdgeInsets tabletPadding;
      late EdgeInsets desktopPadding;

      // Test mobile padding
      tester.view.physicalSize = const Size(400, 800);
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              mobilePadding = ResponsiveUtils.getResponsivePadding(context);
              return const SizedBox();
            },
          ),
        ),
      );

      // Test tablet padding
      tester.view.physicalSize = const Size(800, 1200);
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              tabletPadding = ResponsiveUtils.getResponsivePadding(context);
              return const SizedBox();
            },
          ),
        ),
      );

      // Test desktop padding
      tester.view.physicalSize = const Size(1400, 1000);
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              desktopPadding = ResponsiveUtils.getResponsivePadding(context);
              return const SizedBox();
            },
          ),
        ),
      );

      // Verify padding increases with screen size
      expect(tabletPadding.left, greaterThan(mobilePadding.left));
      expect(desktopPadding.left, greaterThan(tabletPadding.left));

      // Reset window size
      tester.view.resetPhysicalSize();
    });

    testWidgets('Font size multiplier respects text scaling', (
      WidgetTester tester,
    ) async {
      const textScales = [0.8, 1.0, 1.5, 2.0];
      final multipliers = <double>[];

      for (final scale in textScales) {
        await tester.pumpWidget(
          MediaQuery(
            data: MediaQueryData(
              textScaler: TextScaler.linear(scale),
              size: const Size(400, 800),
            ),
            child: Builder(
              builder: (context) {
                multipliers.add(ResponsiveUtils.getFontSizeMultiplier(context));
                return const SizedBox();
              },
            ),
          ),
        );
      }

      // Verify font size multiplier increases with text scale
      for (int i = 1; i < multipliers.length; i++) {
        expect(multipliers[i], greaterThanOrEqualTo(multipliers[i - 1]));
      }

      // Verify multipliers are within reasonable bounds
      for (final multiplier in multipliers) {
        expect(multiplier, greaterThanOrEqualTo(0.8));
        expect(multiplier, lessThanOrEqualTo(2.5));
      }
    });

    testWidgets('Answer grid columns adapt to screen size and orientation', (
      WidgetTester tester,
    ) async {
      late int mobilePortraitColumns;
      late int mobileLandscapeColumns;
      late int tabletPortraitColumns;
      late int tabletLandscapeColumns;

      // Mobile portrait
      tester.view.physicalSize = const Size(400, 800);
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(400, 800)),
          child: Builder(
            builder: (context) {
              mobilePortraitColumns = ResponsiveUtils.getAnswerGridColumns(
                context,
              );
              return const SizedBox();
            },
          ),
        ),
      );

      // Mobile landscape
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(800, 400)),
          child: Builder(
            builder: (context) {
              mobileLandscapeColumns = ResponsiveUtils.getAnswerGridColumns(
                context,
              );
              return const SizedBox();
            },
          ),
        ),
      );

      // Tablet portrait
      tester.view.physicalSize = const Size(800, 1200);
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(800, 1200)),
          child: Builder(
            builder: (context) {
              tabletPortraitColumns = ResponsiveUtils.getAnswerGridColumns(
                context,
              );
              return const SizedBox();
            },
          ),
        ),
      );

      // Tablet landscape
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(1200, 800)),
          child: Builder(
            builder: (context) {
              tabletLandscapeColumns = ResponsiveUtils.getAnswerGridColumns(
                context,
              );
              return const SizedBox();
            },
          ),
        ),
      );

      // Verify grid adapts appropriately
      expect(mobilePortraitColumns, equals(2)); // 2x2 grid for mobile portrait
      expect(
        mobileLandscapeColumns,
        equals(2),
      ); // Still 2x2 for mobile landscape
      expect(tabletPortraitColumns, equals(3)); // 3 columns for tablet portrait
      expect(
        tabletLandscapeColumns,
        equals(4),
      ); // Single row for tablet landscape

      // Reset window size
      tester.view.resetPhysicalSize();
    });

    testWidgets('ResponsiveContainer constrains content width appropriately', (
      WidgetTester tester,
    ) async {
      // Test on desktop (should constrain width)
      tester.view.physicalSize = const Size(1400, 1000);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveContainer(
              child: Container(
                width: double.infinity,
                height: 100,
                color: Colors.blue,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final containerSize = tester.getSize(find.byType(Container).last);
      expect(containerSize.width, lessThan(1400)); // Should be constrained
      expect(containerSize.width, equals(800)); // Desktop max width

      // Test on mobile (should not constrain width)
      tester.view.physicalSize = const Size(400, 800);
      await tester.pumpAndSettle();

      final mobileContainerSize = tester.getSize(find.byType(Container).last);
      expect(
        mobileContainerSize.width,
        lessThanOrEqualTo(400),
      ); // Should use available width

      // Reset window size
      tester.view.resetPhysicalSize();
    });

    testWidgets('ResponsiveBuilder provides correct screen type', (
      WidgetTester tester,
    ) async {
      late ScreenType capturedScreenType;

      tester.view.physicalSize = const Size(800, 1200);

      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveBuilder(
            builder: (context, screenType) {
              capturedScreenType = screenType;
              return Text('Screen type: ${screenType.name}');
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(capturedScreenType, equals(ScreenType.tablet));
      expect(find.text('Screen type: tablet'), findsOneWidget);

      // Reset window size
      tester.view.resetPhysicalSize();
    });

    testWidgets('Accessible button size meets minimum requirements', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final buttonSize = ResponsiveUtils.getAccessibleButtonSize(
                context,
              );
              expect(buttonSize.height, greaterThanOrEqualTo(44.0));
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('Card aspect ratio adapts to screen size', (
      WidgetTester tester,
    ) async {
      late double mobileRatio;
      late double tabletRatio;
      late double desktopRatio;

      // Mobile
      tester.view.physicalSize = const Size(400, 800);
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              mobileRatio = ResponsiveUtils.getCardAspectRatio(context);
              return const SizedBox();
            },
          ),
        ),
      );

      // Tablet
      tester.view.physicalSize = const Size(800, 1200);
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              tabletRatio = ResponsiveUtils.getCardAspectRatio(context);
              return const SizedBox();
            },
          ),
        ),
      );

      // Desktop
      tester.view.physicalSize = const Size(1400, 1000);
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              desktopRatio = ResponsiveUtils.getCardAspectRatio(context);
              return const SizedBox();
            },
          ),
        ),
      );

      // Verify ratios increase with screen size
      expect(tabletRatio, greaterThanOrEqualTo(mobileRatio));
      expect(desktopRatio, greaterThanOrEqualTo(tabletRatio));

      // Reset window size
      tester.view.resetPhysicalSize();
    });

    testWidgets('Animation duration respects reduced motion preference', (
      WidgetTester tester,
    ) async {
      const baseDuration = Duration(milliseconds: 300);

      // Test with animations enabled
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: false),
          child: Builder(
            builder: (context) {
              final duration = ResponsiveUtils.getAccessibleAnimationDuration(
                context,
                baseDuration,
              );
              expect(duration, equals(baseDuration));
              return const SizedBox();
            },
          ),
        ),
      );

      // Test with animations disabled
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Builder(
            builder: (context) {
              final duration = ResponsiveUtils.getAccessibleAnimationDuration(
                context,
                baseDuration,
              );
              expect(duration, equals(Duration.zero));
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('Accessible text style applies proper scaling and contrast', (
      WidgetTester tester,
    ) async {
      const baseStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.normal);

      // Test with high contrast and large text
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            highContrast: true,
            textScaler: TextScaler.linear(1.5),
          ),
          child: Builder(
            builder: (context) {
              final accessibleStyle = ResponsiveUtils.getAccessibleTextStyle(
                context,
                baseStyle,
              );

              expect(
                accessibleStyle.fontSize,
                greaterThan(baseStyle.fontSize!),
              );
              expect(accessibleStyle.fontWeight, equals(FontWeight.w600));
              return const SizedBox();
            },
          ),
        ),
      );

      // Test with normal settings
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            highContrast: false,
            textScaler: TextScaler.linear(1.0),
          ),
          child: Builder(
            builder: (context) {
              final accessibleStyle = ResponsiveUtils.getAccessibleTextStyle(
                context,
                baseStyle,
              );

              expect(accessibleStyle.fontWeight, equals(FontWeight.normal));
              return const SizedBox();
            },
          ),
        ),
      );
    });
  });

  group('Widget Responsive Behavior Tests', () {
    testWidgets('ModernCard adapts to different screen sizes', (
      WidgetTester tester,
    ) async {
      // Test mobile
      tester.view.physicalSize = const Size(400, 800);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ModernCard(child: const Text('Test Card'))),
        ),
      );

      await tester.pumpAndSettle();
      final mobileCardSize = tester.getSize(find.byType(ModernCard));

      // Test tablet
      tester.view.physicalSize = const Size(800, 1200);
      await tester.pumpAndSettle();

      final tabletCardSize = tester.getSize(find.byType(ModernCard));

      // Verify card adapts to screen size
      expect(tabletCardSize.width, greaterThanOrEqualTo(mobileCardSize.width));

      // Reset window size
      tester.view.resetPhysicalSize();
    });

    testWidgets('GradientButton maintains minimum touch target size', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientButton.small(
              text: 'Small Button',
              onPressed: () {},
              gradientColors: const [Colors.blue, Colors.purple],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final buttonSize = tester.getSize(find.byType(GradientButton));
      expect(buttonSize.height, greaterThanOrEqualTo(44.0));
      expect(buttonSize.width, greaterThanOrEqualTo(44.0));
    });

    testWidgets('DogBreedCard spacing adapts to screen size', (
      WidgetTester tester,
    ) async {
      // Test mobile spacing
      tester.view.physicalSize = const Size(400, 800);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DogBreedCard(
              breedName: 'Chihuahua',
              difficulty: 'easy',
              imagePath: 'assets/images/chihuahua.png',
              onTap: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      final mobileCardSize = tester.getSize(find.byType(DogBreedCard));

      // Test tablet spacing
      tester.view.physicalSize = const Size(800, 1200);
      await tester.pumpAndSettle();

      final tabletCardSize = tester.getSize(find.byType(DogBreedCard));

      // Verify spacing adapts (cards should be larger on tablet due to increased padding)
      expect(tabletCardSize.width, greaterThanOrEqualTo(mobileCardSize.width));

      // Reset window size
      tester.view.resetPhysicalSize();
    });
  });
}
