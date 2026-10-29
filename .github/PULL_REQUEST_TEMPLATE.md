## Description
<!-- Provide a concise summary of the changes and the specific work package addressed. -->

- **Related Milestone:** M1 / M2 / M3 / M4 / M5 / M6
- **Work Package (WP):** <!-- e.g., WP 1.5, WP 2.1, WP 2.4 -->

---

## Type of Change
- [ ] New feature (non-breaking addition of functional capability)
- [ ] Bug fix (non-breaking resolution of a defect)
- [ ] Architecture / Seam refactoring (interface or stand-in adjustments)
- [ ] Documentation / CI / Tooling configuration

---

## Quality and Demoability Checklist (The 8 Rules)
- [ ] **Rule 1 (Vertical Slice):** Changes contribute to a complete, runnable end-to-end slice.
- [ ] **Rule 2 (Architecture Seam):** External dependencies sit behind Dart/C# interfaces with safe stand-ins.
- [ ] **Rule 3 (Data Contract):** Complies strictly with the frozen Lesson JSON schema contract.
- [ ] **Rule 4 (Main Demoable):** Verified that `main` branch remains compilable and installable.
- [ ] **Rule 5 (Feature Flags):** Incomplete or experimental logic is guarded behind `AppConfig` flags.
- [ ] **Rule 6 (Honest Labels):** Any mock or stand-in is visibly labeled on-screen.
- [ ] **Rule 7 (Safety Net):** Does not compromise offline operation or seeded demo state.
- [ ] **Security Policy:** No secrets, API keys, or private credentials committed.

---

## Verification and Testing
<!-- Detail the test steps and commands executed to verify these changes. -->
- [ ] Local static analysis passed (`flutter analyze --no-fatal-infos`)
- [ ] Automated unit and widget tests passed (`flutter test`)
- [ ] Manual verification conducted on physical device or emulator

---

## Visual Verification (Screenshots / Recordings)
<!-- Attach screenshots or screen recordings demonstrating the working slice if applicable -->
