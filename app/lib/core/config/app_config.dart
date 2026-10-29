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

  /// Seed | Remote generator switch
  final GeneratorMode generatorMode;

  /// Whether camera/OCR capture flow is active
  final bool enableCapture;

  /// Grounding verification rigor
  final GroundingMode groundingMode;

  /// On-device SLM fallback enable flag
  final bool enableLocalFallback;

  /// Text simplification mode
  final bool enableSimplify;

  /// Text-to-speech engine
  final bool enableTts;

  /// Shows 'Demo generator' badges, limitations tags, and developer debug panels
  final bool demoMode;

  /// Base URL for the ASP.NET Core proxy service
  final String proxyBaseUrl;

  /// API key for authenticated proxy endpoints
  final String apiKey;

  /// Factory pulling configuration from compile-time environment definitions
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

enum GeneratorMode {
  seed,
  remote;

  static GeneratorMode fromString(String val) {
    return val.toLowerCase() == 'remote'
        ? GeneratorMode.remote
        : GeneratorMode.seed;
  }
}

enum GroundingMode {
  off,
  schema,
  lexical,
  full;

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
