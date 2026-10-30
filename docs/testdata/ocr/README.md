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

## 2. Baseline Test Data Index

| Note ID | Subject Domain | Pen / Paper Style | Lighting Condition | Target Line Count |
| :--- | :--- | :--- | :--- | :--- |
| `note_001` | Biology (Photosynthesis) | Dark blue ink on ruled paper | Direct daylight | 12 lines |
| `note_002` | Computer Science (Algorithms) | Black gel pen on unruled paper | Warm indoor lamp | 15 lines |
| `note_003` | Computer Architecture | Blue ballpoint on grid paper | Low contrast shadow | 14 lines |
| `note_004` | Psychology (Memory Models) | Pencil on ruled notebook | Uneven side lighting | 11 lines |
| `note_005` | Linear Algebra (Matrices) | Black fountain pen on plain sheet | High exposure glare | 13 lines |

Ground truth line definitions and normalized test strings are maintained in [`dataset.json`](dataset.json).
