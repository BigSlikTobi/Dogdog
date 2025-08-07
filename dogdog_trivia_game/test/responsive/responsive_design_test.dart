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
      // Reset to a known state
      await tester.binding.setSurfaceSize(const Size(300, 600));

      // Test mobile screen - using smaller size to ensure mobile classification
      tester.view.physicalSize = const Size(300, 600);
      tester.view.devicePixelRatio = 1.0;

      ScreenType? actualScreenType;
      bool? actualIsMobile;
      bool? actualIsTablet;
      bool? actualIsDesktop;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              actualScreenType = ResponsiveUtils.getScreenType(context);
              actualIsMobile = ResponsiveUtils.isMobile(context);
              actualIsTablet = ResponsiveUtils.isTablet(context);
              actualIsDesktop = ResponsiveUtils.isDesktop(context);
              return const SizedBox();
            },
          ),
        ),
      );

      // Now test outside of the build context
      expect(actualScreenType, ScreenType.mobile);
      expect(actualIsMobile, isTrue);
      expect(actualIsTablet, isFalse);
      expect(actualIsDesktop, isFalse);

      // Test tablet screen - logical width should be 700 (clearly in tablet range 600-899)
      await tester.binding.setSurfaceSize(const Size(700, 1000));
      tester.view.physicalSize = const Size(700, 1000);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpAndSettle();

      ScreenType? actualScreenType2;
      bool? actualIsMobile2;
      bool? actualIsTablet2;
      bool? actualIsDesktop2;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              actualScreenType2 = ResponsiveUtils.getScreenType(context);
              actualIsMobile2 = ResponsiveUtils.isMobile(context);
              actualIsTablet2 = ResponsiveUtils.isTablet(context);
              actualIsDesktop2 = ResponsiveUtils.isDesktop(context);
              return const SizedBox();
            },
          ),
        ),
      );

      // Now test outside of the build context
      expect(actualScreenType2, ScreenType.tablet);
      expect(actualIsMobile2, isFalse);
      expect(actualIsTablet2, isTrue);
      expect(actualIsDesktop2, isFalse);

      // Test desktop screen - logical width should be 1000 (clearly in desktop range >= 900)
      await tester.binding.setSurfaceSize(const Size(1000, 800));
      tester.view.physicalSize = const Size(1000, 800);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpAndSettle();

      ScreenType? actualScreenType3;
      bool? actualIsMobile3;
      bool? actualIsTablet3;
      bool? actualIsDesktop3;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              actualScreenType3 = ResponsiveUtils.getScreenType(context);
              actualIsMobile3 = ResponsiveUtils.isMobile(context);
              actualIsTablet3 = ResponsiveUtils.isTablet(context);
              actualIsDesktop3 = ResponsiveUtils.isDesktop(context);
              return const SizedBox();
            },
          ),
        ),
      );

      // Now test outside of the build context
      expect(actualScreenType3, ScreenType.desktop);
      expect(actualIsMobile3, isFalse);
      expect(actualIsTablet3, isFalse);
      expect(actualIsDesktop3, isTrue);

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
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(400, 800)),
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                mobilePadding = ResponsiveUtils.getResponsivePadding(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      // Test tablet padding
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(800, 1200)),
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                tabletPadding = ResponsiveUtils.getResponsivePadding(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      await tester.pump(); // Ensure tablet test completes

      // Test desktop padding
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(1400, 1000)),
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                desktopPadding = ResponsiveUtils.getResponsivePadding(context);
                return const SizedBox();
              },
            ),
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

      // Mobile portrait (400x800 - width < 600 = mobile, height > width = portrait)
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

      // Mobile landscape (500x300 - width < 600 = mobile, height < width = landscape)
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(500, 300)),
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

      // Tablet portrait (800x1200 - 600 <= width < 900 = tablet, height > width = portrait)
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

      // Tablet landscape (850x600 - 600 <= width < 900 = tablet, height < width = landscape)
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(850, 600)),
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
      expect(
        tabletPortraitColumns,
        equals(2),
      ); // 2x2 grid for tablet portrait (same as mobile)
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
      await tester.binding.setSurfaceSize(const Size(1400, 1000));
      tester.view.physicalSize = const Size(1400, 1000);
      tester.view.devicePixelRatio = 1.0;

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
      // Desktop max content width is 800, minus padding (32*2) = 736
      expect(
        containerSize.width,
        equals(736),
      ); // Desktop max width minus padding

      // Test on mobile (should not constrain width)
      await tester.binding.setSurfaceSize(const Size(400, 800));
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
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

      await tester.binding.setSurfaceSize(const Size(800, 1200));
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;

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

      await tester.pump();
      final mobileCardSize = tester.getSize(find.byType(DogBreedCard));

      // Test tablet spacing
      tester.view.physicalSize = const Size(800, 1200);
      await tester.pump();

      final tabletCardSize = tester.getSize(find.byType(DogBreedCard));

      // Verify spacing adapts (cards should be larger on tablet due to increased padding)
      expect(tabletCardSize.width, greaterThanOrEqualTo(mobileCardSize.width));

      // Reset window size
      tester.view.resetPhysicalSize();
    });
  });
}
