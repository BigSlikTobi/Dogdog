import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dogdog_trivia_game/utils/responsive.dart';

void main() {
  group('ResponsiveUtils', () {
    testWidgets('should detect mobile screen type correctly', (tester) async {
      await tester.binding.setSurfaceSize(const Size(500, 800));

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.getScreenType(context), ScreenType.mobile);
              expect(ResponsiveUtils.isMobile(context), true);
              expect(ResponsiveUtils.isTablet(context), false);
              expect(ResponsiveUtils.isDesktop(context), false);
              return Container();
            },
          ),
        ),
      );
    });

    testWidgets('should detect tablet screen type correctly', (tester) async {
      await tester.binding.setSurfaceSize(const Size(700, 1000));

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.getScreenType(context), ScreenType.tablet);
              expect(ResponsiveUtils.isMobile(context), false);
              expect(ResponsiveUtils.isTablet(context), true);
              expect(ResponsiveUtils.isDesktop(context), false);
              return Container();
            },
          ),
        ),
      );
    });

    testWidgets('should detect desktop screen type correctly', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1300, 800));

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(
                ResponsiveUtils.getScreenType(context),
                ScreenType.desktop,
              );
              expect(ResponsiveUtils.isMobile(context), false);
              expect(ResponsiveUtils.isTablet(context), false);
              expect(ResponsiveUtils.isDesktop(context), true);
              return Container();
            },
          ),
        ),
      );
    });

    testWidgets('should provide correct responsive padding', (tester) async {
      await tester.binding.setSurfaceSize(const Size(500, 800)); // Mobile

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final padding = ResponsiveUtils.getResponsivePadding(context);
              expect(padding, const EdgeInsets.all(16.0));
              return Container();
            },
          ),
        ),
      );

      await tester.binding.setSurfaceSize(const Size(700, 1000)); // Tablet
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final padding = ResponsiveUtils.getResponsivePadding(context);
              expect(padding, const EdgeInsets.all(24.0));
              return Container();
            },
          ),
        ),
      );
    });

    testWidgets('should respect text scaling preferences', (tester) async {
      await tester.binding.setSurfaceSize(const Size(500, 800));

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
            child: Builder(
              builder: (context) {
                final multiplier = ResponsiveUtils.getFontSizeMultiplier(
                  context,
                );
                expect(multiplier, greaterThan(1.0));
                expect(multiplier, lessThanOrEqualTo(2.0));
                return Container();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('should provide correct answer grid columns', (tester) async {
      await tester.binding.setSurfaceSize(
        const Size(500, 800),
      ); // Mobile portrait

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final columns = ResponsiveUtils.getAnswerGridColumns(context);
              expect(columns, 2); // 2x2 grid for mobile
              return Container();
            },
          ),
        ),
      );

      await tester.binding.setSurfaceSize(
        const Size(800, 500),
      ); // Tablet landscape
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final columns = ResponsiveUtils.getAnswerGridColumns(context);
              expect(columns, 4); // Single row for landscape on larger screens
              return Container();
            },
          ),
        ),
      );
    });

    testWidgets('should detect landscape orientation correctly', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(800, 500)); // Landscape

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.isLandscape(context), true);
              return Container();
            },
          ),
        ),
      );

      await tester.binding.setSurfaceSize(const Size(500, 800)); // Portrait
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.isLandscape(context), false);
              return Container();
            },
          ),
        ),
      );
    });

    testWidgets('ResponsiveContainer should constrain content width', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1300, 800)); // Desktop

      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveContainer(
            child: Container(
              key: const Key('content'),
              width: double.infinity,
              height: 100,
              color: Colors.blue,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.byKey(const Key('content')).first,
      );
      expect(container.constraints?.maxWidth, 800); // Desktop max width
    });

    testWidgets('ResponsiveBuilder should provide correct screen type', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(700, 1000)); // Tablet

      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveBuilder(
            builder: (context, screenType) {
              expect(screenType, ScreenType.tablet);
              return Container();
            },
          ),
        ),
      );
    });
  });
}
