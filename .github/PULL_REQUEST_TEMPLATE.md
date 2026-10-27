## Description
<!-- Provide a brief summary of the changes and the problem/work package addressed. -->

- **Related Milestone:** M1 / M2 / M3 / M4 / M5 / M6
- **Work Package (WP):** <!-- e.g., WP 1.1, WP 2.3 -->

---

## Type of Change
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] Refactoring / Architecture seam setup
- [ ] Documentation / Configuration / CI

---

## 🎯 Demoability & Quality Checklist (The 8 Rules)
- [ ] **Rule 1 (Vertical Slice):** Changes contribute to a complete, runnable slice.
- [ ] **Rule 2 (Architecture Seam):** External dependencies sit behind Dart/C# interfaces with safe stand-ins.
- [ ] **Rule 3 (Data Contract):** Complies with the Lesson JSON schema contract.
- [ ] **Rule 4 (Main Demoable):** Verified that `main` will remain installable and runnable after merging.
- [ ] **Rule 5 (Feature Flags):** Incomplete or experimental logic is guarded behind `AppConfig` flags.
- [ ] **Rule 6 (Honest Labels):** Any mock or stand-in is visibly labeled on-screen.
- [ ] **Rule 7 (Safety Net):** Does not break offline operation or seeded demo state.
- [ ] **Security:** No secrets, API keys, or credentials committed.

---

## How Has This Been Tested?
<!-- Describe the tests run to verify your changes. Include details of test environment. -->
- [ ] Local static analysis (`flutter analyze` / `dotnet format`)
- [ ] Automated unit or widget tests
- [ ] Manual verification on emulator / physical device

---

## Screenshots or Screen Recordings (if applicable)
<!-- Attach screenshots or quick clips demonstrating the working feature/slice -->
