using NeuroScript.Core;
using NeuroScript.Infrastructure;
using Xunit;

namespace NeuroScript.Api.Tests;

public class GroundingValidatorTests
{
    private readonly GroundingValidator _validator = new();

    [Fact]
    public void ComputeGroundingScore_ReturnsOne_WhenAllLinesValid()
    {
        var lesson = new LessonContract(
            LessonId: "l1",
            Title: "Test Lesson",
            PromptVersion: "v1.0",
            Source: "Test",
            CreatedAt: DateTime.UtcNow.ToString("O"),
            RawNotes: "1: Line one\n2: Line two",
            Flashcards:
            [
                new FlashcardItem("c1", "Q1", "A1", [1], ["A1"]),
                new FlashcardItem("c2", "Q2", "A2", [2], ["A2"])
            ],
            ConceptMap: new ConceptMap([], [])
        );

        var validLines = new HashSet<int> { 1, 2 };
        var score = _validator.ComputeGroundingScore(lesson, validLines);

        Assert.Equal(1.0, score);
        Assert.True(_validator.VerifyGrounding(lesson, validLines));
    }

    [Fact]
    public void ComputeGroundingScore_PenalizesHallucinatedLines()
    {
        var lesson = new LessonContract(
            LessonId: "l1",
            Title: "Test Lesson",
            PromptVersion: "v1.0",
            Source: "Test",
            CreatedAt: DateTime.UtcNow.ToString("O"),
            RawNotes: "1: Line one",
            Flashcards:
            [
                new FlashcardItem("c1", "Q1", "A1", [1], ["A1"]),
                new FlashcardItem("c2", "Q2", "A2", [99], ["Hallucination"]) // 99 does not exist
            ],
            ConceptMap: new ConceptMap([], [])
        );

        var validLines = new HashSet<int> { 1 };
        var score = _validator.ComputeGroundingScore(lesson, validLines);

        Assert.Equal(0.5, score);
        Assert.False(_validator.VerifyGrounding(lesson, validLines, threshold: 0.95));
    }

    [Fact]
    public async Task MockLessonGenerator_ProducesFullyGroundedLesson()
    {
        var generator = new MockLessonGenerator();
        var request = new LessonGenerationRequest(
            NoteHash: "abc123hash",
            Lines:
            [
                new LessonLine(1, "Photosynthesis requires sunlight."),
                new LessonLine(2, "Chlorophyll absorbs red and blue light.")
            ],
            Profile: "ADHD",
            Mode: "online",
            ClientVersion: "1.0.0"
        );

        var response = await generator.GenerateLessonAsync(request);

        Assert.NotNull(response.Lesson);
        Assert.Equal(2, response.Lesson.Flashcards.Count);
        Assert.Equal(2, response.Lesson.ConceptMap.Nodes.Count);
        Assert.Equal(1.0, response.GroundingScore);
        Assert.True(response.IsVerified);
    }
}
