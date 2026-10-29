# NeuroScript AI: Privacy-Preserving Study Platform for Neurodivergent Learners

A specialized, accessible study application engineered for students with Attention Deficit Hyperactivity Disorder (ADHD), Dyslexia, and Autism Spectrum Conditions. NeuroScript AI transforms raw handwritten lecture notes into line-grounded flashcards and interactive concept maps using a hybrid AI pipeline (Google Gemini 2.5 Flash via a secure ASP.NET Core proxy, with an on-device Small Language Model fallback), verified against strict lexical and semantic grounding metrics and stored within a locally encrypted database.

---

## Project Metadata

* **Institution:** Department of Computer Science, University of Engineering & Technology (UET) Taxila
* **Course:** CS-400 Final Year Project (Academic Year 2026–2027)
* **Supervisor:** Mr. Awais Mehmood
* **Engineering Team:**
  * **Zain Tahir** (Roll No. 23-CS-115) – Systems Architecture, Database Engineering, AI Logic, Client-Server Integration
  * **Ujala Sahar** (Roll No. 23-CS-135) – UI/UX Design System, Accessibility Auditing, User Acceptance Testing, Documentation
* **Current Delivery Status:** Milestone 1 (`v0.1.0-m1`) and Milestone 2 (`v0.2.0-m2`) Complete

---

## Problem Statement and Motivation

Undergraduate students with learning differences encounter severe cognitive barriers when revising from handwritten notes:
1. **Executive Dysfunction & Task Initiation (ADHD):** Students experience cognitive overwhelm when confronting dense, unorganized notes. Large study decks cause focus fatigue and task abandonment.
2. **Visual Stress & Phonological Processing (Dyslexia):** High-contrast black text on pure white backgrounds produces visual glare, letter distortion, and fatigue. Crowded text layouts impede reading speed and comprehension.
3. **Sensory Sensitivity & Ambiguity (Autism):** Unpredictable layouts, gratuitous animations, and metaphorical expressions induce cognitive load. Autistic learners require predictable structures and literal wording.
4. **AI Hallucinations in Educational Tools:** Mainstream generative assistants routinely invent non-existent facts or extrapolate beyond provided context without source citations, misguiding revision.
5. **Data Privacy Deficits:** Conventional commercial platforms store student notes and academic records in plaintext on proprietary cloud servers without end-to-end user encryption.

NeuroScript AI resolves these challenges through an accessibility-first client architecture, strict source-grounding verification, and a zero-retention, encrypted offline storage model.

---

## System Architecture

The application adopts a hybrid cloud/edge topology. The client interface is implemented in Flutter, connecting to an ASP.NET Core proxy gateway for cloud-assisted synthesis, while retaining autonomous offline functionality through an embedded Small Language Model (SLM) and an encrypted local database.

```
+-------------------------------------------------------------------------+
|                              Client Layer                               |
|                                                                         |
|  [ Camera Capture ] ---> [ OpenCV Preprocessing ] ---> [ ML Kit OCR ]   |
|                                                            │   │         |
|                                                               ▼         |
|  [ Flutter UI: Riverpod + GoRouter ] <---> [ Line-Number Review Screen] |
|     │   │                                                                |
|  │   │   ├── (Online Flow)  ────────────────┐                             |
|     │   │                                  ▼                             |
|     │   │                       [ ASP.NET Core Proxy ]                   |
|     │   │                               │   │                             |
|     │   │                                  ▼                             |
|     │   │                       [ Google Gemini 2.5 ]                    |
|     │   │                               │   │                             |
|     │   │                                  ▼                             |
|  │   │   ├── (Validation) <─── [ Grounding Validator ]                    |
|     │   │                     (Lexical + Semantic)                       |
|     │   │                                                                |
|     │   └── (Offline Flow) ─> [ On-Device SLM ] ──> [ PendingJobs Queue ]|
|                                    │   │                                 |
|                                       ▼                                 |
|                     [ Drift + SQLCipher (AES-256) ]                     |
+-------------------------------------------------------------------------+
```

### The Six-Stage Processing Pipeline

1. **Optical Acquisition:** Capture multi-page handwritten notes (1–5 pages) with framing guides and flash control.
2. **Computer Vision Enhancement:** Execute background-isolate OpenCV preprocessing: long-side resize to 2000px, Contrast Limited Adaptive Histogram Equalization (CLAHE), bilateral denoising, adaptive Gaussian thresholding, and deskewing.
3. **Optical Character Recognition (OCR):** Transcribe text blocks into ordered, 1-based numbered lines ($1 \dots N$) via Google ML Kit Text Recognition.
4. **Human-in-the-Loop Verification:** Display an editable line-by-line review screen enabling students to correct, merge, or delete transcription errors prior to AI processing.
5. **Synthesis & Closed-Book Compilation:** Transmit confirmed lines to Google Gemini 2.5 Flash using structured delimiters and profile-tailored prompts that forbid external knowledge injection.
6. **Grounding Verification & Storage:** Validate every flashcard and concept map node against cited source lines. Grounded items are committed to the local encrypted SQLite database (Drift + SQLCipher).

---

## Accessibility Profiles

The user interface implements three distinct design systems compliant with WCAG 2.1 AA specifications (contrast ratios $\ge 4.5:1$, touch targets $\ge 48$ dp, scalable typography up to $2.0\times$ without layout clipping).

| Feature / Dimension | ADHD Profile | Dyslexia Profile | Autism Profile |
|---|---|---|---|
| **Primary Palette** | Deep Indigo (`#3F51B5`) & Warm Amber (`#FF9800`) | Slate Blue (`#1E3A8A`) & Teal (`#0D9488`) | Muted Sage Teal (`#3D6B7A`) & Ice Mist (`#EEF3F4`) |
| **Background Tone** | Clean Minimal Grey (`#F8F9FA`) | Warm Anti-Glare Cream (`#FBF8EE`) | Low-Saturation Mist (`#EEF3F4`) |
| **Typography** | Sans-Serif (Standard letter spacing) | Relaxed spacing (Line height $\ge 1.6$, tracking $+0.6$) | Structured, clear hierarchy (Tracking $+0.2$) |
| **Study Sizing** | **5-card micro-sessions** with immediate feedback | Standard 10-card sessions with read-aloud option | Predictable step progression ("Card 2 of 5") |
| **Motion & Audio** | Engaging progress rings and completion badges | Text-to-Speech read-aloud with sentence tracking | Zero autoplay motion (respects `reduce-motion`), silent by default |
| **Wording Mode** | Punchy, single-concept flashcards | Plain language with highlighted keywords | Literal simplification mode (removes idioms and metaphors) |

---

## Grounding-Score Verification Methodology

To prevent hallucinations, every generated study item $g$ citing an evidence window $E$ (the cited line indices plus one adjacent line on either side) is evaluated against a composite mathematical metric before storage:

### 1. Lexical Containment ($L$)
Evaluates unigram ($C_1$) and bigram ($C_2$) token overlap between the generated item and the source window:
$$C_n = \frac{|N_n(g) \cap N_n(E)|}{|N_n(g)|}, \quad L = \frac{C_1 + C_2}{2}$$

### 2. Semantic Embedding Similarity ($Sem$)
Computes cosine similarity between sentence embeddings generated by an on-device quantized MiniLM model:
$$Sem = \max_{j \in E} \left( \frac{v_g \cdot v_j}{\|v_g\| \|v_j\|} \right)$$

### 3. Entity Verification Constraint ($X$)
Extracts all numerical values, proper nouns, dates, and formulas from $g$. If any entity in $g$ does not appear identically within $E$, the item is penalized:
$$X = \begin{cases} 1 & \text{if all entities in } g \text{ exist in } E \\ 0 & \text{otherwise} \end{cases}$$

### 4. Composite Grounding Metric ($G$) and Decision Gate
$$G = \begin{cases} 0.6 \cdot Sem + 0.4 \cdot L & \text{if } X = 1 \\ 0 & \text{if } X = 0 \end{cases}$$

* **Acceptance ($G \ge 0.75 \land X = 1$):** Item is marked verified and stored with source line citations.
* **Regeneration ($0.50 \le G < 0.75$):** Re-prompt generator once with an explicit quote-only constraint.
* **Rejection ($G < 0.50 \lor X = 0$):** Discard item permanently to protect the learner from incorrect data.

---

## Active Recall and Spaced Repetition

Review scheduling is governed by an implementation of the Leitner Spaced Repetition System:

```
[ New Cards ] ──> [ Box 1: 1 Day ]
                     │   │
       ┌────────────────┴───────────────┐
  Correct (Got it)               Incorrect (Not yet)
    │   │                             │   │
       ▼                             │   │
[ Box 2: 3 Days ]                    │   │
    │   │                             │   │
  Correct (Got it)                   │   │
    │   │                             │   │
       ▼                             │   │
[ Box 3: 7 Days ]                    │   │
    │   │                             │   │
  Correct (Got it)                   │   │
    │   │                             │   │
       ▼                             │   │
[ Box 4: 14 Days ]                   │   │
    │   │                             │   │
  Correct (Got it)                   │   │
    │   │                             │   │
       ▼                                ▼
[ Box 5: 30 Days (Mastered) ]   [ Reset to Box 1 ]
```

* **Session Scheduling:** The daily queue prioritizes overdue cards (`nextReviewDate <= now`), followed by unreviewed cards.
* **Cognitive Caps:** Daily session sizes are capped per profile (ADHD: 5 cards; Dyslexia/Autism: 10 cards).
* **Line-Level Provenance:** A dedicated sheet links each flashcard and concept map node directly back to the original handwritten note lines.

---

## Privacy by Design and Data Governance

1. **Local Database Encryption:** User data is encrypted at rest using AES-256 via Drift and SQLCipher. The database encryption key is generated using a cryptographically secure pseudo-random number generator (`Random.secure()`) on first execution and held in hardware-backed secure storage (`FlutterSecureStorage`).
2. **Stateless Backend Proxy:** The ASP.NET Core server stores zero note text and zero generated lesson content. It maintains only metadata in an operational audit log (`RequestLog`: install hash, endpoint, latency, status code, timestamp).
3. **No Unencrypted Cloud Storage:** Notes are never transmitted to cloud endpoints without explicit user consent. When offline, all processing remains strictly local.

---

## Database Schemata (On-Device & Proxy)

### Client Database (Drift / SQLCipher)
* `UserProfiles`: `id` (PK), `profileType` (ADHD, Dyslexia, Autism), `themeSettings` (JSON), `createdAt`.
* `SourceNotes`: `noteId` (PK), `rawOcrText`, `documentHash` (SHA-256), `createdAt`.
* `Lessons`: `lessonId` (PK), `noteId` (FK, cascade delete), `title`, `conceptMapJson`, `promptVersion`, `source`, `createdAt`.
* `Flashcards`: `cardId` (PK), `lessonId` (FK, cascade delete), `question`, `answer`, `sourceLineReference`, `groundingScore`, `verified`.
* `ReviewProgress`: `progressId` (PK), `cardId` (FK, cascade delete), `box` (1..5), `spacedRepetitionInterval` (1, 3, 7, 14, 30), `nextReviewDate`, `lastReviewedAt`, `consecutiveCorrect`.
* `PendingJobs` *(Milestone 4 extension)*: `jobId` (PK), `noteHash`, `status`, `attempts`, `nextAttemptAt`, `createdAt`.

### Backend Database (Entity Framework Core / SQLite)
* `RequestLog`: `Id` (PK), `InstallHash`, `Endpoint`, `Status`, `LatencyMs`, `Provider`, `CreatedAt`.

---

## The Eight Demoability Rules

Development strictly adheres to the eight engineering rules defined in the milestone execution plan:

1. **Vertical Slices, Not Layers:** Each milestone delivers an end-to-end slice spanning presentation down to persistence.
2. **Build Seams First, Fill Later:** External dependencies sit behind Dart/C# interfaces with working stand-ins (seed JSON, mock generators) prior to production integrations.
3. **One Data Contract from Day One:** The Lesson JSON Schema (`docs/contracts/lesson.schema.json`) is frozen and identical across seed data, mock generators, Gemini, and on-device SLMs.
4. **Main is Always Demoable:** Work merges to `main` only through passing pull requests with green CI checks.
5. **Feature Flags Manage Demos:** Experimental or incomplete functionality is isolated behind compile-time `--dart-define` flags (`AppConfig`).
6. **Honest Labels:** Stand-in modules are explicitly tagged in the UI (e.g., `'Demo generator'`) and never misrepresented.
7. **Every Milestone Has a Safety Net:** Deliverables include tagged git releases, signed APKs, pre-seeded datasets, and offline fallback flows.
8. **Early Usability Verification:** Informal peer testing at M2 and M4 surfaces usability defects well in advance of formal acceptance testing.

---

## Milestone Execution Roadmap

| Milestone | Target Period | Core Scope | Status | Git Release Tag |
|---|---|---|---|---|
| **M1: Planning & Design** | Oct – Nov 2026 | Requirements, system architecture, API contracts, Figma prototype, and runnable app shell. | **Complete** | `v0.1.0-m1` |
| **M2: Frontend & Database** | Nov – Dec 2026 | Offline study app, encrypted Drift database, Leitner scheduler, interactive concept map, and source line provenance. | **Complete** | `v0.2.0-m2` |
| **M3: Core Logic & CV** | Dec – Jan 2027 | Camera capture, OpenCV image cleaning, ML Kit OCR, review screen, and ASP.NET Core proxy with mock generator. | Scheduled | `v0.3.0-m3` |
| **M4: AI & Validation** | Jan – Feb 2027 | Gemini 2.5 integration (4A), Grounding validator (4B), and on-device SLM fallback with offline queue (4C). | Scheduled | `v0.4.0-m4` |
| **M5: Accessibility & QA** | Feb – Mar 2027 | Full profile experiences, TTS read-aloud, simplify wording mode, and comprehensive QA testing. | Scheduled | `v0.5.0-m5` |
| **M6: Finalisation** | Mar – Apr 2027 | User Acceptance Testing (SUS evaluation), production hardening, final thesis report, and public release. | Scheduled | `v1.0.0` |

---

## Repository Structure

The project is arranged according to the standard Flutter application architecture, integrating mobile, web, and desktop clients, an ASP.NET Core proxy gateway, design guidelines, and formal contracts:

```
neuroscript-ai/
├── .github/
│   ├── workflows/            # GitHub Actions CI/CD workflows (ci-app.yml, ci-backend.yml)
│   ├── ISSUE_TEMPLATE/       # Standardized issue templates
│   └── PULL_REQUEST_TEMPLATE.md
├── android/                  # Native Android host configuration
├── ios/                      # Native iOS host configuration
├── web/                      # Web host configuration and PWA manifest
├── windows/                  # Native Windows desktop host configuration
├── macos/                    # Native macOS desktop host configuration
├── linux/                    # Native Linux desktop host configuration
├── assets/seed/              # Bundled offline curriculum lessons
├── lib/                      # Dart application source (feature-first architecture)
│   ├── core/                 # AppConfig, theme engine, GoRouter navigation, widgets
│   ├── data/                 # Drift ORM, SQLCipher, repositories, JSON models
│   ├── features/             # Feature vertical slices (splash, library, review, concept map, etc.)
│   ├── services/             # Leitner scheduler and seed loader
│   └── main.dart             # Fast application entrypoint with splash initialization
├── test/                     # 34 automated unit and widget tests
├── backend/                  # ASP.NET Core proxy & validation gateway
│   ├── NeuroScript.Backend.sln
│   ├── prompts/v1/           # System prompt templates & few-shot schema
│   ├── src/                  # Minimal API, Core contracts, Infrastructure
│   └── tests/                # Backend xUnit tests
├── design/                   # UI/UX design specifications and accessibility guidelines
├── docs/                     # Formal contracts, SRS, personas, blueprints
├── analysis_options.yaml     # Flutter strict lint configurations
├── pubspec.yaml              # Flutter dependency manifest
├── .editorconfig             # Cross-IDE formatting conventions
├── .gitignore                # Comprehensive ignore rules
├── CONTRIBUTING.md           # Engineering guidelines and pull request protocol
├── LICENSE                   # Open-source license (MIT)
└── NeuroScript_AI_Milestone_Execution_Plan.pdf  # Master project blueprint
```
---

## Build and Execution Guide

### Prerequisites
* Flutter SDK (version 3.47.x or higher)
* Dart SDK (version 3.13.x or higher)
* .NET SDK (version 9.0.x or higher)
* Android SDK (API Level 34 or higher, Build Tools 36.0.0)
* Java Development Kit (JDK 17 or higher)

### Client Application (Flutter)
```bash
# Fetch dependencies
flutter pub get

# Run static analysis
flutter analyze --no-fatal-infos

# Execute test suite (34 tests)
flutter test

# Run application on connected device (Mobile, Desktop, or Web)
flutter run

# Compile optimized release APKs with architecture splits
flutter build apk --release --split-per-abi
```

### Backend Proxy (.NET 9)
```bash
# Navigate to backend directory
cd backend

# Build solution
dotnet build NeuroScript.Backend.sln

# Run backend test suite
dotnet test NeuroScript.Backend.sln

# Start backend locally
dotnet run --project src/Api/NeuroScript.Api.csproj
```
Generated binaries:
* `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk` (~19.5 MB, modern 64-bit devices)
* `build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk` (~17.0 MB, older 32-bit devices)
* `build/app/outputs/flutter-apk/app-x86_64-release.apk` (~20.8 MB, emulators)

---

## Contributing and Governance

Contributions are managed through feature-branch pull requests adhering to the conventions defined in [CONTRIBUTING.md](CONTRIBUTING.md). Direct pushes to `main` are restricted. All pull requests must pass automated static analysis and unit testing before review and merge.

---

## License

This project is released under the terms of the [MIT License](LICENSE).
