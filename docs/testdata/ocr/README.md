# OCR Evaluation Dataset & Ground-Truth Test Data

This directory stores standardized handwritten note samples and reference ground-truth texts used for measuring Character Error Rate (CER) and Word Error Rate (WER) across OpenCV preprocessing stages and Google ML Kit OCR.

---

## 1. Evaluation Methodology

1. **Character Error Rate (CER):**
   $$\text{CER} = \frac{S + D + I}{N}$$
   where $S$ is substitutions, $D$ is deletions, $I$ is insertions, and $N$ is total characters in ground truth calculated via Levenshtein distance.
2. **Word Error Rate (WER):**
   $$\text{WER} = \frac{S_w + D_w + I_w}{N_w}$$
   calculated over whitespace-delimited word tokens.

---

## 2. Test Data Index

> **Current Status:** Exactly 2 index entries exist currently in [`dataset.json`](dataset.json) (`note_001` and `note_002`). The full target corpus of 30 physical note samples is scheduled for collection in Milestone 3. Fabricate nothing.

| Note ID | Subject Domain | Pen / Paper Style | Lighting Condition | Verified Line Count | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `note_001` | Biology (Photosynthesis) | Dark blue ink on ruled paper | Direct daylight | 7 lines | In Index ([`dataset.json`](dataset.json)) |
| `note_002` | Computer Science (Algorithms) | Black gel pen on plain paper | Warm indoor lamp | 6 lines | In Index ([`dataset.json`](dataset.json)) |

The remaining 28 samples (target: 30) will be collected and indexed during Milestone 3.
