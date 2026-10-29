# NeuroScript AI - System Requirements Specification (SRS)
> **Milestone 1 Deliverable (WP1.1)** • Course: CS-400 Final Year Project, UET Taxila

---

## 1. Functional Requirements (FR)

| ID | Category | Requirement Description | Priority (MoSCoW) | Milestone |
|---|---|---|---|---|
| **FR-01** | Capture | App must capture handwritten notes via camera with live framing guide and flash toggle. | **Must** | M3 |
| **FR-02** | Vision | Preprocess captured note photos (resize, CLAHE contrast normalisation, denoise, adaptive threshold, deskew) in an isolate. | **Must** | M3 |
| **FR-03** | OCR | Extract Latin text into 1-based ordered numbered lines using Google ML Kit. | **Must** | M3 |
| **FR-04** | OCR Edit | Allow students to edit, merge, add, and delete OCR lines on an editable review screen prior to generation. | **Must** | M3 |
| **FR-05** | Lesson Gen | Compile confirmed OCR lines into structured Lesson JSON (flashcards + concept map) via ASP.NET Core proxy to Google Gemini 2.5 Flash. | **Must** | M4A |
| **FR-06** | Grounding | Validate every generated flashcard and node against cited source lines using lexical ($L$), entity ($X$), and semantic ($Sem$) grounding scores ($G = 0.6 \cdot Sem + 0.4 \cdot L$). | **Must** | M4B |
| **FR-07** | Hallucination Guard | Automatically reject or regenerate items failing entity check ($X=0$) or score threshold ($G < 0.50$). | **Must** | M4B |
| **FR-08** | Provenance | Provide a 'Where is this from?' sheet for every card and node highlighting exact cited source lines. | **Must** | M2 |
| **FR-09** | Leitner SRS | Schedule active recall flashcard review using 5 Leitner boxes (intervals 1, 3, 7, 14, 30 days). | **Must** | M2 |
| **FR-10** | Concept Map | Render interactive concept map nodes and directed edges inside an `InteractiveViewer` with pinch-to-zoom and pan. | **Must** | M2 |
| **FR-11** | Local SLM | Provide offline on-device SLM fallback (SmolLM2 / Llama 3.2 1B via llamadart) with battery and RAM capability gates. | **Should** | M4C |
| **FR-12** | Offline Queue | Enqueue failed generations into a persistent `PendingJobs` table when offline or rate-limited. | **Should** | M4C |
| **FR-13** | Accessibility | Provide 3 distinct learner profile themes (ADHD, Dyslexia, Autism) with WCAG 2.1 AA compliant palettes. | **Must** | M1/M2 |
| **FR-14** | Text-to-Speech | Read flashcards aloud offline using `flutter_tts` with synchronous word/sentence highlighting. | **Should** | M5 |
| **FR-15** | Simplify Mode | Rewrite complex card phrasing into literal language for the Autism profile via `/api/v1/text/simplify`. | **Should** | M5 |

---

## 2. Non-Functional Requirements (NFR)

| ID | Category | Requirement Description | Target Metric | Priority |
|---|---|---|---|---|
| **NFR-01** | Privacy & Security | Zero plaintext note retention on external proxy; local database encrypted with AES-256 SQLCipher. | Key stored in Secure Storage; DB unreadable via sqlite3 | **Must** |
| **NFR-02** | Performance | Note capture to generated lesson turnaround time. | $< 15$ seconds on mobile data | **Must** |
| **NFR-03** | Offline First | All core review, concept map, and progress tracking must function with zero network access. | 100% operational in airplane mode | **Must** |
| **NFR-04** | Accessibility | UI contrast ratios, tap targets, and typography scaling. | WCAG 2.1 AA (contrast $\ge 4.5:1$, touch $\ge 48$ dp, text scale up to $2.0\times$) | **Must** |
| **NFR-05** | Reliability | Rate limiter on proxy returning HTTP 429 with `Retry-After`. | Handled gracefully without app crash | **Must** |
| **NFR-06** | Usability | System Usability Scale (SUS) score during Milestone 6 user acceptance testing. | Mean SUS score $\ge 68$ | **Must** |
| **NFR-07** | APK Footprint | Optimized mobile binary footprint via ABI splits. | $< 80$ MB release APK | **Should** |
| **NFR-08** | Code Quality | Automated CI enforcement on pull requests. | Passing static analysis & unit tests | **Must** |
