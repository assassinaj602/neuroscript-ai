# NeuroScript AI Backend: ASP.NET Core Proxy & Validation Gateway

The backend proxy component of NeuroScript AI acts as an enterprise security gateway between mobile client applications and generative AI models (Google Gemini 2.5 Flash). It enforces line-level grounding validation, applies install-based rate limiting, prevents credential exposure, and guarantees a zero-retention privacy policy for handwritten study notes.

---

## Architectural Principles

1. **Zero Note Retention (Privacy Preservation):**
   * The backend never persists note text, flashcard contents, or user identifiers in a permanent database.
   * Only ephemeral request audit metrics (install hash, timestamp, endpoint, latency, status code) are recorded in `RequestLog`.
2. **Pedagogical Grounding Verification (Zero Hallucination):**
   * Ingests numbered OCR lines (`LessonLine`) from the client.
   * `GroundingValidator` audits all generated flashcards and concept nodes to ensure every factual citation corresponds to an authentic line number from the student's handwritten notes.
   * Lessons with grounding scores below 0.95 (95% line citation fidelity) are rejected before client transmission.
3. **Seam-First Design (Rule 2 & Rule 6):**
   * Implements `IProxyLessonService` with `MockLessonGenerator` for deterministic offline testing and early integration verification.
   * Explicitly labeled as `'Demo generator (Proxy Seam)'` in metadata until Milestone 4 production live Gemini integration.
4. **Rate Limiting & Threat Protection:**
   * Validates client build API keys via `X-Api-Key`.
   * Partitions request rate limiting using client hardware install identifiers (`X-Install-Id`), enforcing a sliding window cap (10 requests/hour/install).

---

## Service Endpoints

### 1. Health Probe
* **Route:** `GET /health`
* **Response:**
  ```json
  {
    "status": "Healthy",
    "timestamp": "2026-10-30T00:40:00Z",
    "provider": "Gemini 2.5 Flash (Proxy Seam)",
    "version": "1.0.0-m2"
  }
  ```

### 2. Lesson Generation
* **Route:** `POST /api/v1/lessons/generate`
* **Required Headers:**
  * `X-Api-Key`: Client application authorization token.
  * `X-Install-Id`: UUID representing the client installation for rate limiting.
* **Request Body:**
  ```json
  {
    "noteHash": "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
    "lines": [
      { "lineNumber": 1, "text": "Photosynthesis converts light into chemical energy." },
      { "lineNumber": 2, "text": "Chlorophyll pigments absorb sunlight in thylakoid membranes." }
    ],
    "profile": "Dyslexia",
    "mode": "online",
    "clientVersion": "1.0.0"
  }
  ```
* **Response:**
  ```json
  {
    "lesson": {
      "lessonId": "lesson_20261030004000_a1b2c3",
      "title": "Photosynthesis converts light into...",
      "promptVersion": "v1.0-proxy-seam",
      "source": "Demo generator (Proxy Seam)",
      "createdAt": "2026-10-30T00:40:00.000Z",
      "rawNotes": "1: Photosynthesis converts light into chemical energy.\n2: Chlorophyll pigments absorb sunlight in thylakoid membranes.",
      "flashcards": [ ... ],
      "conceptMap": { "nodes": [ ... ], "edges": [ ... ] }
    },
    "groundingScore": 1.0,
    "isVerified": true
  }
  ```

---

## Directory Structure

```
backend/
├── NeuroScript.Backend.sln     # Visual Studio / .NET 9 solution
├── README.md                   # Service documentation and execution guide
├── prompts/                    # Versioned system prompt templates
│   └── v1/
│       ├── system-prompt-adhd.txt
│       ├── system-prompt-dyslexia.txt
│       ├── system-prompt-autism.txt
│       └── lesson-schema-fewshot.json
├── src/
│   ├── Api/                    # ASP.NET Core minimal web host & endpoints
│   │   ├── Program.cs
│   │   ├── appsettings.json
│   │   └── NeuroScript.Api.csproj
│   ├── Core/                   # Contracts, interfaces, and learner profiles
│   │   ├── LearnerProfile.cs
│   │   ├── LessonContracts.cs
│   │   ├── IProxyLessonService.cs
│   │   └── NeuroScript.Core.csproj
│   └── Infrastructure/         # Generator seams and grounding validator
│       ├── GroundingValidator.cs
│       ├── MockLessonGenerator.cs
│       └── NeuroScript.Infrastructure.csproj
└── tests/
    └── Api.Tests/              # xUnit unit and validation test suite
        ├── GroundingValidatorTests.cs
        └── NeuroScript.Api.Tests.csproj
```

---

## Build and Testing

```bash
# Navigate to backend directory
cd backend

# Restore and build all projects
dotnet build NeuroScript.Backend.sln

# Execute automated test suite
dotnet test NeuroScript.Backend.sln
```
