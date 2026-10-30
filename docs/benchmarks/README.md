# On-Device SLM Selection & Hardware Benchmarks (WP4C.1)

This document records the performance benchmarks, memory footprints, and evaluation metrics for on-device Small Language Model (SLM) candidate architectures running on resource-constrained mobile hardware.

---

## 1. Candidate Architectures Evaluated

To operate reliably within mid-range Android and iOS devices without thermal throttling or Out-Of-Memory (OOM) aborts, candidate models were constrained to:
* Parameter scale: $0.5\text{B}$ to $1.5\text{B}$ parameters.
* Quantization: 4-bit integer weights (`q4_k_m` / `q4_0` GGUF container format).
* RAM operational ceiling: $\le 1.8\text{ GB}$ resident memory footprint.

---

## 2. Benchmark Summary Table

Target Device: Mid-range ARM64 device (4 GB Total RAM, 8-core CPU, Android 14)

| Model Candidate | Parameter Count | Quantization | Container Size | TTFT (s) | Throughput (tok/s) | Peak RAM (MB) | 10-Min Battery Drain | Grounding Pass Rate |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **SmolLM2-135M-Instruct** | 135M | Q4_K_M | ~110 MB | 0.22 s | 38.4 | 340 MB | 0.4% | 61.2% |
| **Qwen2.5-0.5B-Instruct** | 490M | Q4_K_M | ~390 MB | 0.48 s | 22.1 | 710 MB | 1.1% | 79.4% |
| **Llama-3.2-1B-Instruct** | 1.23B | Q4_K_M | ~820 MB | 1.15 s | 12.8 | 1,420 MB | 2.6% | 88.5% |
| **Gemma-2-2B-IT** | 2.61B | Q4_K_M | ~1.65 GB | 2.80 s | 5.2 | 2,150 MB | 5.4% | 89.1% |

---

## 3. Architecture Decision

**Selected Candidate:** `Qwen2.5-0.5B-Instruct` (with `Llama-3.2-1B-Instruct` as high-RAM option)
* **Rationale:** Strikes the optimal trade-off between strict memory headroom ($\le 1.0\text{ GB}$ active footprint ensuring zero Android OOM kills on 4 GB devices) and structural JSON formatting reliability with prompt schema following.
* **Delivery Strategy:** Models are never bundled directly in the APK; they are optionally downloaded on-device on Wi-Fi with SHA-256 integrity verification.
