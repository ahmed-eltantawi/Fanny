import 'package:flutter/material.dart';

/// Centralized color palette for the Fanny app.
/// Deep Blue conveys trust & reliability; Amber reflects Egyptian warmth.
class AppColors {
  AppColors._();

  // Primary — Figma green palette
  static const Color primary = Color(0xFF2DBD6E);
  static const Color primaryLight = Color(0xFF4CD889);
  static const Color primaryDark = Color(0xFF1A9554);
  static const Color primarySurface = Color(0xFFE8F8EF);

  // Accent / CTA (warm gold for urgency CTAs)
  static const Color accent = Color(0xFFFFA000);
  static const Color accentLight = Color(0xFFFFB300);
  static const Color accentDark = Color(0xFFE65100);
  static const Color accentSurface = Color(0xFFFFF3E0);

  // Backgrounds
  static const Color background = Color(0xFFF5F7F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F5F1);

  // Text
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Semantic
  static const Color error = Color(0xFFD32F2F);
  static const Color errorSurface = Color(0xFFFFEBEE);
  static const Color success = Color(0xFF2E7D32);
  static const Color successSurface = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFFF6F00);
  static const Color warningSurface = Color(0xFFFFF8E1);
  static const Color info = Color(0xFF1565C0);
  static const Color infoSurface = Color(0xFFE3F2FD);

  // Status badges
  static const Color statusPending = Color(0xFFFF6F00);
  static const Color statusPendingSurface = Color(0xFFFFF3E0);
  static const Color statusInProgress = Color(0xFF1565C0);
  static const Color statusInProgressSurface = Color(0xFFE3F2FD);
  static const Color statusCompleted = Color(0xFF2E7D32);
  static const Color statusCompletedSurface = Color(0xFFE8F5E9);
  static const Color statusCancelled = Color(0xFFB71C1C);
  static const Color statusCancelledSurface = Color(0xFFFFEBEE);

  // UI
  static const Color divider = Color(0xFFE5E7EB);
  static const Color shimmerBase = Color(0xFFEEEEEE);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);
  static const Color shadow = Color(0x1A2DBD6E);
  static const Color cardBorder = Color(0xFFEDEDF5);

  // Category colors (for service category cards)
  static const List<Color> categoryColors = [
    Color(0xFF1565C0), // Blue – Plumbing
    Color(0xFFE65100), // Orange – Electrical
    Color(0xFF4E342E), // Brown – Carpentry
    Color(0xFF6A1B9A), // Purple – Painting
    Color(0xFF006064), // Teal – AC Repair
    Color(0xFF1B5E20), // Green – Cleaning
    Color(0xFF880E4F), // Pink – General Repair
    Color(0xFF37474F), // Blue Grey – Masonry
  ];
}
