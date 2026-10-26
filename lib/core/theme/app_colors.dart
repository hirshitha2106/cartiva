import 'package:flutter/material.dart';

class AppColors {
  // Brand Primary & Accents
  static const Color primary = Color(0xFF6366F1); // Electric Indigo
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);

  static const Color accentCyan = Color(0xFF06B6D4); // Cyber Cyan
  static const Color accentGold = Color(0xFFF59E0B); // Luxury Gold
  static const Color accentAmber = Color(0xFFF59E0B);
  static const Color accentRose = Color(0xFFF43F5E); // Electric Coral / Rose
  static const Color accentEmerald = Color(0xFF10B981); // Mint Emerald
  static const Color accentPurple = Color(0xFF8B5CF6);

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF090D16); // Deep Obsidian
  static const Color darkSurface = Color(0xFF111827); // Dark Slate Surface
  static const Color darkCard = Color(0xFF161F30); // Elevated Card
  static const Color darkCardBorder = Color(0xFF26334D); // Subtle Glass Border
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextMuted = Color(0xFF64748B);

  // Light Theme Colors
  static const Color lightBackground = Color(0xFFF8FAFC); // Clean Canvas
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextMuted = Color(0xFF94A3B8);

  // Status & Utility
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Gradients
  static const LinearGradient brandGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFD946EF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cyberGradient = LinearGradient(
    colors: [Color(0xFF06B6D4), Color(0xFF3B82F6), Color(0xFF6366F1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFD97706), Color(0xFFB45309)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF161F30), Color(0xFF111827)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient heroGlowGradient = LinearGradient(
    colors: [
      Color(0x336366F1),
      Color(0x228B5CF6),
      Color(0x00000000),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
