import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neuro_script/core/theme/app_palettes.dart';
import 'package:neuro_script/core/theme/app_theme.dart';
import 'package:neuro_script/features/onboarding/onboarding_screen.dart';
import 'package:neuro_script/features/onboarding/profile_select_screen.dart';
import 'package:neuro_script/data/database/database.dart';
import 'package:neuro_script/features/providers.dart';

void main() {
  testWidgets('Onboarding screen renders title and get started button', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.getTheme(ProfileType.dyslexia),
        home: const OnboardingScreen(),
      ),
    );

    expect(find.text('NeuroScript AI'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
    expect(find.text('Grounded Active Recall'), findsOneWidget);
  });

  testWidgets('Profile selection screen renders all 3 learner profiles', (tester) async {
    final db = AppDatabase.memory();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
        ],
        child: MaterialApp(
          theme: AppTheme.getTheme(ProfileType.adhd),
          home: const ProfileSelectScreen(),
        ),
      ),
    );

    expect(find.text('ADHD'), findsOneWidget);
    expect(find.text('Dyslexia'), findsOneWidget);
    expect(find.text('Autism'), findsOneWidget);
    expect(find.text('Save & Continue'), findsOneWidget);

    await db.close();
  });
}
