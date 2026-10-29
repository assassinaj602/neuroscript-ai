// ============================================================================
// NeuroScript AI: Privacy-Preserving Study Platform for Neurodivergent Learners
// File: app/lib/features/architecture/architecture_screen.dart
//
// Description:
//   In-app technical blueprint and specification viewer delivering Milestone 1.
//   Provides interactive tabs displaying the Six-Stage Processing Pipeline,
//   Entity-Relationship Schemas (on-device Drift & backend RequestLog),
//   Frozen API Contracts (Appendix B Lesson JSON & OpenAPI 3.0), and the
//   Eight Demoability Rules.
//
// Key Concepts:
//   - Living Documentation: Embeds architecture blueprints directly inside the running
//     app shell so examiners, supervisors, and developers can inspect specifications
//     on any physical device.
//   - TabBar Navigation: Cleanly categorizes complex system blueprints into four
//     scannable tabs with semantic headers and card tiles.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/card_tile.dart';
import '../../core/widgets/section_header.dart';
import '../providers.dart';

class ArchitectureScreen extends StatelessWidget {
  const ArchitectureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Architecture & Blueprints'),
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(icon: Icon(Icons.hub_outlined), text: 'System Flow'),
              Tab(icon: Icon(Icons.storage_outlined), text: 'ER Schemas'),
              Tab(icon: Icon(Icons.code_outlined), text: 'API Contracts'),
              Tab(icon: Icon(Icons.rule_outlined), text: '8 Demo Rules'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildFlowTab(theme, colorScheme),
            _buildErTab(theme, colorScheme),
            _buildContractsTab(theme, colorScheme),
            _buildRulesTab(context, theme, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildFlowTab(ThemeData theme, ColorScheme colorScheme) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SectionHeader(title: 'High-Level Pipeline (Figure 5.1)'),
        _stepCard(
          step: '1',
          title: 'Capture & OpenCV Preprocessing',
          desc: 'Camera frame -> Isolate resize (2000px) -> CLAHE contrast normalization -> Denoise -> Deskew.',
          icon: Icons.camera_alt_outlined,
          colorScheme: colorScheme,
          theme: theme,
        ),
        _arrowDown(colorScheme),
        _stepCard(
          step: '2',
          title: 'ML Kit OCR & Review Screen',
          desc: 'Extract Latin text lines numbered 1 to N. User corrects/edits text prior to transmission (privacy promise).',
          icon: Icons.document_scanner_outlined,
          colorScheme: colorScheme,
          theme: theme,
        ),
        _arrowDown(colorScheme),
        _stepCard(
          step: '3',
          title: 'ASP.NET Core Proxy Gateway',
          desc: 'Stateless proxy enforcing rate limits, build authentication, and structured logging of metadata only.',
          icon: Icons.dns_outlined,
          colorScheme: colorScheme,
          theme: theme,
        ),
        _arrowDown(colorScheme),
        _stepCard(
          step: '4',
          title: 'Google Gemini 2.5 Flash',
          desc: 'Closed-book compiler prompt: adheres to line delimiters, outputs strictly formatted Lesson JSON contract.',
          icon: Icons.auto_awesome,
          colorScheme: colorScheme,
          theme: theme,
        ),
        _arrowDown(colorScheme),
        _stepCard(
          step: '5',
          title: 'Grounding-Score Validator',
          desc: 'Formula: G = 0.6·Sem + 0.4·L with exact entity check X. Discards ungrounded hallucinations.',
          icon: Icons.verified_outlined,
          colorScheme: colorScheme,
          theme: theme,
        ),
        _arrowDown(colorScheme),
        _stepCard(
          step: '6',
          title: 'On-Device SLM Fallback (Airplane Mode)',
          desc: 'Llama 3.2 1B / SmolLM2 via llamadart runs locally when offline; otherwise enqueues to PendingJobs.',
          icon: Icons.offline_bolt_outlined,
          colorScheme: colorScheme,
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildErTab(ThemeData theme, ColorScheme colorScheme) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SectionHeader(title: 'On-Device Encrypted Database (Figure 5.2)'),
        CardTile(
          title: 'UserProfiles',
          subtitle: 'ProfileID (PK), ProfileType (ADHD|Dyslexia|Autism), ThemeSettings JSON, CreatedAt',
          badgeText: 'Drift + SQLCipher',
          leading: const Icon(Icons.person_outline),
        ),
        CardTile(
          title: 'SourceNotes',
          subtitle:
              'NoteID (PK), RawOCRText, DocumentHash (SHA-256), CreatedAt',
          badgeText: 'Cascade Root',
          leading: const Icon(Icons.notes),
        ),
        CardTile(
          title: 'Lessons',
          subtitle: 'LessonID (PK), NoteID (FK), Title, ConceptMapJSON, PromptVersion, Source, CreatedAt',
          badgeText: 'FK -> SourceNotes',
          leading: const Icon(Icons.book_outlined),
        ),
        CardTile(
          title: 'Flashcards',
          subtitle: 'CardID (PK), LessonID (FK), Question, Answer, SourceLineReference, GroundingScore, Verified',
          badgeText: 'FK -> Lessons',
          leading: const Icon(Icons.style_outlined),
        ),
        CardTile(
          title: 'ReviewProgress',
          subtitle: 'ProgressID (PK), CardID (FK), Box (1..5), SpacedRepetitionInterval (1,3,7,14,30), NextReviewDate',
          badgeText: 'Leitner State',
          leading: const Icon(Icons.timeline),
        ),
        CardTile(
          title: 'PendingJobs (M4C Queue Extension)',
          subtitle: 'JobID (PK), NoteHash, Status, Attempts, NextAttemptAt, CreatedAt',
          badgeText: 'Offline Queue',
          leading: const Icon(Icons.queue_play_next),
        ),
        const SizedBox(height: 12),
        const SectionHeader(title: 'Backend Database (Figure 5.3)'),
        CardTile(
          title: 'RequestLog (Stateless Content)',
          subtitle: 'Id (PK), InstallHash, Endpoint, Status, LatencyMs, Provider, CreatedAt (Zero text stored)',
          badgeText: 'SQLite / EF Core',
          leading: const Icon(Icons.security),
        ),
      ],
    );
  }

  Widget _buildContractsTab(ThemeData theme, ColorScheme colorScheme) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SectionHeader(title: 'Frozen Lesson JSON Contract (Appendix B)'),
        Card(
          color: colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '''{
  "schemaVersion": 1,
  "title": "Photosynthesis Fundamentals",
  "meta": {
    "profile": "Dyslexia",
    "source": "seed|mock|cloud|device",
    "promptVersion": "v1"
  },
  "conceptMap": {
    "nodes": [ { "id": "n1", "label": "...", "sourceLines": [1, 2] } ],
    "edges": [ { "from": "n1", "to": "n2", "label": "..." } ]
  },
  "flashcards": [
    {
      "id": "c1",
      "question": "...",
      "answer": "...",
      "sourceLines": [3],
      "chunks": ["optional chunks"]
    }
  ],
  "verificationQuestion": {
    "question": "...",
    "sourceLines": [5]
  }
}''',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const SectionHeader(title: 'Proxy REST Endpoints (OpenAPI 3.0)'),
        CardTile(
          title: 'GET /health',
          subtitle: 'Returns health status and upstream LLM latency.',
          badgeText: '200 OK',
        ),
        CardTile(
          title: 'POST /api/v1/lessons/generate',
          subtitle: 'Accepts { noteHash, lines[], profile, mode } -> returns Lesson JSON.',
          badgeText: 'X-Api-Key + RateLimit',
        ),
        CardTile(
          title: 'POST /api/v1/text/simplify',
          subtitle: 'Transforms complex card text into literal plain language for Autism profile.',
          badgeText: 'M5 Endpoint',
        ),
      ],
    );
  }

  Widget _buildRulesTab(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Consumer(
      builder: (context, ref, _) {
        final config = ref.watch(appConfigProvider);

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SectionHeader(
              title: 'Active Environment Flags (--dart-define)',
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _flagRow(
                      'generatorMode',
                      config.generatorMode.name,
                      colorScheme,
                    ),
                    _flagRow(
                      'enableCapture',
                      config.enableCapture.toString(),
                      colorScheme,
                    ),
                    _flagRow(
                      'groundingMode',
                      config.groundingMode.name,
                      colorScheme,
                    ),
                    _flagRow(
                      'enableLocalFallback',
                      config.enableLocalFallback.toString(),
                      colorScheme,
                    ),
                    _flagRow(
                      'enableSimplify',
                      config.enableSimplify.toString(),
                      colorScheme,
                    ),
                    _flagRow(
                      'enableTts',
                      config.enableTts.toString(),
                      colorScheme,
                    ),
                    _flagRow(
                      'demoMode',
                      config.demoMode.toString(),
                      colorScheme,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const SectionHeader(title: 'The 8 Demoability Rules'),
            _ruleCard(
              '1. Vertical slices, not layers',
              'Every milestone adds a thin slice from UI to storage.',
            ),
            _ruleCard(
              '2. Build seams first, fill them later',
              'Interfaces and stubs allow modules to be swapped safely.',
            ),
            _ruleCard(
              '3. One data contract from day one',
              'Lesson schema never changes when AI changes.',
            ),
            _ruleCard(
              '4. main is always demoable',
              'CI must pass on PRs; main is always installable.',
            ),
            _ruleCard(
              '5. Feature flags manage demos',
              'Incomplete work is hidden, never shown broken.',
            ),
            _ruleCard(
              '6. Honest labels',
              'Stand-ins and mocks are clearly badged in the UI.',
            ),
            _ruleCard(
              '7. Every milestone has a safety net',
              'Signed APKs, recorded backup demos, seeded data.',
            ),
            _ruleCard(
              '8. Small, early usability checks',
              'Peer tests at M2 and M4 catch usability flaws early.',
            ),
          ],
        );
      },
    );
  }

  Widget _flagRow(String name, String value, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ruleCard(String title, String desc) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        ),
        subtitle: Text(desc, style: const TextStyle(fontSize: 12)),
      ),
    );
  }

  Widget _stepCard({
    required String step,
    required String title,
    required String desc,
    required IconData icon,
    required ColorScheme colorScheme,
    required ThemeData theme,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                step,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(icon, size: 18, color: colorScheme.primary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    style: theme.textTheme.bodySmall?.copyWith(height: 1.3),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _arrowDown(ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Icon(Icons.arrow_downward, color: colorScheme.outline, size: 20),
      ),
    );
  }
}
