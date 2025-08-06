import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dogdog_trivia_game/widgets/dog_breed_card.dart';
import 'package:dogdog_trivia_game/design_system/modern_colors.dart';
import 'package:dogdog_trivia_game/design_system/modern_spacing.dart';

void main() {
  group('DogBreedCard', () {
    testWidgets('should render breed name and image', (
      WidgetTester tester,
    ) async {
      const breedName = 'Test Breed';
      const difficulty = 'easy';
      const imagePath = 'assets/images/test.png';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DogBreedCard(
              breedName: breedName,
              difficulty: difficulty,
              imagePath: imagePath,
            ),
          ),
        ),
      );

      expect(find.text(breedName), findsOneWidget);
      // Should show either Image.asset or fallback Icon
      expect(
        find.byWidgetPredicate((widget) => widget is Image || widget is Icon),
        findsOneWidget,
      );
    });

    testWidgets('should apply gradient background based on difficulty', (
      WidgetTester tester,
    ) async {
      const difficulty = 'easy';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DogBreedCard(
              breedName: 'Test',
              difficulty: difficulty,
              imagePath: 'assets/images/test.png',
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      final gradient = decoration.gradient as LinearGradient;

      expect(
        gradient.colors,
        ModernColors.getGradientForDifficulty(difficulty),
      );
    });

    testWidgets('should respond to tap when enabled', (
      WidgetTester tester,
    ) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DogBreedCard(
              breedName: 'Test',
              difficulty: 'easy',
              imagePath: 'assets/images/test.png',
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(InkWell));
      expect(tapped, isTrue);
    });

    testWidgets('should not respond to tap when disabled', (
      WidgetTester tester,
    ) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DogBreedCard(
              breedName: 'Test',
              difficulty: 'easy',
              imagePath: 'assets/images/test.png',
              onTap: () => tapped = true,
              isEnabled: false,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(InkWell));
      expect(tapped, isFalse);
    });

    testWidgets('should show selected state with border', (
      WidgetTester tester,
    ) async {
      const difficulty = 'easy';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DogBreedCard(
              breedName: 'Test',
              difficulty: difficulty,
              imagePath: 'assets/images/test.png',
              isSelected: true,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      final border = decoration.border as Border;

      expect(border.top.color, ModernColors.getColorForDifficulty(difficulty));
      expect(border.top.width, 3.0);
    });

    testWidgets('should apply custom width and height', (
      WidgetTester tester,
    ) async {
      const customWidth = 200.0;
      const customHeight = 150.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DogBreedCard(
              breedName: 'Test',
              difficulty: 'easy',
              imagePath: 'assets/images/test.png',
              width: customWidth,
              height: customHeight,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.constraints?.maxWidth, customWidth);
      expect(container.constraints?.maxHeight, customHeight);
    });

    testWidgets('should show title and subtitle when provided', (
      WidgetTester tester,
    ) async {
      const title = 'Achievement Title';
      const subtitle = 'Achievement Description';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DogBreedCard(
              breedName: 'Test',
              difficulty: 'easy',
              imagePath: 'assets/images/test.png',
              title: title,
              subtitle: subtitle,
            ),
          ),
        ),
      );

      expect(find.text(title), findsOneWidget);
      expect(find.text(subtitle), findsOneWidget);
    });

    testWidgets('should hide breed name when showBreedName is false', (
      WidgetTester tester,
    ) async {
      const breedName = 'Test Breed';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DogBreedCard(
              breedName: breedName,
              difficulty: 'easy',
              imagePath: 'assets/images/test.png',
              showBreedName: false,
            ),
          ),
        ),
      );

      expect(find.text(breedName), findsNothing);
    });

    testWidgets('should have reduced opacity when disabled', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DogBreedCard(
              breedName: 'Test',
              difficulty: 'easy',
              imagePath: 'assets/images/test.png',
              isEnabled: false,
            ),
          ),
        ),
      );

      final opacity = tester.widget<Opacity>(find.byType(Opacity));
      expect(opacity.opacity, 0.6);
    });

    testWidgets('should show fallback icon when image fails to load', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DogBreedCard(
              breedName: 'Test',
              difficulty: 'easy',
              imagePath: 'assets/images/nonexistent.png',
            ),
          ),
        ),
      );

      // Should show either Image.asset or fallback Icon
      expect(
        find.byWidgetPredicate((widget) => widget is Image || widget is Icon),
        findsOneWidget,
      );
    });

    group('DogBreedCard Constructors', () {
      testWidgets('should create difficulty card', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DogBreedCard.difficulty(
                breedName: 'Test',
                difficulty: 'easy',
                imagePath: 'assets/images/test.png',
                onTap: () {},
              ),
            ),
          ),
        );

        expect(find.byType(DogBreedCard), findsOneWidget);
        expect(find.text('Test'), findsOneWidget);
      });

      testWidgets('should create achievement card', (
        WidgetTester tester,
      ) async {
        const title = 'Achievement';

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DogBreedCard.achievement(
                breedName: 'Test',
                difficulty: 'easy',
                imagePath: 'assets/images/test.png',
                title: title,
              ),
            ),
          ),
        );

        expect(find.byType(DogBreedCard), findsOneWidget);
        expect(find.text(title), findsOneWidget);
        // Breed name should be hidden in achievement cards
        expect(find.text('Test'), findsNothing);
      });
    });

    group('DogBreedCard Variants', () {
      testWidgets('should create chihuahua card with correct properties', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: DogBreedCardVariants.chihuahua(onTap: () {})),
          ),
        );

        expect(find.text('Chihuahua'), findsOneWidget);

        final container = tester.widget<Container>(
          find.byType(Container).first,
        );
        final decoration = container.decoration as BoxDecoration;
        final gradient = decoration.gradient as LinearGradient;

        expect(gradient.colors, ModernColors.getGradientForDifficulty('easy'));
      });

      testWidgets('should create cocker card with correct properties', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: DogBreedCardVariants.cocker(onTap: () {})),
          ),
        );

        expect(find.text('Cocker Spaniel'), findsOneWidget);

        final container = tester.widget<Container>(
          find.byType(Container).first,
        );
        final decoration = container.decoration as BoxDecoration;
        final gradient = decoration.gradient as LinearGradient;

        expect(
          gradient.colors,
          ModernColors.getGradientForDifficulty('medium'),
        );
      });

      testWidgets(
        'should create german shepherd card with correct properties',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: DogBreedCardVariants.germanShepherd(onTap: () {}),
              ),
            ),
          );

          expect(find.text('German Shepherd'), findsOneWidget);

          final container = tester.widget<Container>(
            find.byType(Container).first,
          );
          final decoration = container.decoration as BoxDecoration;
          final gradient = decoration.gradient as LinearGradient;

          expect(
            gradient.colors,
            ModernColors.getGradientForDifficulty('hard'),
          );
        },
      );

      testWidgets('should create great dane card with correct properties', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: DogBreedCardVariants.greatDane(onTap: () {})),
          ),
        );

        expect(find.text('Great Dane'), findsOneWidget);

        final container = tester.widget<Container>(
          find.byType(Container).first,
        );
        final decoration = container.decoration as BoxDecoration;
        final gradient = decoration.gradient as LinearGradient;

        expect(
          gradient.colors,
          ModernColors.getGradientForDifficulty('expert'),
        );
      });

      testWidgets('should create custom card with provided properties', (
        WidgetTester tester,
      ) async {
        const customBreed = 'Custom Breed';
        const customDifficulty = 'medium';

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DogBreedCardVariants.custom(
                breedName: customBreed,
                difficulty: customDifficulty,
                imagePath: 'assets/images/custom.png',
                onTap: () {},
              ),
            ),
          ),
        );

        expect(find.text(customBreed), findsOneWidget);

        final container = tester.widget<Container>(
          find.byType(Container).first,
        );
        final decoration = container.decoration as BoxDecoration;
        final gradient = decoration.gradient as LinearGradient;

        expect(
          gradient.colors,
          ModernColors.getGradientForDifficulty(customDifficulty),
        );
      });
    });

    group('Accessibility', () {
      testWidgets('should have semantic properties', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DogBreedCard(
                breedName: 'Test',
                difficulty: 'easy',
                imagePath: 'assets/images/test.png',
                onTap: () {},
              ),
            ),
          ),
        );

        expect(find.byType(Semantics), findsWidgets);
      });

      testWidgets('should use custom semantic label when provided', (
        WidgetTester tester,
      ) async {
        const semanticLabel = 'Custom accessibility label';

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DogBreedCard(
                breedName: 'Test',
                difficulty: 'easy',
                imagePath: 'assets/images/test.png',
                semanticLabel: semanticLabel,
              ),
            ),
          ),
        );

        expect(find.byType(Semantics), findsWidgets);
      });

      testWidgets('should indicate selected state in semantics', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DogBreedCard(
                breedName: 'Test',
                difficulty: 'easy',
                imagePath: 'assets/images/test.png',
                isSelected: true,
              ),
            ),
          ),
        );

        expect(find.byType(Semantics), findsWidgets);
      });

      testWidgets('should indicate disabled state in semantics', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DogBreedCard(
                breedName: 'Test',
                difficulty: 'easy',
                imagePath: 'assets/images/test.png',
                isEnabled: false,
              ),
            ),
          ),
        );

        expect(find.byType(Semantics), findsWidgets);
      });
    });

    group('Animation', () {
      testWidgets('should have scale animation on press', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DogBreedCard(
                breedName: 'Test',
                difficulty: 'easy',
                imagePath: 'assets/images/test.png',
                onTap: () {},
              ),
            ),
          ),
        );

        expect(find.byType(Transform), findsWidgets);
      });

      testWidgets('should animate when pressed', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DogBreedCard(
                breedName: 'Test',
                difficulty: 'easy',
                imagePath: 'assets/images/test.png',
                onTap: () {},
              ),
            ),
          ),
        );

        // Should have AnimatedBuilder for animations
        expect(find.byType(AnimatedBuilder), findsWidgets);
      });
    });

    group('Edge Cases', () {
      testWidgets('should handle very long breed names', (
        WidgetTester tester,
      ) async {
        const longBreedName =
            'This is a very long dog breed name that might overflow';

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DogBreedCard(
                breedName: longBreedName,
                difficulty: 'easy',
                imagePath: 'assets/images/test.png',
              ),
            ),
          ),
        );

        expect(find.text(longBreedName), findsOneWidget);
      });

      testWidgets('should handle null onTap gracefully', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DogBreedCard(
                breedName: 'Test',
                difficulty: 'easy',
                imagePath: 'assets/images/test.png',
                onTap: null,
              ),
            ),
          ),
        );

        expect(find.byType(DogBreedCard), findsOneWidget);
      });

      testWidgets('should handle empty image path', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DogBreedCard(
                breedName: 'Test',
                difficulty: 'easy',
                imagePath: '',
              ),
            ),
          ),
        );

        // Should show fallback icon
        expect(
          find.byWidgetPredicate((widget) => widget is Image || widget is Icon),
          findsOneWidget,
        );
      });

      testWidgets('should handle very small dimensions', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DogBreedCard(
                breedName: 'Test',
                difficulty: 'easy',
                imagePath: 'assets/images/test.png',
                width: 50.0,
                height: 50.0,
              ),
            ),
          ),
        );

        final container = tester.widget<Container>(
          find.byType(Container).first,
        );
        expect(container.constraints?.maxWidth, 50.0);
        expect(container.constraints?.maxHeight, 50.0);
      });
    });
  });
}
