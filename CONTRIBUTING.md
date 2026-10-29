# Contributing to NeuroScript AI

This repository contains the source code, design assets, and architectural contracts for **NeuroScript AI**, developed as a CS-400 Final Year Project at the University of Engineering & Technology (UET) Taxila. 

To maintain demonstration readiness, prevent architectural drift, and ensure continuous stability, all contributors must strictly follow the development guidelines detailed below.

---

## 1. Core Branching Strategy

* **Protection of `main`:** Direct pushes to the `main` branch are restricted. All contributions must arrive via feature-branch pull requests.
* **Continuous Demoability:** The `main` branch must remain in a runnable, compilable state at all times. An installable APK must be buildable from `main` at every commit.
* **Branch Naming Conventions:**
  * Feature branches: `feat/<work-package-id>-<description>` (e.g., `feat/wp1.5-app-shell`, `feat/wp2.1-encrypted-db`)
  * Bug fixes: `fix/<issue-description>`
  * Documentation and configuration: `docs/<description>` or `chore/<description>`
  * Release preparation: `release/m<N>` (created only during the final week of a milestone sprint)

---

## 2. Development Workflow

1. **Synchronize Local Environment:**
   ```bash
   git checkout main
   git pull origin main
   ```

2. **Create a Dedicated Branch:**
   ```bash
   git checkout -b feat/your-feature-name
   ```

3. **Vertical Slice Implementation:**
   * Build complete, thin functional slices connecting presentation to storage.
   * If an upstream or downstream component is not yet implemented, define a clean interface (seam) with a reliable stand-in or mock.
   * Protect unfinished or experimental code behind feature flags via `AppConfig`.

4. **Verify Locally Before Committing:**
   * Static analysis: Ensure `flutter analyze --no-fatal-infos` reports zero errors and zero warnings.
   * Automated tests: Ensure `flutter test` executes all test suites with a 100% pass rate.
   * Code formatting: Adhere to standard indentation rules defined in `.editorconfig`.

5. **Commit Message Conventions:**
   * Format commits using conventional commit syntax:
     * `feat:` New features or functional modules
     * `fix:` Bug fixes or logic corrections
     * `docs:` Documentation, contracts, or specifications
     * `test:` Unit, widget, or integration tests
     * `chore:` Build scripts, dependencies, or tool configurations

6. **Open a Pull Request:**
   ```bash
   git push -u origin feat/your-feature-name
   ```

---

## 3. Pull Request Review Protocol

Every pull request must fulfill the following verification criteria prior to merge approval:
- [ ] No hard-coded secrets, private keys, API credentials, or `.env` files are included.
- [ ] Architecture complies with the feature-first layout conventions (Appendix D).
- [ ] Any temporary mock or stand-in is explicitly labelled on-screen as required by Rule 6 ("Honest labels").
- [ ] Continuous Integration (CI) automated workflows complete successfully.
- [ ] Pull request description details the exact work packages addressed and manual verification steps.
- [ ] Peer review sign-off is obtained from the project partner.

---

## 4. Secret Management and Security Policy

* **Zero Plaintext Credentials:** Never commit API keys (including Gemini API tokens), signing keystores, or database credentials to version control.
* **Environment Configuration:** Sensitive values must reside exclusively in external environment variables, secure runtime injection arguments (`--dart-define`), or untracked local configuration files.
* **Repository Integrity:** Automated scanning is enforced to prevent secret leakage. Any accidentally committed credential must be immediately revoked and rotated.
