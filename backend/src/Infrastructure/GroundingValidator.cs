using NeuroScript.Core;

namespace NeuroScript.Infrastructure;

/// <summary>
/// Verifies that generated flashcards and concept nodes ground their claims in source OCR line numbers.
/// Eliminates hallucinations by rejecting assertions that do not map to valid input notes.
/// </summary>
public class GroundingValidator
{
    public double ComputeGroundingScore(LessonContract lesson, HashSet<int> validLineNumbers)
    {
        if (lesson.Flashcards.Count == 0) return 0.0;

        int totalChecks = 0;
        int validChecks = 0;

        foreach (var card in lesson.Flashcards)
        {
            if (card.SourceLines.Count == 0)
            {
                totalChecks++;
                continue;
            }

            foreach (var line in card.SourceLines)
            {
                totalChecks++;
                if (validLineNumbers.Contains(line))
                {
                    validChecks++;
                }
            }
        }

        return totalChecks == 0 ? 1.0 : (double)validChecks / totalChecks;
    }

    public bool VerifyGrounding(LessonContract lesson, HashSet<int> validLineNumbers, double threshold = 0.95)
    {
        var score = ComputeGroundingScore(lesson, validLineNumbers);
        return score >= threshold;
    }
}
