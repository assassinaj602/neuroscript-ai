// ============================================================================
// NeuroScript AI: Automated Unit Tests
// File: test/theme_wcag_test.dart
//
// Description:
//   Unit test suite verifying WCAG 2.1 AA mathematical color contrast ratios
//   (>= 4.5:1 for body text, >= 3.0:1 for large text & UI elements) across all
//   three neurodivergent learner profiles (ADHD, Dyslexia, Autism).
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neuro_script/core/theme/app_palettes.dart';
import 'package:neuro_script/core/theme/app_theme.dart';

/// Computes the WCAG 2.1 contrast ratio between two colors.
/// Uses the W3C Relative Luminance formula: (L1 + 0.05) / (L2 + 0.05).
double computeWcagContrast(Color foreground, Color background) {
  final l1 = foreground.computeLuminance();
  final l2 = background.computeLuminance();
  final lighter = l1 > l2 ? l1 : l2;
  final darker = l1 > l2 ? l2 : l1;
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  group('WCAG 2.1 AA Contrast Ratio Verification', () {
    test('ADHD profile colors satisfy WCAG 2.1 AA standards', () {
      final textOnBg = computeWcagContrast(
        AppPalettes.adhdText,
        AppPalettes.adhdBackground,
      );
      final textOnSurface = computeWcagContrast(
        AppPalettes.adhdText,
        AppPalettes.adhdSurface,
      );
      final primaryOnBg = computeWcagContrast(
        AppPalettes.adhdPrimary,
        AppPalettes.adhdBackground,
      );
      final whiteOnPrimary = computeWcagContrast(
        Colors.white,
        AppPalettes.adhdPrimary,
      );
      final secondaryOnBg = computeWcagContrast(
        AppPalettes.adhdSecondary,
        AppPalettes.adhdBackground,
      );
      final whiteOnSecondary = computeWcagContrast(
        Colors.white,
        AppPalettes.adhdSecondary,
      );

      // Body text >= 4.5:1
      expect(
        textOnBg,
        greaterThanOrEqualTo(4.5),
        reason: 'ADHD text on background contrast ratio: $textOnBg',
      );
      expect(
        textOnSurface,
        greaterThanOrEqualTo(4.5),
        reason: 'ADHD text on surface contrast ratio: $textOnSurface',
      );
      expect(
        whiteOnPrimary,
        greaterThanOrEqualTo(4.5),
        reason: 'White text on ADHD primary contrast ratio: $whiteOnPrimary',
      );

      // Large text & UI components >= 3.0:1
      expect(
        primaryOnBg,
        greaterThanOrEqualTo(3.0),
        reason: 'ADHD primary on background contrast ratio: $primaryOnBg',
      );
      expect(
        secondaryOnBg,
        greaterThanOrEqualTo(3.0),
        reason: 'ADHD secondary on background contrast ratio: $secondaryOnBg',
      );
      expect(
        whiteOnSecondary,
        greaterThanOrEqualTo(3.0),
        reason: 'White on ADHD secondary contrast ratio: $whiteOnSecondary',
      );
    });

    test('Dyslexia profile colors satisfy WCAG 2.1 AA standards', () {
      final textOnBg = computeWcagContrast(
        AppPalettes.dyslexiaText,
        AppPalettes.dyslexiaBackground,
      );
      final textOnSurface = computeWcagContrast(
        AppPalettes.dyslexiaText,
        AppPalettes.dyslexiaSurface,
      );
      final primaryOnBg = computeWcagContrast(
        AppPalettes.dyslexiaPrimary,
        AppPalettes.dyslexiaBackground,
      );
      final whiteOnPrimary = computeWcagContrast(
        Colors.white,
        AppPalettes.dyslexiaPrimary,
      );
      final secondaryOnBg = computeWcagContrast(
        AppPalettes.dyslexiaSecondary,
        AppPalettes.dyslexiaBackground,
      );
      final whiteOnSecondary = computeWcagContrast(
        Colors.white,
        AppPalettes.dyslexiaSecondary,
      );

      // Body text >= 4.5:1
      expect(
        textOnBg,
        greaterThanOrEqualTo(4.5),
        reason: 'Dyslexia text on background contrast ratio: $textOnBg',
      );
      expect(
        textOnSurface,
        greaterThanOrEqualTo(4.5),
        reason: 'Dyslexia text on surface contrast ratio: $textOnSurface',
      );
      expect(
        whiteOnPrimary,
        greaterThanOrEqualTo(4.5),
        reason:
            'White text on Dyslexia primary contrast ratio: $whiteOnPrimary',
      );

      // Large text & UI components >= 3.0:1
      expect(
        primaryOnBg,
        greaterThanOrEqualTo(3.0),
        reason: 'Dyslexia primary on background contrast ratio: $primaryOnBg',
      );
      expect(
        secondaryOnBg,
        greaterThanOrEqualTo(3.0),
        reason:
            'Dyslexia secondary on background contrast ratio: $secondaryOnBg',
      );
      expect(
        whiteOnSecondary,
        greaterThanOrEqualTo(3.0),
        reason: 'White on Dyslexia secondary contrast ratio: $whiteOnSecondary',
      );
    });

    test('Autism profile colors satisfy WCAG 2.1 AA standards', () {
      final textOnBg = computeWcagContrast(
        AppPalettes.autismText,
        AppPalettes.autismBackground,
      );
      final textOnSurface = computeWcagContrast(
        AppPalettes.autismText,
        AppPalettes.autismSurface,
      );
      final primaryOnBg = computeWcagContrast(
        AppPalettes.autismPrimary,
        AppPalettes.autismBackground,
      );
      final whiteOnPrimary = computeWcagContrast(
        Colors.white,
        AppPalettes.autismPrimary,
      );
      final secondaryOnBg = computeWcagContrast(
        AppPalettes.autismSecondary,
        AppPalettes.autismBackground,
      );
      final whiteOnSecondary = computeWcagContrast(
        Colors.white,
        AppPalettes.autismSecondary,
      );

      // Body text >= 4.5:1
      expect(
        textOnBg,
        greaterThanOrEqualTo(4.5),
        reason: 'Autism text on background contrast ratio: $textOnBg',
      );
      expect(
        textOnSurface,
        greaterThanOrEqualTo(4.5),
        reason: 'Autism text on surface contrast ratio: $textOnSurface',
      );
      expect(
        whiteOnPrimary,
        greaterThanOrEqualTo(4.5),
        reason: 'White text on Autism primary contrast ratio: $whiteOnPrimary',
      );

      // Large text & UI components >= 3.0:1
      expect(
        primaryOnBg,
        greaterThanOrEqualTo(3.0),
        reason: 'Autism primary on background contrast ratio: $primaryOnBg',
      );
      expect(
        secondaryOnBg,
        greaterThanOrEqualTo(3.0),
        reason: 'Autism secondary on background contrast ratio: $secondaryOnBg',
      );
      expect(
        whiteOnSecondary,
        greaterThanOrEqualTo(3.0),
        reason: 'White on Autism secondary contrast ratio: $whiteOnSecondary',
      );
    });

    test('AppTheme generates complete Material 3 themes for all profiles', () {
      for (final profile in ProfileType.values) {
        final theme = AppTheme.getTheme(profile);
        expect(theme.useMaterial3, isTrue);
        expect(theme.colorScheme.primary, isNotNull);
        expect(theme.colorScheme.onPrimary, isNotNull);
        expect(theme.scaffoldBackgroundColor, isNotNull);
      }
    });
  });
}
