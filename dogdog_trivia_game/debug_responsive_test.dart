import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dogdog_trivia_game/utils/responsive.dart';

void main() {
  testWidgets('Debug responsive sizes', (WidgetTester tester) async {
    // Try different size settings and print what we actually get
    print('=== Testing size 300x600 ===');
    await tester.binding.setSurfaceSize(const Size(300, 600));
    tester.view.physicalSize = const Size(300, 600);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            final mediaQuery = MediaQuery.of(context);
            final screenType = ResponsiveUtils.getScreenType(context);
            print('Physical size: ${tester.view.physicalSize}');
            print('Device pixel ratio: ${tester.view.devicePixelRatio}');
            print('MediaQuery size: ${mediaQuery.size}');
            print('MediaQuery width: ${mediaQuery.size.width}');
            print('Screen type: $screenType');
            return Container();
          },
        ),
      ),
    );

    print('=== Testing size 700x1000 ===');
    await tester.binding.setSurfaceSize(const Size(700, 1000));
    tester.view.physicalSize = const Size(700, 1000);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            final mediaQuery = MediaQuery.of(context);
            final screenType = ResponsiveUtils.getScreenType(context);
            print('Physical size: ${tester.view.physicalSize}');
            print('Device pixel ratio: ${tester.view.devicePixelRatio}');
            print('MediaQuery size: ${mediaQuery.size}');
            print('MediaQuery width: ${mediaQuery.size.width}');
            print('Screen type: $screenType');
            return Container();
          },
        ),
      ),
    );
  });
}
