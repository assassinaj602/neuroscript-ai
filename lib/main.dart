import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/routing/app_router.dart';
import 'core/theme/app_palettes.dart';
import 'core/theme/app_theme.dart';
import 'data/database/database.dart';
import 'features/providers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Create database instance
  final db = AppDatabase();

  runApp(
    ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
      child: const NeuroScriptApp(),
    ),
  );
}

class NeuroScriptApp extends ConsumerWidget {
  const NeuroScriptApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final profileAsync = ref.watch(activeProfileProvider);

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
