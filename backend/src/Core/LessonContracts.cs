using System.Text.Json.Serialization;

namespace NeuroScript.Core;

public record LessonLine(
    [property: JsonPropertyName("lineNumber")] int LineNumber,
    [property: JsonPropertyName("text")] string Text
);

public record LessonGenerationRequest(
    [property: JsonPropertyName("noteHash")] string NoteHash,
    [property: JsonPropertyName("lines")] List<LessonLine> Lines,
    [property: JsonPropertyName("profile")] string Profile,
    [property: JsonPropertyName("mode")] string Mode,
    [property: JsonPropertyName("clientVersion")] string ClientVersion
);

public record FlashcardItem(
    [property: JsonPropertyName("id")] string Id,
    [property: JsonPropertyName("question")] string Question,
    [property: JsonPropertyName("answer")] string Answer,
    [property: JsonPropertyName("sourceLines")] List<int> SourceLines,
    [property: JsonPropertyName("chunks")] List<string> Chunks
);

public record ConceptNode(
    [property: JsonPropertyName("id")] string Id,
    [property: JsonPropertyName("label")] string Label,
    [property: JsonPropertyName("sourceLines")] List<int> SourceLines
);

public record ConceptEdge(
    [property: JsonPropertyName("from")] string From,
    [property: JsonPropertyName("to")] string To,
    [property: JsonPropertyName("label")] string? Label
);

public record ConceptMap(
    [property: JsonPropertyName("nodes")] List<ConceptNode> Nodes,
    [property: JsonPropertyName("edges")] List<ConceptEdge> Edges
);

public record LessonContract(
    [property: JsonPropertyName("lessonId")] string LessonId,
    [property: JsonPropertyName("title")] string Title,
    [property: JsonPropertyName("promptVersion")] string PromptVersion,
    [property: JsonPropertyName("source")] string Source,
    [property: JsonPropertyName("createdAt")] string CreatedAt,
    [property: JsonPropertyName("rawNotes")] string? RawNotes,
    [property: JsonPropertyName("flashcards")] List<FlashcardItem> Flashcards,
    [property: JsonPropertyName("conceptMap")] ConceptMap ConceptMap
);

public record LessonGenerationResponse(
    [property: JsonPropertyName("lesson")] LessonContract Lesson,
    [property: JsonPropertyName("groundingScore")] double GroundingScore,
    [property: JsonPropertyName("isVerified")] bool IsVerified
);
