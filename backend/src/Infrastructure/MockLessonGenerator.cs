using System.Security.Cryptography;
using System.Text;
using NeuroScript.Core;

namespace NeuroScript.Infrastructure;

/// <summary>
/// Architectural stand-in generator adhering to Rule 2 (Build Seams First, Fill Later)
/// and Rule 6 (Honest Labels). Produces fully schema-compliant lessons verified against
/// the input lines before Gemini 2.5 Flash live cloud integration (Milestone 4).
/// </summary>
public class MockLessonGenerator : IProxyLessonService
{
    private readonly GroundingValidator _validator = new();

    public Task<LessonGenerationResponse> GenerateLessonAsync(
        LessonGenerationRequest request,
        CancellationToken cancellationToken = default)
    {
        var validLines = request.Lines.Select(l => l.LineNumber).ToHashSet();
        var rawNotes = string.Join("\n", request.Lines.Select(l => $"{l.LineNumber}: {l.Text}"));

        var cards = new List<FlashcardItem>();
        var nodes = new List<ConceptNode>();
        var edges = new List<ConceptEdge>();

        for (int i = 0; i < request.Lines.Count; i++)
        {
            var line = request.Lines[i];
            var cardId = $"mock_card_{i + 1}_{Guid.NewGuid().ToString("N")[..8]}";
            var nodeId = $"node_{line.LineNumber}";

            cards.Add(new FlashcardItem(
                Id: cardId,
                Question: $"Key takeaway from line {line.LineNumber}?",
                Answer: line.Text,
                SourceLines: [line.LineNumber],
                Chunks: [line.Text]
            ));

            nodes.Add(new ConceptNode(
                Id: nodeId,
                Label: line.Text.Length > 24 ? line.Text[..21] + "..." : line.Text,
                SourceLines: [line.LineNumber]
            ));

            if (i > 0)
            {
                var prevNodeId = $"node_{request.Lines[i - 1].LineNumber}";
                edges.Add(new ConceptEdge(
                    From: prevNodeId,
                    To: nodeId,
                    Label: "leads to"
                ));
            }
        }

        var lessonId = $"lesson_{DateTime.UtcNow:yyyyMMddHHmmss}_{Guid.NewGuid().ToString("N")[..6]}";
        var firstLineText = request.Lines.FirstOrDefault()?.Text ?? "Generated Study Lesson";
        var title = firstLineText.Length > 40 ? firstLineText[..37] + "..." : firstLineText;

        var lesson = new LessonContract(
            LessonId: lessonId,
            Title: title,
            PromptVersion: "v1.0-proxy-seam",
            Source: "Demo generator (Proxy Seam)",
            CreatedAt: DateTime.UtcNow.ToString("O"),
            RawNotes: rawNotes,
            Flashcards: cards,
            ConceptMap: new ConceptMap(Nodes: nodes, Edges: edges)
        );

        var score = _validator.ComputeGroundingScore(lesson, validLines);
        var isVerified = _validator.VerifyGrounding(lesson, validLines);

        var response = new LessonGenerationResponse(
            Lesson: lesson,
            GroundingScore: score,
            IsVerified: isVerified
        );

        return Task.FromResult(response);
    }
}
