import 'package:flutter/material.dart';


class AppColors {
  // --- Colores de Fondo (Backgrounds) ---
  // bg-[#0C0A09] (El fondo más oscuro, tu "canvas")
  static const Color background = Color(0xFF0C0A09);
  // bg-[#1C1917] (Fondo de la barra de nav y tarjetas)
  static const Color surface = Color(0xFF1C1917);
  // bg-white/5 (Bordes y botones sutiles)
  static const Color surfaceLight = Color(0x0DFFFFFF); // 5% de blanco

  // --- Colores de Acento (Accents) ---
  // text-[#2DD4BF] (Tu color primario)
  static const Color primary = Color(0xFF2DD4BF);
  // El gradiente naranja de tu botón 'Zap' [from-[#2DD4BF] to-[#D97706]]
  static const Color secondary = Color(0xFFD97706);
  // text-[#F59E0B] (El color de la estrella 'Star')
  static const Color star = Color(0xFFF59E0B);
  // Color de error o "cerrar sesión"
  static const Color error = Color(0xFFDC2626);

  // --- Colores de Texto (Text) ---
  // text-white/90 (Texto principal)
  static const Color textPrimary = Color(0xE6FFFFFF); // 90% de blanco
  // text-white/60 (Texto secundario, "Línea detectada")
  static const Color textSecondary = Color(0x99FFFFFF); // 60% de blanco
  // text-white/40 (Texto inactivo, íconos de nav)
  static const Color textInactive = Color(0x66FFFFFF); // 40% de blanco
  
  // --- Colores de Bordes (Borders) ---
  // border-white/10
  static const Color border = Color(0x1AFFFFFF); // 10% de blanco
  // border-[#2DD4BF]/30 (Borde activo de la nav)
  static const Color borderActive = Color(0x4D2DD4BF); // 30% de #2DD4BF
}