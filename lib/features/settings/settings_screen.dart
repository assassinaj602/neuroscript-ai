import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_palettes.dart';
import '../../core/utils/document_hash.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/card_tile.dart';
import '../../core/widgets/section_header.dart';
import '../../data/models/lesson_model.dart';
import '../providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final TextEditingController _pasteController = TextEditingController();
  bool _isImporting = false;

  @override
  void dispose() {
    _pasteController.dispose();
    super.dispose();
  }

  Future<void> _handleImportPastedText() async {
    final text = _pasteController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isImporting = true);
    try {
      final noteRepo = ref.read(noteRepositoryProvider);
      final lessonRepo = ref.read(lessonRepositoryProvider);

      final hash = DocumentHash.compute(text);
      final noteId = await noteRepo.saveNote(rawOcrText: text, documentHash: hash);

      // Create simple extractive cards from pasted note lines
      final lines = text.split('\n').where((l) => l.trim().isNotEmpty).toList();
      final cards = <FlashcardModel>[];
      final nodes = <ConceptNodeModel>[];

      for (int i = 0; i < lines.length; i++) {
        final line = lines[i];
        final parts = line.split(RegExp(r'[:–\-]'));
        final q = parts.isNotEmpty ? parts[0].trim() : 'Note point ${i + 1}';
        final a = parts.length > 1 ? parts.sublist(1).join(' ').trim() : line.trim();

        cards.add(
          FlashcardModel(
            id: 'paste_card_${i + 1}',
            question: q,
            answer: a,
            sourceLines: [i + 1],
          ),
        );

        nodes.add(
          ConceptNodeModel(
            id: 'node_${i + 1}',
            label: q.length > 25 ? '${q.substring(0, 22)}...' : q,
            sourceLines: [i + 1],
          ),
        );
      }

      final edges = <ConceptEdgeModel>[];
      for (int i = 0; i < nodes.length - 1; i++) {
        edges.add(
          ConceptEdgeModel(
            from: nodes[i].id,
            to: nodes[i + 1].id,
            label: 'leads to',
          ),
        );
      }

      final lesson = LessonModel(
        schemaVersion: 1,
        title: lines.isNotEmpty ? lines[0] : 'Pasted Note Lesson',
        meta: const LessonMeta(
          profile: 'Dyslexia',
          source: 'mock',
          promptVersion: 'v1',
        ),
        conceptMap: ConceptMapModel(nodes: nodes, edges: edges),
        flashcards: cards,
        rawNotes: text,
      );

      await lessonRepo.saveLesson(noteId: noteId, lesson: lesson);

      _pasteController.clear();
      ref.invalidate(allLessonsProvider);
      ref.invalidate(schedulerMetricsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Custom note converted into study lesson!')),
        );
      }
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
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
            child: const Text('Delete All', style: TextStyle(color: Colors.white)),
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
    final currentProfile = ref.watch(activeProfileProvider).value ?? ProfileType.dyslexia;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Active Profile Selection
            const SectionHeader(title: 'Learner Accessibility Profile'),
            Card(
              child: Column(
                children: ProfileType.values.map((p) {
                  return RadioListTile<ProfileType>(
                    value: p,
                    groupValue: currentProfile,
                    title: Text(p.displayName, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(p.description, style: theme.textTheme.bodySmall),
                    activeColor: colorScheme.primary,
                    onChanged: (newProfile) async {
                      if (newProfile != null) {
                        await ref.read(profileRepositoryProvider).saveProfile(newProfile);
                        ref.invalidate(activeProfileProvider);
                      }
                    },
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            // Architecture & Specifications
            const SectionHeader(title: 'Engineering & Specifications'),
            CardTile(
              title: 'System Architecture & Contracts',
              subtitle: 'Pipeline flow, ER schemas, OpenAPI contract, and the 8 Demoability rules.',
              badgeText: 'Milestone 1 Specification',
              leading: const Icon(Icons.account_tree_outlined),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => context.push('/architecture'),
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
                        color: Colors.green.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.lock_outline, color: Colors.green),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Encrypted Local Database',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'AES-256 bit SQLCipher key stored securely via FlutterSecureStorage.',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Developer / Demo Import Tool
            const SectionHeader(title: 'Developer Test Note Import'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Paste raw handwritten/typed study notes to instantly generate a local lesson slice:',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _pasteController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Line 1: Term - Definition\nLine 2: Concept - Explanation',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      label: 'Import as Lesson Slice',
                      icon: Icons.input,
                      isLoading: _isImporting,
                      onPressed: _handleImportPastedText,
                    ),
                  ],
                ),
              ),
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
    );
  }
}
