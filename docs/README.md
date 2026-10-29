# Architecture and Project Documentation

This directory contains technical specifications, formal data contracts, database schemata, and academic requirement documents for NeuroScript AI.

---

## Directory Index

* **[requirements.md](requirements.md):** Formal System Requirements Specification (SRS) detailing Functional Requirements (`FR-01` to `FR-15`) and Non-Functional Requirements (`NFR-01` to `NFR-08`) with MoSCoW prioritization.
* **[personas.md](personas.md):** Evidence-based learner personas for ADHD (Bilal), Dyslexia (Sara), and Autism (Hamza).
* **[contracts/lesson.schema.json](contracts/lesson.schema.json):** Frozen JSON Schema contract (Appendix B) defining the universal shape of generated study lessons across seed data, mock generators, Google Gemini, and on-device SLMs.
* **[contracts/proxy-api.openapi.yaml](contracts/proxy-api.openapi.yaml):** OpenAPI 3.0 specification for the ASP.NET Core proxy gateway (`GET /health`, `POST /api/v1/lessons/generate`, `POST /api/v1/text/simplify`, rate limit headers, and ProblemDetails error schemas).
* **Master Planning Document:** `NeuroScript_AI_Milestone_Execution_Plan.pdf` (located at repository root).
