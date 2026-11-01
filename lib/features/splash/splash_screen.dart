// ============================================================================
// NeuroScript AI: Privacy-Preserving Study Platform for Neurodivergent Learners
// File: lib/features/splash/splash_screen.dart
//
// Description:
//   Application initialization splash screen.
//   Orchestrates cold-start bootstrapping: loads bundled curriculum seeds in the
//   background, verifies learner profile setup, and smoothly transitions to
//   either Onboarding (for new users) or the Study Library (for returning users).
//
// Key Concepts:
//   - Non-Blocking Bootstrap: Seeds the encrypted database asynchronously without
//     freezing the Flutter UI thread.
//   - Guaranteed Minimum Duration: Prevents jarring visual flickers on ultra-fast
//     devices by enforcing a minimum display duration before navigating.
//   - Neuroinclusive Branding: Uses soft, low-stimulation brand iconography and
//     a polite loading status message for reduced anxiety.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers.dart';

/// Startup splash screen displaying branding while asynchronously initializing
/// bundled seed datasets and determining learner onboarding status.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({
    super.key,
    this.minimumDuration = const Duration(milliseconds: 1000),
    this.onComplete,
  });

  final Duration minimumDuration;
  final void Function(dynamic profile)? onComplete;

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrapApp();
  }

  Future<void> _bootstrapApp() async {
    final stopwatch = Stopwatch()..start();

    // 1. Asynchronously seed bundled curriculum without blocking main UI thread
    try {
      await ref
          .read(seedImporterProvider)
          .importSeedLessons()
          .timeout(const Duration(seconds: 3));
    } on Exception catch (e, st) {
      debugPrint(
        'Seed initialization skipped or encountered non-fatal error: $e\n$st',
      );
    }

    // 2. Read user profile status from secure storage / local database
    dynamic profile;
    try {
      profile = await ref
          .read(activeProfileProvider.future)
          .timeout(const Duration(seconds: 3));
    } on Exception catch (e, st) {
      debugPrint('Profile read error or timeout: $e\n$st');
    }

    // 3. Guarantee minimum splash duration unless reduced motion is requested
    final disableAnimations = mounted
        ? MediaQuery.disableAnimationsOf(context)
        : false;
    final remainingMs = disableAnimations
        ? 0
        : widget.minimumDuration.inMilliseconds - stopwatch.elapsedMilliseconds;
    if (remainingMs > 0) {
      await Future.delayed(Duration(milliseconds: remainingMs));
    }

    if (!mounted) return;

    if (widget.onComplete != null) {
      widget.onComplete!(profile);
      return;
    }

    // 4. Navigate to appropriate destination
    if (profile == null) {
      context.go('/onboarding');
    } else {
      context.go('/library');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // App Brand Icon
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.25),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.psychology_rounded,
                    size: 54,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  'NeuroScript AI',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Subtitle
                Text(
                  'Privacy-Preserving Study Platform\nfor Neurodivergent Learners',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withValues(
                      alpha: 0.75,
                    ),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),

                const Spacer(flex: 2),

                // Subtle accessible loading indicator
                SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  'Initializing secure offline workspace...',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withValues(
                      alpha: 0.6,
                    ),
                  ),
                ),

                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
