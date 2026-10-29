using NeuroScript.Core;
using NeuroScript.Infrastructure;

var builder = WebApplication.CreateBuilder(args);

// Register application services
builder.Services.AddSingleton<IProxyLessonService, MockLessonGenerator>();
builder.Services.AddSingleton<GroundingValidator>();

var app = builder.Build();

// Health check endpoint conforming to proxy-api.openapi.yaml
app.MapGet("/health", () => Results.Ok(new
{
    status = "Healthy",
    timestamp = DateTime.UtcNow,
    provider = "Gemini 2.5 Flash (Proxy Seam)",
    version = "1.0.0-m2"
}));

// Lesson generation endpoint
app.MapPost("/api/v1/lessons/generate", async (
    HttpContext context,
    LessonGenerationRequest request,
    IProxyLessonService lessonService) =>
{
    // 1. Validate API Key header
    if (!context.Request.Headers.TryGetValue("X-Api-Key", out var apiKey) || string.IsNullOrWhiteSpace(apiKey))
    {
        return Results.Unauthorized();
    }

    // 2. Validate Install ID header (for rate-limiting partition)
    if (!context.Request.Headers.TryGetValue("X-Install-Id", out var installId) || string.IsNullOrWhiteSpace(installId))
    {
        return Results.BadRequest(new { error = "Missing required X-Install-Id header." });
    }

    // 3. Validate request payload
    if (request.Lines == null || request.Lines.Count == 0)
    {
        return Results.BadRequest(new { error = "Request must contain at least one numbered OCR line." });
    }

    if (string.IsNullOrWhiteSpace(request.NoteHash))
    {
        return Results.BadRequest(new { error = "Missing noteHash." });
    }

    // 4. Generate lesson via proxy seam
    var result = await lessonService.GenerateLessonAsync(request);

    return Results.Ok(result);
});

app.Run();

// Partial class declaration for WebApplicationFactory integration testing
public partial class Program { }
