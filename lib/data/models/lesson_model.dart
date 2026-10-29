// ============================================================================
// NeuroScript AI: Privacy-Preserving Study Platform for Neurodivergent Learners
// File: app/lib/data/models/lesson_model.dart
//
// Description:
//   Data serialization models for the canonical Lesson JSON Contract.
//   Strictly adheres to Appendix B of the Milestone Execution Plan and
//   Rule 3 of the Demoability Rules ("One data contract from day one").
//
// Architectural Invariants:
//   - Schema Immutability: Frozen in Milestone 1. All sources (bundled seed JSON,
//     ASP.NET Core mock generators, Google Gemini 2.5 Flash, and on-device SLMs)
//     produce this exact JSON structure.
//   - Source Line Citation Grounding: Every concept node and flashcard cites 1-based
//     line references [sourceLines] mapped directly to student handwritten notes,
//     enabling instant "Where is this from?" provenance inspections.
// ============================================================================

import 'dart:convert';

/// Root container for a synthesized study lesson.
class LessonModel {
  const LessonModel({
    required this.schemaVersion,
    required this.title,
    required this.meta,
    required this.conceptMap,
    required this.flashcards,
    this.rawNotes,
    this.verificationQuestion,
  });

  /// The version integer of the lesson schema contract (currently 1).
  final int schemaVersion;

  /// Human-readable title of the synthesized lesson.
  final String title;

  /// Synthesis metadata (target profile, generator source, prompt version).
  final LessonMeta meta;

  /// Knowledge graph structure comprising nodes, relationships, and source citations.
  final ConceptMapModel conceptMap;

  /// List of line-grounded flashcards for active recall study.
  final List<FlashcardModel> flashcards;

  /// Optional raw transcript of the source notes from which this lesson was compiled.
  final String? rawNotes;

  /// Optional comprehension cross-questioning item.
  final VerificationQuestionModel? verificationQuestion;

  /// Deserializes a [Map<String, dynamic>] into a validated [LessonModel].
  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      schemaVersion: json['schemaVersion'] as int? ?? 1,
      title: json['title'] as String? ?? 'Untitled Lesson',
      meta: LessonMeta.fromJson(json['meta'] as Map<String, dynamic>? ?? {}),
      conceptMap: ConceptMapModel.fromJson(
        json['conceptMap'] as Map<String, dynamic>? ?? {},
      ),
      flashcards: (json['flashcards'] as List<dynamic>? ?? [])
          .map((card) => FlashcardModel.fromJson(card as Map<String, dynamic>))
          .toList(),
      rawNotes: json['rawNotes'] as String?,
      verificationQuestion: json['verificationQuestion'] != null
          ? VerificationQuestionModel.fromJson(
              json['verificationQuestion'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Serializes the lesson model into a JSON-compliant map.
  Map<String, dynamic> toJson() => {
    'schemaVersion': schemaVersion,
    'title': title,
    'meta': meta.toJson(),
    'conceptMap': conceptMap.toJson(),
    'flashcards': flashcards.map((f) => f.toJson()).toList(),
    if (rawNotes != null) 'rawNotes': rawNotes,
    if (verificationQuestion != null)
      'verificationQuestion': verificationQuestion!.toJson(),
  };

  /// Encodes the model to a JSON string.
  String toRawJson() => jsonEncode(toJson());

  /// Parses a raw JSON string into a [LessonModel].
  static LessonModel fromRawJson(String str) =>
      LessonModel.fromJson(jsonDecode(str) as Map<String, dynamic>);
}

/// Metadata identifying compiler provenance and profile context.
class LessonMeta {
  const LessonMeta({
    required this.profile,
    required this.source,
    required this.promptVersion,
  });

  /// The target neurodivergent learner profile: 'ADHD', 'Dyslexia', or 'Autism'.
  final String profile;

  /// The engine that compiled the lesson: 'seed', 'mock', 'cloud', or 'device'.
  final String source;

  /// Version of the prompt engineering schema (e.g. 'v1').
  final String promptVersion;

  factory LessonMeta.fromJson(Map<String, dynamic> json) {
    return LessonMeta(
      profile: json['profile'] as String? ?? 'Dyslexia',
      source: json['source'] as String? ?? 'seed',
      promptVersion: json['promptVersion'] as String? ?? 'v1',
    );
  }

  Map<String, dynamic> toJson() => {
    'profile': profile,
    'source': source,
    'promptVersion': promptVersion,
  };
}

/// Graph schema model representing interconnected topics and concepts.
class ConceptMapModel {
  const ConceptMapModel({required this.nodes, required this.edges});

  /// List of concept nodes.
  final List<ConceptNodeModel> nodes;

  /// List of directed, labeled edges between concept nodes.
  final List<ConceptEdgeModel> edges;

  factory ConceptMapModel.fromJson(Map<String, dynamic> json) {
    return ConceptMapModel(
      nodes: (json['nodes'] as List<dynamic>? ?? [])
          .map((n) => ConceptNodeModel.fromJson(n as Map<String, dynamic>))
          .toList(),
      edges: (json['edges'] as List<dynamic>? ?? [])
          .map((e) => ConceptEdgeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'nodes': nodes.map((n) => n.toJson()).toList(),
    'edges': edges.map((e) => e.toJson()).toList(),
  };
}

/// A single node inside the visual concept graph.
class ConceptNodeModel {
  const ConceptNodeModel({
    required this.id,
    required this.label,
    required this.sourceLines,
  });

  /// Unique node identifier (e.g., 'n1').
  final String id;

  /// Concise text label for the concept.
  final String label;

  /// 1-based source note line indices supporting this concept.
  final List<int> sourceLines;

  factory ConceptNodeModel.fromJson(Map<String, dynamic> json) {
    return ConceptNodeModel(
      id: json['id'] as String? ?? '',
      label: json['label'] as String? ?? '',
      sourceLines: (json['sourceLines'] as List<dynamic>? ?? [])
          .map((line) => line as int)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'sourceLines': sourceLines,
  };
}

/// A directed semantic relationship linking two nodes in the concept map.
class ConceptEdgeModel {
  const ConceptEdgeModel({
    required this.from,
    required this.to,
    required this.label,
  });

  /// Identifier of the source node.
  final String from;

  /// Identifier of the destination node.
  final String to;

  /// Natural language relationship label (e.g., 'requires', 'produces', 'part of').
  final String label;

  factory ConceptEdgeModel.fromJson(Map<String, dynamic> json) {
    return ConceptEdgeModel(
      from: json['from'] as String? ?? '',
      to: json['to'] as String? ?? '',
      label: json['label'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'from': from, 'to': to, 'label': label};
}

/// A line-grounded flashcard item for active recall testing.
class FlashcardModel {
  const FlashcardModel({
    required this.id,
    required this.question,
    required this.answer,
    required this.sourceLines,
    this.chunks = const [],
    this.groundingScore,
    this.verified = true,
  });

  /// Unique card identifier (e.g., 'c1').
  final String id;

  /// Question prompt displayed on the card front.
  final String question;

  /// Solution revealed on the card back.
  final String answer;

  /// 1-based line numbers from the student notes cited by this card.
  final List<int> sourceLines;

  /// Optional bite-sized sentence chunks tailored for ADHD micro-reading.
  final List<String> chunks;

  /// Calculated grounding score G (0.0 to 1.0).
  final double? groundingScore;

  /// Verification status determined by the grounding gate.
  final bool verified;

  factory FlashcardModel.fromJson(Map<String, dynamic> json) {
    return FlashcardModel(
      id: json['id'] as String? ?? '',
      question: json['question'] as String? ?? '',
      answer: json['answer'] as String? ?? '',
      sourceLines: (json['sourceLines'] as List<dynamic>? ?? [])
          .map((line) => line as int)
          .toList(),
      chunks: (json['chunks'] as List<dynamic>? ?? [])
          .map((chunk) => chunk as String)
          .toList(),
      groundingScore: (json['groundingScore'] as num?)?.toDouble(),
      verified: json['verified'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'question': question,
    'answer': answer,
    'sourceLines': sourceLines,
    if (chunks.isNotEmpty) 'chunks': chunks,
    if (groundingScore != null) 'groundingScore': groundingScore,
    'verified': verified,
  };
}

/// Optional comprehension question model verifying factual recall.
class VerificationQuestionModel {
  const VerificationQuestionModel({
    required this.question,
    required this.sourceLines,
  });

  /// The check question.
  final String question;

  /// 1-based line citations.
  final List<int> sourceLines;

  factory VerificationQuestionModel.fromJson(Map<String, dynamic> json) {
    return VerificationQuestionModel(
      question: json['question'] as String? ?? '',
      sourceLines: (json['sourceLines'] as List<dynamic>? ?? [])
          .map((line) => line as int)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'question': question,
    'sourceLines': sourceLines,
  };
}
