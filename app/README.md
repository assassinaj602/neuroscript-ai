# NeuroScript AI Mobile Client (Flutter)

The mobile client of NeuroScript AI is an accessible, offline-first study assistant engineered in Flutter for learners with ADHD, Dyslexia, and Autism Spectrum Conditions.

---

## Architectural Architecture

* **Framework:** Flutter 3.47+ / Dart 3.13+
* **State Management:** Riverpod 2.6 (reactive state, dependency injection, and test overrides)
* **Declarative Routing:** GoRouter with animated startup `/splash` routing and profile onboarding guards
* **Persistence & Encryption:** Drift ORM with SQLCipher hardware-backed AES-256 key generation (`FlutterSecureStorage`)
* **Spaced Repetition Engine:** Leitner 5-box scheduler with profile-specific session caps (e.g. 5-card limit for ADHD)
* **Cognitive Provenance:** Line-number grounded flashcards and bezier concept map graph (`InteractiveViewer`)

---

## Directory Organization

```
app/
├── android/            # Native Android platform host (Gradle Kotlin DSL)
├── assets/
│   └── seed/           # Bundled offline curriculum lessons (JSON contract)
├── ios/                # Native iOS platform host (Swift / CocoaPods)
├── lib/
│   ├── core/           # Configuration, theme system, routing, utils
│   │   ├── config/     # AppConfig and environment flags
│   │   ├── routing/    # GoRouter definitions and navigation guards
│   │   ├── theme/      # ADHD, Dyslexia, and Autism accessibility themes
│   │   └── utils/      # DocumentHash SHA-256 calculator
│   ├── data/           # Database tables, repositories, JSON models
│   │   ├── database/   # Drift database definition and SQLCipher setup
│   │   ├── models/     # LessonModel, ConceptMapModel, FlashcardModel
│   │   └── repositories/
│   ├── features/       # Feature vertical slices
│   │   ├── architecture/ # In-app architectural blueprint and schemas
│   │   ├── concept_map/  # Interactive node-link canvas
│   │   ├── lesson/       # Lesson overview and provenance drawer
│   │   ├── library/      # Study library with search and empty states
│   │   ├── onboarding/   # Introduction and learner profile picker
│   │   ├── progress/     # Leitner mastery retention charts
│   │   ├── review/       # 3D flip card review session
│   │   ├── settings/     # Profile switching and security settings
│   │   └── splash/       # Cold-start branding and bootstrap loader
│   ├── services/       # Core domain engines
│   │   ├── scheduler/  # LeitnerScheduler spaced repetition algorithm
│   │   └── seed/       # SeedImporter idempotent asset loader
│   └── main.dart       # Fast entrypoint with ProviderScope and theme routing
└── test/               # Comprehensive automated test suite (34 unit & widget tests)
```

---

## Execution Guide

```bash
# Navigate to the app directory
cd app

# Fetch dependencies
flutter pub get

# Run static analysis
flutter analyze --no-fatal-infos

# Run automated tests
flutter test

# Build release APK
flutter build apk --release --split-per-abi
```
