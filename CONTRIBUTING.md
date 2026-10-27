# Contributing to NeuroScript AI

Thank you for contributing to **NeuroScript AI**. To ensure the project remains demonstratable at all times and complies with the Final Year Project execution guidelines, all team members and contributors must follow this workflow.

---

## 🔒 1. Core Branching Strategy

* **`main` is protected:** Direct pushes to `main` are strictly prohibited.
* **`main` must always be demoable:** At any point in time, the `main` branch must successfully build a runnable application or installable APK.
* **Branch Naming Conventions:**
  * Feature branches: `feat/<wp-id>-<short-description>` or `feature/<name>` (e.g., `feat/wp1.1-app-shell`, `feat/m1-documentation`)
  * Bug fixes: `fix/<short-description>`
  * Documentation/Setup: `docs/<name>` or `chore/<name>`
  * Release preparation: `release/m<N>` (created only during the final week of a milestone)

---

## 🛠️ 2. Development Workflow

1. **Sync with Upstream:**
   ```bash
   git checkout main
   git pull upstream main
   ```
2. **Create a Feature Branch:**
   ```bash
   git checkout -b feat/your-feature-name
   ```
3. **Develop in Vertical Slices:**
   * Build complete, thin slices from screen to storage/service.
   * If an integration is not ready, introduce an interface (seam) with a working stand-in or mock.
   * Protect experimental or work-in-progress features with feature flags (`AppConfig`).
4. **Run Local Checks:**
   * Flutter: Ensure `flutter analyze` and `flutter test` pass with zero warnings/errors.
   * Backend: Ensure `dotnet test` and formatting checks pass.
5. **Commit Cleanly:**
   * Use conventional commit messages: `feat:`, `fix:`, `docs:`, `chore:`, `refactor:`, `test:`.
6. **Push to Your Fork & Open a Pull Request:**
   ```bash
   git push -u origin feat/your-feature-name
   ```

---

## 🔍 3. Pull Request Requirements

Before opening a PR, ensure:
- [ ] No secrets, API keys, credentials, or `.env` files are included.
- [ ] Code follows project architecture guidelines (Appendix D: feature-first folders).
- [ ] Any stand-in or mock is explicitly labelled as specified in Rule 6 ("Honest labels").
- [ ] Continuous Integration (CI) checks pass.
- [ ] PR description details the changes, what milestone/work package it addresses, and how to verify.
- [ ] Peer review approval is obtained before merging into `main`.

---

## 🛡️ 4. Secret & Key Security Policy

* **Never commit** API keys (e.g., Gemini API keys), database encryption passphrases, keystores, or `.env` files.
* Local secrets must reside in environment variables or untracked local override files (e.g., `appsettings.Development.local.json`).
* In production/testing, secrets are injected via host environment variables or secure CI secrets.
