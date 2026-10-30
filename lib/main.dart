// ============================================================================
// NeuroScript AI: Privacy-Preserving Study Platform for Neurodivergent Learners
// File: lib/main.dart
//
// Description:
//   Primary application entry point for the NeuroScript AI Flutter client.
//   Initializes platform bindings, registers Riverpod dependency injection
//   overrides (including the encrypted Drift database), and boots the root
//   MaterialApp configured with GoRouter and profile-adaptive theming.
//
// Key Concepts:
//   - WidgetsFlutterBinding: Ensures native platform channels and engine bindings
//     are operational before any asynchronous initialization runs.
//   - Riverpod ProviderScope: The root container storing all application state
//     and service singletons with declarative lifecycle management.
//   - Encrypted Drift Database: Injected at the root so that repository singletons
//     can safely query encrypted SQLite tables using SQLCipher.
//   - GoRouter Integration: Declarative, deep-link capable navigation that guards
//     unauthenticated routes and directs first-time learners to Onboarding.
//   - Profile-Adaptive Theming: Dynamically recalculates color schemes, typography,
//     and spacing tokens whenever the active learner profile (ADHD, Dyslexia,
//     or Autism) is selected or updated.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/routing/app_router.dart';
import 'core/theme/app_palettes.dart';
import 'core/theme/app_theme.dart';
import 'data/database/database.dart';
import 'features/providers.dart';

/// The global entry point of the Flutter mobile, web, and desktop application.
void main() {
  // 1. Ensure Flutter engine and platform channels are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Instantiate the Drift database instance (backed by SQLCipher AES-256)
  final db = AppDatabase();

  // 3. Mount ProviderScope at the application root with our database singleton
  runApp(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
      ],
      child: const NeuroScriptApp(),
    ),
  );
}

/// The root application widget that listens to profile changes and renders
/// the active theme and router configuration.
class NeuroScriptApp extends ConsumerWidget {
  const NeuroScriptApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the GoRouter provider for route transitions and route guards
    final router = ref.watch(appRouterProvider);

    // Watch the active learner profile to dynamically switch accessibility themes
    final profileAsync = ref.watch(activeProfileProvider);

    // Default to the Dyslexia profile (soft cream anti-glare background) if loading
    final currentProfile = profileAsync.value ?? ProfileType.dyslexia;
    final theme = AppTheme.getTheme(currentProfile);

    return MaterialApp.router(
      title: 'NeuroScript AI',
      debugShowCheckedModeBanner: false,
      theme: theme,
      routerConfig: router,
    );
  }
}
