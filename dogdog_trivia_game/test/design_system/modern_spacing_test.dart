import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dogdog_trivia_game/design_system/modern_spacing.dart';

void main() {
  group('ModernSpacing', () {
    test('should have correct base spacing units', () {
      expect(ModernSpacing.xs, 4.0);
      expect(ModernSpacing.sm, 8.0);
      expect(ModernSpacing.md, 16.0);
      expect(ModernSpacing.lg, 24.0);
      expect(ModernSpacing.xl, 32.0);
      expect(ModernSpacing.xxl, 48.0);
      expect(ModernSpacing.xxxl, 64.0);
    });

    test('should have correct semantic spacing values', () {
      expect(ModernSpacing.tiny, ModernSpacing.xs);
      expect(ModernSpacing.small, ModernSpacing.sm);
      expect(ModernSpacing.medium, ModernSpacing.md);
      expect(ModernSpacing.large, ModernSpacing.lg);
      expect(ModernSpacing.huge, ModernSpacing.xl);
      expect(ModernSpacing.massive, ModernSpacing.xxl);
    });

    test('should have correct component-specific spacing', () {
      expect(ModernSpacing.cardPadding, ModernSpacing.lg);
      expect(ModernSpacing.cardMargin, ModernSpacing.md);
      expect(ModernSpacing.buttonPadding, ModernSpacing.md);
      expect(ModernSpacing.screenPadding, ModernSpacing.lg);
      expect(ModernSpacing.sectionSpacing, ModernSpacing.xl);
      expect(ModernSpacing.elementSpacing, ModernSpacing.md);
    });

    test('should have correct border radius values', () {
      expect(ModernSpacing.radiusSmall, 8.0);
      expect(ModernSpacing.radiusMedium, 12.0);
      expect(ModernSpacing.radiusLarge, 16.0);
      expect(ModernSpacing.radiusXLarge, 20.0);
      expect(ModernSpacing.radiusRound, 50.0);
    });

    test('should have correct EdgeInsets constants', () {
      expect(ModernSpacing.paddingXS, const EdgeInsets.all(4.0));
      expect(ModernSpacing.paddingSM, const EdgeInsets.all(8.0));
      expect(ModernSpacing.paddingMD, const EdgeInsets.all(16.0));
      expect(ModernSpacing.paddingLG, const EdgeInsets.all(24.0));
      expect(ModernSpacing.paddingXL, const EdgeInsets.all(32.0));
      expect(ModernSpacing.paddingXXL, const EdgeInsets.all(48.0));
    });

    test('should have correct horizontal padding', () {
      expect(
        ModernSpacing.paddingHorizontalXS,
        const EdgeInsets.symmetric(horizontal: 4.0),
      );
      expect(
        ModernSpacing.paddingHorizontalSM,
        const EdgeInsets.symmetric(horizontal: 8.0),
      );
      expect(
        ModernSpacing.paddingHorizontalMD,
        const EdgeInsets.symmetric(horizontal: 16.0),
      );
      expect(
        ModernSpacing.paddingHorizontalLG,
        const EdgeInsets.symmetric(horizontal: 24.0),
      );
      expect(
        ModernSpacing.paddingHorizontalXL,
        const EdgeInsets.symmetric(horizontal: 32.0),
      );
    });

    test('should have correct vertical padding', () {
      expect(
        ModernSpacing.paddingVerticalXS,
        const EdgeInsets.symmetric(vertical: 4.0),
      );
      expect(
        ModernSpacing.paddingVerticalSM,
        const EdgeInsets.symmetric(vertical: 8.0),
      );
      expect(
        ModernSpacing.paddingVerticalMD,
        const EdgeInsets.symmetric(vertical: 16.0),
      );
      expect(
        ModernSpacing.paddingVerticalLG,
        const EdgeInsets.symmetric(vertical: 24.0),
      );
      expect(
        ModernSpacing.paddingVerticalXL,
        const EdgeInsets.symmetric(vertical: 32.0),
      );
    });

    test('should have correct component-specific padding', () {
      expect(ModernSpacing.cardPaddingInsets, const EdgeInsets.all(24.0));
      expect(
        ModernSpacing.buttonPaddingInsets,
        const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      );
      expect(ModernSpacing.screenPaddingInsets, const EdgeInsets.all(24.0));
    });

    test('should have correct SizedBox spacing widgets', () {
      expect(ModernSpacing.spaceXS.height, 4.0);
      expect(ModernSpacing.spaceXS.width, 4.0);
      expect(ModernSpacing.spaceSM.height, 8.0);
      expect(ModernSpacing.spaceSM.width, 8.0);
      expect(ModernSpacing.spaceMD.height, 16.0);
      expect(ModernSpacing.spaceMD.width, 16.0);
      expect(ModernSpacing.spaceLG.height, 24.0);
      expect(ModernSpacing.spaceLG.width, 24.0);
      expect(ModernSpacing.spaceXL.height, 32.0);
      expect(ModernSpacing.spaceXL.width, 32.0);
      expect(ModernSpacing.spaceXXL.height, 48.0);
      expect(ModernSpacing.spaceXXL.width, 48.0);
    });

    test('should have correct horizontal spacing widgets', () {
      expect(ModernSpacing.horizontalSpaceXS.width, 4.0);
      expect(ModernSpacing.horizontalSpaceSM.width, 8.0);
      expect(ModernSpacing.horizontalSpaceMD.width, 16.0);
      expect(ModernSpacing.horizontalSpaceLG.width, 24.0);
      expect(ModernSpacing.horizontalSpaceXL.width, 32.0);
    });

    test('should have correct vertical spacing widgets', () {
      expect(ModernSpacing.verticalSpaceXS.height, 4.0);
      expect(ModernSpacing.verticalSpaceSM.height, 8.0);
      expect(ModernSpacing.verticalSpaceMD.height, 16.0);
      expect(ModernSpacing.verticalSpaceLG.height, 24.0);
      expect(ModernSpacing.verticalSpaceXL.height, 32.0);
    });

    test('should have correct BorderRadius definitions', () {
      expect(
        ModernSpacing.borderRadiusSmall,
        const BorderRadius.all(Radius.circular(8.0)),
      );
      expect(
        ModernSpacing.borderRadiusMedium,
        const BorderRadius.all(Radius.circular(12.0)),
      );
      expect(
        ModernSpacing.borderRadiusLarge,
        const BorderRadius.all(Radius.circular(16.0)),
      );
      expect(
        ModernSpacing.borderRadiusXLarge,
        const BorderRadius.all(Radius.circular(20.0)),
      );
      expect(
        ModernSpacing.borderRadiusRound,
        const BorderRadius.all(Radius.circular(50.0)),
      );
    });

    test('should create symmetric EdgeInsets correctly', () {
      final padding = ModernSpacing.symmetric(horizontal: 10.0, vertical: 20.0);
      expect(
        padding,
        const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
      );

      final paddingHorizontalOnly = ModernSpacing.symmetric(horizontal: 15.0);
      expect(
        paddingHorizontalOnly,
        const EdgeInsets.symmetric(horizontal: 15.0, vertical: 0),
      );

      final paddingVerticalOnly = ModernSpacing.symmetric(vertical: 25.0);
      expect(
        paddingVerticalOnly,
        const EdgeInsets.symmetric(horizontal: 0, vertical: 25.0),
      );
    });

    test('should create only EdgeInsets correctly', () {
      final padding = ModernSpacing.only(
        top: 10.0,
        bottom: 20.0,
        left: 30.0,
        right: 40.0,
      );
      expect(
        padding,
        const EdgeInsets.only(top: 10.0, bottom: 20.0, left: 30.0, right: 40.0),
      );

      final paddingPartial = ModernSpacing.only(top: 15.0, left: 25.0);
      expect(
        paddingPartial,
        const EdgeInsets.only(top: 15.0, bottom: 0, left: 25.0, right: 0),
      );
    });

    test('should create SizedBox with custom size', () {
      final space = ModernSpacing.space(20.0);
      expect(space.height, 20.0);
      expect(space.width, 20.0);
    });

    test('should create horizontal SizedBox with custom width', () {
      final space = ModernSpacing.horizontalSpace(15.0);
      expect(space.width, 15.0);
    });

    test('should create vertical SizedBox with custom height', () {
      final space = ModernSpacing.verticalSpace(25.0);
      expect(space.height, 25.0);
    });

    test('should create BorderRadius with custom radius', () {
      final borderRadius = ModernSpacing.borderRadius(18.0);
      expect(borderRadius, const BorderRadius.all(Radius.circular(18.0)));
    });

    test('should have correct asymmetric padding', () {
      expect(ModernSpacing.paddingTop, const EdgeInsets.only(top: 16.0));
      expect(ModernSpacing.paddingBottom, const EdgeInsets.only(bottom: 16.0));
      expect(ModernSpacing.paddingLeft, const EdgeInsets.only(left: 16.0));
      expect(ModernSpacing.paddingRight, const EdgeInsets.only(right: 16.0));
    });

    test('should have correct safe area padding', () {
      expect(
        ModernSpacing.safeAreaPadding,
        const EdgeInsets.only(top: 24.0, bottom: 24.0, left: 16.0, right: 16.0),
      );
    });
  });

  group('ModernSpacing Responsive', () {
    test('should have responsive helper methods', () {
      // Test that the responsive methods exist and can be called
      // Note: These methods require a BuildContext, so we test their existence
      expect(ModernSpacing.responsive, isA<Function>());
      expect(ModernSpacing.responsivePadding, isA<Function>());
    });
  });
}
