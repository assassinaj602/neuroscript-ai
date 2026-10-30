# Entity Relationship Diagrams (Appendix A)

This document specifies the database schemas for both the on-device encrypted database (Figure 5.2) and the ephemeral proxy metadata store (Figure 5.3).

---

## 1. On-Device Encrypted Database (Figure 5.2)

The client database is implemented via Drift and encrypted using SQLCipher AES-256. All foreign keys enforce cascading deletions to preserve relational integrity.

```mermaid
erDiagram
    USER_PROFILES ||--o{ SOURCE_NOTES : "owns"
    USER_PROFILES {
        text profileId PK "UUID"
        text profileType "ADHD | Dyslexia | Autism"
        text themeSettings "JSON encoded preferences"
        datetime createdAt "Creation timestamp"
    }

    SOURCE_NOTES ||--o{ LESSONS : "generates"
    SOURCE_NOTES {
        text noteId PK "UUID"
        text rawOcrText "Full raw OCR output text"
        text documentHash UK "SHA-256 normalized hash"
        datetime createdAt "Capture timestamp"
    }

    LESSONS ||--o{ FLASHCARDS : "contains"
    LESSONS {
        text lessonId PK "UUID"
        text noteId FK "Foreign Key -> SOURCE_NOTES.noteId"
        text title "Lesson Title"
        text conceptMapJson "JSON nodes and edges"
        text promptVersion "Compiler prompt version tag"
        text source "seed | mock | cloud | device"
        datetime createdAt "Generation timestamp"
    }

    FLASHCARDS ||--o{ REVIEW_PROGRESS : "tracks"
    FLASHCARDS {
        text cardId PK "UUID"
        text lessonId FK "Foreign Key -> LESSONS.lessonId"
        text question "Flashcard front prompt"
        text answer "Flashcard back explanation"
        text sourceLineReference "JSON array of 1-based source lines"
        real groundingScore "Computed validation score G in [0, 1]"
        boolean verified "Flag whether item passed validation"
    }

    REVIEW_PROGRESS {
        text progressId PK "UUID"
        text cardId FK "Foreign Key -> FLASHCARDS.cardId"
        integer spacedRepetitionInterval "Current Leitner box (1, 3, 7, 14, 30 days)"
        datetime nextReviewDate "UTC timestamp for scheduled review"
        datetime lastReviewedAt "Timestamp of most recent review attempt"
    }

    PENDING_JOBS {
        text jobId PK "UUID"
        text noteHash "Document hash reference"
        text status "pending | in_flight | completed | failed"
        integer attempts "Retry attempt counter"
        datetime nextAttemptAt "Backoff timestamp"
        datetime createdAt "Job submission timestamp"
    }
```

---

## 2. Backend Proxy Audit Store (Figure 5.3)

The ASP.NET Core proxy persists exclusively privacy-compliant telemetry and metadata in an internal SQLite database (`RequestLog`). No user notes or generated card contents are stored.

```mermaid
erDiagram
    REQUEST_LOG {
        text id PK "UUID"
        text installHash "One-way salted hash of install ID"
        text endpoint "API route accessed"
        integer statusCode "HTTP status code (200, 429, 500, etc.)"
        integer latencyMs "Processing duration in milliseconds"
        text provider "mock | gemini | fallback"
        datetime createdAt "UTC access timestamp"
    }
```
