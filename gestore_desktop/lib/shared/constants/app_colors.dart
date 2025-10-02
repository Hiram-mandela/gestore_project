// ========================================
// lib/shared/constants/app_colors.dart
// Palette de couleurs moderne pour GESTORE
// ========================================
import 'package:flutter/material.dart';

/// Palette de couleurs GESTORE
class AppColors {
  // Couleurs principales
  static const Color primary = Color(0xFF1E3A8A); // Bleu profond
  static const Color primaryLight = Color(0xFF3B82F6); // Bleu clair
  static const Color primaryDark = Color(0xFF1E40AF); // Bleu très foncé

  static const Color secondary = Color(0xFF7C3AED); // Violet
  static const Color secondaryLight = Color(0xFFA78BFA); // Violet clair
  static const Color secondaryDark = Color(0xFF6D28D9); // Violet foncé

  static const Color accent = Color(0xFF06B6D4); // Cyan

  // Couleurs de statut
  static const Color success = Color(0xFF10B981); // Vert émeraude
  static const Color warning = Color(0xFFF59E0B); // Ambre
  static const Color error = Color(0xFFEF4444); // Rouge
  static const Color info = Color(0xFF3B82F6); // Bleu

  // Couleurs de fond
  static const Color backgroundLight = Color(0xFFF8FAFC); // Gris très clair
  static const Color backgroundDark = Color(0xFF0F172A); // Bleu très foncé

  static const Color surfaceLight = Color(0xFFFFFFFF); // Blanc
  static const Color surfaceDark = Color(0xFF1E293B); // Gris bleuté foncé

  // Couleurs de texte
  static const Color textPrimary = Color(0xFF0F172A); // Presque noir
  static const Color textSecondary = Color(0xFF64748B); // Gris moyen
  static const Color textTertiary = Color(0xFF94A3B8); // Gris clair

  static const Color textPrimaryDark = Color(0xFFF1F5F9); // Presque blanc
  static const Color textSecondaryDark = Color(0xFFCBD5E1); // Gris clair
  static const Color textTertiaryDark = Color(0xFF94A3B8); // Gris moyen

  // Couleurs de bordure
  static const Color border = Color(0xFFE2E8F0); // Gris très clair
  static const Color borderDark = Color(0xFF334155); // Gris bleuté

  // Couleurs overlay
  static const Color overlay = Color(0x1A000000); // Noir 10%
  static const Color overlayDark = Color(0x33000000); // Noir 20%

  // Couleurs pour modules
  static const Color inventory = Color(0xFF8B5CF6); // Violet
  static const Color sales = Color(0xFF10B981); // Vert
  static const Color customers = Color(0xFF3B82F6); // Bleu
  static const Color reports = Color(0xFFF59E0B); // Orange
  static const Color settings = Color(0xFF64748B); // Gris

  // Gradient principal
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF10B981), Color(0xFF059669)],
  );

  // Méthodes utilitaires
  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }

  static BoxShadow cardShadow({bool isDark = false}) {
    return BoxShadow(
      color: isDark
          ? Colors.black.withValues(alpha: 0.3)
          : Colors.black.withValues(alpha: 0.08),
      blurRadius: 12,
      offset: const Offset(0, 4),
    );
  }

  static BoxShadow subtleShadow({bool isDark = false}) {
    return BoxShadow(
      color: isDark
          ? Colors.black.withValues(alpha: 0.2)
          : Colors.black.withValues(alpha: 0.05),
      blurRadius: 8,
      offset: const Offset(0, 2),
    );
  }
}