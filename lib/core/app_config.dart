// ============================================================================
// NeuroScript AI: Privacy-Preserving Study Platform for Neurodivergent Learners
// File: lib/core/app_config.dart
//
// Description:
//   Compile-time configuration and runtime feature flags system.
//   Enforces Rule 5 of the Milestone Execution Plan ("Feature flags manage demos"),
//   allowing developers and testers to safely isolate half-finished subsystems,
//   toggle demo modes, switch generator endpoints, and adjust verification rigor
//   without modifying client source code.
//
// Architectural Concepts:
//   - String.fromEnvironment / bool.fromEnvironment: Injects compile-time constants
//     via `--dart-define` flags during `flutter run` or `flutter build`.
//   - Seam Toggling: Toggles between offline seed lesson generation (Milestone 2),
//     ASP.NET Core proxy mock generation (Milestone 3), and live Google Gemini AI
//     (Milestone 4).
//   - Zero Incomplete UI Bleed: Half-finished features (e.g., live OCR camera capture)
//     remain hidden behind boolean flags until their corresponding milestone passes.
// ============================================================================

/// Application configuration and feature flags driven by `--dart-define`.
///
/// Follows the NeuroScript AI Milestone Execution Plan (Section 3.2).
class AppConfig {
  const AppConfig({
    this.generatorMode = GeneratorMode.seed,
    this.enableCapture = false,
    this.groundingMode = GroundingMode.off,
    this.enableLocalFallback = false,
    this.enableSimplify = false,
    this.enableTts = false,
    this.demoMode = true,
    this.proxyBaseUrl = 'https://localhost:5001',
    this.apiKey = '',
  });

  /// Controls the active lesson content source.
  /// - `seed`: Loads bundled offline curriculum JSON from assets (Milestone 2).
  /// - `remote`: Calls the external ASP.NET Core proxy gateway (Milestone 3+).
  final GeneratorMode generatorMode;

  /// Whether the live camera capture and OpenCV image preprocessing flow is active.
  /// Set to `false` in Milestones 1 and 2; enabled in Milestone 3.
  final bool enableCapture;

  /// Determines the grounding score verification rigor applied to generated lessons:
  /// - `off`: Grounding checks disabled (Milestones 1-2).
  /// - `schema`: Validates JSON schema conformance only (Milestone 3 / 4A).
  /// - `lexical`: Evaluates n-gram containment L and entity constraint X (Milestone 4B v1).
  /// - `full`: Evaluates lexical + MiniLM semantic embedding score Sem (Milestone 4B v2).
  final GroundingMode groundingMode;

  /// Enables the on-device Small Language Model (SLM) fallback and offline job queue.
  /// Set to `false` until Milestone 4C.
  final bool enableLocalFallback;

  /// Enables the literal text simplification mode for Autistic learners.
  /// Scheduled for Milestone 5.
  final bool enableSimplify;

  /// Enables the Text-to-Speech (TTS) read-aloud engine with word tracking.
  /// Scheduled for Milestone 5.
  final bool enableTts;

  /// When `true`, displays demo tags (e.g., 'Demo generator' badge), limitations
  /// disclaimers, and developer testing shortcuts. Set to `false` in production.
  final bool demoMode;

  /// Base URL for the ASP.NET Core proxy gateway.
  final String proxyBaseUrl;

  /// API key for authenticated proxy endpoints (never committed; injected via build environment).
  final String apiKey;

  /// Factory pulling configuration from compile-time environment definitions.
  ///
  /// Example command line:
  /// ```bash
  /// flutter run --dart-define=GENERATOR_MODE=seed --dart-define=DEMO_MODE=true
  /// ```
  factory AppConfig.fromEnvironment() {
    const genModeStr = String.fromEnvironment(
      'GENERATOR_MODE',
      defaultValue: 'seed',
    );
    const capture = bool.fromEnvironment('ENABLE_CAPTURE', defaultValue: false);
    const groundingStr = String.fromEnvironment(
      'GROUNDING_MODE',
      defaultValue: 'off',
    );
    const fallback = bool.fromEnvironment(
      'ENABLE_LOCAL_FALLBACK',
      defaultValue: false,
    );
    const simplify = bool.fromEnvironment(
      'ENABLE_SIMPLIFY',
      defaultValue: false,
    );
    const tts = bool.fromEnvironment('ENABLE_TTS', defaultValue: false);
    const demo = bool.fromEnvironment('DEMO_MODE', defaultValue: true);
    const proxyUrl = String.fromEnvironment(
      'PROXY_URL',
      defaultValue: 'https://localhost:5001',
    );
    const key = String.fromEnvironment('API_KEY', defaultValue: '');

    return AppConfig(
      generatorMode: GeneratorMode.fromString(genModeStr),
      enableCapture: capture,
      groundingMode: GroundingMode.fromString(groundingStr),
      enableLocalFallback: fallback,
      enableSimplify: simplify,
      enableTts: tts,
      demoMode: demo,
      proxyBaseUrl: proxyUrl,
      apiKey: key,
    );
  }

  /// Returns a copy of this [AppConfig] with the given fields replaced with new values.
  AppConfig copyWith({
    GeneratorMode? generatorMode,
    bool? enableCapture,
    GroundingMode? groundingMode,
    bool? enableLocalFallback,
    bool? enableSimplify,
    bool? enableTts,
    bool? demoMode,
    String? proxyBaseUrl,
    String? apiKey,
  }) {
    return AppConfig(
      generatorMode: generatorMode ?? this.generatorMode,
      enableCapture: enableCapture ?? this.enableCapture,
      groundingMode: groundingMode ?? this.groundingMode,
      enableLocalFallback: enableLocalFallback ?? this.enableLocalFallback,
      enableSimplify: enableSimplify ?? this.enableSimplify,
      enableTts: enableTts ?? this.enableTts,
      demoMode: demoMode ?? this.demoMode,
      proxyBaseUrl: proxyBaseUrl ?? this.proxyBaseUrl,
      apiKey: apiKey ?? this.apiKey,
    );
  }
}

/// Enumeration of available lesson generation backends.
enum GeneratorMode {
  /// Loads bundled pre-verified curriculum lessons from local assets.
  seed,

  /// Calls the ASP.NET Core proxy server for cloud or mock generation.
  remote;

  /// Parses a string into a [GeneratorMode], defaulting to [GeneratorMode.seed].
  static GeneratorMode fromString(String val) {
    return val.toLowerCase() == 'remote'
        ? GeneratorMode.remote
        : GeneratorMode.seed;
  }
}

/// Enumeration of grounding verification levels.
enum GroundingMode {
  /// Grounding checks disabled.
  off,

  /// Validates adherence to the Appendix B JSON contract only.
  schema,

  /// Computes lexical n-gram containment L and checks exact entity preservation X.
  lexical,

  /// Full composite score combining lexical, entity, and MiniLM semantic embeddings.
  full;

  /// Parses a string into a [GroundingMode], defaulting to [GroundingMode.off].
  static GroundingMode fromString(String val) {
    switch (val.toLowerCase()) {
      case 'schema':
        return GroundingMode.schema;
      case 'lexical':
        return GroundingMode.lexical;
      case 'full':
        return GroundingMode.full;
      case 'off':
      default:
        return GroundingMode.off;
    }
  }
}
