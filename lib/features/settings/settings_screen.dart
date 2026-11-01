// ============================================================================
// NeuroScript AI: Privacy-Preserving Study Platform for Neurodivergent Learners
// File: lib/features/settings/settings_screen.dart
//
// Description:
//   Learner accessibility preferences, privacy governance, and app settings.
//   Enables profile switching, typography scaling (1.0x - 2.0x) with live preview,
//   sensory reduced-motion toggle, high-contrast toggle, academic project metadata,
//   and atomic zero-retention database wipe.
// ============================================================================

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_palettes.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/card_tile.dart';
import '../../core/widgets/section_header.dart';
import '../providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  void _showPrivacyDetailsDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.shield_outlined, color: Colors.green),
            SizedBox(width: 10),
            Text('Privacy & Cryptography'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Zero Cloud Retention Policy',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 6),
              Text(
                'Your handwritten lecture notes and study telemetry remain strictly on your local device. No raw notes are transmitted to unencrypted cloud databases.',
                style: TextStyle(fontSize: 13),
              ),
              SizedBox(height: 12),
              Text(
                kIsWeb
                    ? 'Web Storage (Demo Only)'
                    : 'AES-256 SQLCipher at Rest',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 6),
              Text(
                kIsWeb
                    ? 'On web platforms, data is stored locally in IndexedDB using WebAssembly. Note: Web storage is not encrypted (demo only). Use native Android, iOS, or Desktop builds for hardware-secured AES-256 encryption at rest.'
                    : 'Every database page is encrypted using AES-256 in CBC mode with PBKDF2 key derivation. The 256-bit cryptographic key is stored inside hardware keystores (Android Keystore / iOS Keychain) and is never hardcoded or printed to logs.',
                style: TextStyle(fontSize: 13),
              ),
              SizedBox(height: 12),
              Text(
                'Deterministic Document Hashing',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 6),
              Text(
                'Each note transcript is hashed with SHA-256 after normalization to enforce on-device deduplication without cloud roundtrips.',
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline),
            SizedBox(width: 10),
            Text('About NeuroScript AI'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'NeuroScript AI v1.0.0 (Milestones 1 & 2)',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 6),
              Text(
                'Privacy-preserving study platform designed for neurodivergent learners (ADHD, Dyslexia, and Autism Spectrum Conditions).',
                style: TextStyle(fontSize: 13),
              ),
              SizedBox(height: 12),
              Text(
                'Academic Project Details',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 4),
              Text(
                '• Department of Computer Science, UET Taxila\n• CS-400 Final Year Project (2026–2027)\n• Supervisor: Mr. Awais Mehmood\n• Authors: Zain Tahir (23-CS-115) & Ujala Sahar (23-CS-135)',
                style: TextStyle(fontSize: 13, height: 1.4),
              ),
              SizedBox(height: 12),
              Text(
                'Milestone Status',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 4),
              Text(
                '• Milestone 1: Planning, Requirements, & Architecture (Complete)\n• Milestone 2: Offline Study App & Encrypted Database (Complete)\n• Milestone 3: OCR Capture & Preprocessing (Scheduled)',
                style: TextStyle(fontSize: 13, height: 1.4),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete All Local Data?'),
        content: const Text(
          'This will permanently wipe your encrypted database, all custom lessons, and spaced repetition history.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Delete All',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final db = ref.read(appDatabaseProvider);
      await db.clearAllData();
      ref.invalidate(activeProfileProvider);
      ref.invalidate(allLessonsProvider);
      ref.invalidate(schedulerMetricsProvider);

      if (mounted) {
        context.go('/onboarding');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentProfile =
        ref.watch(activeProfileProvider).value ?? ProfileType.dyslexia;
    final a11y = ref.watch(accessibilityPreferencesProvider);
    final a11yNotifier = ref.read(accessibilityPreferencesProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 880),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Active Profile Selection
                const SectionHeader(title: 'Learner Accessibility Profile'),
                Card(
                  child: RadioGroup<ProfileType>(
                    groupValue: currentProfile,
                    onChanged: (newProfile) async {
                      if (newProfile != null) {
                        await ref
                            .read(profileRepositoryProvider)
                            .saveProfile(newProfile);
                        ref.invalidate(activeProfileProvider);
                      }
                    },
                    child: Column(
                      children: ProfileType.values.map((p) {
                        return RadioListTile<ProfileType>(
                          value: p,
                          title: Text(
                            p.displayName,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            p.description,
                            style: theme.textTheme.bodySmall,
                          ),
                          activeColor: colorScheme.primary,
                        );
                      }).toList(),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Accessibility Fine-Tuning
                const SectionHeader(title: 'Accessibility Fine-Tuning'),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Typography Scaling',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '${(a11y.textScale * 100).toInt()}%',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Slider(
                          value: a11y.textScale,
                          min: 1.0,
                          max: 2.0,
                          divisions: 10,
                          label: '${(a11y.textScale * 100).toInt()}%',
                          onChanged: (val) {
                            a11yNotifier.setTextScale(val);
                          },
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Sample text at ${(a11y.textScale * 100).toInt()}% scale.',
                            style: TextStyle(
                              fontSize: 14 * a11y.textScale,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Divider(height: 24),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text(
                            'Reduced Motion',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: const Text(
                            'Disables 3D card flips and bouncy animation transitions.',
                            style: TextStyle(fontSize: 12),
                          ),
                          value: a11y.reducedMotion,
                          onChanged: (val) {
                            a11yNotifier.setReducedMotion(val);
                          },
                        ),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text(
                            'High Contrast Outlines',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: const Text(
                            'Increases contrast borders around all cards and buttons.',
                            style: TextStyle(fontSize: 12),
                          ),
                          value: a11y.highContrast,
                          onChanged: (val) {
                            a11yNotifier.setHighContrast(val);
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Privacy & Database Encryption Info
                const SectionHeader(title: 'Security & Privacy'),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: kIsWeb
                                ? Colors.amber.withValues(alpha: 0.12)
                                : Colors.green.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            kIsWeb ? Icons.cloud_queue : Icons.lock_outline,
                            color: kIsWeb
                                ? Colors.amber.shade800
                                : Colors.green,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                kIsWeb
                                    ? 'Not encrypted (demo only)'
                                    : 'Encrypted Local Database',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                kIsWeb
                                    ? 'Web storage uses IndexedDB WASM. Not encrypted (demo only).'
                                    : 'AES-256 bit hardware-keyed encryption at rest. Zero unencrypted cloud data transmission.',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: _showPrivacyDetailsDialog,
                          child: const Text('Details'),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Project & About
                const SectionHeader(title: 'Application Information'),
                CardTile(
                  title: 'About NeuroScript AI',
                  subtitle: 'Academic project details, team credits, and architecture documentation.',
                  leading: const Icon(Icons.info_outline),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _showAboutDialog,
                ),

                const SizedBox(height: 10),

                // Study Analytics Shortcut
                CardTile(
                  title: 'Learning Analytics & Leitner Boxes',
                  subtitle: 'Inspect review streaks, 5-box card distribution, and mastery metrics.',
                  leading: const Icon(Icons.bar_chart_outlined),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => context.push('/progress'),
                ),

                const SizedBox(height: 24),

                // Clear Data Danger Zone
                AppButton(
                  label: 'Delete All Data & Reset',
                  icon: Icons.delete_forever,
                  isSecondary: true,
                  onPressed: _confirmDeleteAllData,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
