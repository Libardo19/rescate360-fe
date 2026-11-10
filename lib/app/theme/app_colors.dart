import 'package:flutter/material.dart';

/// Paleta de colores de RESCATE360 (mockups del ciudadano).
/// Tema claro: fondo blanco, azul marino para acciones principales y
/// coral como acento para alertas y detalles.
class AppColors {
  AppColors._();

  // Fondos
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF4F6FA);
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color surfaceBorder = Color(0xFFE3E7EF);

  // Acentos
  static const Color primary = Color(0xFF0F2A5C); // azul marino
  static const Color primaryDark = Color(0xFF081C42);
  static const Color accent = Color(0xFFE5534B); // coral
  static const Color info = Color(0xFF3E7BFA);

  // Texto
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF5B6475);
  static const Color textMuted = Color(0xFF8A93A6);

  // Estados
  static const Color danger = Color(0xFFE5534B);
  static const Color success = Color(0xFF2FA96B);
  static const Color warning = Color(0xFFF5A524);
}
