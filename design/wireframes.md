# Screen Wireframes and Interaction Architecture

This document formalizes the low-fidelity and high-fidelity screen wireframes, visual hierarchies, and interaction flows designed for NeuroScript AI across mobile and tablet viewports.

---

## 1. Master Screen Inventory

The application architecture encompasses 11 core screens, 3 modal sheets, and 4 system state views:

1. **Splash & Startup (`/splash`)**: Initial platform initialization, secure key extraction from `flutter_secure_storage`, and routing gate.
2. **Onboarding (`/onboarding`)**: Welcome carousel introducing offline-first privacy, line-grounded verification, and neuroinclusive design.
3. **Profile Selection (`/profile-select`)**: Profile selector choosing between ADHD, Dyslexia, and Autism design systems with real-time palette preview.
4. **Library (`/library`)**: Central dashboard listing enrolled study decks, card review counts, mastery percentages, and active study sessions.
5. **Lesson Overview (`/lesson/:id`)**: Comprehensive lesson summary, key takeaways, concept count, and primary actions ("Review Flashcards", "Concept Map").
6. **Flashcard Review (`/review/:id`)**: 3D flip card review session adhering to profile-specific session caps (5 for ADHD, 10 default) with Leitner SRS grade actions.
7. **Concept Map (`/concept-map/:id`)**: Multi-touch interactive semantic knowledge graph powered by `InteractiveViewer` with node line-provenance inspection.
8. **Progress & Analytics (`/progress`)**: Longitudinal mastery metrics, Leitner box distribution (Boxes 1–5), study streaks, and deck completion meters.
9. **Settings & Accessibility (`/settings`)**: Profile switching, font scale slider ($1.0\times$ to $2.0\times$), TTS voice selector, and secure database purge.
10. **Architecture Blueprint (`/architecture`)**: System component topology, security layers, data flow diagrams, and active feature flag inspections.
11. **OCR Document Review (`/ocr-review`)**: Numbered line-by-line inspection interface for captured handwritten notes (Milestone 3).

---

## 2. Screen Wireframe Specifications

### 2.1 Onboarding and Profile Selection
```text
+-------------------------------------------------------+
|  NeuroScript AI                                       |
|  Personalized, Grounded Study for Neurodivergent Minds|
|                                                       |
|  +-------------------------------------------------+  |
|  | [O] ADHD Focus Profile                          |  |
|  |     Chunked 5-card sessions, high-contrast      |  |
|  |     visual dividers, dopamine progress rings.   |  |
|  +-------------------------------------------------+  |
|                                                       |
|  +-------------------------------------------------+  |
|  | [A] Dyslexia Reading Profile                    |  |
|  |     Warm anti-glare background, widened line    |  |
|  |     spacing, line-level source provenance.      |  |
|  +-------------------------------------------------+  |
|                                                       |
|  +-------------------------------------------------+  |
|  | [S] Autism Predictability Profile               |  |
|  |     Calm low-saturation tones, literal wording, |  |
|  |     deterministic layouts, zero autoplay motion.|  |
|  +-------------------------------------------------+  |
|                                                       |
|  [           Confirm Profile & Continue           ]   |
+-------------------------------------------------------+
```

### 2.2 Flashcard Review with Line-Level Provenance Sheet
```text
+-------------------------------------------------------+
| <- Lesson Overview               Card 2 of 5   [TTS]  |
| ===================================================== |
| Progress: [====                ] 40% Completed        |
|                                                       |
| +---------------------------------------------------+ |
| |                                                   | |
| |  Question:                                        | |
| |  What is the primary role of chlorophyll in the   | |
| |  light-dependent reactions?                       | |
| |                                                   | |
| |  [ Tap to Reveal Answer ]                         | |
| |                                                   | |
| |  [?] Where is this from? (Lines 3-4)              | |
| +---------------------------------------------------+ |
|                                                       |
| [  Not Yet (Reset Box 1)  ]    [  Got It (Advance)  ] |
+-------------------------------------------------------+
| MODAL SHEET: "Where is this from?"                    |
| Source Note: "Biology Lecture - Photosynthesis"       |
| Document Hash: 8f4a1c...                              |
|                                                       |
| Line 2: Light energy is absorbed by pigments.         |
| Line 3: > Chlorophyll absorbs blue and red wavelengths|
| Line 4: > and converts light into chemical energy ATP.|
| Line 5: Carbon fixation occurs in the stroma later.   |
|                                                       |
| [                      Close Sheet                  ] |
+-------------------------------------------------------+
```

### 2.3 Interactive Semantic Concept Map
```text
+-------------------------------------------------------+
| <- Lesson Overview           Concept Map      [Reset] |
| ===================================================== |
| +---------------------------------------------------+ |
| |                                                   | |
| |   [Light Energy] ----(activates)---> [Chlorophyll]| |
| |                                             |     | |
| |                                        (synthesizes)|
| |                                             v     | |
| |   [Stroma (Calvin)] <---(supplies)---- [ATP/NADPH]| |
| |                                                   | |
| +---------------------------------------------------+ |
| Hint: Pinch to zoom, drag to pan canvas.              |
| Selected Node: Chlorophyll (Cited in Source Lines 3, 4)|
| [ View Source Evidence ]                              |
+-------------------------------------------------------+
```

---

## 3. WCAG 2.1 AA Ergonomics & Touch Target Verification

* **Touch Targets:** All interactive buttons (`AppButton`, card flip targets, chip selectors) adhere to a minimum bounding box of $48 \times 48\text{ dp}$.
* **Contrast Compliance:** All text and card boundaries meet or exceed the $4.5:1$ contrast threshold for standard body text and $3.0:1$ for large titles.
* **Non-Reliance on Color Alone:** State indicators (such as card mastery, review scheduling, and validation badges) combine color cues with explicit typography, icons, and numerical badges.
