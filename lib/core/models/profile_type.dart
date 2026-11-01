// ============================================================================
// NeuroScript AI: Privacy-Preserving Study Platform for Neurodivergent Learners
// File: lib/core/models/profile_type.dart
//
// Description:
//   Core domain model representing supported neurodivergent learner profiles.
//   Decoupled from presentation and UI theme tokens so data and service layers
//   can utilize profile logic without importing Flutter theme packages.
// ============================================================================

/// Supported neurodivergent learner profiles.
enum ProfileType {
  /// Focuses on micro-learning sessions, dopamine feedback loops, and minimal distraction.
  adhd,

  /// Focuses on scotopic sensitivity alleviation, anti-glare warm backgrounds, and readable typography.
  dyslexia,

  /// Focuses on low sensory noise, literal language, predictable structures, and reduced motion.
  autism;

  /// Returns the human-readable display name of the profile.
  String get displayName {
    switch (this) {
      case ProfileType.adhd:
        return 'ADHD';
      case ProfileType.dyslexia:
        return 'Dyslexia';
      case ProfileType.autism:
        return 'Autism';
    }
  }

  /// Returns a concise description of the profile's accessibility adaptations.
  String get description {
    switch (this) {
      case ProfileType.adhd:
        return '5-card micro-sessions, visual progress cues, and high focus.';
      case ProfileType.dyslexia:
        return 'Soft cream background, relaxed letter spacing, and line height.';
      case ProfileType.autism:
        return 'Calm pastel palette, predictable layout, and low sensory noise.';
    }
  }

  /// Parses a string into a [ProfileType], defaulting to [ProfileType.dyslexia].
  static ProfileType fromString(String val) {
    switch (val.toLowerCase()) {
      case 'adhd':
        return ProfileType.adhd;
      case 'dyslexia':
        return ProfileType.dyslexia;
      case 'autism':
        return ProfileType.autism;
      default:
        return ProfileType.dyslexia;
    }
  }
}
