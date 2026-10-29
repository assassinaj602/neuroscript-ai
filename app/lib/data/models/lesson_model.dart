import 'dart:convert';

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

  final int schemaVersion;
  final String title;
  final LessonMeta meta;
  final ConceptMapModel conceptMap;
  final List<FlashcardModel> flashcards;
  final String? rawNotes;
  final VerificationQuestionModel? verificationQuestion;

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

  String toRawJson() => jsonEncode(toJson());

  static LessonModel fromRawJson(String str) =>
      LessonModel.fromJson(jsonDecode(str) as Map<String, dynamic>);
}

class LessonMeta {
  const LessonMeta({
    required this.profile,
    required this.source,
    required this.promptVersion,
  });

  final String profile;
  final String source;
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

class ConceptMapModel {
  const ConceptMapModel({required this.nodes, required this.edges});

  final List<ConceptNodeModel> nodes;
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

class ConceptNodeModel {
  const ConceptNodeModel({
    required this.id,
    required this.label,
    required this.sourceLines,
  });

  final String id;
  final String label;
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

class ConceptEdgeModel {
  const ConceptEdgeModel({
    required this.from,
    required this.to,
    required this.label,
  });

  final String from;
  final String to;
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

  final String id;
  final String question;
  final String answer;
  final List<int> sourceLines;
  final List<String> chunks;
  final double? groundingScore;
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

class VerificationQuestionModel {
  const VerificationQuestionModel({
    required this.question,
    required this.sourceLines,
  });

  final String question;
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
