# Architecture and Project Documentation

This directory contains technical specifications, formal data contracts, database schemata, and academic requirement documents for NeuroScript AI.

---

## Directory Index

* **[requirements.md](requirements.md):** Formal System Requirements Specification (SRS) detailing Functional Requirements (`FR-01` to `FR-15`) and Non-Functional Requirements (`NFR-01` to `NFR-08`) with MoSCoW prioritization.
* **[personas.md](personas.md):** Evidence-based learner personas for ADHD (Bilal), Dyslexia (Sara), and Autism (Hamza).
* **[proposal/README.md](proposal/README.md):** Master Final Year Project (FYP) proposal metadata and milestone roadmaps.
* **[contracts/lesson.schema.json](contracts/lesson.schema.json):** Frozen JSON Schema contract (Appendix B) defining the universal shape of generated study lessons across seed data, mock generators, Google Gemini, and on-device SLMs.
* **[contracts/proxy-api.openapi.yaml](contracts/proxy-api.openapi.yaml):** OpenAPI 3.0 specification for the ASP.NET Core proxy gateway (`GET /health`, `POST /api/v1/lessons/generate`, `POST /api/v1/text/simplify`, rate limit headers, and ProblemDetails error schemas).
* **[diagrams/architecture.md](diagrams/architecture.md):** High-level component topology and system flow diagram (Figure 5.1).
* **[diagrams/database_er.md](diagrams/database_er.md):** Entity Relationship (ER) diagrams for on-device encrypted database (Figure 5.2) and backend audit store (Figure 5.3).
* **[diagrams/sequence_diagrams.md](diagrams/sequence_diagrams.md):** System sequence diagrams for both online cloud generation and offline fallback execution.
* **[testdata/ocr/README.md](testdata/ocr/README.md):** Handwritten note OCR evaluation dataset and ground-truth text corpus.
* **[benchmarks/README.md](benchmarks/README.md):** On-device SLM hardware benchmarks, token latency, and memory footprint evaluations.
* **Master Planning Document:** [`NeuroScript_AI_Milestone_Execution_Plan.pdf`](../NeuroScript_AI_Milestone_Execution_Plan.pdf) (located at repository root).
