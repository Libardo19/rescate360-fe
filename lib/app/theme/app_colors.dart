import 'package:flutter/material.dart';

/// Paleta de colores de RESCATE360, extraída de los mockups de Figma.
/// Tema oscuro con acento en rojo coral para llamadas a la acción y alertas.
class AppColors {
  AppColors._();

  // Fondos
  static const Color background = Color(0xFF0E1320);
  static const Color surface = Color(0xFF171D2C);
  static const Color surfaceElevated = Color(0xFF1E2637);
  static const Color surfaceBorder = Color(0xFF2A3346);

  // Acentos
  static const Color primary = Color(0xFFE5534B);
  static const Color primaryDark = Color(0xFFC2413A);
  static const Color info = Color(0xFF3E7BFA);

  // Texto
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF98A2B8);
  static const Color textMuted = Color(0xFF6B7488);

  // Estados
  static const Color danger = Color(0xFFE5534B);
  static const Color success = Color(0xFF3FBF7F);
}
