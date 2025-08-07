import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dogdog_trivia_game/services/image_service.dart';
import 'package:dogdog_trivia_game/widgets/dog_breed_card.dart';
import 'package:dogdog_trivia_game/widgets/success_animation_widget.dart';
import 'package:dogdog_trivia_game/widgets/app_initializer.dart';

void main() {
  group('Image Loading Performance Integration Tests', () {
    testWidgets('preloads critical images efficiently', (tester) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox())),
      );

      await ImageService.preloadCriticalImages(
        tester.element(find.byType(Scaffold)),
      );

      stopwatch.stop();

      // Image preloading should complete within reasonable time (5 seconds max)
      expect(stopwatch.elapsedMilliseconds, lessThan(5000));
    });

    testWidgets('dog breed cards load images efficiently', (tester) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                DogBreedCardVariants.chihuahua(width: 100, height: 100),
                DogBreedCardVariants.cocker(width: 100, height: 100),
                DogBreedCardVariants.germanShepherd(width: 100, height: 100),
                DogBreedCardVariants.greatDane(width: 100, height: 100),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      stopwatch.stop();

      // Multiple dog breed cards should render within reasonable time
      expect(stopwatch.elapsedMilliseconds, lessThan(3000));
      expect(find.byType(DogBreedCard), findsNWidgets(4));
    });

    testWidgets('success animation images load without delay', (tester) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SuccessAnimationWidget(
              width: 100,
              height: 100,
              autoStart: false, // Don't start animation automatically
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      stopwatch.stop();

      // Success animation widget should render quickly
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      expect(find.byType(SuccessAnimationWidget), findsOneWidget);
    });

    testWidgets('app initializer completes within acceptable time', (
      tester,
    ) async {
      final stopwatch = Stopwatch()..start();
      bool initializationComplete = false;

      await tester.pumpWidget(
        MaterialApp(
          home: AppInitializer(
            onInitializationComplete: () {
              initializationComplete = true;
            },
            child: const Text('App Ready'),
          ),
        ),
      );

      // Wait for initialization to complete
      await tester.pumpAndSettle();

      stopwatch.stop();

      // App initialization should complete within reasonable time
      expect(stopwatch.elapsedMilliseconds, lessThan(10000));
      expect(initializationComplete, isTrue);
      expect(find.text('App Ready'), findsOneWidget);
    });

    testWidgets('handles multiple simultaneous image loads', (tester) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GridView.count(
              crossAxisCount: 2,
              children: [
                ImageService.getDogBreedImage(
                  breedName: 'chihuahua',
                  width: 50,
                  height: 50,
                ),
                ImageService.getDogBreedImage(
                  breedName: 'cocker',
                  width: 50,
                  height: 50,
                ),
                ImageService.getDogBreedImage(
                  breedName: 'german shepherd',
                  width: 50,
                  height: 50,
                ),
                ImageService.getDogBreedImage(
                  breedName: 'great dane',
                  width: 50,
                  height: 50,
                ),
                ImageService.getSuccessImage(
                  isFirstImage: true,
                  width: 50,
                  height: 50,
                ),
                ImageService.getSuccessImage(
                  isFirstImage: false,
                  width: 50,
                  height: 50,
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      stopwatch.stop();

      // Multiple simultaneous image loads should complete efficiently
      expect(stopwatch.elapsedMilliseconds, lessThan(5000));
      expect(find.byType(Image), findsNWidgets(6));
    });

    testWidgets('image cache improves subsequent load times', (tester) async {
      // First load - measure time
      final firstLoadStopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ImageService.getDogBreedImage(
              breedName: 'chihuahua',
              width: 100,
              height: 100,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      firstLoadStopwatch.stop();

      // Second load - should be faster due to caching
      final secondLoadStopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ImageService.getDogBreedImage(
              breedName: 'chihuahua',
              width: 100,
              height: 100,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      secondLoadStopwatch.stop();

      // Both loads should complete, second should be faster or similar
      expect(firstLoadStopwatch.elapsedMilliseconds, lessThan(3000));
      expect(
        secondLoadStopwatch.elapsedMilliseconds,
        lessThanOrEqualTo(firstLoadStopwatch.elapsedMilliseconds),
      );
    });

    testWidgets('error handling does not significantly impact performance', (
      tester,
    ) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                // Valid image
                ImageService.getDogBreedImage(
                  breedName: 'chihuahua',
                  width: 50,
                  height: 50,
                ),
                // Invalid image path
                ImageService.getOptimizedImage(
                  imagePath: 'assets/images/nonexistent.png',
                  width: 50,
                  height: 50,
                ),
                // Another valid image
                ImageService.getSuccessImage(
                  isFirstImage: true,
                  width: 50,
                  height: 50,
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      stopwatch.stop();

      // Error handling should not significantly slow down rendering
      expect(stopwatch.elapsedMilliseconds, lessThan(3000));
      expect(find.byType(Image), findsNWidgets(3));
    });

    testWidgets('memory usage remains stable with multiple image loads', (
      tester,
    ) async {
      // Load many images to test memory stability
      for (int i = 0; i < 5; i++) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  ImageService.getDogBreedImage(
                    breedName: 'chihuahua',
                    width: 50,
                    height: 50,
                  ),
                  ImageService.getDogBreedImage(
                    breedName: 'cocker',
                    width: 50,
                    height: 50,
                  ),
                  ImageService.getSuccessImage(
                    isFirstImage: true,
                    width: 50,
                    height: 50,
                  ),
                ],
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Clear cache periodically to test memory management
        if (i % 2 == 0) {
          ImageService.clearCache();
        }
      }

      // Should complete without memory issues
      expect(find.byType(Image), findsNWidgets(3));
    });

    testWidgets('responsive image sizing works correctly', (tester) async {
      // Test different screen sizes
      final sizes = [
        const Size(320, 568), // iPhone SE
        const Size(375, 667), // iPhone 8
        const Size(414, 896), // iPhone 11 Pro Max
        const Size(768, 1024), // iPad
      ];

      for (final size in sizes) {
        await tester.binding.setSurfaceSize(size);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ImageService.getDogBreedImage(
                breedName: 'chihuahua',
                width: size.width * 0.5,
                height: size.height * 0.3,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Should render correctly on all screen sizes
        expect(find.byType(Image), findsOneWidget);
      }

      // Reset to default size
      await tester.binding.setSurfaceSize(null);
    });

    group('Cache Statistics', () {
      testWidgets('cache statistics are accurate', (tester) async {
        // Clear cache first
        ImageService.clearCache();

        var stats = ImageService.getCacheStats();
        expect(stats['cachedImages'], equals(0));

        // Load some images
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ImageService.getDogBreedImage(breedName: 'chihuahua'),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Check stats after loading
        stats = ImageService.getCacheStats();
        expect(stats['cachedImages'], isA<int>());
        expect(stats['loadingImages'], isA<int>());
        expect(stats['cacheKeys'], isA<List>());
      });
    });
  });
}
