# On-Device SLM Selection & Hardware Benchmarks (WP4C.1)

This document serves as the benchmark template for evaluating candidate on-device Small Language Models (SLMs) running on mobile hardware.

> **Status:** NOT MEASURED YET (planned for M4C). Benchmarks will be executed on physical hardware during Milestone 4C.

---

## 1. Candidate Architectures to be Evaluated

To operate reliably within mid-range Android and iOS devices without thermal throttling or Out-Of-Memory (OOM) aborts, candidate models will be evaluated against:
* Target parameter scale: 0.5B to 1.5B parameters.
* Target quantization: 4-bit integer weights (`q4_k_m` / `q4_0` GGUF container format).
* RAM operational ceiling: $\le 1.8\text{ GB}$ resident memory footprint.

---

## 2. Benchmark Summary Table (Template)

Target Device: Physical test devices (planned for Milestone 4C).

| Model Candidate | Parameter Count | Quantization | Container Size | TTFT (s) | Throughput (tok/s) | Peak RAM (MB) | 10-Min Battery Drain | Grounding Pass Rate |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **SmolLM2-135M-Instruct** | NOT MEASURED YET (planned for M4C) | NOT MEASURED YET (planned for M4C) | NOT MEASURED YET (planned for M4C) | NOT MEASURED YET (planned for M4C) | NOT MEASURED YET (planned for M4C) | NOT MEASURED YET (planned for M4C) | NOT MEASURED YET (planned for M4C) | NOT MEASURED YET (planned for M4C) |
| **Qwen2.5-0.5B-Instruct** | NOT MEASURED YET (planned for M4C) | NOT MEASURED YET (planned for M4C) | NOT MEASURED YET (planned for M4C) | NOT MEASURED YET (planned for M4C) | NOT MEASURED YET (planned for M4C) | NOT MEASURED YET (planned for M4C) | NOT MEASURED YET (planned for M4C) | NOT MEASURED YET (planned for M4C) |
| **Llama-3.2-1B-Instruct** | NOT MEASURED YET (planned for M4C) | NOT MEASURED YET (planned for M4C) | NOT MEASURED YET (planned for M4C) | NOT MEASURED YET (planned for M4C) | NOT MEASURED YET (planned for M4C) | NOT MEASURED YET (planned for M4C) | NOT MEASURED YET (planned for M4C) | NOT MEASURED YET (planned for M4C) |
| **Gemma-2-2B-IT** | NOT MEASURED YET (planned for M4C) | NOT MEASURED YET (planned for M4C) | NOT MEASURED YET (planned for M4C) | NOT MEASURED YET (planned for M4C) | NOT MEASURED YET (planned for M4C) | NOT MEASURED YET (planned for M4C) | NOT MEASURED YET (planned for M4C) | NOT MEASURED YET (planned for M4C) |

---

## 3. Architecture Decision

* **Status:** NOT MEASURED YET (planned for M4C). Final candidate selection will be determined empirically in Milestone 4C based on physical device measurements.
* **Delivery Strategy:** Models will not be bundled directly in the APK; they will be optionally downloaded on-device via Wi-Fi with SHA-256 integrity verification.
