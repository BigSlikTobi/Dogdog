import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'lib/utils/responsive.dart';

void main() {
  testWidgets('Debug padding values', (WidgetTester tester) async {
    // Test tablet (800x1200)
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;

    late ScreenType screenType;
    late EdgeInsets padding;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            screenType = ResponsiveUtils.getScreenType(context);
            padding = ResponsiveUtils.getResponsivePadding(context);
            print('Size: ${MediaQuery.of(context).size}');
            print('Screen type: $screenType');
            print('Padding: $padding');
            return const SizedBox();
          },
        ),
      ),
    );

    await tester.pump();
  });
}
