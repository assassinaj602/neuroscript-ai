# NeuroScript AI 🧠📝

> **Privacy-first study application for neurodivergent learners (ADHD, dyslexia, autism).**  
> Converts handwritten notes into grounding-validated flashcards and interactive concept maps via an ASP.NET Core proxy to Google Gemini, with an on-device Small Language Model (SLM) fallback.

---

## 📌 Project Information
* **Course:** CS-400 Final Year Project (2026–2027)
* **Institution:** Department of Computer Science, University of Engineering & Technology (UET) Taxila
* **Supervisor:** Mr. Awais Mehmood
* **Team:**
  * **Zain Tahir** (23-CS-115) – *Backend, Database, AI Logic, Integration*
  * **Ujala Sahar** (23-CS-135) – *UI/UX, QA, User Testing, Documentation*

---

## 🚀 Key Features

* **Accessible Learning Profiles:** Specialized UX/UI adaptations for ADHD (chunked sessions, gamified dopamine loops), Dyslexia (OpenDyslexic typography, bionic reading, syllable highlights), and Autism (low-sensory palette, predictable layout).
* **Handwritten Note Processing:** On-device camera capture with OpenCV perspective correction/cleaning and Google ML Kit OCR text extraction.
* **AI Lesson Generation:** Cloud-based lesson synthesis using Google Gemini 2.5 Flash via a secure ASP.NET Core proxy.
* **Grounding-Score Validation:** Strict lexical and entity validation to detect and guard against AI hallucinations before content reaches the student.
* **Offline On-Device SLM Fallback:** Offline lesson generation powered by an on-device SLM (e.g., SmolLM2 / Llama 3.2 1B via llama.cpp/llamadart) with an automated sync queue.
* **Active Recall & Spaced Repetition:** Interactive Leitner / SM-2 spaced repetition review sessions and hierarchical concept map visualization.
* **Privacy by Design:** Local-first encrypted database (Drift + SQLCipher) with zero plaintext retention of user notes on external servers.

---

## 🏗️ Architecture Overview

```
[ Camera / Notes ]
       │
       ▼
[ OpenCV Cleanup & ML Kit OCR ]
       │
       ▼
[ Flutter Client (Drift + Riverpod) ]
       │
       ├── (Online) ──> [ ASP.NET Core Proxy ] ──> [ Google Gemini API ]
       │                         │
       │                         └── [ Grounding Validator ]
       │
       └── (Offline) ─> [ On-Device SLM (llamadart) ] ──> [ Local DB Queue ]
```

---

## 🗺️ Milestone Roadmap

The project follows a vertical-slice roadmap where every milestone concludes with an installable, demonstrable application:

| Milestone | Scope & Demo Headline | Target Tag |
|---|---|---|
| **M1: Planning & Design** (Oct–Nov) | Clickable Figma prototype + installed app shell with profile and palette switching | `v0.1.0-m1` |
| **M2: Frontend & Database** (Nov–Dec) | Complete offline study app: sample lessons, flashcard review with spaced repetition, encrypted DB | `v0.2.0-m2` |
| **M3: Core Logic & CV** (Dec–Jan) | Scan handwriting → clean → OCR → edit → cloud proxy → lesson → review | `v0.3.0-m3` |
| **M4: AI & Validation** (Jan–Feb) | 4A: Gemini lessons; 4B: Grounding-score badges; 4C: Offline SLM fallback & queue | `v0.4.1-4a/b/c` |
| **M5: Accessibility & QA** (Feb–Mar) | 3 profile experiences, TTS read-aloud, simplify mode, QA and evaluation report | `v0.5.0-m5` |
| **M6: Finalisation** (Mar–Apr) | Release build, UAT with SUS, final report, poster, and presentation | `v1.0.0` |

---

## 🏛️ Monorepo Structure

```
neuroscript-ai/
├── app/                  # Flutter mobile client (feature-first architecture)
│   ├── lib/
│   │   ├── core/         # AppConfig, theme, routing, errors, utils
│   │   ├── data/         # Drift database, DAOs, repositories
│   │   ├── features/     # Feature modules (onboarding, capture, lesson, etc.)
│   │   └── services/     # Interfaces & implementations (seed, remote, local)
│   └── test/             # Unit and widget tests
├── backend/              # ASP.NET Core proxy and validation service
│   ├── src/Api/          # Controllers and endpoints
│   ├── src/Core/         # Business logic and interfaces
│   ├── src/Infrastructure/ # External clients (Gemini, caching)
│   └── tests/            # Backend unit and integration tests
├── design/               # UI/UX design specifications and Figma exports
├── docs/                 # Project documentation, contracts, diagrams, execution plan
├── .github/              # Issue/PR templates and CI/CD workflows
└── NeuroScript_AI_Milestone_Execution_Plan.pdf
```

---

## 📐 The Eight Demoability Rules

1. **Vertical slices, not layers:** Every milestone produces an installable app holding a working, complete user slice.
2. **Build seams first, fill them later:** Every external service is backed by Dart/C# interfaces with reliable stand-ins.
3. **One data contract from day one:** Fixed JSON schema for lessons across seed, mock, Gemini, and on-device SLM.
4. **`main` is always demoable:** Changes merge only via PRs with passing CI checks.
5. **Feature flags manage demos:** Compile-time and runtime toggles (`--dart-define`) isolate incomplete features.
6. **Honest labels:** Stand-ins and mocks are clearly identified on-screen during demos.
7. **Every milestone has a safety net:** Tagged releases, signed APKs, seeded demo data, and fallback screen recordings.
8. **Small, early usability checks:** Guerrilla testing sessions with peers at M2 and M4 before final evaluation.

---

## 🤝 Contributing & Git Workflow

* Please read [`CONTRIBUTING.md`](./CONTRIBUTING.md) for branch naming, PR conventions, and code review rules.
* Direct pushes to `main` are strictly forbidden. All changes must be submitted via feature branches (`feature/<wp-id>-name`) and pull requests.

---

## 📄 License

This project is licensed under the MIT License - see the [`LICENSE`](./LICENSE) file for details.
