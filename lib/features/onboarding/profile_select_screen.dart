// ============================================================================
// NeuroScript AI: Privacy-Preserving Study Platform for Neurodivergent Learners
// File: lib/features/onboarding/profile_select_screen.dart
//
// Description:
//   Interactive learner profiling interface (WP2.4).
//   Presents three structured cards for ADHD, Dyslexia, and Autism profiles,
//   allowing learners to select their preferred learning experience and
//   instantly preview the corresponding visual theme.
//
// Key Concepts:
//   - Zero-Friction Profile Selection: Learners tap one clear card with a single-sentence
//     explanation; selection is immediately saved to the encrypted UserProfiles table.
//   - Non-Clinical Framing: Profiles are framed strictly as accessibility aids and
//     study modalities rather than clinical medical diagnoses.
//   - Immediate Palette Demonstration: Tapping a profile immediately updates the
//     local state and reflects the color palette and typography choices.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_palettes.dart';
import '../../core/widgets/app_button.dart';
import '../providers.dart';

class ProfileSelectScreen extends ConsumerStatefulWidget {
  const ProfileSelectScreen({super.key});

  @override
  ConsumerState<ProfileSelectScreen> createState() =>
      _ProfileSelectScreenState();
}

class _ProfileSelectScreenState extends ConsumerState<ProfileSelectScreen> {
  ProfileType _selected = ProfileType.dyslexia;
  bool _isLoading = false;

  Future<void> _handleContinue() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(profileRepositoryProvider);
      await repo.saveProfile(_selected);
      ref.invalidate(activeProfileProvider);

      if (mounted) {
        context.go('/library');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Choose Your Learning Profile')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Personalize Your Experience',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select the profile that best fits your focus and reading style. You can change this anytime in Settings.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.75),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: RadioGroup<ProfileType>(
                  groupValue: _selected,
                  onChanged: (val) {
                    if (val != null) setState(() => _selected = val);
                  },
                  child: ListView(
                    children: ProfileType.values.map((p) {
                      final isSelected = p == _selected;
                      return Semantics(
                        selected: isSelected,
                        child: Card(
                          elevation: isSelected ? 3 : 1,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: isSelected
                                  ? colorScheme.primary
                                  : colorScheme.outline.withValues(alpha: 0.5),
                              width: isSelected ? 2.2 : 1.0,
                            ),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => setState(() => _selected = p),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Radio<ProfileType>(
                                    value: p,
                                    activeColor: colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          p.displayName,
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          p.description,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                color: colorScheme.onSurface
                                                    .withValues(alpha: 0.85),
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              AppButton(
                label: 'Save & Continue',
                icon: Icons.check,
                isLoading: _isLoading,
                onPressed: _handleContinue,
              ),
            ],
          ),
        ),
      ),
    ),
  ),
    );
  }
}
