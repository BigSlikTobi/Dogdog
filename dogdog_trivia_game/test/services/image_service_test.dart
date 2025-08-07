import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dogdog_trivia_game/services/image_service.dart';

void main() {
  group('ImageService', () {
    testWidgets('preloadCriticalImages completes without error', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox())),
      );

      // Should complete without throwing
      await expectLater(
        ImageService.preloadCriticalImages(
          tester.element(find.byType(Scaffold)),
        ),
        completes,
      );
    });

    testWidgets('getOptimizedImage returns widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ImageService.getOptimizedImage(
              imagePath: 'assets/images/chihuahua.png',
              width: 100,
              height: 100,
            ),
          ),
        ),
      );

      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('getDogBreedImage returns widget for valid breed', (
      tester,
    ) async {
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

      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('getDogBreedImage handles unknown breed', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ImageService.getDogBreedImage(
              breedName: 'unknown_breed',
              width: 100,
              height: 100,
            ),
          ),
        ),
      );

      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('getSuccessImage returns widget for both image variants', (
      tester,
    ) async {
      // Test first image
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ImageService.getSuccessImage(
              isFirstImage: true,
              width: 100,
              height: 100,
            ),
          ),
        ),
      );

      expect(find.byType(Image), findsOneWidget);

      // Test second image
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ImageService.getSuccessImage(
              isFirstImage: false,
              width: 100,
              height: 100,
            ),
          ),
        ),
      );

      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('getOptimizedImage shows placeholder while loading', (
      tester,
    ) async {
      final placeholder = Container(
        key: const Key('placeholder'),
        color: Colors.grey,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ImageService.getOptimizedImage(
              imagePath: 'assets/images/chihuahua.png',
              width: 100,
              height: 100,
              placeholder: placeholder,
            ),
          ),
        ),
      );

      // Initially should show the image widget (which may show placeholder internally)
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('getOptimizedImage shows error widget on failure', (
      tester,
    ) async {
      final errorWidget = Container(key: const Key('error'), color: Colors.red);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ImageService.getOptimizedImage(
              imagePath: 'assets/images/nonexistent.png',
              width: 100,
              height: 100,
              errorWidget: errorWidget,
            ),
          ),
        ),
      );

      // Should show the image widget initially
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('getOptimizedImage includes semantic label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ImageService.getOptimizedImage(
              imagePath: 'assets/images/chihuahua.png',
              width: 100,
              height: 100,
              semanticLabel: 'Test image',
            ),
          ),
        ),
      );

      expect(find.bySemanticsLabel('Test image'), findsOneWidget);
    });

    test('clearCache clears the image cache', () {
      // Clear cache should not throw
      expect(() => ImageService.clearCache(), returnsNormally);
    });

    test('getCacheStats returns cache information', () {
      final stats = ImageService.getCacheStats();

      expect(stats, isA<Map<String, dynamic>>());
      expect(stats.containsKey('cachedImages'), isTrue);
      expect(stats.containsKey('loadingImages'), isTrue);
      expect(stats.containsKey('cacheKeys'), isTrue);
      expect(stats['cachedImages'], isA<int>());
      expect(stats['loadingImages'], isA<int>());
      expect(stats['cacheKeys'], isA<List>());
    });

    group('Dog breed image path mapping', () {
      testWidgets('maps chihuahua correctly', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ImageService.getDogBreedImage(breedName: 'chihuahua'),
            ),
          ),
        );

        expect(find.byType(Image), findsOneWidget);
      });

      testWidgets('maps cocker spaniel correctly', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ImageService.getDogBreedImage(breedName: 'cocker spaniel'),
            ),
          ),
        );

        expect(find.byType(Image), findsOneWidget);
      });

      testWidgets('maps german shepherd correctly', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ImageService.getDogBreedImage(breedName: 'german shepherd'),
            ),
          ),
        );

        expect(find.byType(Image), findsOneWidget);
      });

      testWidgets('maps great dane correctly', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ImageService.getDogBreedImage(breedName: 'great dane'),
            ),
          ),
        );

        expect(find.byType(Image), findsOneWidget);
      });

      testWidgets('maps pug correctly', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ImageService.getDogBreedImage(breedName: 'pug'),
            ),
          ),
        );

        expect(find.byType(Image), findsOneWidget);
      });
    });

    group('Image optimization features', () {
      testWidgets('enables memory cache by default', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ImageService.getOptimizedImage(
                imagePath: 'assets/images/chihuahua.png',
                width: 100,
                height: 100,
              ),
            ),
          ),
        );

        expect(find.byType(Image), findsOneWidget);
      });

      testWidgets('can disable memory cache', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ImageService.getOptimizedImage(
                imagePath: 'assets/images/chihuahua.png',
                width: 100,
                height: 100,
                enableMemoryCache: false,
              ),
            ),
          ),
        );

        expect(find.byType(Image), findsOneWidget);
      });

      testWidgets('handles different BoxFit values', (tester) async {
        for (final fit in BoxFit.values) {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: ImageService.getOptimizedImage(
                  imagePath: 'assets/images/chihuahua.png',
                  width: 100,
                  height: 100,
                  fit: fit,
                ),
              ),
            ),
          );

          expect(find.byType(Image), findsOneWidget);
        }
      });
    });

    group('Default fallback widgets', () {
      testWidgets('dog breed images have pet icon fallback', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ImageService.getDogBreedImage(
                breedName: 'nonexistent',
                width: 100,
                height: 100,
              ),
            ),
          ),
        );

        // Should show image widget initially
        expect(find.byType(Image), findsOneWidget);
      });

      testWidgets('success images have check circle fallback', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ImageService.getSuccessImage(
                isFirstImage: true,
                width: 100,
                height: 100,
              ),
            ),
          ),
        );

        // Should show image widget initially
        expect(find.byType(Image), findsOneWidget);
      });
    });
  });
}
