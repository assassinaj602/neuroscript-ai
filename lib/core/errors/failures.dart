// ============================================================================
// NeuroScript AI: Privacy-Preserving Study Platform for Neurodivergent Learners
// File: app/lib/core/errors/failures.dart
//
// Description:
//   Domain error representation using strongly typed Failure objects.
//   Enforces WP2.3 error handling architecture, ensuring that raw exceptions
//   never escape into the presentation layer unhandled, and guarantees that
//   learners with sensory sensitivities are never presented with jarring,
//   cryptic stack traces.
//
// Key Concepts:
//   - Typed Domain Failures: Replaces primitive strings or untyped exceptions
//     with structured objects that map neatly into friendly UI error cards.
//   - Consistent Recovery: Each failure can be caught and rendered inside an
//     AsyncValue.error widget containing a clear, low-stress "Retry" action.
// ============================================================================

/// Base failure class representing a domain-level error across the application.
abstract class Failure {
  const Failure(this.message);

  /// Human-readable, non-technical explanation of the failure.
  final String message;

  @override
  String toString() => message;
}

/// Indicates a failure during an encrypted SQLite/Drift database operation.
class DatabaseFailure extends Failure {
  const DatabaseFailure([
    super.message = 'A local storage error occurred. Please restart the app.',
  ]);
}

/// Indicates that the bundled offline curriculum seed could not be loaded or parsed.
class SeedImportFailure extends Failure {
  const SeedImportFailure([
    super.message = 'Failed to load offline curriculum lessons.',
  ]);
}

/// Indicates that generated flashcards or concept map nodes failed the
/// grounding verification threshold (composite grounding score G < 0.50 or entity check X == 0).
class ValidationFailure extends Failure {
  const ValidationFailure([
    super.message = 'The content failed grounding score verification and was rejected.',
  ]);
}

/// Indicates an upstream network timeout, DNS resolution error, or unreachable proxy.
class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message = 'Network connection failed. Offline study features remain active.',
  ]);
}
