import 'package:flutter/material.dart';

enum ProfileType {
  adhd,
  dyslexia,
  autism;

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

/// Profile-tailored color palettes satisfying WCAG 2.1 AA contrast requirements.
class AppPalettes {
  AppPalettes._();

  // --- ADHD: High Focus & Dopamine Loops ---
  static const adhdPrimary = Color(0xFF3F51B5); // Deep Indigo
  static const adhdSecondary = Color(0xFFFF9800); // Warm Amber
  static const adhdBackground = Color(0xFFF8F9FA); // Ultra clean
  static const adhdSurface = Colors.white;
  static const adhdText = Color(0xFF1A1A24);

  // --- Dyslexia: Anti-Glare & Typography Friendly ---
  static const dyslexiaPrimary = Color(0xFF1E3A8A); // Slate Blue
  static const dyslexiaSecondary = Color(0xFF0D9488); // Teal Accent
  static const dyslexiaBackground = Color(0xFFFBF8EE); // Warm Cream
  static const dyslexiaSurface = Color(0xFFFFFDF8);
  static const dyslexiaText = Color(0xFF2B2D42); // Softened Charcoal (no pure black glare)

  // --- Autism: Low Sensory Noise & Predictability ---
  static const autismPrimary = Color(0xFF3D6B7A); // Muted Sage/Teal
  static const autismSecondary = Color(0xFF7A9E9F); // Pastel Blue/Green
  static const autismBackground = Color(0xFFEEF3F4); // Gentle Ice Mist
  static const autismSurface = Color(0xFFF8FAFB);
  static const autismText = Color(0xFF263238); // Low-saturation Navy Grey
}
