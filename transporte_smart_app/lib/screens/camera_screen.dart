import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:transporte_smart_app/theme/app_colors.dart';
import 'package:transporte_smart_app/models/route_model.dart';
import 'package:transporte_smart_app/screens/result_screen.dart';

class CameraScreen extends StatelessWidget {
  const CameraScreen({super.key});

  // --- FUNCIÓN DE NAVEGACIÓN SIMULADA ---
  // (Esto es lo que tu 'onDetect' hacía en React)
  void _simulateDetection(BuildContext context) {
    // 1. Creamos una ruta de prueba (harcoded)
    // En el futuro, esto vendrá de la IA.
    final Map<String, dynamic> fakeJson = {
      "nombre": "C. Chuquiaguillo - San Pedro",
      "paradas": {
        "ida": [
          "Plaza Villarroel",
          "Av. Busch",
          "Estadio",
          "Plaza San Pedro"
        ],
        "vuelta": [
          "Plaza San Pedro",
          "Plaza Eguino",
          "Miraflores",
          "Av. Busch"
        ]
      }
    };
    final AppRoute testRoute = AppRoute.fromJson("273", fakeJson);

    // 2. Navegamos a la pantalla de resultados
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(route: testRoute),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // El fondo ya está en main.dart
      body: Stack(
        fit: StackFit.expand, // Para que el fondo ocupe todo
        children: [
          // --- 1. Fondo de Cámara Simulado ---
          Image.asset(
            'assets/images/camera_bg.jpg',
            fit: BoxFit.cover,
          ),
          // Filtro de desenfoque y opacidad
          Container(
            color: AppColors.background.withOpacity(0.4),
          ),

          // --- 2. Overlay de Gradiente (como en CameraScreen.tsx) ---
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.background.withOpacity(0.8),
                  Colors.transparent,
                  AppColors.background.withOpacity(0.8)
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // --- 3. Contenido Principal ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0).copyWith(top: 60.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Encabezado
                Text(
                  "Hola, Usuario", // Puedes cambiar esto
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Listo para tu próximo viaje",
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
                
                // --- 4. Área de "Scanner" ---
                Expanded(
                  child: Center(
                    child: _buildScannerArea(),
                  ),
                ),

                // Espacio para el botón flotante
                const SizedBox(height: 120),
              ],
            ),
          ),

          // --- 5. Botón de "Zap" (Detección) ---
          _buildZapButton(context),
        ],
      ),
    );
  }

  // Widget para el área de escaneo
  Widget _buildScannerArea() {
    return Container(
      width: 300,
      height: 200,
      decoration: BoxDecoration(
        // bg-white/5
        color: AppColors.surfaceLight,
        // border-white/10
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          "Enfoca el letrero del minibús",
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }

  // Widget para el botón "Zap" (como en CameraScreen.tsx)
  Widget _buildZapButton(BuildContext context) {
    return Positioned(
      bottom: 120, // Altura para que quede justo encima de la nav
      right: 24,
      child: InkWell(
        onTap: () => _simulateDetection(context), // Llama a la simulación
        borderRadius: BorderRadius.circular(32),
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // bg-gradient-to-br from-[#2DD4BF] to-[#D97706]
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            // border-2 border-white/20
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              )
            ],
          ),
          child: const Icon(
            LucideIcons.zap,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
}