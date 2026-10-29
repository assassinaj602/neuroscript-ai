namespace NeuroScript.Core;

public interface IProxyLessonService
{
    Task<LessonGenerationResponse> GenerateLessonAsync(
        LessonGenerationRequest request,
        CancellationToken cancellationToken = default
    );
}
