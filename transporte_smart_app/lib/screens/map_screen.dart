import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:transporte_smart_app/theme/app_colors.dart';
import 'dart:ui';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Por ahora, es una simulación visual
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // --- 1. Fondo de Mapa Simulado ---
          Image.asset(
            'assets/images/map_bg.jpg',
            fit: BoxFit.cover,
          ),
          // Overlay oscuro (como en tu MapScreen.tsx)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.background.withOpacity(0.9),
                  AppColors.surface.withOpacity(0.6),
                  AppColors.background.withOpacity(0.9),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // --- 2. Contenido (Encabezado y Tarjeta) ---
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Encabezado
                  const SizedBox(height: 16),
                  Text(
                    "Mapa de Ruta",
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Visualiza tus rutas favoritas",
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                  
                  // Tarjeta de ejemplo (simulada)
                  const Spacer(), // Empuja la tarjeta al fondo
                  _buildSimulatedCard(),
                  const SizedBox(height: 120), // Espacio para la barra de nav
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Tarjeta inferior (traducción de la tarjeta en MapScreen.tsx)
  Widget _buildSimulatedCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.8),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info de la ruta
              Text(
                "LÍNEA 212",
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Pampahasi - Cementerio",
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              
              // Timeline (Origen -> Destino)
              _buildTimelineRow(
                "Pampahasi", 
                AppColors.primary, 
                isOrigin: true
              ),
              // Línea vertical punteada
              Padding(
                padding: const EdgeInsets.only(left: 5.0, top: 4, bottom: 4),
                child: Container(
                  height: 20,
                  width: 2,
                  color: AppColors.textInactive,
                ),
              ),
              _buildTimelineRow(
                "Cementerio", 
                AppColors.secondary, 
                isOrigin: false
              ),
              
              const SizedBox(height: 20),
              // Botón "Iniciar navegación"
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.navigation, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      "Iniciar navegación",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget para la fila de Origen/Destino
  Widget _buildTimelineRow(String location, Color color, {bool isOrigin = false}) {
    return Row(
      children: [
        // Círculo
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.3),
            border: Border.all(color: color, width: 2),
          ),
        ),
        const SizedBox(width: 12),
        // Etiqueta
        Text(
          isOrigin ? "Origen" : "Destino",
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        const SizedBox(width: 8),
        Text(
          location,
          style: TextStyle(
            color: AppColors.textPrimary, 
            fontSize: 14, 
            fontWeight: FontWeight.w500
          ),
        ),
      ],
    );
  }
}