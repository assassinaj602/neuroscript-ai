// ============================================================================
// NeuroScript AI: Privacy-Preserving Study Platform for Neurodivergent Learners
// File: app/lib/features/onboarding/onboarding_screen.dart
//
// Description:
//   First-run introduction screen welcoming learners and establishing trust.
//   Explains core platform pillars: neuroinclusive adaptations, local database
//   encryption at rest, and line-level grounded flashcards.
//
// Key Concepts:
//   - Responsive Viewport Constraints: Uses SingleChildScrollView with IntrinsicHeight
//     and ConstrainedBox to guarantee zero rendering overflows across diverse phone
//     sizes and 2.0x font scaling factors (WP2.5 / WP2.6).
//   - Clear Value Proposition: Sets expectations about privacy, offline support,
//     and profile personalization prior to learner profiling.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/app_button.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 48,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16),
                      Center(
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.psychology,
                            size: 48,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'NeuroScript AI',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Privacy-first study app designed for neurodivergent learners.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 28),
                      _featureRow(
                        icon: Icons.verified_user_outlined,
                        title: 'Grounded Active Recall',
                        desc: 'Every flashcard cites exact line numbers back to your original notes.',
                        colorScheme: colorScheme,
                        theme: theme,
                      ),
                      const SizedBox(height: 16),
                      _featureRow(
                        icon: Icons.account_tree_outlined,
                        title: 'Interactive Concept Maps',
                        desc: 'Explore structural visual relationships between terms with pinch-to-zoom.',
                        colorScheme: colorScheme,
                        theme: theme,
                      ),
                      const SizedBox(height: 16),
                      _featureRow(
                        icon: Icons.lock_outline,
                        title: 'Encrypted & Offline First',
                        desc: 'Your study material never leaves your device unencrypted.',
                        colorScheme: colorScheme,
                        theme: theme,
                      ),
                      const Spacer(),
                      const SizedBox(height: 24),
                      AppButton(
                        label: 'Get Started',
                        icon: Icons.arrow_forward,
                        onPressed: () => context.go('/profile_select'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _featureRow({
    required IconData icon,
    required String title,
    required String desc,
    required ColorScheme colorScheme,
    required ThemeData theme,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 22, color: colorScheme.primary),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(desc, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}
