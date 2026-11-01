// ============================================================================
// NeuroScript AI: Automated Unit Tests
// File: test/router_guard_test.dart
//
// Description:
//   Unit test suite verifying declarative GoRouter navigation guards and redirection
//   rules:
//   1. Unauthenticated / first-launch users with no profile are guarded and forced
//      to `/onboarding`.
//   2. Existing learners with configured profiles attempting to visit onboarding
//      are redirected to `/library`.
//   3. Splash and cold-start loading states do not trigger premature redirects.
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:neuro_script/core/routing/app_router.dart';
import 'package:neuro_script/core/theme/app_palettes.dart';

void main() {
  group('GoRouter Onboarding Guard Evaluation Unit Tests', () {
    test('Cold start loading: Does not redirect while profile is loading', () {
      final redirect = evaluateAppRouteGuard(
        isLoading: true,
        profile: null,
        matchedLocation: '/splash',
      );
      expect(redirect, isNull);

      final redirectLib = evaluateAppRouteGuard(
        isLoading: true,
        profile: null,
        matchedLocation: '/library',
      );
      expect(redirectLib, isNull);
    });

    test('Splash screen: Never redirects away while on /splash', () {
      final redirectNoProfile = evaluateAppRouteGuard(
        isLoading: false,
        profile: null,
        matchedLocation: '/splash',
      );
      expect(redirectNoProfile, isNull);

      final redirectWithProfile = evaluateAppRouteGuard(
        isLoading: false,
        profile: ProfileType.dyslexia,
        matchedLocation: '/splash',
      );
      expect(redirectWithProfile, isNull);
    });

    test('Guard 1: First-time learner (no profile) accessing /library is redirected to /onboarding', () {
      final redirect = evaluateAppRouteGuard(
        isLoading: false,
        profile: null,
        matchedLocation: '/library',
      );
      expect(redirect, equals('/onboarding'));
    });

    test('Guard 1: First-time learner (no profile) accessing /settings is redirected to /onboarding', () {
      final redirect = evaluateAppRouteGuard(
        isLoading: false,
        profile: null,
        matchedLocation: '/settings',
      );
      expect(redirect, equals('/onboarding'));
    });

    test('Guard 1: First-time learner (no profile) accessing /progress is redirected to /onboarding', () {
      final redirect = evaluateAppRouteGuard(
        isLoading: false,
        profile: null,
        matchedLocation: '/progress',
      );
      expect(redirect, equals('/onboarding'));
    });

    test('Guard 1: First-time learner (no profile) accessing /lesson/:id is redirected to /onboarding', () {
      final redirect = evaluateAppRouteGuard(
        isLoading: false,
        profile: null,
        matchedLocation: '/lesson/lesson_001',
      );
      expect(redirect, equals('/onboarding'));
    });

    test('Guard 1: First-time learner (no profile) accessing /onboarding is allowed (no redirect)', () {
      final redirect = evaluateAppRouteGuard(
        isLoading: false,
        profile: null,
        matchedLocation: '/onboarding',
      );
      expect(redirect, isNull);
    });

    test('Guard 1: First-time learner (no profile) accessing /profile_select is allowed (no redirect)', () {
      final redirect = evaluateAppRouteGuard(
        isLoading: false,
        profile: null,
        matchedLocation: '/profile_select',
      );
      expect(redirect, isNull);
    });

    test('Guard 2: Configured learner (with profile) accessing /onboarding is redirected to /library', () {
      for (final profile in [
        ProfileType.adhd,
        ProfileType.dyslexia,
        ProfileType.autism,
      ]) {
        final redirect = evaluateAppRouteGuard(
          isLoading: false,
          profile: profile,
          matchedLocation: '/onboarding',
        );
        expect(redirect, equals('/library'));
      }
    });

    test('Guard 2: Configured learner (with profile) accessing /profile_select is redirected to /library', () {
      for (final profile in [
        ProfileType.adhd,
        ProfileType.dyslexia,
        ProfileType.autism,
      ]) {
        final redirect = evaluateAppRouteGuard(
          isLoading: false,
          profile: profile,
          matchedLocation: '/profile_select',
        );
        expect(redirect, equals('/library'));
      }
    });

    test('Guard 2: Configured learner (with profile) accessing /library is allowed (no redirect)', () {
      final redirect = evaluateAppRouteGuard(
        isLoading: false,
        profile: ProfileType.dyslexia,
        matchedLocation: '/library',
      );
      expect(redirect, isNull);
    });

    test('Guard 2: Configured learner (with profile) accessing /settings is allowed (no redirect)', () {
      final redirect = evaluateAppRouteGuard(
        isLoading: false,
        profile: ProfileType.autism,
        matchedLocation: '/settings',
      );
      expect(redirect, isNull);
    });

    test('Guard 2: Configured learner (with profile) accessing /progress is allowed (no redirect)', () {
      final redirect = evaluateAppRouteGuard(
        isLoading: false,
        profile: ProfileType.adhd,
        matchedLocation: '/progress',
      );
      expect(redirect, isNull);
    });
  });
}
