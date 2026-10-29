// ============================================================================
// NeuroScript AI: Privacy-Preserving Study Platform for Neurodivergent Learners
// File: app/lib/core/theme/app_palettes.dart
//
// Description:
//   Neuroinclusive design tokens and color palettes adhering strictly to
//   WCAG 2.1 AA accessibility guidelines (contrast ratios >= 4.5:1 for body text).
//   Engineered specifically to alleviate cognitive strain, visual stress, and
//   sensory overload across three core learner profiles.
//
// Cognitive & Accessibility Rationale:
//   1. ADHD Profile (Executive Dysfunction & Motivation):
//      - Primary: Deep Indigo (#3F51B5) providing clear visual anchor points.
//      - Accent: Warm Amber (#FF9800) highlighting active milestones and dopamine cues.
//      - Background: Minimal Clean Grey (#F8F9FA) eliminating distracting clutter.
//   2. Dyslexia Profile (Visual Stress & Scotopic Sensitivity):
//      - Background: Warm Cream (#FBF8EE) preventing the harsh glare of pure white.
//      - Foreground: Soft Charcoal (#2B2D42) preventing the "dancing letter" effect
//        caused by extreme pure-black/pure-white contrast.
//      - Primary: Slate Blue (#1E3A8A) with high readability and calm presence.
//   3. Autism Profile (Sensory Regulation & Predictability):
//      - Primary: Muted Sage Teal (#3D6B7A) evoking low emotional arousal.
//      - Background: Gentle Ice Mist (#EEF3F4) ensuring uniform, soft luminance.
//      - Palette: Zero high-saturation neons or vibrating color combinations.
// ============================================================================

import 'package:flutter/material.dart';

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

/// Static palette tokens for the three neurodivergent design systems.
class AppPalettes {
  AppPalettes._();

  // --------------------------------------------------------------------------
  // ADHD Design Tokens: High Focus, Clear Structure, and Dopamine Feedback
  // --------------------------------------------------------------------------
  static const adhdPrimary = Color(0xFF3F51B5); // Deep Indigo
  static const adhdSecondary = Color(0xFFFF9800); // Warm Amber
  static const adhdBackground = Color(0xFFF8F9FA); // Ultra-clean minimal background
  static const adhdSurface = Colors.white;
  static const adhdText = Color(0xFF1A1A24); // High contrast dark charcoal

  // --------------------------------------------------------------------------
  // Dyslexia Design Tokens: Anti-Glare, Calming Contrast, and Scotopic Relief
  // --------------------------------------------------------------------------
  static const dyslexiaPrimary = Color(0xFF1E3A8A); // Slate Blue
  static const dyslexiaSecondary = Color(0xFF0D9488); // Calming Teal
  static const dyslexiaBackground = Color(0xFFFBF8EE); // Warm Cream (anti-glare)
  static const dyslexiaSurface = Color(0xFFFFFDF8); // Soft off-white surface
  static const dyslexiaText = Color(0xFF2B2D42); // Soft Charcoal (no stark black glare)

  // --------------------------------------------------------------------------
  // Autism Design Tokens: Sensory Regulation, Low Saturation, and Predictability
  // --------------------------------------------------------------------------
  static const autismPrimary = Color(0xFF3D6B7A); // Muted Sage / Slate Teal
  static const autismSecondary = Color(0xFF7A9E9F); // Pastel Blue-Green
  static const autismBackground = Color(0xFFEEF3F4); // Gentle Ice Mist
  static const autismSurface = Color(0xFFF8FAFB); // Very soft neutral surface
  static const autismText = Color(0xFF263238); // Low-saturation Navy Grey
}
