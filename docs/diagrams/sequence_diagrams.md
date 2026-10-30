# System Sequence Diagrams

This document illustrates the execution lifecycle across the online generation flow and the offline/degraded fallback pathway.

---

## 1. Sequence 1: Camera Scan to Grounded Lesson Generation

Illustrates the end-to-end workflow: note capture, on-device OCR, line numbering, cloud generation, grounding verification, and encrypted storage.

```mermaid
sequenceDiagram
    autonumber
    actor User as Learner
    participant Camera as Camera / OpenCV
    participant OCR as Google ML Kit
    participant Review as OCR Review UI
    participant Client as Flutter Client
    participant Proxy as ASP.NET Core Proxy
    participant Gemini as Google Gemini API
    participant Validator as Grounding Validator
    participant DB as SQLCipher Drift DB

    User->>Camera: Capture handwritten note pages
    Camera->>Camera: CLAHE + Grayscale + Deskew
    Camera->>OCR: Pass preprocessed image buffer
    OCR-->>Client: Recognized blocks and numbered lines (1..N)
    Client->>Review: Display line-by-line editor
    User->>Review: Correct any recognition error & tap "Generate"
    Review->>Client: Confirmed text & lines
    Client->>Client: Compute DocumentHash (SHA-256)
    Client->>Proxy: POST /api/v1/lessons/generate { noteHash, lines, profile }
    Proxy->>Proxy: Validate rate limit & headers
    Proxy->>Gemini: Closed-book prompt with strict JSON schema
    Gemini-->>Proxy: Raw Lesson JSON
    Proxy-->>Client: Lesson JSON Contract response
    Client->>Validator: Validate card facts against evidence lines
    Validator->>Validator: Compute G = 0.6*Sem + 0.4*L with Entity Check X
    Validator-->>Client: Grounded Lesson (Verified items flagged)
    Client->>DB: Atomic transaction (Note, Lesson, Cards, Progress)
    DB-->>Client: Save confirmation
    Client->>User: Display Lesson Overview & Concept Map
```

---

## 2. Sequence 2: Cloud Failure, On-Device Fallback & Offline Queue

Illustrates the fault-tolerant resilience path when network connectivity is severed or the proxy rate limit is reached.

```mermaid
sequenceDiagram
    autonumber
    actor User as Learner
    participant Client as Flutter Client
    participant Router as GenerationRouter
    participant Proxy as ASP.NET Core Proxy
    participant LocalSLM as On-Device SLM (LlamaDart)
    participant Queue as PendingJobs Queue
    participant DB as SQLCipher Drift DB

    User->>Client: Tap "Generate Lesson"
    Client->>Router: Route generation request
    Router->>Proxy: Attempt HTTPS cloud synthesis
    alt Cloud Timeout / HTTP 429 / Offline
        Proxy-->>Router: Error / Connection Failure
        Router->>Router: Capability check (RAM >= 4GB, Battery >= 20%)
        alt Device Eligible for Local Inference
            Router->>LocalSLM: Generate mini-lesson (5 cards)
            LocalSLM-->>Router: Local Lesson JSON
            Router->>DB: Save Lesson with Source="device"
            Router->>User: Display Lesson with "Made on this device" badge
        else Device Ineligible or Background Heavy
            Router->>Queue: Enqueue Job in PendingJobs table
            Queue->>DB: Persist Job Status = "pending"
            Router->>User: Display "Saved to Offline Queue" banner
        end
    end
```
